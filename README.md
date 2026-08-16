# Simple Notes

A native macOS text editor. Open, type, save.

Simple Notes is a small, local, distraction-free writing app for `.txt` and `.md` files. It supports Arabic, English, Turkish, and other Unicode text, including mixed right-to-left and left-to-right documents.

**macOS 14 or later.** No account, no cloud, no network.

<p align="center">
  <img src="docs/window.png" alt="Simple Notes main window with mixed Arabic, English, and Turkish text" width="800">
</p>

<p align="center"><em>The real main window: type, save as TXT or Markdown, with a live word count.</em></p>


## Install

1. Download **SimpleNotes.dmg** from the [latest release](https://github.com/MoomenALdahdouh/SimpleNotes/releases/latest).
2. Open the disk image and drag **Simple Notes** into **Applications**.
3. Open **Simple Notes** from Applications.

### If macOS says the app cannot be opened

This build is ad-hoc signed (not notarized with an Apple Developer ID). That is normal for an open-source local app.

**Easiest:** in Finder, right-click **Simple Notes** → **Open** → **Open**.

Or in Terminal:

```bash
xattr -d com.apple.quarantine "/Applications/Simple Notes.app"
open "/Applications/Simple Notes.app"
```

## Use

Launch the app and start typing.

| Action | Shortcut |
| --- | --- |
| New | ⌘N |
| Open | ⌘O |
| Save | ⌘S |
| Save As | ⇧⌘S |
| Find | ⌘F |
| Close | ⌘W |

Files save as UTF-8 **Plain Text (`.txt`)** or **Markdown (`.md`)**. Markdown is edited as source, not previewed. The first save suggests a timestamp name such as `2026-08-16_13-47-00.txt`.

## Privacy

Everything stays on your Mac. Simple Notes does not use the internet, analytics, accounts, or cloud sync.

## Build from source

You need macOS 14+ and either Xcode or Command Line Tools.

```bash
git clone https://github.com/MoomenALdahdouh/SimpleNotes.git
cd SimpleNotes
./scripts/test.sh
./scripts/build.sh
./scripts/package-dmg.sh
open "dist/Simple Notes.app"
```

`scripts/build.sh` creates `dist/Simple Notes.app`. `scripts/package-dmg.sh` creates `dist/SimpleNotes.dmg`.

To install that local build:

```bash
./build/install.sh
```

If Xcode is installed:

```bash
open SimpleNotes.xcodeproj
```

Then run the **Simple Notes** scheme.

## Tests

Command Line Tools do not include XCTest. Use:

```bash
./scripts/test.sh
```

With Xcode, run the **SimpleNotesTests** target from the Test navigator.

## Known limitations

- The distributed app is ad-hoc signed, not Developer ID notarized.
- Markdown is plain text. It is not rendered.
- Very large files still open, but scrolling can slow down.

## License

MIT. See [LICENSE](LICENSE).
