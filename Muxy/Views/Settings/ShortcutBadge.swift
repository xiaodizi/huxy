import SwiftUI

struct ShortcutBadge: View {
    let label: String
    var compact: Bool = false

    var body: some View {
        Text(label)
            .font(.custom("JetBrainsMono Nerd Font", size: compact ? 9 : 11).weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, compact ? 4 : 6)
            .padding(.vertical, compact ? 1 : 3)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.25), radius: compact ? 2 : 4, y: compact ? 1 : 2)
            .accessibilityLabel("Keyboard shortcut: \(label)")
    }
}
