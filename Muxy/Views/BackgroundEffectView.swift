import SwiftUI

struct BackgroundEffectView<Content: View>: View {
    let content: Content
    @AppStorage("muxy.transparencyEnabled") private var transparencyEnabled = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    private var themeBackgroundIsTransparent: Bool {
        MuxyTheme.nsBg.alphaComponent < 1.0
    }

    var body: some View {
        content
            .background(VisualEffectBackground(transparent: transparencyEnabled || themeBackgroundIsTransparent))
    }
}

private struct VisualEffectBackground: NSViewRepresentable {
    let transparent: Bool

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = transparent ? .underWindowBackground : .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = transparent ? .underWindowBackground : .hudWindow
    }
}
