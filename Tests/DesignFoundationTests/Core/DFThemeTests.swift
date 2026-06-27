import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFColorTokens")
struct DFColorTokensTests {

    @Test("default primary color is not clear")
    func defaultPrimaryIsNotClear() {
        let tokens = DFColorTokens.default
        #expect(tokens.primary != .clear)
    }

    @Test("tokens are mutatable")
    func tokensAreMutatable() {
        var tokens = DFColorTokens.default
        tokens.primary = .red
        #expect(tokens.primary == .red)
    }

    @Test("respectsColorScheme defaults to true")
    func respectsColorSchemeDefault() {
        #expect(DFColorTokens.default.respectsColorScheme == true)
    }
}

@Suite("DFSpacingTokens")
struct DFSpacingTokensTests {
    @Test("spacing scale is ordered sm < md < lg")
    func spacingScaleOrdered() {
        let s = DFSpacingTokens.default
        #expect(s.xs < s.sm)
        #expect(s.sm < s.md)
        #expect(s.md < s.lg)
        #expect(s.lg < s.xl)
        #expect(s.xl < s.xxl)
    }
}

@Suite("DFRadiusTokens")
struct DFRadiusTokensTests {
    @Test("none is zero, full is large")
    func radiusBounds() {
        let r = DFRadiusTokens.default
        #expect(r.none == 0)
        #expect(r.full > 100)
    }
}

@Suite("DFTypographyTokens")
struct DFTypographyTokensTests {
    @Test("display line spacing is greater than label")
    func displayGreaterLineSpacing() {
        let t = DFTypographyTokens.default
        #expect(t.display.lineSpacing >= t.label.lineSpacing)
    }
}

@Suite("DFAnimationTokens")
struct DFAnimationTokensTests {
    @Test("animation tokens are not nil")
    func animationsExist() {
        let a = DFAnimationTokens.default
        // Verify by using them — Animation has no public equality, so just ensure they exist
        let _ = a.fast
        let _ = a.default
        let _ = a.slow
    }
}

@Suite("DFComponentTokens")
struct DFComponentTokensTests {
    @Test("button tokens default to nil (inherits from global)")
    func buttonTokensDefaultNil() {
        let tokens = DFComponentTokens.default
        #expect(tokens.button.cornerRadius == nil)
        #expect(tokens.button.horizontalPadding == nil)
        #expect(tokens.button.verticalPadding == nil)
        #expect(tokens.button.labelStyle == nil)
    }

    @Test("non-nil component token overrides are preserved")
    func buttonTokenOverride() {
        var tokens = DFComponentTokens.default
        tokens.button.cornerRadius = 20
        #expect(tokens.button.cornerRadius == 20)
    }

    @Test("textfield tokens default to nil")
    func textFieldTokensDefaultNil() {
        let tokens = DFComponentTokens.default
        #expect(tokens.textField.cornerRadius == nil)
        #expect(tokens.textField.horizontalPadding == nil)
        #expect(tokens.textField.verticalPadding == nil)
        #expect(tokens.textField.inputStyle == nil)
        #expect(tokens.textField.labelStyle == nil)
    }

    @Test("card tokens default to nil")
    func cardTokensDefaultNil() {
        let tokens = DFComponentTokens.default
        #expect(tokens.card.cornerRadius == nil)
        #expect(tokens.card.padding == nil)
    }

    @Test("avatar tokens default to nil")
    func avatarTokensDefaultNil() {
        let tokens = DFComponentTokens.default
        #expect(tokens.avatar.defaultSize == nil)
        #expect(tokens.avatar.borderWidth == nil)
    }

    @Test("badge tokens default to nil")
    func badgeTokensDefaultNil() {
        let tokens = DFComponentTokens.default
        #expect(tokens.badge.cornerRadius == nil)
        #expect(tokens.badge.horizontalPadding == nil)
        #expect(tokens.badge.verticalPadding == nil)
    }

    @Test("icon tokens default to nil")
    func iconTokensDefaultNil() {
        let tokens = DFComponentTokens.default
        #expect(tokens.icon.defaultSize == nil)
    }

    @Test("component tokens are mutable")
    func componentTokensAreMutable() {
        var tokens = DFComponentTokens.default
        tokens.card.padding = 16
        #expect(tokens.card.padding == 16)
    }
}

@Suite("DFTheme")
struct DFThemeTests {

    @Test("default theme has default color tokens")
    func defaultThemeColors() {
        let theme = DFTheme.default
        #expect(theme.colors.respectsColorScheme == true)
    }

    @Test("theme mutation is independent (value semantics)")
    func themeValueSemantics() {
        var theme1 = DFTheme.default
        let theme2 = DFTheme.default
        theme1.colors.primary = .red
        // theme2 must be unaffected
        #expect(theme2.colors.primary != .red)
    }

    @Test("custom initialiser composes correctly")
    func customInit() {
        let theme = DFTheme(colors: DFColorTokens(primary: .green))
        #expect(theme.colors.primary == .green)
        // Unspecified tokens still use defaults
        #expect(theme.spacing.md == DFSpacingTokens.default.md)
    }
}
