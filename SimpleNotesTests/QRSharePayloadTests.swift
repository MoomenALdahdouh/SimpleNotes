import XCTest
@testable import SimpleNotesCore

final class QRSharePayloadTests: XCTestCase {
    func testEmptyAndWhitespaceAreNotEncodable() {
        XCTAssertEqual(QRSharePayload.prepare(""), .empty)
        XCTAssertEqual(QRSharePayload.prepare("   \n\t  "), .empty)
    }

    func testASCIIUsesRawUTF8WithoutBOM() {
        let status = QRSharePayload.prepare("Hello from Simple Notes")
        guard case .ready(let data) = status else {
            return XCTFail("expected ready payload")
        }
        XCTAssertFalse(data.starts(with: [0xEF, 0xBB, 0xBF]))
        XCTAssertEqual(QRSharePayload.decodedText(from: data), "Hello from Simple Notes")
    }

    func testArabicAndTurkishUseUTF8BOMSoPhonesDecodeUnicode() {
        let text = "مرحبا بالعالم Hello Merhaba Dünya"
        let status = QRSharePayload.prepare(text)
        guard case .ready(let data) = status else {
            return XCTFail("expected ready payload")
        }
        XCTAssertTrue(data.starts(with: [0xEF, 0xBB, 0xBF]))
        XCTAssertEqual(QRSharePayload.decodedText(from: data), text)
    }

    func testTooLongNotesAreRejected() {
        let text = String(repeating: "a", count: QRSharePayload.maxByteCount + 1)
        let status = QRSharePayload.prepare(text)
        guard case .tooLong(let byteCount, let limit) = status else {
            return XCTFail("expected tooLong")
        }
        XCTAssertEqual(byteCount, QRSharePayload.maxByteCount + 1)
        XCTAssertEqual(limit, QRSharePayload.maxByteCount)
    }

    func testPayloadFitsAtTheByteLimit() {
        let text = String(repeating: "a", count: QRSharePayload.maxByteCount)
        let status = QRSharePayload.prepare(text)
        guard case .ready(let data) = status else {
            return XCTFail("expected ready payload at the limit")
        }
        XCTAssertEqual(data.count, QRSharePayload.maxByteCount)
    }
}
