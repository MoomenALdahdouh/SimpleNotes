import XCTest
@testable import SimpleNotesCore

final class FileServiceTests: XCTestCase {
    private func tempURL(_ name: String) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(name)
    }

    func testSaveAndOpenTxtPreservesUTF8() throws {
        let url = tempURL("simple-notes-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: url) }

        let text = "Hello from Simple Notes"
        try FileService.writeText(text, to: url)
        let loaded = try FileService.readText(from: url)
        XCTAssertEqual(loaded, text)
        XCTAssertEqual(url.pathExtension, "txt")
    }

    func testSaveAndOpenMarkdownPreservesExactSource() throws {
        let url = tempURL("simple-notes-\(UUID().uuidString).md")
        defer { try? FileManager.default.removeItem(at: url) }

        let text = "# Hello\n\n**Bold**\n\n* Item\n"
        try FileService.writeText(text, to: url)
        let loaded = try FileService.readText(from: url)
        XCTAssertEqual(loaded, text)
        XCTAssertEqual(FileFormat(url: url), .markdown)
    }

    func testUTF8HasNoBOM() throws {
        let url = tempURL("simple-notes-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: url) }

        try FileService.writeText("Hello", to: url)
        let data = try Data(contentsOf: url)
        XCTAssertFalse(data.starts(with: [0xEF, 0xBB, 0xBF]))
        XCTAssertEqual(FileService.decodeUTF8(data), "Hello")
    }

    func testSaveAsChangesExtension() throws {
        let directory = FileManager.default.temporaryDirectory
        let txt = directory.appendingPathComponent("simple-notes-\(UUID().uuidString).txt")
        let md = directory.appendingPathComponent("simple-notes-\(UUID().uuidString).md")
        defer {
            try? FileManager.default.removeItem(at: txt)
            try? FileManager.default.removeItem(at: md)
        }

        let text = "# Title\ncontent"
        try FileService.writeText(text, to: txt)
        let loaded = try FileService.readText(from: txt)
        try FileService.writeText(loaded, to: md)
        XCTAssertEqual(try FileService.readText(from: md), text)
        XCTAssertEqual(FileFormat(url: md), .markdown)
    }

    func testOpenMissingFileThrows() {
        let url = tempURL("does-not-exist-\(UUID().uuidString).txt")
        XCTAssertThrowsError(try FileService.readText(from: url)) { error in
            XCTAssertTrue(error is FileServiceError)
        }
    }

    func testInvalidEncodingThrows() throws {
        let url = tempURL("latin1-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data([0xE9]).write(to: url)
        XCTAssertThrowsError(try FileService.readText(from: url)) { error in
            XCTAssertEqual(error as? FileServiceError, .encoding)
        }
    }

    func testStripsUTF8BOMOnRead() throws {
        let url = tempURL("bom-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: url) }
        var data = Data([0xEF, 0xBB, 0xBF])
        data.append(contentsOf: "مرحبا".utf8)
        try data.write(to: url)
        XCTAssertEqual(try FileService.readText(from: url), "مرحبا")
    }
}
