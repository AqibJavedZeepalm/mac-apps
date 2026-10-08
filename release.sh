#!/bin/bash
# Creates a GitHub release for an app version in AqibJavedZeepalm/mac-apps and uploads its notarized zip.
#   ./release.sh <App> <version> "<one line of notes>"     e.g. ./release.sh Notchet 1.0.4 "Compact cards"
# The zip comes from ~/Projects/mac-tools/<App>/build/<App>-<version>.zip (made by ./build.sh dist).
set -euo pipefail
APP=$1 VERSION=$2 NOTES=${3:-""}
ZIP="$HOME/Projects/mac-tools/$APP/build/$APP-$VERSION.zip"
[[ -f "$ZIP" ]] || ZIP="$HOME/projects/portfolio-aqib/public/downloads/$APP-$VERSION.zip"
[[ -f "$ZIP" ]] || { echo "no zip for $APP $VERSION" >&2; exit 1; }
TAG="$(echo "$APP" | tr '[:upper:]' '[:lower:]')-$VERSION"
SLUG="$(echo "$APP" | tr '[:upper:]' '[:lower:]')"
gh release create "$TAG" "$ZIP" --repo AqibJavedZeepalm/mac-apps --title "$APP $VERSION" \
  --notes "${NOTES:+$NOTES

}Notarized by Apple. Install steps and the full notes: https://aqibjaved.dev/apps/$SLUG/"
echo "https://github.com/AqibJavedZeepalm/mac-apps/releases/download/$TAG/$APP-$VERSION.zip"
