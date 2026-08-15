import XCTest
@testable import SimpleNotesCore

final class EncodingTests: XCTestCase {
    func testArabicRoundTrip() throws {
        try roundTrip("مرحبا بالعالم")
    }

    func testEnglishRoundTrip() throws {
        try roundTrip("Hello World")
    }

    func testTurkishCharactersRoundTrip() throws {
        try roundTrip("şğıİöüç ŞĞIİÖÜÇ Merhaba Dünya")
    }

    func testMixedArabicEnglishTurkishRoundTrip() throws {
        try roundTrip("مرحبا بالعالم Hello World Merhaba Dünya")
    }

    func testEmojiRoundTrip() throws {
        try roundTrip("Notes 👋📝🌍")
    }

    func testUnicodePunctuationRoundTrip() throws {
        try roundTrip("«سلام» — “hello” …")
    }

    func testUTF8DataMatchesString() {
        let text = "مرحبا Hello Merhaba 👋"
        let data = FileService.utf8Data(from: text)
        XCTAssertNotNil(data)
        XCTAssertEqual(FileService.decodeUTF8(data!), text)
    }

    private func roundTrip(_ text: String) throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("encoding-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: url) }
        try FileService.writeText(text, to: url)
        XCTAssertEqual(try FileService.readText(from: url), text)
    }
}
