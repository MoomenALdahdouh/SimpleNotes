import SwiftUI

struct StatusBarView: View {
    var session: DocumentSession

    var body: some View {
        HStack(spacing: 16) {
            Text("Words: \(session.wordCount)")
            Text("Characters: \(session.characterCount)")
            Spacer()
            Text(session.format.displayName)
        }
        .font(.system(size: 11, weight: .regular))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(session.wordCount) words, \(session.characterCount) characters, \(session.format.displayName)")
    }
}
