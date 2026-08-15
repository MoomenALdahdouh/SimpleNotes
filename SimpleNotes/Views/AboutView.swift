import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)

            Text("Simple Notes")
                .font(.title2.weight(.semibold))

            Text("Version 1.0")
                .foregroundStyle(.secondary)

            Text("A simple native text editor for macOS.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 28)
        .frame(width: 340)
        .background(.windowBackground)
    }
}
