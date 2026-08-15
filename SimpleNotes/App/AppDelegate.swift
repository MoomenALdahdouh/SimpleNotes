import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var session: DocumentSession?
    private weak var observedWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async { [weak self] in
            self?.configureMainWindow()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let session else { return .terminateNow }
        return session.requestClose() ? .terminateNow : .terminateCancel
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        DispatchQueue.main.async { [weak self] in
            self?.session?.open(url: url)
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        session?.requestClose() ?? true
    }

    func windowDidBecomeKey(_ notification: Notification) {
        session?.syncWindowChrome()
        session?.focusEditor()
    }

    func configureMainWindow() {
        guard let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "main" })
                ?? NSApp.windows.first(where: { !($0 is NSPanel) }) else {
            return
        }

        if observedWindow !== window {
            window.delegate = self
            observedWindow = window
        }

        window.minSize = NSSize(width: 600, height: 400)
        window.setFrameAutosaveName("SimpleNotesMainWindow")
        if !window.setFrameUsingName("SimpleNotesMainWindow") {
            var frame = window.frame
            frame.size = NSSize(width: 1000, height: 700)
            window.setFrame(frame, display: true)
            window.center()
        }
        session?.syncWindowChrome()
        session?.focusEditor()
    }
}
