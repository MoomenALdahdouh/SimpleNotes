import XCTest
@testable import SimpleNotesCore

final class FilenameGeneratorTests: XCTestCase {
    func testTimestampUsesLocalDateTimeFormat() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: 2026, month: 8, day: 15, hour: 16, minute: 42, second: 31)
        let date = components.date!

        let name = FilenameGenerator.timestampName(date: date, timeZone: TimeZone(secondsFromGMT: 0)!)
        XCTAssertEqual(name, "2026-08-15_16-42-31")
    }

    func testDefaultFilenameUsesTxtExtension() {
        let name = FilenameGenerator.defaultFilename(
            format: .txt,
            date: Date(timeIntervalSince1970: 1_776_290_551),
            timeZone: TimeZone(secondsFromGMT: 0)!
        )
        XCTAssertTrue(name.hasSuffix(".txt"))
        XCTAssertTrue(name.contains("_"))
    }

    func testDefaultFilenameUsesMarkdownExtension() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 3 * 3600)!
        let date = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: 2026, month: 12, day: 1, hour: 9, minute: 15, second: 7).date!
        let name = FilenameGenerator.defaultFilename(format: .markdown, date: date, timeZone: calendar.timeZone)
        XCTAssertEqual(name, "2026-12-01_09-15-07.md")
    }

    func testNeverUsesUntitled() {
        let name = FilenameGenerator.timestampName(date: Date(), timeZone: .current)
        XCTAssertFalse(name.lowercased().contains("untitled"))
        XCTAssertFalse(name.lowercased().contains("document"))
    }
}
