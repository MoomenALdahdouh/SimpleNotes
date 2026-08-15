import Foundation

public enum FilenameGenerator: Sendable {
    public static let dateFormat = "yyyy-MM-dd_HH-mm-ss"

    public static func timestampName(
        date: Date = Date(),
        timeZone: TimeZone = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }

    public static func defaultFilename(
        format: FileFormat,
        date: Date = Date(),
        timeZone: TimeZone = .current
    ) -> String {
        "\(timestampName(date: date, timeZone: timeZone)).\(format.fileExtension)"
    }
}
