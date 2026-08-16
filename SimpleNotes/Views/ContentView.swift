import SwiftUI

struct ContentView: View {
    var session: DocumentSession

    var body: some View {
        VStack(spacing: 0) {
            NotesEditor(session: session)
            StatusBarView(session: session)
        }
        .frame(minWidth: 600, minHeight: 400)
        .background(Color(nsColor: .textBackgroundColor))
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: session.newDocument) {
                    Label("New", systemImage: "plus")
                }
                .help("New")
                .accessibilityLabel("New document")

                Button(action: session.openDocument) {
                    Label("Open", systemImage: "folder")
                }
                .help("Open")
                .accessibilityLabel("Open file")

                Button(action: { _ = session.save() }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .help("Save")
                .accessibilityLabel("Save")

                Button(action: session.showFontPanel) {
                    Label("Font", systemImage: "textformat")
                }
                .help("Font")
                .accessibilityLabel("Choose font")

                Picker("Font Size", selection: fontSizeBinding) {
                    ForEach(sizeOptions, id: \.self) { size in
                        Text(sizeLabel(size)).tag(size)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 68)
                .help("Font Size")
                .accessibilityLabel("Font size")
            }
        }
        .toolbarRole(.editor)
        .navigationTitle(session.windowTitle)
        .onAppear {
            session.updateCounts()
            session.syncWindowChrome()
            session.focusEditor()
        }
        .onChange(of: session.isDirty) { _, _ in
            session.syncWindowChrome()
        }
        .onChange(of: session.windowTitle) { _, _ in
            session.syncWindowChrome()
        }
    }

    private var fontSizeBinding: Binding<CGFloat> {
        Binding(
            get: { session.fontSize },
            set: { session.setFontSize($0) }
        )
    }

    private var sizeOptions: [CGFloat] {
        var sizes = FontSizes.presets
        if !sizes.contains(where: { abs($0 - session.fontSize) < 0.01 }) {
            sizes.append(session.fontSize)
            sizes.sort()
        }
        return sizes
    }

    private func sizeLabel(_ size: CGFloat) -> String {
        if size.rounded() == size {
            return "\(Int(size))"
        }
        return String(format: "%.1f", size)
    }
}
