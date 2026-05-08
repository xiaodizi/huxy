import SwiftUI

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

struct WelcomeBlurView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeBlurView()
            .frame(height: 200)
    }
}
