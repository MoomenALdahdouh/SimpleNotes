import AppKit
import SwiftUI

struct NotesEditor: NSViewRepresentable {
    var session: DocumentSession

    func makeCoordinator() -> Coordinator {
        Coordinator(session: session)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = .textBackgroundColor
        scrollView.automaticallyAdjustsContentInsets = false

        for manager in session.textStorage.layoutManagers {
            session.textStorage.removeLayoutManager(manager)
        }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false
        textContainer.lineFragmentPadding = 5
        layoutManager.addTextContainer(textContainer)
        session.textStorage.addLayoutManager(layoutManager)

        let textView = NotesNSTextView(frame: .zero, textContainer: textContainer)
        textView.configure()
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.delegate = context.coordinator
        textView.onOpenFile = { url in
            session.handleDroppedURL(url)
        }
        textView.onUnsupportedDrop = {
            Alerts.unsupportedFileType()
        }

        scrollView.documentView = textView
        context.coordinator.scrollView = scrollView
        session.attach(textView: textView)

        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
            session.syncWindowChrome()
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.session = session
        guard let textView = scrollView.documentView as? NSTextView else { return }

        if textView.font != session.font {
            textView.font = session.font
            textView.typingAttributes = [
                .font: session.font,
                .foregroundColor: NSColor.textColor
            ]
        }

        textView.backgroundColor = .textBackgroundColor
        textView.textColor = .textColor
        scrollView.backgroundColor = .textBackgroundColor
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var session: DocumentSession
        weak var scrollView: NSScrollView?

        init(session: DocumentSession) {
            self.session = session
        }

        func textDidChange(_ notification: Notification) {
            session.markEdited()
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            false
        }
    }
}
