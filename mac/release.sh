#!/bin/sh
# Publishes build/Recurse.app as GitHub release v$(cat VERSION). Bump VERSION, commit and push first.
set -e
cd "$(dirname "$0")"
V=$(cat VERSION)
[ -z "$(git status --porcelain)" ] || { echo "commit your changes first"; exit 1; }
[ "$(git rev-parse HEAD)" = "$(git rev-parse @{u})" ] || { echo "push first"; exit 1; }
! gh release view "v$V" >/dev/null 2>&1 || { echo "v$V is already released: bump VERSION"; exit 1; }
./build-app.sh
ZIP="build/Recurse.zip"
ditto -c -k --keepParent build/Recurse.app "$ZIP"
gh release create "v$V" "$ZIP" --target "$(git rev-parse HEAD)" --title "Recurse $V" --notes-file - <<NOTES
## Install
1. Download **Recurse.zip**, unzip it and drag **Recurse.app** into Applications.
2. Open it. macOS says it can't verify the app: open **System Settings › Privacy & Security**, scroll down and click **Open Anyway**. Only needed once.
3. Running code needs \`python3\`: if macOS offers to install the Command Line Tools, accept. AI grading and the tutor need the \`claude\` CLI, logged in.

## Update
**Recurse › Check for Updates…** downloads and installs it, or replace the app with this one. Your progress lives in \`~/Library/Application Support/Recurse\` and is kept.
NOTES
echo "released v$V"
