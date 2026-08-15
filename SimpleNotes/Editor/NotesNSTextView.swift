import AppKit
import SimpleNotesCore

final class NotesNSTextView: NSTextView {
    var onOpenFile: ((URL) -> Void)?
    var onUnsupportedDrop: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    func configure() {
        isRichText = false
        importsGraphics = false
        allowsImageEditing = false
        allowsUndo = true
        usesFindBar = true
        isIncrementalSearchingEnabled = true
        usesInspectorBar = false
        isAutomaticQuoteSubstitutionEnabled = false
        isAutomaticDashSubstitutionEnabled = false
        isAutomaticTextReplacementEnabled = false
        isAutomaticSpellingCorrectionEnabled = false
        isAutomaticDataDetectionEnabled = false
        isAutomaticLinkDetectionEnabled = false
        smartInsertDeleteEnabled = false
        isGrammarCheckingEnabled = false
        baseWritingDirection = .natural
        alignment = .natural
        drawsBackground = true
        backgroundColor = .textBackgroundColor
        textColor = .textColor
        insertionPointColor = .textColor
        isVerticallyResizable = true
        isHorizontallyResizable = false
        autoresizingMask = [.width]
        textContainerInset = NSSize(width: 28, height: 22)
        font = NSFont.systemFont(ofSize: FontSizes.defaultSize)
        registerForDraggedTypes([.fileURL])
    }

    override var acceptsFirstResponder: Bool { true }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if containsFileURLs(sender) {
            return .copy
        }
        return super.draggingEntered(sender)
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if containsFileURLs(sender) {
            return .copy
        }
        return super.draggingUpdated(sender)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = fileURLs(from: sender)
        if urls.isEmpty {
            return super.performDragOperation(sender)
        }

        guard let url = urls.first else { return false }
        if FileFormat.isSupported(url: url) {
            onOpenFile?(url)
        } else {
            onUnsupportedDrop?()
        }
        return true
    }

    private func containsFileURLs(_ sender: NSDraggingInfo) -> Bool {
        sender.draggingPasteboard.canReadObject(
            forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]
        )
    }

    private func fileURLs(from sender: NSDraggingInfo) -> [URL] {
        sender.draggingPasteboard.readObjects(
            forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]
        ) as? [URL] ?? []
    }
}
