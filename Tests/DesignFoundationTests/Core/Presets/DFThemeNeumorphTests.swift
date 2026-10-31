import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Neumorph")
struct DFThemeNeumorphTests {

    @Test("neumorphLight and neumorphDark are distinct themes")
    func neumorphVariantsAreDistinct() {
        #expect(DFTheme.neumorphLight.colors.primary != DFTheme.neumorphDark.colors.primary)
    }

    @Test("neumorphLight respectsColorScheme is false")
    func neumorphLightNoAdaptation() {
        #expect(DFTheme.neumorphLight.colors.respectsColorScheme == false)
    }

    @Test("neumorphDark respectsColorScheme is false")
    func neumorphDarkNoAdaptation() {
        #expect(DFTheme.neumorphDark.colors.respectsColorScheme == false)
    }

    @Test("neumorphLight primary is indigo")
    func neumorphLightPrimary() {
        #expect(DFTheme.neumorphLight.colors.primary == Color(red: 0.400, green: 0.345, blue: 0.918))
    }

    @Test("neumorphDark primary is light indigo")
    func neumorphDarkPrimary() {
        #expect(DFTheme.neumorphDark.colors.primary == Color(red: 0.580, green: 0.510, blue: 0.976))
    }

    // MARK: Radius — large, soft

    @Test("neumorph radius sm is 10")
    func neumorphRadiusSm() {
        #expect(DFTheme.neumorphLight.radius.sm == 10)
        #expect(DFTheme.neumorphDark.radius.sm  == 10)
    }

    @Test("neumorph radius md is 16")
    func neumorphRadiusMd() {
        #expect(DFTheme.neumorphLight.radius.md == 16)
        #expect(DFTheme.neumorphDark.radius.md  == 16)
    }

    @Test("neumorph radius lg is 24")
    func neumorphRadiusLg() {
        #expect(DFTheme.neumorphLight.radius.lg == 24)
        #expect(DFTheme.neumorphDark.radius.lg  == 24)
    }

    // MARK: Shadows — large blur, low opacity (diffuse)

    @Test("neumorph sm shadow radius is 8")
    func neumorphShadowSmRadius() {
        #expect(DFTheme.neumorphLight.shadows.sm.radius == 8)
    }

    @Test("neumorph lg shadow radius is 22")
    func neumorphShadowLgRadius() {
        #expect(DFTheme.neumorphLight.shadows.lg.radius == 22)
    }
}
