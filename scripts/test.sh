#!/usr/bin/env bash
# Runs every test target in BookApp.xctestplan, with code coverage, on the snapshot
# reference simulator. Snapshots are recorded on iPhone 17 Pro / iOS 26.5; other iOS
# versions render text differently. Extra arguments are passed to xcodebuild.
set -euo pipefail
cd "$(dirname "$0")/.."

DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5}"

xcodebuild test \
  -workspace BookApp.xcworkspace \
  -scheme BookApp \
  -destination "$DESTINATION" \
  "$@"
