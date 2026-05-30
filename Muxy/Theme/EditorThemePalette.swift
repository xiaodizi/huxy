import AppKit

struct EditorThemePalette {
    let background: NSColor
    let foreground: NSColor
    let accent: NSColor
    private let paletteColors: [Int: NSColor]

    // Catppuccin Mocha palette
    static let catppuccinMochaColors: [Int: NSColor] = [
        0: NSColor(srgbRed: 0.12, green: 0.12, blue: 0.18, alpha: 1), // base (bg)
        1: NSColor(srgbRed: 0.95, green: 0.55, blue: 0.66, alpha: 1), // red
        2: NSColor(srgbRed: 0.65, green: 0.89, blue: 0.63, alpha: 1), // green
        3: NSColor(srgbRed: 0.98, green: 0.89, blue: 0.69, alpha: 1), // yellow
        4: NSColor(srgbRed: 0.54, green: 0.71, blue: 0.98, alpha: 1), // blue (accent)
        5: NSColor(srgbRed: 0.58, green: 0.65, blue: 0.97, alpha: 1), // mauve
        6: NSColor(srgbRed: 0.80, green: 0.76, blue: 0.97, alpha: 1), // lavender
        7: NSColor(srgbRed: 0.58, green: 0.89, blue: 0.84, alpha: 1), // teal
        8: NSColor(srgbRed: 0.73, green: 0.76, blue: 0.87, alpha: 1), // subtext1
        9: NSColor(srgbRed: 0.73, green: 0.76, blue: 0.87, alpha: 1), // subtext0
        10: NSColor(srgbRed: 0.36, green: 0.36, blue: 0.44, alpha: 1), // surface2
        11: NSColor(srgbRed: 0.22, green: 0.22, blue: 0.29, alpha: 1), // surface1
        12: NSColor(srgbRed: 0.19, green: 0.19, blue: 0.25, alpha: 1), // surface0
    ]

    @MainActor
    static var active: EditorThemePalette {
        let ghostty = GhosttyService.shared
        let preview = ThemeService.shared.activeThemePreview()
        return resolve(
            preview: preview,
            fallbackBackground: ghostty.backgroundColor,
            fallbackForeground: ghostty.foregroundColor,
            fallbackAccent: ghostty.accentColor,
            fallbackPaletteColor: { index in
                ghostty.paletteColor(at: index) ?? catppuccinMochaColors[index]
            }
        )
    }

    func paletteColor(at index: Int) -> NSColor? {
        paletteColors[index]
    }

    static func resolve(
        preview: ThemePreview?,
        fallbackBackground: NSColor,
        fallbackForeground: NSColor,
        fallbackAccent: NSColor,
        fallbackPaletteColor: (Int) -> NSColor?
    ) -> EditorThemePalette {
        let palette = preview?.palette ?? []
        var colors: [Int: NSColor] = [:]
        for index in 0 ..< 16 {
            if index < palette.count {
                colors[index] = palette[index]
            } else if let fallback = fallbackPaletteColor(index) {
                colors[index] = fallback
            }
        }

        let accent = palette.count > 4
            ? palette[4]
            : (fallbackPaletteColor(4) ?? fallbackAccent)

        return EditorThemePalette(
            background: preview?.background ?? fallbackBackground,
            foreground: preview?.foreground ?? fallbackForeground,
            accent: accent,
            paletteColors: colors
        )
    }
}
