#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Simple Notes.app"
DMG="$ROOT/dist/SimpleNotes.dmg"
STAGE="$ROOT/build/dmg"

if [[ ! -d "$APP" ]]; then
  echo "Missing app bundle. Run scripts/build.sh first." >&2
  exit 1
fi

rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

rm -f "$DMG"
hdiutil create \
  -volname "Simple Notes" \
  -srcfolder "$STAGE" \
  -ov \
  -format UDZO \
  "$DMG"

echo "Created: $DMG"
