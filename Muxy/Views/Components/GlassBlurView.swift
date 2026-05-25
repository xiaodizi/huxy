import SwiftUI

struct GlassBlurView: View {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    var fallbackColor: Color = .clear
    @AppStorage("muxy.blurEnabled") private var blurEnabled = true

    var body: some View {
        Group {
            if blurEnabled {
                GlassBlurBase(material: material, blendingMode: blendingMode)
            } else {
                fallbackColor
            }
        }
    }
}

struct GlassBlurBase: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
