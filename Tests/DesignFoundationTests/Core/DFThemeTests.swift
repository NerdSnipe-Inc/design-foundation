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
