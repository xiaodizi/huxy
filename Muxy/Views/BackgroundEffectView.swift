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
            .background(
                GlassBlurView(
                    material: (transparencyEnabled || themeBackgroundIsTransparent) ? .underWindowBackground : .hudWindow,
                    blendingMode: .behindWindow
                )
                .allowsHitTesting(false)
            )
            .overlay(
                // subtle gradient overlay and vignette to match screenshot
                LinearGradient(gradient: Gradient(colors: [TerminalTheme.bgTop.opacity(0.18), TerminalTheme.bgBottom.opacity(0.18)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .blendMode(.overlay)
            )
    }
}
