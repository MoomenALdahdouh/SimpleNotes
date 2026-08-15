import SwiftUI

@main
struct SimpleNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var session = DocumentSession()

    var body: some Scene {
        Window("Simple Notes", id: "main") {
            ContentView(session: session)
                .onAppear {
                    appDelegate.session = session
                    appDelegate.configureMainWindow()
                }
                .onOpenURL { url in
                    session.open(url: url)
                }
        }
        .defaultSize(width: 1000, height: 700)
        .windowResizability(.contentMinSize)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            AppCommands(session: session)
        }

        Window("About Simple Notes", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 340, height: 220)
        .windowStyle(.titleBar)
    }
}
