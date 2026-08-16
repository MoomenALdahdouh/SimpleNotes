import AppKit
import Foundation

enum SupportLinks {
    static let koFi = URL(string: "https://ko-fi.com/moomenaldahdouh")!

    static func openKoFi() {
        NSWorkspace.shared.open(koFi)
    }
}
