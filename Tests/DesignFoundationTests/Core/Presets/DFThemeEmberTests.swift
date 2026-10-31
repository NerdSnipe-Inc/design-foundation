import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Ember")
struct DFThemeEmberTests {

    @Test("emberLight and emberDark are distinct themes")
    func emberVariantsAreDistinct() {
        #expect(DFTheme.emberLight.colors.primary != DFTheme.emberDark.colors.primary)
    }

    @Test("emberLight respectsColorScheme is false")
    func emberLightNoAdaptation() {
        #expect(DFTheme.emberLight.colors.respectsColorScheme == false)
    }

    @Test("emberDark respectsColorScheme is false")
    func emberDarkNoAdaptation() {
        #expect(DFTheme.emberDark.colors.respectsColorScheme == false)
    }

    @Test("emberLight primary is orange-red")
    func emberLightPrimary() {
        #expect(DFTheme.emberLight.colors.primary == Color(red: 0.918, green: 0.267, blue: 0.102))
    }

    @Test("emberDark primary is bright orange")
    func emberDarkPrimary() {
        #expect(DFTheme.emberDark.colors.primary == Color(red: 1.0, green: 0.447, blue: 0.267))
    }

    // MARK: Radius — sharp, angular

    @Test("ember radius sm is 2")
    func emberRadiusSm() {
        #expect(DFTheme.emberLight.radius.sm == 2)
        #expect(DFTheme.emberDark.radius.sm  == 2)
    }

    @Test("ember radius md is 4")
    func emberRadiusMd() {
        #expect(DFTheme.emberLight.radius.md == 4)
        #expect(DFTheme.emberDark.radius.md  == 4)
    }

    @Test("ember radius lg is 8")
    func emberRadiusLg() {
        #expect(DFTheme.emberLight.radius.lg == 8)
        #expect(DFTheme.emberDark.radius.lg  == 8)
    }

    // MARK: Shadows — punchy

    @Test("ember sm shadow radius is 3")
    func emberShadowSmRadius() {
        #expect(DFTheme.emberLight.shadows.sm.radius == 3)
    }

    @Test("ember lg shadow y-offset is 8")
    func emberShadowLgY() {
        #expect(DFTheme.emberLight.shadows.lg.y == 8)
    }
}
