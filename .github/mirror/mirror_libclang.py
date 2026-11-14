#!/usr/bin/env python3
"""Mirror Qt's prebuilt libclang archives and their unmodified source branches."""

import argparse
import base64
from datetime import datetime, timedelta, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import tempfile
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen


SOURCE = "https://download.qt.io/development_releases/prebuilt/libclang/"
UPSTREAM = "https://code.qt.io/clang/llvm-project.git"
REPOSITORY = "hicknhack-software/Qt-llvm-project"
MIN_VERSION = (23, 0, 0)


def version_key(version):
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise ValueError(f"Invalid release version: {version!r}")
    return tuple(map(int, version.split(".")))


def discover(index):
    releases = {}
    for row in re.findall(r"<tr\b[^>]*>.*?</tr>", index, re.S | re.I):
        match = re.search(
            r'href="(libclang-release_(\d+\.\d+\.\d+)-based-md5\.txt)"', row
        )
        if not match or version_key(match[2]) < MIN_VERSION:
            continue
        stamp = re.search(r"\d{2}-[A-Za-z]{3}-\d{4}\s+\d{2}:\d{2}", row)
        if not stamp:
            raise ValueError(f"Missing timestamp for {match[1]}")
        date = datetime.strptime(stamp[0], "%d-%b-%Y %H:%M")
        tag = f"libclang-release_{match[2]}_based_{date:%d-%b-%Y_%H-%M}"
        releases[match[2]] = {"version": match[2], "manifest": match[1], "tag": tag}
    if not releases:
        raise ValueError("No current releases found in Qt's directory index")
    return [releases[v] for v in sorted(releases, key=version_key)]


def parse_manifest(data, version):
    checksums = {}
    prefix = f"libclang-release_{version}-based-"
    for line in data.decode("ascii").splitlines():
        match = re.fullmatch(r"([0-9a-fA-F]{32})\s+\*?([A-Za-z0-9_.+-]+\.7z)", line)
        if not match or not match[2].startswith(prefix) or match[2] in checksums:
            raise ValueError(f"Invalid checksum entry: {line!r}")
        checksums[match[2]] = match[1].lower()
    if not checksums:
        raise ValueError("Empty checksum manifest")
    return checksums


def read_url(url):
    for attempt in range(4):
        try:
            with urlopen(url, timeout=90) as response:
                return response.read()
        except (HTTPError, URLError, TimeoutError):
            if attempt == 3:
                raise


class GitHub:
    def __init__(self, token):
        self.token = token
        self.root = f"https://api.github.com/repos/{REPOSITORY}"

    def request(self, path, data=None, method=None):
        headers = {
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "qt-libclang-mirror",
        }
        if self.token:
            headers["Authorization"] = f"Bearer {self.token}"
        body = None if data is None else json.dumps(data).encode()
        if body is not None:
            headers["Content-Type"] = "application/json"
        request = Request(self.root + path, data=body, headers=headers, method=method)
        with urlopen(request, timeout=90) as response:
            result = response.read()
        return json.loads(result) if result else None

    def optional(self, path):
        try:
            return self.request(path)
        except HTTPError as error:
            if error.code == 404:
                return None
            raise

    def assets(self, release):
        assets = []
        page = 1
        while True:
            batch = self.request(f"/releases/{release['id']}/assets?per_page=100&page={page}")
            assets.extend(batch)
            if len(batch) < 100:
                return assets
            page += 1

    def upload(self, release, path):
        url = release["upload_url"].split("{")[0] + "?name=" + quote(path.name)
        headers = {
            "Authorization": f"Bearer {self.token}",
            "Accept": "application/vnd.github+json",
            "Content-Type": "application/octet-stream",
            "Content-Length": str(path.stat().st_size),
        }
        with path.open("rb") as stream:
            request = Request(url, data=stream, headers=headers, method="POST")
            with urlopen(request, timeout=600) as response:
                return json.load(response)


def complete(release, assets, names, manifest_digest):
    by_name = {asset["name"]: asset for asset in assets}
    if release["draft"] or set(by_name) != set(names):
        return False
    if any(a["state"] != "uploaded" or a["size"] <= 0 for a in assets):
        return False
    manifest = by_name[names[-1]]
    return manifest.get("digest") == "sha256:" + manifest_digest


def source_sha(branch):
    result = subprocess.run(
        ["git", "ls-remote", "--exit-code", UPSTREAM, f"refs/heads/{branch}"],
        check=True, capture_output=True, text=True,
    )
    sha = result.stdout.split()[0]
    if not re.fullmatch(r"[0-9a-f]{40}", sha):
        raise ValueError("Invalid upstream commit")
    return sha


def mirror_branch(github, version, sha, directory):
    branch = f"release_{version}-based"
    ref = github.optional(f"/git/ref/heads/{branch}")
    if ref and ref["object"]["sha"] == sha:
        print(f"Source branch already mirrored: {branch} ({sha})", flush=True)
        return
    if ref:
        raise ValueError(f"Refusing to move existing source branch {branch}")
    repo = directory / "source.git"
    auth = base64.b64encode(f"x-access-token:{github.token}".encode()).decode()
    env = dict(os.environ, GIT_CONFIG_COUNT="1",
               GIT_CONFIG_KEY_0="http.https://github.com/.extraheader",
               GIT_CONFIG_VALUE_0=f"AUTHORIZATION: basic {auth}")
    ssh_key = os.getenv("MIRROR_SSH_KEY")
    mirror_url = f"https://github.com/{REPOSITORY}.git"
    if ssh_key:
        key_path = directory / "mirror-key"
        key_path.write_text(ssh_key.rstrip() + "\n", encoding="ascii")
        key_path.chmod(0o600)
        hosts_path = directory / "known_hosts"
        keys = json.loads(read_url("https://api.github.com/meta"))["ssh_keys"]
        hosts_path.write_text(
            "".join(f"[ssh.github.com]:443 {key}\n" for key in keys), encoding="ascii")
        env["GIT_SSH_COMMAND"] = (
            f"ssh -i {shlex.quote(key_path.as_posix())} -o IdentitiesOnly=yes "
            f"-o StrictHostKeyChecking=yes -o UserKnownHostsFile={shlex.quote(hosts_path.as_posix())}"
        )
        mirror_url = f"ssh://git@ssh.github.com:443/{REPOSITORY}.git"
    elif os.getenv("GITHUB_ACTIONS") == "true":
        raise ValueError("MIRROR_SSH_KEY is required to push source branches containing workflows")

    def git(*args):
        subprocess.run(["git", "-C", str(repo), *args], check=True, env=env)

    if not repo.exists():
        subprocess.run(["git", "init", "--bare", str(repo)], check=True)
        git("remote", "add", "mirror", mirror_url)
        git("remote", "add", "qt", UPSTREAM)
        # Share the mirror's ancestry without checking out LLVM or downloading its blobs.
        refs = github.request("/git/matching-refs/heads/release_")
        candidates = []
        for item in refs:
            match = re.fullmatch(r"refs/heads/release_(\d+\.\d+\.\d+)-based", item["ref"])
            if match:
                candidates.append((version_key(match[1]), item["ref"]))
        if candidates:
            git("fetch", "--filter=blob:none", "--no-tags", "mirror", max(candidates)[1])
    git("fetch", "--filter=blob:none", "--no-tags", "qt", f"refs/heads/{branch}")
    fetched = subprocess.check_output(
        ["git", "-C", str(repo), "rev-parse", "FETCH_HEAD"], text=True
    ).strip()
    if fetched != sha:
        raise ValueError(f"Upstream branch {branch} changed during fetch; retry")
    git("push", "mirror", f"{sha}:refs/heads/{branch}")


def hashes(path):
    md5 = hashlib.md5(usedforsecurity=False)
    sha256 = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            md5.update(block)
            sha256.update(block)
    return md5.hexdigest(), "sha256:" + sha256.hexdigest()


def download(path, expected_md5):
    print(f"Downloading {path.name}", flush=True)
    subprocess.run(
        ["curl", "--fail", "--location", "--retry", "4", "--retry-all-errors",
         "--connect-timeout", "30", "--max-time", "3600", "--silent", "--show-error",
         "--output", str(path), SOURCE + path.name], check=True,
    )
    md5, sha256 = hashes(path)
    if md5 != expected_md5:
        raise ValueError(f"Qt checksum mismatch for {path.name}: {md5} != {expected_md5}")
    return sha256


def ensure_asset(github, release, path, sha256):
    for attempt in range(4):
        current = next((a for a in github.assets(release) if a["name"] == path.name), None)
        if current:
            if (current["state"] == "uploaded" and current["size"] == path.stat().st_size
                    and current.get("digest") == sha256):
                print(f"Verified existing asset: {path.name}", flush=True)
                return
            if current["state"] == "starter" and current["size"] == 0 and release["draft"]:
                github.request(f"/releases/assets/{current['id']}", method="DELETE")
            else:
                raise ValueError(f"Refusing to replace different existing asset: {path.name}")
        try:
            print(f"Uploading {path.name}", flush=True)
            asset = github.upload(release, path)
            if (asset["state"] != "uploaded" or asset["size"] != path.stat().st_size
                    or asset.get("digest") != sha256):
                raise ValueError(f"GitHub upload verification failed: {path.name}")
            return
        except (HTTPError, URLError, TimeoutError, ConnectionError):
            if attempt == 3:
                raise


def mirror_release(github, item, directory, dry_run):
    data = read_url(SOURCE + item["manifest"])
    checksums = parse_manifest(data, item["version"])
    names = [*checksums, item["manifest"]]
    digest = hashlib.sha256(data).hexdigest()
    release = github.optional("/releases/tags/" + quote(item["tag"]))
    assets = github.assets(release) if release else []
    branch = f"release_{item['version']}-based"
    sha = source_sha(branch)
    tag = github.optional("/git/ref/tags/" + quote(item["tag"]))
    if tag and tag["object"]["sha"] != sha:
        raise ValueError(f"Release tag does not point to the upstream commit: {item['tag']}")
    if release and complete(release, assets, names, digest):
        print(f"Already complete: {item['tag']}", flush=True)
        if not dry_run:
            mirror_branch(github, item["version"], sha, directory)
        return "complete"
    print(f"{'Would mirror' if dry_run else 'Mirroring'} {item['tag']}: "
          f"{len(checksums)} archives, source {sha}", flush=True)
    if dry_run:
        return "missing"
    mirror_branch(github, item["version"], sha, directory)
    if not release:
        body = (f"Mirror of binaries from: {SOURCE}\n\n"
                f"[{item['manifest']}]({SOURCE}{item['manifest']})")
        release = github.request("/releases", {
            "tag_name": item["tag"], "target_commitish": sha, "name": item["tag"],
            "body": body, "draft": True, "prerelease": False,
        })
    manifest = directory / item["manifest"]
    manifest.write_bytes(data)
    ensure_asset(github, release, manifest, "sha256:" + digest)
    for name, expected_md5 in checksums.items():
        path = directory / name
        sha256 = download(path, expected_md5)
        ensure_asset(github, release, path, sha256)
        path.unlink()
    if read_url(SOURCE + item["manifest"]) != data:
        raise ValueError("Qt changed its checksum manifest during mirroring; retry")
    final = github.assets(release)
    published = dict(release, draft=False)
    if not complete(published, final, names, digest):
        raise ValueError("Release is incomplete; leaving it as a draft")
    if release["draft"]:
        latest = github.optional("/releases/latest")
        match = re.search(r"release_(\d+\.\d+\.\d+)", latest["tag_name"]) if latest else None
        newer = not match or version_key(item["version"]) >= version_key(match[1])
        github.request(f"/releases/{release['id']}",
                       {"draft": False, "make_latest": "true" if newer else "false"},
                       method="PATCH")
    print(f"Published https://github.com/{REPOSITORY}/releases/tag/{item['tag']}", flush=True)
    return "published"


def keepalive(github):
    repository = github.request("")
    branch = repository["default_branch"]
    if branch != "mirror-automation":
        raise ValueError("Keepalive may only update the mirror-automation branch")
    ref = github.request("/git/ref/heads/" + branch)
    parent = ref["object"]["sha"]
    commit = github.request("/git/commits/" + parent)
    last = datetime.fromisoformat(commit["committer"]["date"].replace("Z", "+00:00"))
    if datetime.now(timezone.utc) - last < timedelta(days=28):
        print("Schedule keepalive is not due")
        return
    new = github.request("/git/commits", {
        "message": "Keep the Friday libclang mirror schedule active",
        "tree": commit["tree"]["sha"], "parents": [parent],
    })
    github.request("/git/refs/heads/" + branch, {"sha": new["sha"], "force": False},
                   method="PATCH")
    print("Recorded monthly activity to keep GitHub's schedule enabled")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--versions", default=os.getenv("MIRROR_VERSIONS", ""))
    parser.add_argument("--keepalive", action="store_true")
    args = parser.parse_args()
    dry_run = args.dry_run or os.getenv("MIRROR_DRY_RUN", "").lower() == "true"
    github = GitHub(os.getenv("GH_TOKEN", ""))
    if not dry_run and not github.token:
        parser.error("GH_TOKEN with contents:write is required")
    if args.keepalive:
        keepalive(github)
        return
    items = discover(read_url(SOURCE).decode("utf-8"))
    if args.versions:
        requested = {v.strip() for v in args.versions.split(",")}
        for version in requested:
            version_key(version)
        missing = requested - {item["version"] for item in items}
        if missing:
            raise ValueError(f"Requested releases not found at Qt: {sorted(missing)}")
        items = [item for item in items if item["version"] in requested]
    results = []
    failures = []
    with tempfile.TemporaryDirectory(prefix="qt-libclang-mirror-") as scratch:
        for item in items:
            try:
                status = mirror_release(github, item, Path(scratch), dry_run)
                results.append(f"- {item['tag']}: {status}")
            except Exception as error:
                print(f"ERROR: {item['version']}: {error}", flush=True)
                results.append(f"- {item['tag']}: failed ({error})")
                failures.append(item["version"])
    summary = "Qt libclang mirror\n\n" + "\n".join(results) + "\n"
    print(summary)
    if os.getenv("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as stream:
            stream.write(summary)
    if failures:
        raise SystemExit("Failed releases: " + ", ".join(failures))


if __name__ == "__main__":
    main()
