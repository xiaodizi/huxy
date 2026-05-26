import SwiftUI

struct GlassBlurView: View {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    var fallbackColor: Color = .clear
    @AppStorage("muxy.blurEnabled") private var blurEnabled = true
    @AppStorage("muxy.blurStrength") private var blurStrength = "medium"

    private var resolvedMaterial: NSVisualEffectView.Material {
        switch blurStrength {
        case "light":
            return .hudWindow
        case "strong":
            return .menu
        default:
            return .fullScreenUI
        }
    }

    var body: some View {
        Group {
            if blurEnabled {
                GlassBlurBase(material: resolvedMaterial, blendingMode: blendingMode)
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
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
