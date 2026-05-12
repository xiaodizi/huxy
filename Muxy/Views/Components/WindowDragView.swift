import AppKit
import SwiftUI

struct WindowDragRepresentable: NSViewRepresentable {
    var alwaysEnabled: Bool = false

    func makeNSView(context: Context) -> WindowDragView {
        let view = WindowDragView()
        view.alwaysEnabled = alwaysEnabled
        return view
    }

    func updateNSView(_ nsView: WindowDragView, context: Context) {
        nsView.alwaysEnabled = alwaysEnabled
    }
}

final class WindowDragView: NSView {
    var alwaysEnabled = false

    override var acceptsFirstResponder: Bool { false }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { false }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            let action = UserDefaults.standard.string(forKey: "AppleActionOnDoubleClick") ?? "Maximize"
            switch action {
            case "Minimize":
                window?.miniaturize(nil)
            default:
                window?.zoom(nil)
            }
            return
        }
        let threshold = NSEvent.doubleClickInterval
        guard let next = window?.nextEvent(
            matching: [.leftMouseUp, .leftMouseDown, .leftMouseDragged],
            until: Date(timeIntervalSinceNow: threshold),
            inMode: .eventTracking,
            dequeue: true
        )
        else {
            window?.performDrag(with: event)
            return
        }
        if next.type == .leftMouseDragged {
            window?.performDrag(with: event)
        } else if next.type == .leftMouseDown {
            mouseDown(with: next)
        }
    }
}
