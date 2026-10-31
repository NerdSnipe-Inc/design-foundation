import SwiftUI

/// A pair of light and dark themes that adapts automatically to the current color scheme.
public struct DFThemePreset: Sendable {
    public let light: DFTheme
    public let dark: DFTheme

    /// Creates a preset with explicit light and dark themes.
    public init(light: DFTheme, dark: DFTheme) {
        self.light = light
        self.dark = dark
    }

    /// Returns the light or dark theme based on the given color scheme.
    public func resolve(for colorScheme: ColorScheme) -> DFTheme {
        colorScheme == .dark ? dark : light
    }

    /// A cool blue-grey preset suitable for professional and productivity interfaces.
    public static let slate  = DFThemePreset(light: .slateLight,  dark: .slateDark)
    /// A vibrant violet preset with soft shadows, suited for creative and expressive UIs.
    public static let aurora = DFThemePreset(light: .auroraLight, dark: .auroraDark)
    /// A warm earth-tone preset with tight radii and strong shadows for a grounded feel.
    public static let copper = DFThemePreset(light: .copperLight, dark: .copperDark)
    /// A natural green preset with generous radii and subtle shadows for a calm aesthetic.
    public static let sage   = DFThemePreset(light: .sageLight,   dark: .sageDark)
    /// A bold, saturated red preset — deep garnet red (#C8102E), white cards, off-white background.
    public static let garnet = DFThemePreset(light: .garnetLight, dark: .garnetDark)
    /// A dark-mode-native teal preset with a true-black (OLED-tuned) dark variant.
    public static let midnight = DFThemePreset(light: .midnightLight, dark: .midnightDark)
    /// A soft neumorphic indigo preset — low-contrast surfaces, large radii, diffuse shadows.
    public static let neumorph = DFThemePreset(light: .neumorphLight, dark: .neumorphDark)
    /// A bold, energetic orange-red preset with tight radii and punchy shadows.
    public static let ember = DFThemePreset(light: .emberLight, dark: .emberDark)
}

public extension View {
    /// Applies a theme preset that automatically selects the light or dark variant
    /// based on the current environment color scheme.
    func dfThemePreset(_ preset: DFThemePreset) -> some View {
        modifier(DFThemePresetModifier(preset: preset))
    }
}

private struct DFThemePresetModifier: ViewModifier {
    let preset: DFThemePreset
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.dfTheme(preset.resolve(for: colorScheme))
    }
}
