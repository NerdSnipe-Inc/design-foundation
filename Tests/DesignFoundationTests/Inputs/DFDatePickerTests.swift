import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFDatePickerStyleConfiguration")
struct DFDatePickerStyleConfigurationTests {
    @Test("configuration holds all values")
    func configurationHoldsValues() {
        let config = DFDatePickerStyleConfiguration(
            label: "Birthdate",
            content: AnyView(EmptyView()),
            isDisabled: false,
            theme: .default
        )
        #expect(config.label == "Birthdate")
        #expect(config.isDisabled == false)
    }

    @Test("configuration with disabled state")
    func configurationDisabled() {
        let config = DFDatePickerStyleConfiguration(
            label: "Event Date",
            content: AnyView(EmptyView()),
            isDisabled: true,
            theme: .default
        )
        #expect(config.isDisabled == true)
    }
}

@Suite("DFDatePicker Environment")
struct DFDatePickerEnvironmentTests {
    @Test("dfDatePickerStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfDatePickerStyle
    }
}

@Suite("DFDatePicker Built-in Styles")
struct DFDatePickerBuiltinStyleTests {
    @Test("compact style instantiates")
    func compactInstantiates() {
        let _ = DFCompactDatePickerStyle()
    }

    @Test("graphical style instantiates")
    func graphicalInstantiates() {
        let _ = DFGraphicalDatePickerStyle()
    }

    @Test("wheel style instantiates")
    func wheelInstantiates() {
        let _ = DFWheelDatePickerStyle()
    }
}
