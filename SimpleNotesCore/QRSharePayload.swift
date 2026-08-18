import Foundation

/// Prepares note text as a QR payload that phone cameras can decode as UTF-8.
public enum QRSharePayload: Sendable {
    public enum Status: Equatable, Sendable {
        case empty
        case ready(Data)
        case tooLong(byteCount: Int, limit: Int)
    }

    /// QR version 40, error correction M, 8-bit byte mode.
    public static let maxByteCount = 2331

    private static let utf8BOM = Data([0xEF, 0xBB, 0xBF])

    public static func prepare(_ text: String, maxByteCount: Int = maxByteCount) -> Status {
        let visible = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !visible.isEmpty else { return .empty }

        let utf8 = Data(text.utf8)
        let needsBOM = utf8.contains { $0 > 127 }

        if needsBOM, utf8.count + utf8BOM.count <= maxByteCount {
            var payload = utf8BOM
            payload.append(utf8)
            return .ready(payload)
        }

        if utf8.count <= maxByteCount {
            return .ready(utf8)
        }

        let attempted = utf8.count + (needsBOM ? utf8BOM.count : 0)
        return .tooLong(byteCount: attempted, limit: maxByteCount)
    }

    public static func decodedText(from payload: Data) -> String? {
        guard var text = String(data: payload, encoding: .utf8) else { return nil }
        if text.hasPrefix("\u{FEFF}") {
            text.removeFirst()
        }
        return text
    }
}
