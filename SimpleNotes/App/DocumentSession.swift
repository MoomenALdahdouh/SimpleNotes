import AppKit
import SimpleNotesCore
import UniformTypeIdentifiers

@MainActor
@Observable
final class DocumentSession: NSObject {
    let textStorage = NSTextStorage()
    var fileURL: URL?
    var format: FileFormat = .txt
    var isDirty = false
    var font: NSFont = NSFont.systemFont(ofSize: FontSizes.defaultSize)
    var fontSize: CGFloat = FontSizes.defaultSize
    var wordCount = 0
    var characterCount = 0

    weak var textView: NSTextView?

    var windowTitle: String {
        fileURL?.lastPathComponent ?? "Simple Notes"
    }

    var documentNameForAlerts: String {
        fileURL?.lastPathComponent ?? "Untitled"
    }

    private var lastKnownModificationDate: Date?
    private var isWriting = false
    private var isReloading = false
    private let fileWatcher = FileWatcher()

    override init() {
        super.init()
        fileWatcher.onChanged = { [weak self] in
            self?.handleExternalChange()
        }
        fileWatcher.onMoved = { [weak self] url in
            self?.fileURL = url
            self?.format = FileFormat(url: url) ?? self?.format ?? .txt
            self?.syncWindowChrome()
        }
        fileWatcher.onDeleted = { [weak self] in
            self?.handleExternalDeletion()
        }
        updateCounts()
    }

    var currentText: String {
        textStorage.string
    }

    func attach(textView: NSTextView) {
        self.textView = textView
        applyFontToStorage()
        NSFontManager.shared.target = self
        NSFontManager.shared.action = #selector(changeFont(_:))
    }

    func markEdited() {
        guard !isReloading else { return }
        isDirty = true
        updateCounts()
        syncWindowChrome()
    }

    func updateCounts() {
        let text = textStorage.string
        wordCount = WordCounter.wordCount(in: text)
        characterCount = WordCounter.characterCount(in: text)
    }

    func newDocument() {
        guard prepareToReplaceDocument() else { return }
        resetDocument()
        focusEditor()
    }

    func openDocument() {
        guard prepareToReplaceDocument() else { return }

        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = Self.openContentTypes
        panel.message = "Choose a plain text or Markdown file."

        guard panel.runModal() == .OK, let url = panel.url else { return }
        open(url: url, skipUnsavedCheck: true)
    }

    func open(url: URL, skipUnsavedCheck: Bool = false) {
        let standardized = url.standardizedFileURL
        if fileURL?.standardizedFileURL == standardized && !isDirty {
            return
        }

        if !skipUnsavedCheck {
            guard prepareToReplaceDocument() else { return }
        }

        guard FileFormat.isSupported(url: url) else {
            Alerts.unsupportedFileType()
            return
        }

        do {
            let text = try FileService.readText(from: url)
            replaceText(text)
            fileURL = url
            format = FileFormat(url: url) ?? .txt
            isDirty = false
            lastKnownModificationDate = FileService.modificationDate(of: url)
            startWatching()
            textView?.undoManager?.removeAllActions()
            updateCounts()
            syncWindowChrome()
            focusEditor()
        } catch {
            Alerts.couldNotOpen(error)
        }
    }

    func handleDroppedURL(_ url: URL) {
        if FileFormat.isSupported(url: url) {
            open(url: url)
        } else {
            Alerts.unsupportedFileType()
        }
    }

    @discardableResult
    func save() -> Bool {
        if let fileURL {
            return write(to: fileURL)
        }
        return saveAs()
    }

    @discardableResult
    func saveAs() -> Bool {
        presentSavePanel(defaultFormat: format)
    }

    func showFind() {
        performFinderAction(.showFindInterface)
    }

    func findNext() {
        performFinderAction(.nextMatch)
    }

    func findPrevious() {
        performFinderAction(.previousMatch)
    }

    func showFontPanel() {
        NSFontManager.shared.target = self
        NSFontManager.shared.action = #selector(changeFont(_:))
        NSFontManager.shared.orderFrontFontPanel(self)
        NSFontPanel.shared.setPanelFont(font, isMultiple: false)
    }

    func setFontFamily(_ name: String) {
        let newFont = NSFont(name: name, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        font = newFont
        applyFontToStorage()
    }

    func setFontSize(_ size: CGFloat) {
        let clamped = FontSizes.clamped(size)
        fontSize = clamped
        font = NSFont(descriptor: font.fontDescriptor, size: clamped) ?? NSFont.systemFont(ofSize: clamped)
        applyFontToStorage()
    }

    func increaseFontSize() {
        setFontSize(FontSizes.nextPreset(after: fontSize))
    }

    func decreaseFontSize() {
        setFontSize(FontSizes.previousPreset(before: fontSize))
    }

    func resetFontSize() {
        setFontSize(FontSizes.defaultSize)
    }

    func showCustomFontSize() {
        let alert = NSAlert()
        alert.messageText = "Font Size"
        alert.informativeText = "Enter a size in points."
        let field = NSTextField(string: formattedSize(fontSize))
        field.frame = NSRect(x: 0, y: 0, width: 220, height: 24)
        field.placeholderString = "14"
        alert.accessoryView = field
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = field

        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let value = field.doubleValue
        if value > 0 {
            setFontSize(CGFloat(value))
        }
    }

    @objc func changeFont(_ sender: NSFontManager) {
        let converted = sender.convert(font)
        font = converted
        fontSize = converted.pointSize
        applyFontToStorage()
    }

    func requestClose() -> Bool {
        prepareToReplaceDocument()
    }

    func syncWindowChrome() {
        guard let window = textView?.window ?? NSApp.keyWindow else { return }
        window.title = windowTitle
        window.isDocumentEdited = isDirty
        window.representedURL = fileURL
    }

    func focusEditor() {
        DispatchQueue.main.async { [weak self] in
            guard let textView = self?.textView else { return }
            textView.window?.makeFirstResponder(textView)
        }
    }

    private func performFinderAction(_ action: NSTextFinder.Action) {
        guard let textView else { return }
        textView.window?.makeFirstResponder(textView)
        textView.performTextFinderAction(TextFinderActionSender(action))
    }

    private func prepareToReplaceDocument() -> Bool {
        guard isDirty else { return true }

        switch Alerts.confirmSave(documentName: documentNameForAlerts) {
        case .alertFirstButtonReturn:
            return save()
        case .alertSecondButtonReturn:
            return true
        default:
            return false
        }
    }

    private func resetDocument() {
        stopWatching()
        replaceText("")
        fileURL = nil
        format = .txt
        isDirty = false
        lastKnownModificationDate = nil
        textView?.undoManager?.removeAllActions()
        updateCounts()
        syncWindowChrome()
    }

    private func replaceText(_ text: String) {
        isReloading = true
        textStorage.beginEditing()
        textStorage.mutableString.setString(text)
        applyFontToStorage()
        textStorage.endEditing()
        isReloading = false
        textView?.selectedRanges = [NSValue(range: NSRange(location: 0, length: 0))]
    }

    private func applyFontToStorage() {
        let fullRange = NSRange(location: 0, length: textStorage.length)
        if fullRange.length > 0 {
            textStorage.addAttribute(.font, value: font, range: fullRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.textColor, range: fullRange)
        }
        textView?.font = font
        textView?.textColor = .textColor
        textView?.typingAttributes = [
            .font: font,
            .foregroundColor: NSColor.textColor
        ]
    }

    private func presentSavePanel(defaultFormat: FileFormat) -> Bool {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        panel.nameFieldStringValue = FilenameGenerator.timestampName()
        panel.allowsOtherFileTypes = false

        let accessory = SaveFormatAccessory(format: defaultFormat) { [weak panel] format in
            panel?.allowedContentTypes = [format.utType]
        }
        panel.accessoryView = accessory.view
        panel.allowedContentTypes = [defaultFormat.utType]

        guard panel.runModal() == .OK, let chosenURL = panel.url else {
            return false
        }

        let selectedFormat = accessory.format
        let enteredName = panel.nameFieldStringValue
        let sanitized = FileNameSanitizer.applyingExtension(
            filename: enteredName.isEmpty ? chosenURL.lastPathComponent : enteredName,
            format: selectedFormat
        )
        var finalURL = chosenURL.deletingLastPathComponent().appendingPathComponent(sanitized)

        if finalURL.pathExtension.lowercased() != selectedFormat.fileExtension {
            finalURL = finalURL.deletingPathExtension().appendingPathExtension(selectedFormat.fileExtension)
        }

        return write(to: finalURL, format: selectedFormat)
    }

    @discardableResult
    private func write(to url: URL, format newFormat: FileFormat? = nil) -> Bool {
        isWriting = true
        defer { isWriting = false }

        do {
            try FileService.writeText(textStorage.string, to: url)
            fileURL = url
            if let newFormat {
                format = newFormat
            } else if let detected = FileFormat(url: url) {
                format = detected
            }
            isDirty = false
            lastKnownModificationDate = FileService.modificationDate(of: url)
            startWatching()
            syncWindowChrome()
            return true
        } catch {
            Alerts.couldNotSave(error)
            return false
        }
    }

    private func startWatching() {
        stopWatching()
        guard let fileURL else { return }
        fileWatcher.start(url: fileURL)
    }

    private func stopWatching() {
        fileWatcher.stop()
    }

    private func handleExternalChange() {
        guard !isWriting, let fileURL else { return }
        let diskDate = FileService.modificationDate(of: fileURL)
        if let diskDate, let lastKnownModificationDate, diskDate <= lastKnownModificationDate.addingTimeInterval(0.8) {
            return
        }

        if isDirty {
            switch Alerts.externalChangeConflict(filename: fileURL.lastPathComponent) {
            case .alertFirstButtonReturn:
                lastKnownModificationDate = diskDate
            case .alertSecondButtonReturn:
                reloadFromDisk()
            default:
                break
            }
        } else {
            reloadFromDisk()
        }
    }

    private func handleExternalDeletion() {
        guard let name = fileURL?.lastPathComponent else { return }
        stopWatching()
        fileURL = nil
        isDirty = true
        lastKnownModificationDate = nil
        syncWindowChrome()
        Alerts.fileDeletedExternally(filename: name)
    }

    private func reloadFromDisk() {
        guard let fileURL else { return }
        do {
            let text = try FileService.readText(from: fileURL)
            replaceText(text)
            isDirty = false
            lastKnownModificationDate = FileService.modificationDate(of: fileURL)
            textView?.undoManager?.removeAllActions()
            updateCounts()
            syncWindowChrome()
        } catch {
            Alerts.couldNotOpen(error)
        }
    }

    private func formattedSize(_ size: CGFloat) -> String {
        if size.rounded() == size {
            return String(Int(size))
        }
        return String(format: "%.1f", size)
    }

    private static var openContentTypes: [UTType] {
        var types: [UTType] = [.plainText, .text]
        if let md = UTType(filenameExtension: "md") {
            types.append(md)
        }
        if let markdown = UTType(filenameExtension: "markdown") {
            types.append(markdown)
        }
        return types
    }
}

private final class TextFinderActionSender: NSObject {
    @objc let tag: Int

    init(_ action: NSTextFinder.Action) {
        self.tag = action.rawValue
    }
}

@MainActor
private final class SaveFormatAccessory: NSObject {
    private(set) var format: FileFormat
    let view: NSView
    private let popUp: NSPopUpButton
    private var onChange: (FileFormat) -> Void

    init(format: FileFormat, onChange: @escaping (FileFormat) -> Void) {
        self.format = format
        self.onChange = onChange
        self.popUp = NSPopUpButton(frame: NSRect(x: 88, y: 4, width: 180, height: 24), pullsDown: false)
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 280, height: 32))
        super.init()

        let label = NSTextField(labelWithString: "Format:")
        label.frame = NSRect(x: 12, y: 7, width: 70, height: 17)
        label.alignment = .right

        popUp.removeAllItems()
        for item in FileFormat.allCases {
            popUp.addItem(withTitle: "\(item.typeName) (.\(item.fileExtension))")
        }
        popUp.selectItem(at: FileFormat.allCases.firstIndex(of: format) ?? 0)
        popUp.target = self
        popUp.action = #selector(changed)

        view.addSubview(label)
        view.addSubview(popUp)
    }

    @objc private func changed() {
        let index = popUp.indexOfSelectedItem
        let cases = FileFormat.allCases
        guard cases.indices.contains(index) else { return }
        format = cases[index]
        onChange(format)
    }
}
