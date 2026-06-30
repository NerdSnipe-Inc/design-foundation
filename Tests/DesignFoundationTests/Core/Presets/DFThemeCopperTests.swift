import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Copper")
struct DFThemeCopperTests {

    @Test("copperLight and copperDark are distinct themes")
    func copperVariantsAreDistinct() {
        #expect(DFTheme.copperLight.colors.primary != DFTheme.copperDark.colors.primary)
    }

    @Test("copperLight respectsColorScheme is false")
    func copperLightNoAdaptation() {
        #expect(DFTheme.copperLight.colors.respectsColorScheme == false)
    }

    @Test("copperDark respectsColorScheme is false")
    func copperDarkNoAdaptation() {
        #expect(DFTheme.copperDark.colors.respectsColorScheme == false)
    }

    @Test("copperLight primary is copper")
    func copperLightPrimary() {
        #expect(DFTheme.copperLight.colors.primary == Color(red: 0.769, green: 0.384, blue: 0.176))
    }

    @Test("copperDark primary is warm amber")
    func copperDarkPrimary() {
        #expect(DFTheme.copperDark.colors.primary == Color(red: 0.957, green: 0.635, blue: 0.380))
    }

    // MARK: Radius — sharper than default

    @Test("copper radius sm is 3")
    func copperRadiusSm() {
        #expect(DFTheme.copperLight.radius.sm == 3)
        #expect(DFTheme.copperDark.radius.sm  == 3)
    }

    @Test("copper radius md is 6")
    func copperRadiusMd() {
        #expect(DFTheme.copperLight.radius.md == 6)
        #expect(DFTheme.copperDark.radius.md  == 6)
    }

    @Test("copper radius lg is 10")
    func copperRadiusLg() {
        #expect(DFTheme.copperLight.radius.lg == 10)
        #expect(DFTheme.copperDark.radius.lg  == 10)
    }

    // MARK: Shadows — more defined

    @Test("copper sm shadow radius is 3")
    func copperShadowSmRadius() {
        #expect(DFTheme.copperLight.shadows.sm.radius == 3)
    }

    @Test("copper md shadow y-offset is 5")
    func copperShadowMdY() {
        #expect(DFTheme.copperLight.shadows.md.y == 5)
    }

    @Test("copper lg shadow y-offset is 10")
    func copperShadowLgY() {
        #expect(DFTheme.copperLight.shadows.lg.y == 10)
    }
}
