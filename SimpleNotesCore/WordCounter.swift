import Foundation

public enum WordCounter: Sendable {
    /// Unicode-aware word count using Foundation substring enumeration.
    public static func wordCount(in string: String) -> Int {
        guard !string.isEmpty else { return 0 }

        var count = 0
        string.enumerateSubstrings(
            in: string.startIndex..<string.endIndex,
            options: [.byWords, .localized]
        ) { substring, _, _, _ in
            if let substring, !substring.isEmpty {
                count += 1
            }
        }
        return count
    }

    /// User-visible characters (Unicode extended grapheme clusters).
    public static func characterCount(in string: String) -> Int {
        string.count
    }
}
