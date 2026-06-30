import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFThemePreset")
struct DFThemePresetTests {

    @Test("custom init stores light and dark themes")
    func customInitStoresThemes() {
        var light = DFTheme.default
        light.colors.primary = .red
        var dark = DFTheme.default
        dark.colors.primary = .blue

        let preset = DFThemePreset(light: light, dark: dark)

        #expect(preset.light.colors.primary == .red)
        #expect(preset.dark.colors.primary == .blue)
    }

    @Test("slate preset light and dark primaries differ")
    func slatePresetHasTwoDistinctThemes() {
        let preset = DFThemePreset.slate
        #expect(preset.light.colors.primary != preset.dark.colors.primary)
    }

    @Test("aurora preset light and dark primaries differ")
    func auroraPresetHasTwoDistinctThemes() {
        let preset = DFThemePreset.aurora
        #expect(preset.light.colors.primary != preset.dark.colors.primary)
    }

    @Test("copper preset light and dark primaries differ")
    func copperPresetHasTwoDistinctThemes() {
        let preset = DFThemePreset.copper
        #expect(preset.light.colors.primary != preset.dark.colors.primary)
    }

    @Test("sage preset light and dark primaries differ")
    func sagePresetHasTwoDistinctThemes() {
        let preset = DFThemePreset.sage
        #expect(preset.light.colors.primary != preset.dark.colors.primary)
    }

    @Test("preset light theme matches named DFTheme static")
    func presetLightMatchesNamedStatic() {
        #expect(DFThemePreset.slate.light.radius.md == DFTheme.slateLight.radius.md)
        #expect(DFThemePreset.slate.dark.radius.md  == DFTheme.slateDark.radius.md)
    }
}
