import Foundation

public enum FileServiceError: Error, Equatable, LocalizedError, Sendable {
    case encoding
    case unsupportedType
    case permissionDenied
    case notFound
    case diskFull
    case invalidFilename
    case readFailed(String)
    case writeFailed(String)

    public var errorDescription: String? {
        switch self {
        case .encoding:
            return "The file could not be read as UTF-8 text."
        case .unsupportedType:
            return "Unsupported file type."
        case .permissionDenied:
            return "Permission denied."
        case .notFound:
            return "The file could not be found."
        case .diskFull:
            return "The disk is full."
        case .invalidFilename:
            return "The file name is invalid."
        case .readFailed(let reason):
            return reason
        case .writeFailed(let reason):
            return reason
        }
    }
}

public enum FileService: Sendable {
    public static func readText(from url: URL) throws -> String {
        let data: Data
        do {
            data = try Data(contentsOf: url, options: [.mappedIfSafe])
        } catch {
            throw mapReadError(error)
        }

        guard var text = decodeUTF8(data) else {
            throw FileServiceError.encoding
        }

        if text.hasPrefix("\u{FEFF}") {
            text.removeFirst()
        }
        return text
    }

    public static func writeText(_ text: String, to url: URL) throws {
        let directory = url.deletingLastPathComponent()
        if !directory.path.isEmpty, directory.path != "/", !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                throw mapWriteError(error)
            }
        }

        guard let data = text.data(using: .utf8) else {
            throw FileServiceError.encoding
        }

        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw mapWriteError(error)
        }
    }

    public static func modificationDate(of url: URL) -> Date? {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
    }

    public static func decodeUTF8(_ data: Data) -> String? {
        String(data: data, encoding: .utf8)
    }

    public static func utf8Data(from text: String) -> Data? {
        text.data(using: .utf8)
    }

    private static func mapReadError(_ error: Error) -> FileServiceError {
        let nsError = error as NSError
        if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case NSFileReadNoPermissionError:
                return .permissionDenied
            case NSFileReadNoSuchFileError, NSFileNoSuchFileError:
                return .notFound
            case NSFileReadInvalidFileNameError:
                return .invalidFilename
            default:
                break
            }
        }
        if nsError.domain == NSPOSIXErrorDomain {
            if nsError.code == 2 { return .notFound }
            if nsError.code == 13 { return .permissionDenied }
        }
        return .readFailed(error.localizedDescription)
    }

    private static func mapWriteError(_ error: Error) -> FileServiceError {
        let nsError = error as NSError
        if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case NSFileWriteOutOfSpaceError:
                return .diskFull
            case NSFileWriteNoPermissionError:
                return .permissionDenied
            case NSFileWriteInvalidFileNameError:
                return .invalidFilename
            case NSFileNoSuchFileError:
                return .notFound
            default:
                break
            }
        }
        if nsError.domain == NSPOSIXErrorDomain {
            if nsError.code == 28 { return .diskFull }
            if nsError.code == 13 { return .permissionDenied }
        }
        return .writeFailed(error.localizedDescription)
    }
}
