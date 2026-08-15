import Foundation
import UniformTypeIdentifiers

public enum FileFormat: String, CaseIterable, Sendable, Equatable {
    case txt
    case markdown

    public var fileExtension: String {
        switch self {
        case .txt: return "txt"
        case .markdown: return "md"
        }
    }

    public var displayName: String {
        switch self {
        case .txt: return "TXT"
        case .markdown: return "Markdown"
        }
    }

    public var typeName: String {
        switch self {
        case .txt: return "Plain Text"
        case .markdown: return "Markdown"
        }
    }

    public var utType: UTType {
        switch self {
        case .txt:
            return .plainText
        case .markdown:
            return UTType(filenameExtension: "md") ?? .plainText
        }
    }

    public init?(url: URL) {
        self.init(pathExtension: url.pathExtension)
    }

    public init?(pathExtension: String) {
        switch pathExtension.lowercased() {
        case "txt", "text":
            self = .txt
        case "md", "markdown":
            self = .markdown
        default:
            return nil
        }
    }

    public static var supportedExtensions: Set<String> {
        ["txt", "text", "md", "markdown"]
    }

    public static func isSupported(url: URL) -> Bool {
        FileFormat(url: url) != nil
    }
}
