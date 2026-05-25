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

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard bounds.contains(point) else { return nil }

        if alwaysEnabled {
            return self
        }

        // 仅在标题栏区域接收事件
        guard point.y > bounds.height - 52 else { return nil }

        // 避免误伤红绿灯与右侧工具区（仅用于全宽拖拽层）
        if point.x < 75 { return nil }
        if point.x > bounds.width - 100 { return nil }
        return self
    }

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

        // 按住即拖动，避免“按住不松手也无法拖拽”
        window?.performDrag(with: event)
    }
}
