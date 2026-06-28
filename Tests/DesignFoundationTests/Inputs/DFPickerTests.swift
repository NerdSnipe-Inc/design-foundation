import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFPickerStyleConfiguration")
struct DFPickerStyleConfigurationTests {
    @Test("configuration holds all values")
    func configurationHoldsValues() {
        let config = DFPickerStyleConfiguration(
            label: "Color",
            content: AnyView(EmptyView()),
            isDisabled: false,
            theme: .default
        )
        #expect(config.label == "Color")
        #expect(config.isDisabled == false)
    }

    @Test("configuration with disabled state")
    func configurationDisabled() {
        let config = DFPickerStyleConfiguration(
            label: "Size",
            content: AnyView(EmptyView()),
            isDisabled: true,
            theme: .default
        )
        #expect(config.isDisabled == true)
    }
}

@Suite("DFPicker Environment")
struct DFPickerEnvironmentTests {
    @Test("dfPickerStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfPickerStyle
    }
}

@Suite("DFPicker Built-in Styles")
struct DFPickerBuiltinStyleTests {
    @Test("segmented style instantiates")
    func segmentedInstantiates() {
        let _ = DFSegmentedPickerStyle()
    }

    @Test("menu style instantiates")
    func menuInstantiates() {
        let _ = DFMenuPickerStyle()
    }

    @Test("wheel style instantiates")
    func wheelInstantiates() {
        let _ = DFWheelPickerStyle()
    }
}
