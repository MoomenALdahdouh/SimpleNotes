import AppKit
import Foundation
import SimpleNotesCore

@main
struct SimpleNotesChecks {
    static func main() {
        var failures = 0
        func expect(_ condition: @autoclosure () -> Bool, _ message: String, file: StaticString = #fileID, line: UInt = #line) {
            if !condition() {
                failures += 1
                fputs("FAIL \(file):\(line) \(message)\n", stderr)
            }
        }

        func expectEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "", file: StaticString = #fileID, line: UInt = #line) {
            if actual != expected {
                failures += 1
                fputs("FAIL \(file):\(line) \(message) expected \(expected), got \(actual)\n", stderr)
            }
        }

        // 1. Automatic filename generation
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0)!
        let stampDate = DateComponents(calendar: utc, timeZone: utc.timeZone, year: 2026, month: 8, day: 15, hour: 16, minute: 42, second: 31).date!
        expectEqual(FilenameGenerator.timestampName(date: stampDate, timeZone: utc.timeZone), "2026-08-15_16-42-31")
        expect(!FilenameGenerator.timestampName().lowercased().contains("untitled"), "timestamp must not use Untitled")

        var istanbul = Calendar(identifier: .gregorian)
        istanbul.timeZone = TimeZone(secondsFromGMT: 3 * 3600)!
        let mdDate = DateComponents(calendar: istanbul, timeZone: istanbul.timeZone, year: 2026, month: 12, day: 1, hour: 9, minute: 15, second: 7).date!
        expectEqual(FilenameGenerator.defaultFilename(format: .markdown, date: mdDate, timeZone: istanbul.timeZone), "2026-12-01_09-15-07.md")

        // 15. File extension handling
        expectEqual(FileNameSanitizer.applyingExtension(filename: "notes", format: .txt), "notes.txt")
        expectEqual(FileNameSanitizer.applyingExtension(filename: "notes", format: .markdown), "notes.md")
        expectEqual(FileNameSanitizer.applyingExtension(filename: "notes.txt", format: .txt), "notes.txt")
        expectEqual(FileNameSanitizer.applyingExtension(filename: "notes.md", format: .markdown), "notes.md")
        expectEqual(FileNameSanitizer.applyingExtension(filename: "notes.md", format: .txt), "notes.txt")
        expectEqual(FileNameSanitizer.applyingExtension(filename: "notes.txt", format: .markdown), "notes.md")
        expectEqual(
            FileNameSanitizer.applyingExtension(filename: "   ", format: .txt, date: stampDate, timeZone: utc.timeZone),
            "2026-08-15_16-42-31.txt"
        )
        expectEqual(
            FileNameSanitizer.applyingExtension(filename: "Untitled.txt", format: .txt, date: stampDate, timeZone: utc.timeZone),
            "2026-08-15_16-42-31.txt"
        )

        // 11–12. Word and character counting
        expectEqual(WordCounter.wordCount(in: ""), 0)
        expectEqual(WordCounter.characterCount(in: ""), 0)
        expectEqual(WordCounter.wordCount(in: "Hello World"), 2)
        expectEqual(WordCounter.characterCount(in: "Hello World"), 11)
        expectEqual(WordCounter.wordCount(in: "مرحبا بالعالم"), 2)
        expectEqual(WordCounter.characterCount(in: "مرحبا بالعالم"), 13)
        expectEqual(WordCounter.wordCount(in: "مرحبا بالعالم Hello World"), 4)
        expectEqual(WordCounter.wordCount(in: "Merhaba Dünya"), 2)
        expectEqual(WordCounter.characterCount(in: "şğıİöüç"), 7)
        expectEqual(WordCounter.wordCount(in: "مرحبا بالعالم Hello World Merhaba Dünya"), 6)
        expectEqual(WordCounter.characterCount(in: "👋"), 1)
        expectEqual(WordCounter.characterCount(in: "Hello 👋"), 7)
        expectEqual(WordCounter.wordCount(in: "Hello, world!"), 2)

        // QR share payload for phone cameras
        expectEqual(QRSharePayload.prepare(""), QRSharePayload.Status.empty)
        expectEqual(QRSharePayload.prepare("   \n"), QRSharePayload.Status.empty)
        if case .ready(let ascii) = QRSharePayload.prepare("Hello from Simple Notes") {
            expect(!ascii.starts(with: [0xEF, 0xBB, 0xBF]), "ASCII QR payload must not include a BOM")
            expectEqual(QRSharePayload.decodedText(from: ascii), "Hello from Simple Notes")
        } else {
            expect(false, "ASCII note should encode as a QR payload")
        }
        let mixedNote = "مرحبا بالعالم Hello Merhaba Dünya"
        if case .ready(let unicode) = QRSharePayload.prepare(mixedNote) {
            expect(unicode.starts(with: [0xEF, 0xBB, 0xBF]), "Unicode QR payload should include a UTF-8 BOM")
            expectEqual(QRSharePayload.decodedText(from: unicode), mixedNote)
        } else {
            expect(false, "Unicode note should encode as a QR payload")
        }
        let oversized = String(repeating: "a", count: QRSharePayload.maxByteCount + 1)
        if case .tooLong(let byteCount, let limit) = QRSharePayload.prepare(oversized) {
            expectEqual(byteCount, QRSharePayload.maxByteCount + 1)
            expectEqual(limit, QRSharePayload.maxByteCount)
        } else {
            expect(false, "oversized note should be rejected")
        }

        func roundTrip(_ text: String, ext: String = "txt") throws {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("sn-\(UUID().uuidString).\(ext)")
            defer { try? FileManager.default.removeItem(at: url) }
            try FileService.writeText(text, to: url)
            let loaded = try FileService.readText(from: url)
            expectEqual(loaded, text, "round-trip \(ext)")
        }

        do {
            // 2–10, 13–16. Save/open UTF-8, languages, emoji, markdown, save as
            try roundTrip("Hello from Simple Notes", ext: "txt")
            try roundTrip("# Hello\n\n**Bold**\n\n* Item\n", ext: "md")
            try roundTrip("مرحبا بالعالم")
            try roundTrip("Hello World")
            try roundTrip("şğıİöüç ŞĞIİÖÜÇ Merhaba Dünya")
            try roundTrip("مرحبا بالعالم Hello World Merhaba Dünya")
            try roundTrip("Notes 👋📝🌍")
            try roundTrip("«سلام» — “hello” …")

            let txt = FileManager.default.temporaryDirectory.appendingPathComponent("sn-\(UUID().uuidString).txt")
            let md = FileManager.default.temporaryDirectory.appendingPathComponent("sn-\(UUID().uuidString).md")
            defer {
                try? FileManager.default.removeItem(at: txt)
                try? FileManager.default.removeItem(at: md)
            }
            try FileService.writeText("# Title\ncontent", to: txt)
            try FileService.writeText(try FileService.readText(from: txt), to: md)
            expectEqual(try FileService.readText(from: md), "# Title\ncontent")
            expectEqual(FileFormat(url: md), .markdown)
            expectEqual(FileFormat(url: txt), .txt)

            let noBom = FileManager.default.temporaryDirectory.appendingPathComponent("sn-\(UUID().uuidString).txt")
            defer { try? FileManager.default.removeItem(at: noBom) }
            try FileService.writeText("Hello", to: noBom)
            let data = try Data(contentsOf: noBom)
            expect(!data.starts(with: [0xEF, 0xBB, 0xBF]), "UTF-8 must not include a BOM")

            let bom = FileManager.default.temporaryDirectory.appendingPathComponent("sn-bom-\(UUID().uuidString).txt")
            defer { try? FileManager.default.removeItem(at: bom) }
            var bomData = Data([0xEF, 0xBB, 0xBF])
            bomData.append(contentsOf: "مرحبا".utf8)
            try bomData.write(to: bom)
            expectEqual(try FileService.readText(from: bom), "مرحبا")

            let missing = FileManager.default.temporaryDirectory.appendingPathComponent("missing-\(UUID().uuidString).txt")
            do {
                _ = try FileService.readText(from: missing)
                expect(false, "missing file should throw")
            } catch is FileServiceError {
                expect(true, "missing file throws FileServiceError")
            }

            let latin = FileManager.default.temporaryDirectory.appendingPathComponent("latin-\(UUID().uuidString).txt")
            defer { try? FileManager.default.removeItem(at: latin) }
            try Data([0xE9]).write(to: latin)
            do {
                _ = try FileService.readText(from: latin)
                expect(false, "invalid encoding should throw")
            } catch let error as FileServiceError {
                expectEqual(error, .encoding)
            }

            let mixed = "مرحبا Hello Merhaba 👋"
            expectEqual(FileService.decodeUTF8(FileService.utf8Data(from: mixed)!), mixed)
        } catch {
            failures += 1
            fputs("FAIL file I/O \(error)\n", stderr)
        }

        // 17. Undo/Redo via NSTextView
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
        expectEqual(textView.string, "Hello", "insert")
        textView.undoManager?.undo()
        expectEqual(textView.string, "", "undo")
        textView.undoManager?.redo()
        expectEqual(textView.string, "Hello", "redo")
        window.orderOut(nil)

        if failures == 0 {
            print("All Simple Notes checks passed.")
        } else {
            fputs("\(failures) check(s) failed.\n", stderr)
            exit(1)
        }
    }
}
