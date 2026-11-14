import hashlib
from datetime import datetime, timedelta, timezone
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch

import mirror_libclang as mirror


VERSION = "23.1.0"
NAME = f"libclang-release_{VERSION}-based-windows-vs2022_64.7z"
MANIFEST = f"libclang-release_{VERSION}-based-md5.txt"
DATA = ("0" * 32 + "  " + NAME + "\n").encode()
SHA = "a" * 40
ITEM = {"version": VERSION, "manifest": MANIFEST,
        "tag": "libclang-release_23.1.0_based_03-Sep-2026_15-02"}


def asset(name, data=b"archive"):
    return {"id": 7, "name": name, "state": "uploaded", "size": len(data),
            "digest": "sha256:" + hashlib.sha256(data).hexdigest()}


class DiscoveryTests(unittest.TestCase):
    def test_version_order_timestamp_and_only_stable_manifest_links(self):
        def row(version):
            return (f'<tr><td><a href="libclang-release_{version}-based-md5.txt">'
                    f'md5</a></td><td>03-Sep-2026 15:02</td></tr>')
        index = row("23.1.10") + row("22.1.8") + row("23.1.2")
        index += row("24.0.0-rc1") + row("23.1.1").replace('.txt"', '.txt.mirrorlist"')
        releases = mirror.discover(index)
        self.assertEqual([r["version"] for r in releases], ["23.1.2", "23.1.10"])
        self.assertEqual(releases[0]["tag"], "libclang-release_23.1.2_based_03-Sep-2026_15-02")

    def test_changed_directory_format_fails_instead_of_silent_success(self):
        with self.assertRaises(ValueError):
            mirror.discover("<html>service unavailable</html>")

    def test_manifest_rejects_paths_wrong_versions_duplicates_and_empty(self):
        invalid = [b"", b"invalid\n", DATA + DATA,
                   DATA.replace(VERSION.encode(), b"24.1.0"),
                   DATA.replace(NAME.encode(), b"../" + NAME.encode())]
        for data in invalid:
            with self.subTest(data=data), self.assertRaises(ValueError):
                mirror.parse_manifest(data, VERSION)
        self.assertEqual(mirror.parse_manifest(DATA, VERSION), {NAME: "0" * 32})


class TransferTests(unittest.TestCase):
    def test_checksum_mismatch_stops_before_upload(self):
        with tempfile.TemporaryDirectory() as scratch:
            path = Path(scratch) / NAME
            path.write_bytes(b"corrupt archive")
            with patch.object(mirror.subprocess, "run"), self.assertRaisesRegex(
                    ValueError, "checksum mismatch"):
                mirror.download(path, "0" * 32)

    def test_identical_existing_asset_is_retained_and_conflict_is_not_deleted(self):
        github = Mock()
        with tempfile.TemporaryDirectory() as scratch:
            path = Path(scratch) / NAME
            path.write_bytes(b"archive")
            _, digest = mirror.hashes(path)
            github.assets.return_value = [asset(NAME)]
            mirror.ensure_asset(github, {"draft": True}, path, digest)
            github.upload.assert_not_called()
            github.request.assert_not_called()
            github.assets.return_value[0]["digest"] = "sha256:other"
            with self.assertRaisesRegex(ValueError, "Refusing to replace"):
                mirror.ensure_asset(github, {"draft": True}, path, digest)
            github.request.assert_not_called()

    def test_upload_retry_reconciles_a_success_with_a_lost_response(self):
        github = Mock()
        github.assets.side_effect = [[], [asset(NAME)]]
        github.upload.side_effect = TimeoutError("response lost")
        with tempfile.TemporaryDirectory() as scratch:
            path = Path(scratch) / NAME
            path.write_bytes(b"archive")
            mirror.ensure_asset(github, {"draft": True}, path, mirror.hashes(path)[1])
        github.upload.assert_called_once()
        github.request.assert_not_called()

    def test_branch_conflict_never_force_pushes(self):
        github = Mock()
        github.optional.return_value = {"object": {"sha": "b" * 40}}
        with patch.object(mirror.subprocess, "run") as git:
            with self.assertRaisesRegex(ValueError, "Refusing to move"):
                mirror.mirror_branch(github, VERSION, SHA, Path("unused"))
            git.assert_not_called()


class PublishingTests(unittest.TestCase):
    def setUp(self):
        self.github = Mock()
        self.github.optional.side_effect = [None, None, None]
        self.release = {"id": 1, "draft": True, "upload_url": "unused"}
        self.github.request.return_value = self.release
        self.github.assets.return_value = [asset(NAME), asset(MANIFEST, DATA)]

    def run_release(self, reads, upload_error=None):
        with tempfile.TemporaryDirectory() as scratch, \
                patch.object(mirror, "read_url", side_effect=reads), \
                patch.object(mirror, "source_sha", return_value=SHA), \
                patch.object(mirror, "mirror_branch"), \
                patch.object(mirror, "download", return_value="sha256:archive"), \
                patch.object(mirror, "ensure_asset", side_effect=upload_error), \
                patch.object(Path, "unlink"):
            return mirror.mirror_release(self.github, ITEM, Path(scratch), False)

    def test_release_targets_upstream_commit_and_publishes_after_verified_assets(self):
        self.assertEqual(self.run_release([DATA, DATA]), "published")
        create = self.github.request.call_args_list[0]
        self.assertEqual(create.args[1]["target_commitish"], SHA)
        self.assertTrue(create.args[1]["draft"])
        self.assertEqual(self.github.request.call_args_list[-1].kwargs["method"], "PATCH")

    def test_upload_failure_keeps_release_as_draft(self):
        with self.assertRaisesRegex(RuntimeError, "upload failed"):
            self.run_release([DATA], RuntimeError("upload failed"))
        self.assertEqual(self.github.request.call_count, 1)

    def test_missing_asset_keeps_release_as_draft(self):
        self.github.assets.return_value = [asset(MANIFEST, DATA)]
        with self.assertRaisesRegex(ValueError, "incomplete"):
            self.run_release([DATA, DATA])
        self.assertEqual(self.github.request.call_count, 1)

    def test_changed_manifest_keeps_release_as_draft(self):
        with self.assertRaisesRegex(ValueError, "changed its checksum"):
            self.run_release([DATA, b"changed"])
        self.assertEqual(self.github.request.call_count, 1)

    def test_completed_release_does_not_transfer_archives(self):
        release = dict(self.release, draft=False)
        self.github.optional.side_effect = [release, {"object": {"sha": SHA}}]
        with tempfile.TemporaryDirectory() as scratch, \
                patch.object(mirror, "read_url", return_value=DATA), \
                patch.object(mirror, "source_sha", return_value=SHA), \
                patch.object(mirror, "mirror_branch"), \
                patch.object(mirror, "download") as download:
            self.assertEqual(mirror.mirror_release(
                self.github, ITEM, Path(scratch), False), "complete")
        download.assert_not_called()
        self.github.request.assert_not_called()

    def test_dry_run_does_not_push_create_or_upload(self):
        with tempfile.TemporaryDirectory() as scratch, \
                patch.object(mirror, "read_url", return_value=DATA), \
                patch.object(mirror, "source_sha", return_value=SHA), \
                patch.object(mirror, "mirror_branch") as push:
            self.assertEqual(mirror.mirror_release(
                self.github, ITEM, Path(scratch), True), "missing")
        push.assert_not_called()
        self.github.request.assert_not_called()
        self.github.upload.assert_not_called()


class KeepaliveTests(unittest.TestCase):
    def test_monthly_keepalive_retains_the_tree_and_never_force_pushes(self):
        github = Mock()
        old = datetime.now(timezone.utc) - timedelta(days=29)
        github.request.side_effect = [
            {"default_branch": "mirror-automation"}, {"object": {"sha": SHA}},
            {"committer": {"date": old.isoformat()}, "tree": {"sha": "tree"}},
            {"sha": "new"}, None,
        ]
        mirror.keepalive(github)
        create = github.request.call_args_list[-2].args[1]
        self.assertEqual(create["tree"], "tree")
        self.assertEqual(create["parents"], [SHA])
        self.assertFalse(github.request.call_args_list[-1].args[1]["force"])

    def test_recent_activity_and_source_branches_are_never_changed(self):
        github = Mock()
        github.request.side_effect = [
            {"default_branch": "mirror-automation"}, {"object": {"sha": SHA}},
            {"committer": {"date": datetime.now(timezone.utc).isoformat()}},
        ]
        mirror.keepalive(github)
        self.assertEqual(github.request.call_count, 3)
        github.request.side_effect = [{"default_branch": "release_23.1.0-based"}]
        with self.assertRaisesRegex(ValueError, "only update"):
            mirror.keepalive(github)


class GitIntegrationTests(unittest.TestCase):
    def test_missing_source_branch_is_fetched_and_pushed_at_the_exact_commit(self):
        with tempfile.TemporaryDirectory() as scratch:
            directory = Path(scratch)
            source = directory / "upstream"
            destination = directory / "mirror.git"
            source.mkdir()

            def git(*args):
                return subprocess.check_output(["git", *map(str, args)], text=True).strip()

            git("init", "--initial-branch=release_23.1.0-based", source)
            (source / "file.txt").write_text("source commit\n", encoding="ascii")
            git("-C", source, "add", "file.txt")
            git("-C", source, "-c", "user.name=Mirror test", "-c", "user.email=test@example.com",
                "-c", "commit.gpgsign=false", "-c", "core.hooksPath=", "commit", "-m", "Source")
            sha = git("-C", source, "rev-parse", "HEAD")
            git("init", "--bare", destination)
            config = directory / "gitconfig"
            config.write_text(
                f'[url "{source.as_uri()}"]\n\tinsteadOf = {mirror.UPSTREAM}\n'
                f'[url "{destination.as_uri()}"]\n'
                f'\tinsteadOf = https://github.com/{mirror.REPOSITORY}.git\n', encoding="utf-8")
            github = Mock(token="test-token")
            github.optional.return_value = None
            github.request.return_value = []
            with patch.dict(os.environ, {"GIT_CONFIG_GLOBAL": str(config),
                                         "GITHUB_ACTIONS": "false", "MIRROR_SSH_KEY": ""}):
                mirror.mirror_branch(github, VERSION, sha, directory)
            self.assertEqual(git("-C", destination, "rev-parse", "refs/heads/release_23.1.0-based"),
                             sha)


if __name__ == "__main__":
    unittest.main()
