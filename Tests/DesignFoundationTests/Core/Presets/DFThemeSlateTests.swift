import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Slate")
struct DFThemeSlateTests {

    // MARK: Structure

    @Test("slateLight and slateDark are distinct themes")
    func slateVariantsAreDistinct() {
        #expect(DFTheme.slateLight.colors.primary != DFTheme.slateDark.colors.primary)
    }

    // MARK: Color tokens

    @Test("slateLight respectsColorScheme is false")
    func slateLightDoesNotRespectColorScheme() {
        #expect(DFTheme.slateLight.colors.respectsColorScheme == false)
    }

    @Test("slateDark respectsColorScheme is false")
    func slateDarkDoesNotRespectColorScheme() {
        #expect(DFTheme.slateDark.colors.respectsColorScheme == false)
    }

    @Test("slateLight primary is deep navy-slate")
    func slateLightPrimary() {
        #expect(DFTheme.slateLight.colors.primary == Color(red: 0.110, green: 0.239, blue: 0.353))
    }

    @Test("slateDark primary is sky blue")
    func slateDarkPrimary() {
        #expect(DFTheme.slateDark.colors.primary == Color(red: 0.392, green: 0.710, blue: 0.965))
    }

    @Test("slateLight interactive fill is deep navy")
    func slateLightInteractiveFill() {
        #expect(DFTheme.slateLight.colors.interactiveFill == Color(red: 0.118, green: 0.239, blue: 0.490))
    }

    // MARK: Contrast regression (WCAG AA)

    /// WCAG relative luminance of an sRGB channel value in 0...1.
    private static func linearize(_ c: Double) -> Double {
        c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }

    /// WCAG relative luminance for an sRGB color, given as 0...1 components.
    private static func relativeLuminance(r: Double, g: Double, b: Double) -> Double {
        0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
    }

    /// WCAG contrast ratio between two relative luminances.
    private static func contrastRatio(_ l1: Double, _ l2: Double) -> Double {
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    @Test("slateDark interactiveFill clears WCAG AA 4.5:1 against white text")
    func slateDarkInteractiveFillClearsContrastAgainstWhiteText() {
        // DFFilledButtonStyle renders white text directly on top of interactiveFill
        // in dark mode — this must stay >= 4.5:1 to remain WCAG AA compliant for
        // normal-size text. Regression guard for the fix that darkened this token
        // from Color(0.392, 0.710, 0.965) (~2.21:1) to Color(0.251, 0.456, 0.620).
        let fillLuminance = Self.relativeLuminance(r: 0.251, g: 0.456, b: 0.620)
        let whiteLuminance = Self.relativeLuminance(r: 1.0, g: 1.0, b: 1.0)
        let ratio = Self.contrastRatio(fillLuminance, whiteLuminance)
        #expect(ratio >= 4.5)
    }

    // MARK: Radius tokens

    @Test("slate radius sm is 4")
    func slateRadiusSm() {
        #expect(DFTheme.slateLight.radius.sm == 4)
        #expect(DFTheme.slateDark.radius.sm  == 4)
    }

    @Test("slate radius md is 8")
    func slateRadiusMd() {
        #expect(DFTheme.slateLight.radius.md == 8)
        #expect(DFTheme.slateDark.radius.md  == 8)
    }

    @Test("slate radius lg is 12")
    func slateRadiusLg() {
        #expect(DFTheme.slateLight.radius.lg == 12)
        #expect(DFTheme.slateDark.radius.lg  == 12)
    }

    // MARK: Shadow tokens

    @Test("slate sm shadow radius is 4")
    func slateShadowSmRadius() {
        #expect(DFTheme.slateLight.shadows.sm.radius == 4)
    }

    @Test("slate md shadow radius is 8")
    func slateShadowMdRadius() {
        #expect(DFTheme.slateLight.shadows.md.radius == 8)
    }

    @Test("slate lg shadow y-offset is 8")
    func slateShadowLgY() {
        #expect(DFTheme.slateLight.shadows.lg.y == 8)
    }
}
