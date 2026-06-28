import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFCheckboxStyleConfiguration")
struct DFCheckboxStyleConfigurationTests {
    @Test("holds all values correctly")
    func holdsValues() {
        let config = DFCheckboxStyleConfiguration(
            isChecked: true,
            isEnabled: false,
            theme: .default
        )
        #expect(config.isChecked == true)
        #expect(config.isEnabled == false)
    }
}

@Suite("DFCheckbox Environment")
struct DFCheckboxEnvironmentTests {
    @Test("dfCheckboxStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfCheckboxStyle
    }
}

@Suite("DFCheckbox Styles")
struct DFCheckboxStyleTests {
    @Test("default style is Sendable")
    func defaultSendable() {
        let _: any DFCheckboxStyle & Sendable = DFDefaultCheckboxStyle()
    }

    @Test("AnyDFCheckboxStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFCheckboxStyle(DFDefaultCheckboxStyle())
        let config = DFCheckboxStyleConfiguration(isChecked: false, isEnabled: true, theme: .default)
        let _ = style.makeBody(configuration: config)
    }
}
