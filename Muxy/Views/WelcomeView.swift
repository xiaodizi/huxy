import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            WelcomeBlurView()

            VStack(spacing: 0) {
                    // Welcome hero shown at top (no extra top drag bar here)
                WelcomeHeroView()
                    .frame(maxWidth: 900)
                    .padding(.top, 8)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct WelcomeBlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
