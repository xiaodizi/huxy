import SwiftUI

// Prototype Welcome hero panel styled like a terminal dashboard
struct WelcomeHeroView: View {
    var body: some View {
        HStack(spacing: 20) {
            // Left hero
            VStack(spacing: 16) {
                HStack {
                    Text("Claude Code")
                        .font(.custom("JetBrainsMono Nerd Font", size: 20).weight(.semibold))
                        .foregroundColor(.orange)
                    Spacer()
                    Text("v2.1.133")
                        .font(.custom("JetBrainsMono Nerd Font", size: 12).weight(.regular))
                        .foregroundColor(.gray)
                }

                Text("Welcome back!")
                    .font(.custom("JetBrainsMono Nerd Font", size: 28).weight(.bold))
                     .foregroundColor(Color.white.opacity(0.94))

                // simple pixel-art-like placeholder
                Image(systemName: "character.text.quote")
                    .resizable()
                    .frame(width: 64, height: 48)
                    .foregroundColor(TerminalTheme.orange)

                Text("gpt-5-mini with medium effort · API Usage Billing")
                    .font(.custom("JetBrainsMono Nerd Font", size: 12).weight(.regular))
                    .foregroundColor(TerminalTheme.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right tips column
            VStack(alignment: .leading, spacing: 8) {
                Text("Tips for getting started")
                    .font(.custom("JetBrainsMono Nerd Font", size: 18).weight(.bold))
                    .foregroundColor(TerminalTheme.orange)

                Rectangle()
                    .fill(TerminalTheme.orange)
                    .frame(height: 1)
                    .opacity(0.9)

                Text("Run /init to create a CLAUDE.md file with instructions for Claude")
                    .font(.custom("JetBrainsMono Nerd Font", size: 12).weight(.regular))
                    .foregroundColor(TerminalTheme.muted)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
         .padding(26)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(TerminalTheme.panelBg)
                .background(RoundedRectangle(cornerRadius: 8).stroke(TerminalTheme.orange, lineWidth: 2))
        )
        .padding(.horizontal, 12)
    }
}

struct WelcomeHeroView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeHeroView()
            .preferredColorScheme(.dark)
            .frame(height: 220)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.06, green: 0.06, blue: 0.08, opacity: 1), Color(.sRGB, red: 0.08, green: 0.06, blue: 0.1, opacity: 1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}
