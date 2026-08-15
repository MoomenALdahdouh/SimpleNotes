# Simple Notes

A native macOS text editor. Open, type, save.

## Requirements

- macOS 14 or later
- Swift 5.9+ (Xcode 15+ or Command Line Tools)

This project builds with either Xcode or Swift Package Manager. Command Line Tools are enough to compile, test, and package a local app.

## How to build

Using SwiftPM:

```bash
swift build -c release --product SimpleNotes
./scripts/build.sh
```

`scripts/build.sh` compiles a Release binary, wraps it as `dist/Simple Notes.app`, and ad-hoc signs it.

Using Xcode (when installed):

```bash
open SimpleNotes.xcodeproj
```

Then choose the Simple Notes scheme and Run, or:

```bash
xcodebuild -project SimpleNotes.xcodeproj -scheme "Simple Notes" -configuration Release
```

## How to run

```bash
open "dist/Simple Notes.app"
```

Or press Run in Xcode.

## How to create the DMG

```bash
./scripts/build.sh
./scripts/package-dmg.sh
```

This writes `dist/SimpleNotes.dmg`.

## How to install

Double-click `SimpleNotes.dmg`, drag **Simple Notes** into **Applications**, then open it.

From the command line:

```bash
./build/install.sh
```

If Gatekeeper blocks a local ad-hoc build:

```bash
xattr -d com.apple.quarantine "/Applications/Simple Notes.app"
```

## Tests

Command Line Tools do not include XCTest. Run the bundled checks with:

```bash
./scripts/test.sh
```

That executes `SimpleNotesChecks`, covering filenames, UTF-8 round-trips (Arabic, English, Turkish, emoji, mixed text), word/character counts, save/open, extensions, and undo/redo.

If Xcode is installed, the `SimpleNotesTests` target in `SimpleNotes.xcodeproj` can also be run from the Test navigator.

## Known limitations

- There is no Developer ID signature in this tree. A local Release build is ad-hoc signed and runs on the development Mac.
- Version 1 edits `.txt` and `.md` as plain text. Markdown is not rendered.
- Very large files (tens of megabytes) remain editable but may feel slower to open or scroll.
- Replace in Find is the native macOS find bar, not a custom UI.
