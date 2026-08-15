import SwiftUI

struct AppCommands: Commands {
    var session: DocumentSession
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New") {
                session.newDocument()
            }
            .keyboardShortcut("n", modifiers: .command)

            Button("Open…") {
                session.openDocument()
            }
            .keyboardShortcut("o", modifiers: .command)

            Divider()

            Button("Save") {
                session.save()
            }
            .keyboardShortcut("s", modifiers: .command)

            Button("Save As…") {
                session.saveAs()
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])

            Divider()

            Button("Close") {
                NSApp.keyWindow?.performClose(nil)
            }
            .keyboardShortcut("w", modifiers: .command)
        }

        CommandGroup(replacing: .undoRedo) {
            Button("Undo") {
                NSApp.sendAction(Selector(("undo:")), to: nil, from: nil)
            }
            .keyboardShortcut("z", modifiers: .command)

            Button("Redo") {
                NSApp.sendAction(Selector(("redo:")), to: nil, from: nil)
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])
        }

        CommandGroup(after: .pasteboard) {
            Divider()
            Button("Find…") {
                session.showFind()
            }
            .keyboardShortcut("f", modifiers: .command)

            Button("Find Next") {
                session.findNext()
            }
            .keyboardShortcut("g", modifiers: .command)

            Button("Find Previous") {
                session.findPrevious()
            }
            .keyboardShortcut("g", modifiers: [.command, .shift])
        }

        CommandMenu("Format") {
            Button("Font…") {
                session.showFontPanel()
            }
            .keyboardShortcut("t", modifiers: .command)

            Menu("Font Size") {
                ForEach(FontSizes.presets, id: \.self) { size in
                    Button("\(Int(size))") {
                        session.setFontSize(size)
                    }
                }
                Divider()
                Button("Custom…") {
                    session.showCustomFontSize()
                }
            }
        }

        CommandGroup(after: .toolbar) {
            Button("Increase Font Size") {
                session.increaseFontSize()
            }
            .keyboardShortcut("+", modifiers: .command)

            Button("Decrease Font Size") {
                session.decreaseFontSize()
            }
            .keyboardShortcut("-", modifiers: .command)

            Button("Reset Font Size") {
                session.resetFontSize()
            }
            .keyboardShortcut("0", modifiers: .command)
        }

        CommandGroup(replacing: .help) {
            Button("About Simple Notes") {
                openWindow(id: "about")
            }
        }
    }
}
