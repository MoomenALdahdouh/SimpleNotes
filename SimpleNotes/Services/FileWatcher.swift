import Foundation

final class FileWatcher: NSObject, NSFilePresenter {
    var presentedItemURL: URL?
    let presentedItemOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "SimpleNotes.FileWatcher"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    var onChanged: (() -> Void)?
    var onMoved: ((URL) -> Void)?
    var onDeleted: (() -> Void)?

    func start(url: URL) {
        stop()
        presentedItemURL = url
        NSFileCoordinator.addFilePresenter(self)
    }

    func stop() {
        NSFileCoordinator.removeFilePresenter(self)
        presentedItemURL = nil
    }

    func presentedItemDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.onChanged?()
        }
    }

    func presentedItemDidMove(to newURL: URL) {
        presentedItemURL = newURL
        DispatchQueue.main.async { [weak self] in
            self?.onMoved?(newURL)
        }
    }

    func accommodatePresentedItemDeletion(completionHandler: @escaping (Error?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.onDeleted?()
        }
        completionHandler(nil)
    }
}
