import SwiftUI

struct StatusBarView: View {
    var session: DocumentSession

    var body: some View {
        HStack(spacing: 18) {
            labeledValue("Words", session.wordCount)
            labeledValue("Characters", session.characterCount)
            Spacer()
            Text(session.format.displayName)
        }
        .font(.system(size: 11))
        .monospacedDigit()
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 5)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .top) {
            Divider()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(session.wordCount) words, \(session.characterCount) characters, \(session.format.displayName)")
    }

    private func labeledValue(_ title: String, _ value: Int) -> some View {
        HStack(spacing: 4) {
            Text("\(title):")
            Text("\(value)")
        }
    }
}
