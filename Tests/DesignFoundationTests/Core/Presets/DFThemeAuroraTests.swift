import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Aurora")
struct DFThemeAuroraTests {

    @Test("auroraLight and auroraDark are distinct themes")
    func auroraVariantsAreDistinct() {
        #expect(DFTheme.auroraLight.colors.primary != DFTheme.auroraDark.colors.primary)
    }

    @Test("auroraLight respectsColorScheme is false")
    func auroraLightNoAdaptation() {
        #expect(DFTheme.auroraLight.colors.respectsColorScheme == false)
    }

    @Test("auroraDark respectsColorScheme is false")
    func auroraDarkNoAdaptation() {
        #expect(DFTheme.auroraDark.colors.respectsColorScheme == false)
    }

    @Test("auroraLight primary is electric violet")
    func auroraLightPrimary() {
        #expect(DFTheme.auroraLight.colors.primary == Color(red: 0.424, green: 0.278, blue: 1.0))
    }

    @Test("auroraDark primary is soft violet")
    func auroraDarkPrimary() {
        #expect(DFTheme.auroraDark.colors.primary == Color(red: 0.655, green: 0.545, blue: 0.980))
    }

    // MARK: Radius — more rounded than default

    @Test("aurora radius sm is 4")
    func auroraRadiusSm() {
        #expect(DFTheme.auroraLight.radius.sm == 4)
    }

    @Test("aurora radius md is 10")
    func auroraRadiusMd() {
        #expect(DFTheme.auroraLight.radius.md == 10)
        #expect(DFTheme.auroraDark.radius.md  == 10)
    }

    @Test("aurora radius lg is 16")
    func auroraRadiusLg() {
        #expect(DFTheme.auroraLight.radius.lg == 16)
        #expect(DFTheme.auroraDark.radius.lg  == 16)
    }

    // MARK: Shadows — soft

    @Test("aurora sm shadow radius is 6")
    func auroraShadowSmRadius() {
        #expect(DFTheme.auroraLight.shadows.sm.radius == 6)
    }

    @Test("aurora md shadow radius is 12")
    func auroraShadowMdRadius() {
        #expect(DFTheme.auroraLight.shadows.md.radius == 12)
    }

    @Test("aurora lg shadow y-offset is 6")
    func auroraShadowLgY() {
        #expect(DFTheme.auroraLight.shadows.lg.y == 6)
    }
}
