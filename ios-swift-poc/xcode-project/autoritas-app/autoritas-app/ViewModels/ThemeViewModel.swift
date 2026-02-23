import Foundation
import SwiftUI

// MARK: - Default Themes (port of StitchTheme.ts)

private let stitchLightColors = ThemeColors(
    primary: "#137fec",
    background: "#ffffff",
    text: "#111827",
    secondaryText: "#9ca3af",
    accent: "#f3f4f6",
    cardBackground: "#ffffff",
    inputBackground: "#f9fafb",
    messageBubbleUser: "#137fec",
    messageBubbleAgent: "#f3f4f6"
)

private let stitchDarkColors = ThemeColors(
    primary: "#137fec",
    background: "#101922",
    text: "#FFFFFF",
    secondaryText: "#92adc9",
    accent: "#192633",
    cardBackground: "#192633",
    inputBackground: "#ffffff0d",   // rgba(255,255,255,0.05)
    messageBubbleUser: "#137fec",
    messageBubbleAgent: "#1e293b"
)

private let defaultLayout = ThemeLayout(
    borderRadius: 4,
    borderWidth: 1,
    spacingUnit: 8,
    chatPosition: "bottom",
    widgetPosition: "top"
)

private let defaultTypography = ThemeTypography(
    headingFontName: "Inter",
    headingFontUrl: "",
    bodyFontName: "Inter",
    bodyFontUrl: ""
)

private let defaultStyles = ThemeStyles(
    colors: stitchLightColors,
    layout: defaultLayout,
    typography: defaultTypography
)

let STITCH_THEME_LIGHT = GeneratedTheme(
    meta: ThemeMeta(name: "Stitch Remix", generatedAt: nil),
    styles: defaultStyles
)

let STITCH_THEME_DARK = GeneratedTheme(
    meta: ThemeMeta(name: "Stitch Remix Dark", generatedAt: nil),
    styles: ThemeStyles(colors: stitchDarkColors, layout: defaultLayout, typography: defaultTypography)
)

// MARK: - ThemeViewModel

class ThemeViewModel: ObservableObject {
    @Published var theme: GeneratedTheme = STITCH_THEME_LIGHT

    var isDark: Bool { theme.meta.name.contains("Dark") }

    func applyTheme(_ newTheme: GeneratedTheme) {
        DispatchQueue.main.async { self.theme = newTheme }
    }

    func toggleTheme() {
        applyTheme(isDark ? STITCH_THEME_LIGHT : STITCH_THEME_DARK)
    }
}

// MARK: - Hex Color extension (used throughout views)

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r, g, b, a: Double
        switch hexSanitized.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8)  / 255
            b = Double(rgb & 0x0000FF)          / 255
            a = 1.0
        case 8:
            r = Double((rgb & 0xFF000000) >> 24) / 255
            g = Double((rgb & 0x00FF0000) >> 16) / 255
            b = Double((rgb & 0x0000FF00) >> 8)  / 255
            a = Double(rgb & 0x000000FF)          / 255
        default:
            r = 0; g = 0; b = 0; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// Convenience accessors on ThemeViewModel
extension ThemeViewModel {
    var primaryColor: Color        { Color(hex: theme.styles.colors.primary) }
    var backgroundColor: Color     { Color(hex: theme.styles.colors.background) }
    var textColor: Color           { Color(hex: theme.styles.colors.text) }
    var secondaryTextColor: Color  { Color(hex: theme.styles.colors.secondaryText) }
    var accentColor: Color         { Color(hex: theme.styles.colors.accent) }
    var cardBgColor: Color         { Color(hex: theme.styles.colors.cardBackground) }
    var inputBgColor: Color        { Color(hex: theme.styles.colors.inputBackground) }
    var bubbleUserColor: Color     { Color(hex: theme.styles.colors.messageBubbleUser) }
    var bubbleAgentColor: Color    { Color(hex: theme.styles.colors.messageBubbleAgent) }
    var borderRadius: Double       { theme.styles.layout.borderRadius }
}
