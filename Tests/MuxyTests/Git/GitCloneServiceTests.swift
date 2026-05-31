import Foundation
import Testing

@Suite("GitCloneService")
struct GitCloneServiceTests {
    @Test("clone with HTTPS authentication succeeds")
    async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let targetPath = tempDir.appendingPathComponent("test-repo-\(UUID())")
        defer { try? FileManager.default.removeItem(at: targetPath) }

        let service = GitCloneService()
        var progressUpdates: [(Double, String)] = []

        let result = try await service.clone(
            repositoryURL: "https://github.com/torvalds/linux.git",
            targetPath: targetPath.path,
            authMethod: .https
        ) { progress, message in
            progressUpdates.append((progress, message))
        }

        #expect(FileManager.default.fileExists(atPath: result))
        #expect(progressUpdates.count > 0)
    }

    @Test("clone rejects invalid URL")
    async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let targetPath = tempDir.appendingPathComponent("test-repo")
        defer { try? FileManager.default.removeItem(at: targetPath) }

        let service = GitCloneService()

        await #expect(throws: GitCloneService.CloneError.self) {
            try await service.clone(
                repositoryURL: "not-a-url",
                targetPath: targetPath.path,
                authMethod: .https
            ) { _, _ in }
        }
    }

    @Test("clone fails when target directory already exists")
    async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let targetPath = tempDir.appendingPathComponent("existing-dir-\(UUID())")
        try FileManager.default.createDirectory(at: targetPath, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: targetPath) }

        let service = GitCloneService()

        await #expect(throws: GitCloneService.CloneError.self) {
            try await service.clone(
                repositoryURL: "https://github.com/torvalds/linux.git",
                targetPath: targetPath.path,
                authMethod: .https
            ) { _, _ in }
        }
    }

    @Test("clone progress callback fires during operation")
    async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let targetPath = tempDir.appendingPathComponent("test-repo-\(UUID())")
        defer { try? FileManager.default.removeItem(at: targetPath) }

        let service = GitCloneService()
        var lastProgress: Double = -1

        _ = try await service.clone(
            repositoryURL: "https://github.com/torvalds/linux.git",
            targetPath: targetPath.path,
            authMethod: .https
        ) { progress, _ in
            lastProgress = progress
        }

        #expect(lastProgress >= 0)
    }

    @Test("cancel clone operation stops execution")
    async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let targetPath = tempDir.appendingPathComponent("test-repo-cancel-\(UUID())")
        defer { try? FileManager.default.removeItem(at: targetPath) }

        let service = GitCloneService()
        var cloneCancelled = false

        let cloneTask = Task {
            do {
                _ = try await service.clone(
                    repositoryURL: "https://github.com/torvalds/linux.git",
                    targetPath: targetPath.path,
                    authMethod: .https
                ) { _, _ in }
            } catch GitCloneService.CloneError.cancelled {
                cloneCancelled = true
            } catch {
                // other errors acceptable
            }
        }

        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        service.cancelCurrentClone()

        await cloneTask.value

        #expect(cloneCancelled || !FileManager.default.fileExists(atPath: targetPath.path))
    }
}
