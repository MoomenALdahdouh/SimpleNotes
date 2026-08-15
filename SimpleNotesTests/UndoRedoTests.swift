import AppKit
import XCTest

final class UndoRedoTests: XCTestCase {
    @MainActor
    func testTextViewUndoAndRedo() {
        let storage = NSTextStorage(string: "")
        let layoutManager = NSLayoutManager()
        let container = NSTextContainer(size: NSSize(width: 400, height: 200))
        storage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(container)

        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 200), textContainer: container)
        textView.allowsUndo = true
        textView.isRichText = false

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentView = textView
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(textView)

        textView.insertText("Hello", replacementRange: NSRange(location: 0, length: 0))
        XCTAssertEqual(textView.string, "Hello")

        textView.undoManager?.undo()
        XCTAssertEqual(textView.string, "")

        textView.undoManager?.redo()
        XCTAssertEqual(textView.string, "Hello")

        window.orderOut(nil)
    }
}
