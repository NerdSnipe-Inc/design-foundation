import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Sage")
struct DFThemeSageTests {

    @Test("sageLight and sageDark are distinct themes")
    func sageVariantsAreDistinct() {
        #expect(DFTheme.sageLight.colors.primary != DFTheme.sageDark.colors.primary)
    }

    @Test("sageLight respectsColorScheme is false")
    func sageLightNoAdaptation() {
        #expect(DFTheme.sageLight.colors.respectsColorScheme == false)
    }

    @Test("sageDark respectsColorScheme is false")
    func sageDarkNoAdaptation() {
        #expect(DFTheme.sageDark.colors.respectsColorScheme == false)
    }

    @Test("sageLight primary is deep sage green")
    func sageLightPrimary() {
        #expect(DFTheme.sageLight.colors.primary == Color(red: 0.176, green: 0.416, blue: 0.310))
    }

    @Test("sageDark primary is mint green")
    func sageDarkPrimary() {
        #expect(DFTheme.sageDark.colors.primary == Color(red: 0.455, green: 0.776, blue: 0.616))
    }

    // MARK: Radius — most rounded

    @Test("sage radius sm is 6")
    func sageRadiusSm() {
        #expect(DFTheme.sageLight.radius.sm == 6)
        #expect(DFTheme.sageDark.radius.sm  == 6)
    }

    @Test("sage radius md is 12")
    func sageRadiusMd() {
        #expect(DFTheme.sageLight.radius.md == 12)
        #expect(DFTheme.sageDark.radius.md  == 12)
    }

    @Test("sage radius lg is 18")
    func sageRadiusLg() {
        #expect(DFTheme.sageLight.radius.lg == 18)
        #expect(DFTheme.sageDark.radius.lg  == 18)
    }

    // MARK: Shadows — very soft

    @Test("sage sm shadow radius is 8")
    func sageShadowSmRadius() {
        #expect(DFTheme.sageLight.shadows.sm.radius == 8)
    }

    @Test("sage md shadow radius is 16")
    func sageShadowMdRadius() {
        #expect(DFTheme.sageLight.shadows.md.radius == 16)
    }

    @Test("sage lg shadow y-offset is 5")
    func sageShadowLgY() {
        #expect(DFTheme.sageLight.shadows.lg.y == 5)
    }
}
