import SwiftUI

public struct DFThemePreset: Sendable {
    public let light: DFTheme
    public let dark: DFTheme

    public init(light: DFTheme, dark: DFTheme) {
        self.light = light
        self.dark = dark
    }

    public static let slate  = DFThemePreset(light: .slateLight,  dark: .slateDark)
    public static let aurora = DFThemePreset(light: .auroraLight, dark: .auroraDark)
    public static let copper = DFThemePreset(light: .copperLight, dark: .copperDark)
    public static let sage   = DFThemePreset(light: .sageLight,   dark: .sageDark)
}

public extension View {
    func dfThemePreset(_ preset: DFThemePreset) -> some View {
        modifier(DFThemePresetModifier(preset: preset))
    }
}

private struct DFThemePresetModifier: ViewModifier {
    let preset: DFThemePreset
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.dfTheme(colorScheme == .dark ? preset.dark : preset.light)
    }
}
