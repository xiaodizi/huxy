import SwiftUI

struct GlassBlurView: View {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    var fallbackColor: Color = .clear
    @AppStorage("muxy.blurEnabled") private var blurEnabled = true
    @AppStorage("muxy.blurStrength") private var blurStrength: Double = 0.5

    private var resolvedMaterial: NSVisualEffectView.Material {
        // blurStrength 范围 0.0-1.0
        // 0.0-0.33: hudWindow (最亮)
        // 0.34-0.66: fullScreenUI (中等)
        // 0.67-1.0: menu (最暗)
        if blurStrength < 0.33 {
            return .hudWindow
        } else if blurStrength < 0.67 {
            return .fullScreenUI
        } else {
            return .menu
        }
    }

    var body: some View {
        Group {
            if blurEnabled && blurStrength > 0 {
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
