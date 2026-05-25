import SwiftUI

enum ThemePickerMode {
    case light
    case dark
    case currentAppearance

    static var sidebar: ThemePickerMode { .currentAppearance }
}

struct ThemePicker: View {
    var mode: ThemePickerMode = .currentAppearance
    @Environment(ThemeService.self) private var themeService
    @AppStorage("muxy.windowOpacity") private var windowOpacity: Double = 0.92
    @State private var themes: [ThemePreview] = []
    @State private var currentTheme: String?

    var body: some View {
        VStack(spacing: 0) {
            windowOpacitySection
            Divider().overlay(MuxyTheme.border)

            SearchableListPicker(
                items: themes,
                filterKey: \.name,
                placeholder: "Search themes",
                emptyLabel: "No themes found",
                onSelect: { selectTheme($0) },
                row: { theme, isHighlighted in
                    ThemeRow(
                        theme: theme,
                        isActive: theme.name == currentTheme,
                        isHighlighted: isHighlighted
                    )
                }
            )
        }
        .frame(width: 300, height: 470)
        .task {
            themes = await themeService.loadThemes()
            currentTheme = currentName()
        }
    }

    private var windowOpacitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Window Transparency")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(MuxyTheme.fg)
                Spacer()
                Text("\(Int((windowOpacity * 100).rounded()))%")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(MuxyTheme.fgMuted)
            }

            Slider(
                value: Binding(
                    get: { max(0.80, min(1.0, windowOpacity)) },
                    set: { windowOpacity = max(0.80, min(1.0, $0)) }
                ),
                in: 0.80 ... 1.0,
                step: 0.01
            )

            HStack(spacing: 6) {
                opacityPresetButton("85%", value: 0.85)
                opacityPresetButton("90%", value: 0.90)
                opacityPresetButton("95%", value: 0.95)
                opacityPresetButton("100%", value: 1.0)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(MuxyTheme.bg)
    }

    private func opacityPresetButton(_ title: String, value: Double) -> some View {
        Button(title) {
            windowOpacity = value
        }
        .buttonStyle(.plain)
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(MuxyTheme.fg)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(abs(windowOpacity - value) < 0.005 ? MuxyTheme.surface : MuxyTheme.hover)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(MuxyTheme.border, lineWidth: 0.5)
        )
    }

    private func currentName() -> String? {
        isDarkMode() ? themeService.currentDarkThemeName() : themeService.currentLightThemeName()
    }

    private func isDarkMode() -> Bool {
        switch mode {
        case .light: false
        case .dark: true
        case .currentAppearance: themeService.activeAppearance() == .dark
        }
    }

    private func selectTheme(_ theme: ThemePreview) {
        currentTheme = theme.name
        if isDarkMode() {
            themeService.applyDarkTheme(theme.name)
        } else {
            themeService.applyLightTheme(theme.name)
        }
    }
}

private struct ThemeRow: View {
    let theme: ThemePreview
    let isActive: Bool
    let isHighlighted: Bool
    @State private var hovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(theme.name)
                    .font(.system(size: 11))
                    .foregroundStyle(MuxyTheme.fg)
                    .lineLimit(1)

                Spacer(minLength: 0)

                if isActive {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                }
            }

            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(nsColor: theme.background))
                    .overlay(
                        Text("Ab")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(nsColor: theme.foreground))
                    )
                    .frame(width: 24)

                ForEach(Array(theme.palette.enumerated()), id: \.offset) { _, color in
                    Rectangle().fill(Color(nsColor: color))
                }
            }
            .frame(height: 14)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(MuxyTheme.border, lineWidth: 0.5)
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isHighlighted ? MuxyTheme.surface : (hovered ? MuxyTheme.hover : .clear))
        .onHover { hovered = $0 }
    }
}
