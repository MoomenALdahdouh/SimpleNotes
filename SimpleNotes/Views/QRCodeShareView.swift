import AppKit
import SimpleNotesCore
import SwiftUI

struct QRCodeShareView: View {
    var session: DocumentSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Scan with your phone")
                .font(.title2.weight(.semibold))

            Text("Point your camera at this code, then copy or share the text into any notes app.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)

            qrPlate

            HStack(spacing: 12) {
                Button("Copy Text") {
                    copyNote()
                }
                .disabled(isBlank)
                .keyboardShortcut("c", modifiers: [.command, .shift])

                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .padding(28)
        .frame(minWidth: 480, minHeight: 560)
        .background(.windowBackground)
    }

    private var isBlank: Bool {
        _ = session.characterCount
        return session.currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ViewBuilder
    private var qrPlate: some View {
        switch QRSharePayload.prepare(session.currentText) {
        case .empty:
            placeholderPlate("Type a note first, then scan this window with your phone.")
        case .tooLong(let byteCount, let limit):
            placeholderPlate(
                "This note is too long for one QR code (\(byteCount) bytes, limit \(limit)). Shorten it, or copy the text instead."
            )
        case .ready(let payload):
            GeometryReader { geometry in
                let side = min(geometry.size.width, geometry.size.height)
                ZStack {
                    Color.white
                    if let image = QRCodeRenderer.image(from: payload, dimension: side) {
                        Image(nsImage: image)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(16)
                            .accessibilityLabel("QR code of the current note")
                    } else {
                        Text("Could not create a QR code for this note.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(24)
                    }
                }
                .frame(width: side, height: side)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(minWidth: 360, minHeight: 360)
        }
    }

    private func placeholderPlate(_ message: String) -> some View {
        ZStack {
            Color.white
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(32)
        }
        .frame(minWidth: 360, minHeight: 360)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
    }

    private func copyNote() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(session.currentText, forType: .string)
    }
}
