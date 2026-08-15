#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Generating app icon…"
python3 "$ROOT/scripts/generate-icon.py"

echo "Building release binary…"
swift build -c release --product SimpleNotes

BIN="$(swift build -c release --show-bin-path)/SimpleNotes"
APP_DIR="$ROOT/dist/Simple Notes.app"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BIN" "$APP_DIR/Contents/MacOS/SimpleNotes"
cp "$ROOT/SimpleNotes/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$ROOT/SimpleNotes/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
printf 'APPL????' > "$APP_DIR/Contents/PkgInfo"

# Copy SwiftPM resource bundle if the build produced one.
RESOURCE_BUNDLE="$(dirname "$BIN")/SimpleNotes_SimpleNotes.bundle"
if [[ -d "$RESOURCE_BUNDLE" ]]; then
  cp -R "$RESOURCE_BUNDLE" "$APP_DIR/Contents/Resources/"
fi

echo "Ad-hoc signing…"
codesign --force --deep --sign - \
  --entitlements "$ROOT/SimpleNotes/Resources/SimpleNotes.entitlements" \
  "$APP_DIR"

echo "Built: $APP_DIR"
