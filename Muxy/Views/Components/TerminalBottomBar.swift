import SwiftUI

struct TerminalBottomBar: View {
    var context: String = "lei.fu/c_code"
    var modelName: String = "gpt-5-mini"
    var tokenUsage: String = "0/200k"

    var body: some View {
        ZStack {
            // translucent blurred background
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .cornerRadius(6)

            HStack(alignment: .center, spacing: 12) {
                HStack(spacing: 8) {
                    Text("[\(modelName)]")
                        .font(.custom("JetBrainsMono Nerd Font", size: 12).weight(.semibold))
                        .foregroundColor(TerminalTheme.accentGreen)
                    Text(context)
                        .font(.custom("JetBrainsMono Nerd Font", size: 12))
                        .foregroundColor(MuxyTheme.fg)
                }

                Spacer()

                // center token bar
                HStack(spacing: 8) {
                    Capsule()
                        .fill(Color.black.opacity(0.35))
                        .frame(width: 260, height: 8)
                        .overlay(
                            Capsule().fill(TerminalTheme.accentGreen)
                                .frame(width: 6, height: 8)
                                .offset(x: -100)
                        )
                    Text(tokenUsage)
                        .font(.custom("JetBrainsMono Nerd Font", size: 12))
                        .foregroundColor(TerminalTheme.muted)
                }

                Spacer()

                Text("CLAUDE.md | 58 rules | 2 MCPs | 3 hooks")
                    .font(.custom("JetBrainsMono Nerd Font", size: 12))
                    .foregroundColor(TerminalTheme.muted)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
        .frame(height: 48)
        .padding(.horizontal, 8)
    }
}

struct TerminalBottomBar_Previews: PreviewProvider {
    static var previews: some View {
        TerminalBottomBar()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
