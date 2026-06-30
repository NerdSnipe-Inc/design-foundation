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
