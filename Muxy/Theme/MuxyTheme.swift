import AppKit
import SwiftUI

enum MuxyTheme {
    @MainActor static var bg: Color { snapshot.bg }
    @MainActor static var nsBg: NSColor { snapshot.nsBg }
    @MainActor static var fg: Color { snapshot.fg }
    @MainActor static var fgMuted: Color { snapshot.fgMuted }
    @MainActor static var fgDim: Color { snapshot.fgDim }
    @MainActor static var surface: Color { snapshot.surface }
    @MainActor static var border: Color { snapshot.border }
    @MainActor static var hover: Color { snapshot.hover }

    @MainActor static var accent: Color { snapshot.accent }
    @MainActor static var accentSoft: Color { snapshot.accentSoft }
    @MainActor static var warning: Color { snapshot.warning }

    @MainActor static var diffAddFg: Color { snapshot.diffAddFg }
    @MainActor static var diffRemoveFg: Color { snapshot.diffRemoveFg }
    @MainActor static var diffHunkFg: Color { snapshot.diffHunkFg }
    @MainActor static var diffAddBg: Color { snapshot.diffAddBg }
    @MainActor static var diffRemoveBg: Color { snapshot.diffRemoveBg }
    @MainActor static var diffHunkBg: Color { snapshot.diffHunkBg }

    @MainActor static var nsDiffAdd: NSColor { snapshot.nsDiffAdd }
    @MainActor static var nsDiffRemove: NSColor { snapshot.nsDiffRemove }
    @MainActor static var nsDiffHunk: NSColor { snapshot.nsDiffHunk }
    @MainActor static var nsDiffString: NSColor { snapshot.nsDiffString }
    @MainActor static var nsDiffNumber: NSColor { snapshot.nsDiffNumber }
    @MainActor static var nsDiffComment: NSColor { snapshot.nsDiffComment }

    @MainActor static var colorScheme: ColorScheme { snapshot.colorScheme }

    @MainActor private static var cachedVersion: Int = -1
    @MainActor private static var cachedAppearance: ThemeAppearance = .light
    @MainActor private static var cachedSnapshot: Snapshot?

    @MainActor private static var snapshot: Snapshot {
        let version = GhosttyService.shared.configVersion
        let appearance = ThemeService.shared.activeAppearance()
        if let cachedSnapshot, cachedVersion == version, cachedAppearance == appearance {
            return cachedSnapshot
        }
        let newSnapshot = Snapshot(from: GhosttyService.shared, appearance: appearance)
        cachedVersion = version
        cachedAppearance = appearance
        cachedSnapshot = newSnapshot
        return newSnapshot
    }
}

extension MuxyTheme {
    struct Snapshot {
        let palette: EditorThemePalette
        let nsBg: NSColor
        let bg: Color
        let fg: Color
        let fgMuted: Color
        let fgDim: Color
        let surface: Color
        let border: Color
        let hover: Color
        let accent: Color
        let accentSoft: Color
        let warning: Color
        let diffAddFg: Color
        let diffRemoveFg: Color
        let diffHunkFg: Color
        let diffAddBg: Color
        let diffRemoveBg: Color
        let diffHunkBg: Color
        let nsDiffAdd: NSColor
        let nsDiffRemove: NSColor
        let nsDiffHunk: NSColor
        let nsDiffString: NSColor
        let nsDiffNumber: NSColor
        let nsDiffComment: NSColor
        let colorScheme: ColorScheme

        @MainActor
        init(from _service: Any, appearance: Any) {
            let palette = EditorThemePalette.active
            self.palette = palette
            self.nsBg = palette.background
            self.bg = Color(nsColor: palette.background)
            self.fg = Color(nsColor: palette.foreground)

            self.fgMuted = Color(nsColor: palette.foreground.withAlphaComponent(0.72))
            self.fgDim = Color(nsColor: palette.foreground.withAlphaComponent(0.55))
            self.surface = Color(nsColor: palette.background.withAlphaComponent(0.88))
            self.border = Color(nsColor: palette.foreground.withAlphaComponent(0.18))
            self.hover = Color(nsColor: palette.background.withAlphaComponent(0.70))
            self.accent = Color(nsColor: palette.accent)
            self.accentSoft = Color(nsColor: palette.accent.withAlphaComponent(0.1))
            self.warning = Color(nsColor: palette.paletteColor(at: 3) ?? palette.accent)

            let addColor = palette.paletteColor(at: 2) ?? palette.accent
            let removeColor = palette.paletteColor(at: 1) ?? palette.accent
            let hunkColor = palette.paletteColor(at: 6) ?? palette.accent

            self.nsDiffAdd = addColor
            self.nsDiffRemove = removeColor
            self.nsDiffHunk = hunkColor
            self.nsDiffString = addColor
            self.nsDiffNumber = palette.paletteColor(at: 3) ?? palette.foreground
            self.nsDiffComment = palette.paletteColor(at: 8) ?? palette.foreground.withAlphaComponent(0.72)

            self.diffAddFg = Color(nsColor: addColor)
            self.diffRemoveFg = Color(nsColor: removeColor)
            self.diffHunkFg = Color(nsColor: hunkColor)
            self.diffAddBg = Color(nsColor: addColor.withAlphaComponent(0.16))
            self.diffRemoveBg = Color(nsColor: removeColor.withAlphaComponent(0.16))
            self.diffHunkBg = Color(nsColor: hunkColor.withAlphaComponent(0.1))

            self.colorScheme = ThemeService.shared.activeAppearance() == .dark ? .dark : .light
        }
    }
}

// MARK: - Glass Background Colors
extension MuxyTheme {
    @MainActor
    static func glassTitlebarGradient(opacity: Double) -> [Color] {
        [
            Color(nsColor: NSColor(srgbRed: 0.13, green: 0.14, blue: 0.20, alpha: opacity)),
            Color(nsColor: NSColor(srgbRed: 0.09, green: 0.10, blue: 0.15, alpha: opacity * 0.98))
        ]
    }

    @MainActor
    static func glassSidebarBaseGradient(opacity: Double) -> [Color] {
        [
            Color(nsColor: NSColor(srgbRed: 0.09, green: 0.10, blue: 0.14, alpha: opacity * 0.80)),
            Color(nsColor: NSColor(srgbRed: 0.11, green: 0.12, blue: 0.18, alpha: opacity * 0.62))
        ]
    }

    @MainActor
    static func glassSidebarAccentGradient(opacity: Double) -> [Color] {
        [
            Color(nsColor: NSColor(srgbRed: 0.50, green: 0.42, blue: 0.92, alpha: opacity * 0.24)),
            Color.clear,
            Color(nsColor: NSColor(srgbRed: 0.28, green: 0.54, blue: 0.95, alpha: opacity * 0.14))
        ]
    }

    @MainActor
    static func glassHighlightGradient(opacity: Double) -> [Color] {
        [
            Color.white.opacity(opacity * 0.44),
            Color.white.opacity(opacity * 0.18),
            Color.clear
        ]
    }

    @MainActor
    static func glassLeftEdgeGradient(opacity: Double) -> [Color] {
        [
            Color.white.opacity(opacity * 0.20),
            Color.clear
        ]
    }

    @MainActor
    static func glassRightEdgeBrightGradient(opacity: Double) -> [Color] {
        [
            Color(nsColor: NSColor(srgbRed: 0.94, green: 0.86, blue: 1.00, alpha: opacity * 0.56)),
            Color(nsColor: NSColor(srgbRed: 0.88, green: 0.70, blue: 0.98, alpha: opacity * 0.28))
        ]
    }

    @MainActor
    static func glassRightEdgeDarkGradient(opacity: Double) -> [Color] {
        [
            Color.black.opacity(opacity * 0.52),
            Color.black.opacity(opacity * 0.24)
        ]
    }

    @MainActor
    static func glassVignetteGradient(opacity: Double) -> [Color] {
        [
            Color.black.opacity(opacity * 0.22),
            Color.clear,
            Color.black.opacity(opacity * 0.24)
        ]
    }

    @MainActor
    static func glassShadowGradient(opacity: Double) -> [Color] {
        [
            Color.clear,
            Color.black.opacity(opacity * 0.18)
        ]
    }
}
