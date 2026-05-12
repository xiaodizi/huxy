import SwiftUI

struct StatusBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            // Left: context badge
            HStack(spacing: 6) {
                Text("[gpt-5-mini]")
                    .font(.custom("JetBrainsMono Nerd Font", size: 12).weight(.semibold))
                    .foregroundColor(Color.green)
                Text("lei.fu/c_code")
                    .font(.custom("JetBrainsMono Nerd Font", size: 12).weight(.regular))
                    .foregroundColor(MuxyTheme.fg)
            }

            Spacer()

            // Center: progress bar small
            HStack(spacing: 6) {
                ProgressView(value: 0.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(.sRGB, red: 0.2, green: 0.95, blue: 0.8, opacity: 1)))
                    .frame(width: 120)
                Text("0/200k")
                    .font(.custom("JetBrainsMono Nerd Font", size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Right: small status summary
            HStack(spacing: 10) {
                Text("CLAUDE.md | 58 rules | 2 MCPs | 3 hooks")
                    .font(.custom("JetBrainsMono Nerd Font", size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(gradient: Gradient(colors: [TerminalTheme.bgTop.opacity(0.6), TerminalTheme.bgBottom.opacity(0.6)]), startPoint: .leading, endPoint: .trailing)
                .overlay(Rectangle().stroke(Color.white.opacity(0.03), lineWidth: 1))
        )
    }
}

struct StatusBarView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarView()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
