import Foundation

enum GitCloneState: Sendable {
    case idle
    case cloning(progress: Double, message: String)
    case completed(path: String)
    case failed(error: String)

    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }

    var isCloning: Bool {
        if case .cloning = self { return true }
        return false
    }

    var progress: Double? {
        if case let .cloning(progress, _) = self { return progress }
        return nil
    }

    var message: String? {
        if case let .cloning(_, message) = self { return message }
        return nil
    }

    var resultPath: String? {
        if case let .completed(path) = self { return path }
        return nil
    }

    var errorMessage: String? {
        if case let .failed(error) = self { return error }
        return nil
    }
}
