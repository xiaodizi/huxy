import SwiftUI

/// Preview-only mockup that reproduces the terminal-dashboard visual for screenshots.
/// This file is preview-only and does not change app layout or runtime behavior.
struct TerminalThemeMockup: View {
    var body: some View {
        ZStack {
            // background gradient
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.06, green: 0.06, blue: 0.08), Color(red: 0.09, green: 0.07, blue: 0.10)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            // subtle vignette / texture
            Rectangle()
                .fill(Color.black.opacity(0.12))
                .blendMode(.overlay)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Top traffic lights only (simulate native window controls)
                HStack {
                    HStack(spacing: 8) {
                        Circle().fill(Color.red).frame(width: 12, height: 12)
                        Circle().fill(Color.yellow).frame(width: 12, height: 12)
                        Circle().fill(Color.green).frame(width: 12, height: 12)
                    }
                    .padding(.leading, 12)

                    Spacer()
                }
                .frame(height: 28)

                Spacer()

                // Hero card
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Claude Code")
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color.orange)
                            Spacer()
                            Text("v2.1.133")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color.gray)
                        }

                        Text("Welcome back!")
                            .font(.system(size: 26, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.95))

                        Image(systemName: "terminal.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 42)
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.3))

                        Text("gpt-5-mini with medium effort · API Usage Billing")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tips for getting started")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.orange)

                        Rectangle().fill(Color.orange).frame(height: 1).opacity(0.9)

                        Text("Run /init to create a CLAUDE.md file with instructions for Claude")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.gray)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.25))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.orange, lineWidth: 2))
                )
                .padding(.horizontal, 24)

                Spacer()

                // Main terminal-like area (empty text block)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.05))
                    .frame(height: 220)
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Text("/tech-content-collector:collect ai tutorials --format markdown")
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundColor(Color.white.opacity(0.9))
                                Spacer()
                            }
                            .padding(.horizontal, 18)
                            .padding(.bottom, 12)
                        }
                    )
                    .padding(.horizontal, 12)

                // Bottom command & status area
                VStack(spacing: 8) {
                    // separator
                    Rectangle().fill(Color.white.opacity(0.03)).frame(height: 1)

                    HStack(alignment: .center) {
                        Text("[gpt-5-mini]")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(red: 0.2, green: 0.95, blue: 0.8))

                        Text("lei.fu/c_code")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.9))

                        Spacer()

                        // token bar mock
                        HStack(spacing: 8) {
                            Capsule().fill(Color.black.opacity(0.5)).frame(width: 260, height: 8)
                                .overlay(Capsule().fill(Color(red: 0.2, green: 0.95, blue: 0.8)).frame(width: 24, height: 8).offset(x: -100))
                            Text("0/200k")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color.gray)
                        }

                        Spacer()

                        Text("CLAUDE.md  |  58 rules  |  2 MCPs  |  3 hooks")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.gray)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                }
                .background(Color.black.opacity(0.18))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
    }
}

struct TerminalThemeMockup_Previews: PreviewProvider {
    static var previews: some View {
        TerminalThemeMockup()
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 1400, height: 520))
    }
}
