<div align="center">

<img src="docs/icon.png" alt="Simple Notes" width="96">

# Simple Notes

Native macOS text editor. Open, type, save.

[![build](https://img.shields.io/github/actions/workflow/status/MoomenALdahdouh/SimpleNotes/ci.yml?label=build)](https://github.com/MoomenALdahdouh/SimpleNotes/actions)
[![license](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![release](https://img.shields.io/github/v/release/MoomenALdahdouh/SimpleNotes?label=release)](https://github.com/MoomenALdahdouh/SimpleNotes/releases/latest)
[![macOS](https://img.shields.io/badge/macOS-14%2B-black)](https://github.com/MoomenALdahdouh/SimpleNotes/releases/latest)
[![arch](https://img.shields.io/badge/arch-arm64-lightgrey)](https://github.com/MoomenALdahdouh/SimpleNotes/releases/latest)

</div>

---

## Overview

Simple Notes is a distraction-free editor for `.txt` and `.md` files, built with Swift, SwiftUI, and AppKit. It opens into a blank `NSTextView` so you can type immediately. Arabic, English, Turkish, mixed RTL/LTR, and other Unicode text use macOS layout. No accounts, ads, telemetry, or network requirement at runtime.

<p align="center">
  <img src="docs/window.png" alt="Simple Notes main window" width="760">
</p>

## Installation

Download **SimpleNotes.dmg** from [Releases](https://github.com/MoomenALdahdouh/SimpleNotes/releases/latest), drag **Simple Notes** into **Applications**, then open it.

The distributed build is ad-hoc signed (not notarized). If macOS blocks it:

```bash
xattr -d com.apple.quarantine "/Applications/Simple Notes.app"
open "/Applications/Simple Notes.app"
```

Or right-click the app → **Open** → **Open**.

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
```

```bash
# Xcode
open SimpleNotes.xcodeproj
```

## Usage

| Action | Shortcut |
| --- | --- |
| New | ⌘N |
| Open | ⌘O |
| Save | ⌘S |
| Save As | ⇧⌘S |
| Find | ⌘F |
| Close | ⌘W |

UTF-8 `.txt` is the default. Markdown is edited as source, not previewed.

## Support

[Buy me a coffee](https://ko-fi.com/moomenaldahdouh) · in the app: **Help → Buy Me a Coffee**

## License

[MIT](LICENSE)
