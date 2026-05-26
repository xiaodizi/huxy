import SwiftUI

struct GlassBlurView: View {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    var fallbackColor: Color = .clear
    @AppStorage("muxy.blurEnabled") private var blurEnabled = true
    @AppStorage("muxy.blurStrength") private var blurStrength: Double = 0.5

    var body: some View {
        Group {
            if blurEnabled && blurStrength > 0 {
                GlassBlurBase(material: material, blendingMode: blendingMode, strength: blurStrength)
            } else {
                fallbackColor
            }
        }
    }
}

struct GlassBlurBase: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let strength: Double

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.isEmphasized = true
        view.alphaValue = strength
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.alphaValue = strength
    }
}
