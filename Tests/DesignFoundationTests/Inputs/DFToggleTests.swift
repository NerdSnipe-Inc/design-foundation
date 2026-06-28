import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFToggleStyleConfiguration")
struct DFToggleStyleConfigurationTests {
    @Test("configuration is Sendable")
    func configurationIsSendable() {
        // If this compiles, DFToggleStyleConfiguration: Sendable
        func requiresSendable<T: Sendable>(_: T) {}
        @State var isOn = true
        let config = DFToggleStyleConfiguration(
            label: "Enable notifications",
            isOn: .constant(true),
            isDisabled: false,
            theme: .default
        )
        requiresSendable(config)
        #expect(config.label == "Enable notifications")
        #expect(config.isOn.wrappedValue == true)
        #expect(config.isDisabled == false)
    }

    @Test("configuration with disabled state")
    func configurationDisabled() {
        let config = DFToggleStyleConfiguration(
            label: "Off",
            isOn: .constant(false),
            isDisabled: true,
            theme: .default
        )
        #expect(config.isDisabled == true)
        #expect(config.isOn.wrappedValue == false)
    }
}

@Suite("DFToggle Environment")
struct DFToggleEnvironmentTests {
    @Test("dfToggleStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfToggleStyle
    }
}

@Suite("DFToggle Built-in Styles")
struct DFToggleBuiltinStyleTests {
    @Test("switch style instantiates")
    func switchStyleInstantiates() {
        let _ = DFSwitchToggleStyle()
    }

    @Test("checkbox style instantiates")
    func checkboxStyleInstantiates() {
        let _ = DFCheckboxToggleStyle()
    }
}
