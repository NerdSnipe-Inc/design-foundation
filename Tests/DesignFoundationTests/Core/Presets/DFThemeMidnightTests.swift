import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Midnight")
struct DFThemeMidnightTests {

    @Test("midnightLight and midnightDark are distinct themes")
    func midnightVariantsAreDistinct() {
        #expect(DFTheme.midnightLight.colors.primary != DFTheme.midnightDark.colors.primary)
    }

    @Test("midnightLight respectsColorScheme is false")
    func midnightLightNoAdaptation() {
        #expect(DFTheme.midnightLight.colors.respectsColorScheme == false)
    }

    @Test("midnightDark respectsColorScheme is false")
    func midnightDarkNoAdaptation() {
        #expect(DFTheme.midnightDark.colors.respectsColorScheme == false)
    }

    @Test("midnightLight primary is deep teal")
    func midnightLightPrimary() {
        #expect(DFTheme.midnightLight.colors.primary == Color(red: 0.0, green: 0.447, blue: 0.416))
    }

    @Test("midnightDark primary is bright cyan-teal")
    func midnightDarkPrimary() {
        #expect(DFTheme.midnightDark.colors.primary == Color(red: 0.0, green: 0.898, blue: 0.831))
    }

    @Test("midnightDark background is true black (OLED)")
    func midnightDarkBackgroundIsTrueBlack() {
        #expect(DFTheme.midnightDark.colors.background == Color(red: 0.0, green: 0.0, blue: 0.0))
    }

    // MARK: Radius

    @Test("midnight radius sm is 6")
    func midnightRadiusSm() {
        #expect(DFTheme.midnightLight.radius.sm == 6)
        #expect(DFTheme.midnightDark.radius.sm  == 6)
    }

    @Test("midnight radius md is 10")
    func midnightRadiusMd() {
        #expect(DFTheme.midnightLight.radius.md == 10)
        #expect(DFTheme.midnightDark.radius.md  == 10)
    }

    @Test("midnight radius lg is 16")
    func midnightRadiusLg() {
        #expect(DFTheme.midnightLight.radius.lg == 16)
        #expect(DFTheme.midnightDark.radius.lg  == 16)
    }

    // MARK: Shadows — subtle, dark-UI-appropriate

    @Test("midnight sm shadow radius is 4")
    func midnightShadowSmRadius() {
        #expect(DFTheme.midnightLight.shadows.sm.radius == 4)
    }

    @Test("midnight lg shadow opacity is higher than sm")
    func midnightShadowLgDeeperThanSm() {
        #expect(DFTheme.midnightLight.shadows.lg.radius > DFTheme.midnightLight.shadows.sm.radius)
    }
}
