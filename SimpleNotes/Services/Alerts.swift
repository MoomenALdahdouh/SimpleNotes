import AppKit

@MainActor
enum Alerts {
    static func error(message: String, reason: String? = nil) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = message
        if let reason, !reason.isEmpty {
            alert.informativeText = reason
        }
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    static func unsupportedFileType() {
        error(message: "Unsupported file type.")
    }

    static func couldNotSave(_ error: Error) {
        self.error(message: "Could not save the file.", reason: error.localizedDescription)
    }

    static func couldNotOpen(_ error: Error) {
        self.error(message: "Could not open the file.", reason: error.localizedDescription)
    }

    static func confirmSave(documentName: String) -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Do you want to save the changes you made to “\(documentName)”?"
        alert.informativeText = "Your changes will be lost if you don’t save them."
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Don't Save")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal()
    }

    static func externalChangeConflict(filename: String) -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "“\(filename)” was modified by another application."
        alert.informativeText = "You also have unsaved changes. Which version do you want to keep?"
        alert.addButton(withTitle: "Keep My Version")
        alert.addButton(withTitle: "Load From Disk")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal()
    }

    static func fileDeletedExternally(filename: String) {
        error(
            message: "“\(filename)” is no longer available.",
            reason: "The file was moved or deleted. Save to choose a new location."
        )
    }
}
