import AppKit

extension NSWindow {
    func applyMuxyWindowBackground() {
        self.isOpaque = false
        self.backgroundColor = .clear
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
    }
}
