import AppKit
import SimpleNotesCore

enum FontSizes {
    static let presets: [CGFloat] = [10, 11, 12, 13, 14, 15, 16, 18, 20, 24, 28, 32, 36, 48]
    static let defaultSize: CGFloat = 14
    static let minimumSize: CGFloat = 8
    static let maximumSize: CGFloat = 128

    static func clamped(_ size: CGFloat) -> CGFloat {
        min(max(size, minimumSize), maximumSize)
    }

    static func nextPreset(after size: CGFloat) -> CGFloat {
        presets.first(where: { $0 > size + 0.1 }) ?? min(size + 1, maximumSize)
    }

    static func previousPreset(before size: CGFloat) -> CGFloat {
        presets.last(where: { $0 < size - 0.1 }) ?? max(size - 1, minimumSize)
    }
}
