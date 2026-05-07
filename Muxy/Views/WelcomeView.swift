import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            WelcomeBlurView()

            VStack(spacing: 0) {
                WindowDragRepresentable()
                    .frame(height: 32)
                Spacer()
                Text("No project selected")
                    .font(.system(size: 13))
                    .foregroundStyle(MuxyTheme.fgDim)
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
