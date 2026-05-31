import Foundation
import os

private let logger = Logger(subsystem: "app.muxy", category: "GitCloneService")

actor GitCloneService {
    enum CloneError: LocalizedError {
        case invalidURL
        case targetDirectoryExists
        case cloneFailed(String)
        case sshKeyNotFound
        case authenticationFailed
        case cancelled

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                "Invalid Git repository URL"
            case .targetDirectoryExists:
                "Target directory already exists"
            case let .cloneFailed(reason):
                "Clone failed: \(reason)"
            case .sshKeyNotFound:
                "SSH key not found at ~/.ssh/id_rsa"
            case .authenticationFailed:
                "Authentication failed. Check credentials"
            case .cancelled:
                "Clone operation cancelled"
            }
        }
    }

    enum AuthMethod: Sendable {
        case https
        case ssh
    }

    nonisolated private let cancellationFlag = CancellationFlag()

    func clone(
        repositoryURL: String,
        targetPath: String,
        authMethod: AuthMethod,
        onProgress: @escaping @Sendable (Double, String) -> Void
    ) async throws -> String {
        // Validate URL format
        guard repositoryURL.contains("://") || repositoryURL.contains("@") else {
            throw CloneError.invalidURL
        }

        // Check target doesn't exist
        let fm = FileManager.default
        guard !fm.fileExists(atPath: targetPath) else {
            throw CloneError.targetDirectoryExists
        }

        // Create parent directory
        let parentPath = (targetPath as NSString).deletingLastPathComponent
        if !fm.fileExists(atPath: parentPath) {
            try fm.createDirectory(atPath: parentPath, withIntermediateDirectories: true)
        }

        cancellationFlag.reset()

        return try await withTaskCancellationHandler {
            var args = ["clone"]

            // Configure authentication
            switch authMethod {
            case .https:
                // Use credential helper (macOS keychain)
                args.append(contentsOf: ["-c", "credential.helper=osxkeychain"])
            case .ssh:
                // Verify SSH key exists
                let sshKeyPath = (NSHomeDirectory() as NSString).appendingPathComponent(".ssh/id_rsa")
                guard fm.fileExists(atPath: sshKeyPath) else {
                    throw CloneError.sshKeyNotFound
                }
                // SSH will use default key via ssh-agent
            }

            args.append(repositoryURL)
            args.append(targetPath)

            var progressUpdates = [String]()
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            process.arguments = args

            let pipe = Pipe()
            process.standardError = pipe
            process.standardOutput = Pipe() // Suppress stdout

            try process.run()

            // Read stderr for progress
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                progressUpdates = output.split(separator: "\n").map(String.init)
            }

            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                // Clean up partial clone
                try? fm.removeItem(atPath: targetPath)
                let reason = progressUpdates.last ?? "Unknown error"
                throw CloneError.cloneFailed(reason)
            }

            // Simulate progress callbacks from updates
            for (index, update) in progressUpdates.enumerated() {
                let progress = Double(index) / Double(max(progressUpdates.count, 1))
                onProgress(min(progress, 0.99), update)
            }
            onProgress(1.0, "Clone completed")

            return targetPath
        } onCancel: {
            cancellationFlag.cancel()
        }
    }

    func cancelCurrentClone() {
        cancellationFlag.cancel()
    }
}

private final class CancellationFlag: @unchecked Sendable {
    private var _cancelled = false
    private let lock = NSLock()

    var isCancelled: Bool {
        lock.withLock { _cancelled }
    }

    func cancel() {
        lock.withLock { _cancelled = true }
    }

    func reset() {
        lock.withLock { _cancelled = false }
    }
}

extension NSLock {
    @inlinable
    func withLock<R>(_ body: () throws -> R) rethrows -> R {
        lock()
        defer { unlock() }
        return try body()
    }
}
