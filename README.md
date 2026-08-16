<div align="center">

# Simple Notes

A native macOS text editor. Open, type, save.

[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)](https://github.com/MoomenALdahdouh/SimpleNotes/releases/latest)
[![Swift](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)](https://www.swift.org)
[![Release](https://img.shields.io/github/v/release/MoomenALdahdouh/SimpleNotes)](https://github.com/MoomenALdahdouh/SimpleNotes/releases/latest)
[![License](https://img.shields.io/github/license/MoomenALdahdouh/SimpleNotes)](LICENSE)

[Download](https://github.com/MoomenALdahdouh/SimpleNotes/releases/latest) · [Ko-fi](https://ko-fi.com/moomenaldahdouh)

<img src="docs/window.png" alt="Simple Notes main window" width="760">

</div>

## Overview

Simple Notes is a local, distraction-free editor for `.txt` and `.md` files. Launch it and start typing. Files stay on your Mac — no account, no cloud, no network.

It uses a native `NSTextView`, so Arabic, English, Turkish, mixed RTL/LTR text, emoji, undo, find, and Unicode all behave like a normal macOS editor.

## Features

- Opens into a blank editor (no onboarding)
- UTF-8 `.txt` (default) and `.md` (source, not preview)
- Mixed-language and bidirectional text
- Font and size, find, drag-and-drop, autosave prompts
- Live word and character counts

## Installation

Download **SimpleNotes.dmg** from [Releases](https://github.com/MoomenALdahdouh/SimpleNotes/releases/latest), drag **Simple Notes** into **Applications**, then open it.

If macOS blocks the app (ad-hoc signed, not notarized):

```bash
xattr -d com.apple.quarantine "/Applications/Simple Notes.app"
open "/Applications/Simple Notes.app"
```

Or in Finder: right-click **Simple Notes** → **Open** → **Open**.

## Build from source

Requires macOS 14+ and Xcode or Command Line Tools.

```bash
git clone https://github.com/MoomenALdahdouh/SimpleNotes.git
cd SimpleNotes

# Checks
./scripts/test.sh

# App + DMG
./scripts/build.sh
./scripts/package-dmg.sh

# Run
open "dist/Simple Notes.app"

# Optional: copy to /Applications
./build/install.sh
```

With Xcode:

```bash
open SimpleNotes.xcodeproj
```

Then run the **Simple Notes** scheme.

## Usage

| Action | Shortcut |
| --- | --- |
| New | ⌘N |
| Open | ⌘O |
| Save | ⌘S |
| Save As | ⇧⌘S |
| Find | ⌘F |
| Close | ⌘W |

Markdown is edited as text. The first save suggests a timestamp name such as `2026-08-16_13-47-00.txt`.

## Support

If this is useful: [buy me a coffee](https://ko-fi.com/moomenaldahdouh).

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/moomenaldahdouh)

In the app: **Help → Buy Me a Coffee**, or the About window.

## License

[MIT](LICENSE)
