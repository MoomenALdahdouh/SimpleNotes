#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Simple Notes.app"

if [[ ! -d "$APP" ]]; then
  echo "Missing app bundle. Run scripts/build.sh first." >&2
  exit 1
fi

DEST="/Applications/Simple Notes.app"
rm -rf "$DEST"
cp -R "$APP" "$DEST"
echo "Installed to $DEST"
echo "Launch with: open \"$DEST\""
