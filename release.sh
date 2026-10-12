#!/bin/bash
# Creates a GitHub release for an app version in AqibJavedZeepalm/mac-apps and uploads its notarized zip, then bumps
# the app's Homebrew cask in ~/Projects/homebrew-tap (AqibJavedZeepalm/homebrew-tap) and pushes it.
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

# Homebrew: `brew install --cask aqibjavedzeepalm/tap/<slug>` downloads this same zip, so its cask names this version
# and the zip's checksum. The apps update themselves (auto_updates), so a cask a release behind still works.
TAP="$HOME/Projects/homebrew-tap"
CASK="$TAP/Casks/$SLUG.rb"
if [[ -f "$CASK" ]]; then
  SHA=$(shasum -a 256 "$ZIP" | cut -d' ' -f1)
  sed -i '' -e "s/^  version \".*\"/  version \"$VERSION\"/" -e "s/^  sha256 \".*\"/  sha256 \"$SHA\"/" "$CASK"
  git -C "$TAP" add "Casks/$SLUG.rb"
  git -C "$TAP" commit -q -m "$APP $VERSION"
  git -C "$TAP" push -q
  echo "Homebrew: $SLUG $VERSION"
else
  echo "No Homebrew cask for $SLUG yet ($CASK)"
fi
