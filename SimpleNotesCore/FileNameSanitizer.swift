import Foundation

public enum FileNameSanitizer: Sendable {
    private static let knownExtensions = ["txt", "text", "md", "markdown"]

    /// Ensures the filename has exactly one correct extension for `format`.
    /// Empty names become a local timestamp. Never duplicates `.txt` / `.md`.
    public static func applyingExtension(
        filename: String,
        format: FileFormat,
        date: Date = Date(),
        timeZone: TimeZone = .current
    ) -> String {
        var base = filename.trimmingCharacters(in: .whitespacesAndNewlines)

        if base.isEmpty || isPlaceholderName(base) {
            base = FilenameGenerator.timestampName(date: date, timeZone: timeZone)
        }

        let ext = format.fileExtension
        let nsBase = base as NSString
        let existing = nsBase.pathExtension.lowercased()

        if existing == ext {
            return base
        }

        if knownExtensions.contains(existing) {
            let without = nsBase.deletingPathExtension
            let fallback = without.isEmpty
                ? FilenameGenerator.timestampName(date: date, timeZone: timeZone)
                : without
            return "\(fallback).\(ext)"
        }

        return "\(base).\(ext)"
    }

    public static func isPlaceholderName(_ name: String) -> Bool {
        let trimmed = (name as NSString).deletingPathExtension
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return trimmed == "untitled"
            || trimmed == "new document"
            || trimmed == "document"
    }
}
