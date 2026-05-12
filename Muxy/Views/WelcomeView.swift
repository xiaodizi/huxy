import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            WindowDragRepresentable()
                .frame(height: 32)
            Spacer()
            Text("No project selected")
                .font(.custom("JetBrainsMono Nerd Font", size: 13))
                .foregroundStyle(MuxyTheme.fgDim)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
