import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFSecureFieldStyleConfiguration")
struct DFSecureFieldStyleConfigurationTests {
    @Test("configuration holds all values")
    func configurationHoldsValues() {
        let theme = DFTheme.default
        var toggleCalled = false
        let config = DFSecureFieldStyleConfiguration(
            label: "Password",
            placeholder: "••••••••",
            fieldContent: AnyView(EmptyView()),
            isRevealed: false,
            onToggleReveal: { toggleCalled = true },
            isFocused: false,
            isDisabled: false,
            validationState: .none,
            theme: theme
        )
        #expect(config.label == "Password")
        #expect(config.isRevealed == false)
        #expect(config.isDisabled == false)
        config.onToggleReveal()
        #expect(toggleCalled == true)
    }
}

@Suite("DFSecureField Environment")
struct DFSecureFieldEnvironmentTests {
    @Test("dfSecureFieldStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfSecureFieldStyle
    }
}

@Suite("DFSecureField Built-in Styles")
struct DFSecureFieldBuiltinStyleTests {
    @Test("outlined secure style instantiates")
    func outlinedInstantiates() {
        let _ = DFOutlinedSecureFieldStyle()
    }

    @Test("filled secure style instantiates")
    func filledInstantiates() {
        let _ = DFFilledSecureFieldStyle()
    }
}
