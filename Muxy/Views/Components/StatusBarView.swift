import SwiftUI

struct StatusBarView: View {
    var body: some View {
        HStack(spacing: 0) {
            // Left: context badge
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("[gpt-5-mini]")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.green)
                }

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 12)

                Text("lei.fu/c_code")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color(white: 0.6))
            }

            Spacer()

            // Center: progress bar
            HStack(spacing: 8) {
                ProgressView(value: 0.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(white: 0.35)))
                    .frame(width: 100)
                Text("0/200k")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color(white: 0.45))
            }

            Spacer()

            // Right: status info
            HStack(spacing: 6) {
                Label("CLAUDE.md", systemImage: "doc.text")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color(white: 0.5))

                Text("·")
                    .foregroundStyle(Color(white: 0.3))

                Label("58 rules", systemImage: "list.bullet")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color(white: 0.5))

                Text("·")
                    .foregroundStyle(Color(white: 0.3))

                Label("2 MCPs", systemImage: "puzzlepiece.extension")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color(white: 0.5))

                Text("·")
                    .foregroundStyle(Color(white: 0.3))

                Label("3 hooks", systemImage: "link")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color(white: 0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color(white: 0.12), Color(white: 0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.03))
                .frame(height: 1)
        }
    }
}

struct StatusBarView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarView()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
