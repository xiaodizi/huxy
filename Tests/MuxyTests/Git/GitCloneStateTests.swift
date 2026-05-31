import Foundation
import Testing

@Suite("GitCloneState")
struct GitCloneStateTests {
    @Test("idle state is default")
    func idleStateDefault() {
        let state = GitCloneState.idle
        #expect(state.isIdle)
        #expect(!state.isCloning)
    }

    @Test("cloning state tracks progress")
    func cloningState() {
        let state = GitCloneState.cloning(progress: 0.5, message: "Downloading objects...")
        #expect(!state.isIdle)
        #expect(state.isCloning)
        #expect(state.progress == 0.5)
        #expect(state.message == "Downloading objects...")
    }

    @Test("completed state stores result path")
    func completedState() {
        let path = "/tmp/repo"
        let state = GitCloneState.completed(path: path)
        #expect(!state.isIdle)
        #expect(!state.isCloning)
        #expect(state.resultPath == path)
    }

    @Test("failed state stores error")
    func failedState() {
        let error = "Network timeout"
        let state = GitCloneState.failed(error: error)
        #expect(!state.isIdle)
        #expect(!state.isCloning)
        #expect(state.errorMessage == error)
    }

    @Test("GitCloneState is Sendable")
    func sendableState() {
        let state: GitCloneState = .cloning(progress: 0.75, message: "test")
        func checkSendable<T: Sendable>(_: T) {}
        checkSendable(state)
    }
}
