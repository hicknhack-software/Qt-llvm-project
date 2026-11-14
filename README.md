# Qt libclang binary mirror

This repository mirrors Qt's prebuilt libclang archives from
https://download.qt.io/development_releases/prebuilt/libclang/.
The `release_*` branches contain the unmodified source branches from
https://code.qt.io/clang/llvm-project.git.

The default `mirror-automation` branch contains only the mirroring automation.
Keep it as the default branch: GitHub schedules run from the default branch.

## Automatic and manual updates

The **Mirror Qt libclang** workflow checks every Friday at 07:23 UTC
(08:23 CET / 09:23 CEST). It discovers stable versions from 23.0.0 onward;
older releases are retained as they were manually mirrored.
Run it manually from Actions to check immediately. The optional `versions`
input accepts a comma-separated list such as `23.1.0,23.1.1`. The `dry_run`
input discovers missing releases without publishing or pushing anything.

For each release, the workflow:

1. Reads Qt's checksum manifest and uses its modification timestamp for the
   release name and tag, matching the existing release naming convention.
2. Fetches the corresponding `release_<version>-based` source branch and
   pushes it without force. Existing branches must match the upstream SHA.
3. Creates a draft release at that source commit, with the existing description
   format and a link to Qt's checksum manifest.
4. Copies every archive listed in the manifest, checks its MD5, and verifies
   GitHub's reported upload size and SHA-256. The checksum manifest is also
   attached so it remains available if Qt removes the original.
5. Publishes only after all assets are present and the manifest is unchanged.

Interrupted drafts are resumed, identical assets are retained, and conflicting
assets or source refs fail the run without being overwritten. Completed
releases are skipped without downloading the archives again. New source
branches without prebuilt archives are ignored. Concurrent runs are serialized.
Releases are processed in version order; individual failures do not stop other
versions, but the workflow reports failure if any release fails.

## GitHub settings

Enable Actions for this repository. The publishing job uses the built-in
`GITHUB_TOKEN` with `contents: write` for releases and assets. Source pushes
use a dedicated write-enabled SSH deploy key, whose private key is stored in
the Actions secret `MIRROR_SSH_KEY`. This is necessary because the source
branches include upstream workflow files, which `GITHUB_TOKEN` cannot update.
The key grants access only to this repository; no personal token is stored.
SSH host keys are obtained through GitHub's HTTPS metadata API and checked.
No additional environments or runners are needed. Checkout is pinned to a commit.
The workflow has a repository guard and does not publish on pushes or pull
requests. Changes to the automation run its tests.

GitHub disables schedules in public repositories after 60 days without
repository activity. Successful scheduled checks create an empty commit on
`mirror-automation` only when its latest commit is at least 28 days old,
keeping the schedule active during periods without new libclang releases.
Source branches and release tags are never changed by this keepalive.

## Local checks

Requires Python 3.10+, Git, and curl. No Python packages are required.

```sh
python -m unittest discover -s .github/mirror -v
python .github/mirror/mirror_libclang.py --dry-run --versions 23.1.0,23.1.1
```

For an authenticated local run, provide `GH_TOKEN` through the environment.
Git history is fetched into a temporary bare repository only when a source
branch is missing from GitHub. Existing mirror history is fetched without
blobs to reduce transfer, then Qt's new history is fetched and pushed.
Archives are transferred one at a time and deleted after verified upload.
