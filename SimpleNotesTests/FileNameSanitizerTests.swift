import XCTest
@testable import SimpleNotesCore

final class FileNameSanitizerTests: XCTestCase {
    func testAddsTxtExtension() {
        XCTAssertEqual(FileNameSanitizer.applyingExtension(filename: "notes", format: .txt), "notes.txt")
    }

    func testAddsMarkdownExtension() {
        XCTAssertEqual(FileNameSanitizer.applyingExtension(filename: "notes", format: .markdown), "notes.md")
    }

    func testDoesNotDuplicateTxt() {
        XCTAssertEqual(FileNameSanitizer.applyingExtension(filename: "notes.txt", format: .txt), "notes.txt")
    }

    func testDoesNotDuplicateMarkdown() {
        XCTAssertEqual(FileNameSanitizer.applyingExtension(filename: "notes.md", format: .markdown), "notes.md")
    }

    func testReplacesMarkdownWithTxt() {
        XCTAssertEqual(FileNameSanitizer.applyingExtension(filename: "notes.md", format: .txt), "notes.txt")
    }

    func testReplacesTxtWithMarkdown() {
        XCTAssertEqual(FileNameSanitizer.applyingExtension(filename: "notes.txt", format: .markdown), "notes.md")
    }

    func testEmptyNameBecomesTimestamp() {
        let date = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2026, month: 8, day: 15, hour: 16, minute: 42, second: 31
        ).date!
        let name = FileNameSanitizer.applyingExtension(
            filename: "   ",
            format: .txt,
            date: date,
            timeZone: TimeZone(secondsFromGMT: 0)!
        )
        XCTAssertEqual(name, "2026-08-15_16-42-31.txt")
    }

    func testUntitledIsReplacedWithTimestamp() {
        let date = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2026, month: 8, day: 15, hour: 16, minute: 42, second: 31
        ).date!
        let name = FileNameSanitizer.applyingExtension(
            filename: "Untitled.txt",
            format: .txt,
            date: date,
            timeZone: TimeZone(secondsFromGMT: 0)!
        )
        XCTAssertEqual(name, "2026-08-15_16-42-31.txt")
    }
}
