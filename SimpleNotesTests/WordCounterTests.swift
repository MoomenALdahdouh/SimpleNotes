import XCTest
@testable import SimpleNotesCore

final class WordCounterTests: XCTestCase {
    func testEmptyDocument() {
        XCTAssertEqual(WordCounter.wordCount(in: ""), 0)
        XCTAssertEqual(WordCounter.characterCount(in: ""), 0)
    }

    func testEnglishWords() {
        XCTAssertEqual(WordCounter.wordCount(in: "Hello World"), 2)
        XCTAssertEqual(WordCounter.characterCount(in: "Hello World"), 11)
    }

    func testArabicWords() {
        let text = "مرحبا بالعالم"
        XCTAssertEqual(WordCounter.wordCount(in: text), 2)
        XCTAssertEqual(WordCounter.characterCount(in: text), 13)
    }

    func testMixedArabicEnglish() {
        XCTAssertEqual(WordCounter.wordCount(in: "مرحبا بالعالم Hello World"), 4)
    }

    func testTurkishWordsAndCharacters() {
        XCTAssertEqual(WordCounter.wordCount(in: "Merhaba Dünya"), 2)
        XCTAssertEqual(WordCounter.characterCount(in: "şğıİöüç"), 7)
    }

    func testMixedSentenceFromSpec() {
        XCTAssertEqual(WordCounter.wordCount(in: "مرحبا بالعالم Hello World Merhaba Dünya"), 6)
    }

    func testEmojiIsOneCharacter() {
        XCTAssertEqual(WordCounter.characterCount(in: "👋"), 1)
        XCTAssertEqual(WordCounter.characterCount(in: "Hello 👋"), 7)
    }

    func testPunctuationDoesNotInflateWordCount() {
        XCTAssertEqual(WordCounter.wordCount(in: "Hello, world!"), 2)
    }
}
