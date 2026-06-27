import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFIconSource")
struct DFIconSourceTests {
    @Test("symbol source holds name")
    func symbolSourceHoldsName() {
        let source = DFIconSource.symbol("star.fill")
        if case .symbol(let name) = source {
            #expect(name == "star.fill")
        } else {
            Issue.record("Expected .symbol case")
        }
    }

    @Test("image source holds image")
    func imageSourceHoldsImage() {
        let img = Image(systemName: "star")
        let source = DFIconSource.image(img)
        if case .image = source {
            // Passes — image case exists
        } else {
            Issue.record("Expected .image case")
        }
    }
}

@Suite("DFIconStyleConfiguration")
struct DFIconStyleConfigurationTests {
    @Test("configuration holds source and size")
    func configurationHoldsValues() {
        let config = DFIconStyleConfiguration(
            source: .symbol("heart.fill"),
            size: 24,
            isDisabled: false,
            theme: .default
        )
        #expect(config.size == 24)
        #expect(config.isDisabled == false)
    }
}

@Suite("DFIcon Environment")
struct DFIconEnvironmentTests {
    @Test("dfIconStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfIconStyle
    }
}
