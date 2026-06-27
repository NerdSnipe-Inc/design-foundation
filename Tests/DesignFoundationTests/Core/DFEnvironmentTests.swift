import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme Environment")
struct DFEnvironmentTests {

    @Test("default environment value is DFTheme.default")
    func defaultEnvironmentValue() {
        // EnvironmentValues can be instantiated directly in tests
        let values = EnvironmentValues()
        #expect(values.dfTheme.spacing.md == DFTheme.default.spacing.md)
        #expect(values.dfTheme.radius.lg == DFTheme.default.radius.lg)
    }

    @Test("environment value can be read via property")
    func environmentValueReadProperty() {
        let values = EnvironmentValues()
        let theme = values.dfTheme
        #expect(theme.spacing.md == DFTheme.default.spacing.md)
    }

    @Test("environment value can be set via property")
    func environmentValueSetProperty() {
        var values = EnvironmentValues()
        let customTheme = DFTheme(colors: DFColorTokens(primary: .purple))
        values.dfTheme = customTheme
        #expect(values.dfTheme.colors.primary == .purple)
    }

    @Test("custom theme overrides default")
    func customThemeOverridesDefault() {
        var values = EnvironmentValues()
        let customTheme = DFTheme(spacing: DFSpacingTokens(md: 50))
        values.dfTheme = customTheme
        #expect(values.dfTheme.spacing.md == 50)
        #expect(values.dfTheme.spacing.md != DFTheme.default.spacing.md)
    }
}
