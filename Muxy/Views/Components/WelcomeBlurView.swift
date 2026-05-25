import SwiftUI

struct WelcomeBlurView: View {
    var body: some View {
        GlassBlurView(material: .hudWindow, blendingMode: .behindWindow)
            .allowsHitTesting(false)
    }
}

struct WelcomeBlurView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeBlurView()
            .frame(height: 200)
    }
}
