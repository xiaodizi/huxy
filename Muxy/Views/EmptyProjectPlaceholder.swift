import SwiftUI

struct EmptyProjectPlaceholder: View {
    let project: Project
    let onCreateTab: () -> Void

    var body: some View {
        ZStack {
            WelcomeBlurView()

            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "macwindow.badge.plus")
                    .font(.custom("JetBrainsMono Nerd Font", size: 28))
                    .foregroundStyle(MuxyTheme.fgMuted)
                Text("No tabs in \(project.name)")
                    .font(.custom("JetBrainsMono Nerd Font", size: 14).weight(.semibold))
                    .foregroundStyle(MuxyTheme.fg)
                Text("Open a new terminal tab to start working in this project.")
                    .font(.custom("JetBrainsMono Nerd Font", size: 12))
                    .foregroundStyle(MuxyTheme.fgMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
                Button(action: onCreateTab) {
                    HStack(spacing: 8) {
                        Text("New Tab")
                        Text(KeyBindingStore.shared.combo(for: .newTab).displayString)
                            .font(.custom("JetBrainsMono Nerd Font", size: 11).weight(.medium))
                            .opacity(0.72)
                    }
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
