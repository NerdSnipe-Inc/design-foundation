import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFValidationState")
struct DFValidationStateTests {
    @Test("none case is distinct")
    func noneCaseExists() {
        let state = DFValidationState.none
        if case .none = state { } else { Issue.record("Expected .none") }
    }

    @Test("error case holds message")
    func errorCaseHoldsMessage() {
        let state = DFValidationState.error("Required field")
        if case .error(let msg) = state {
            #expect(msg == "Required field")
        } else {
            Issue.record("Expected .error")
        }
    }

    @Test("valid case is distinct")
    func validCaseExists() {
        let state = DFValidationState.valid
        if case .valid = state { } else { Issue.record("Expected .valid") }
    }
}

@Suite("DFTextFieldStyleConfiguration")
struct DFTextFieldStyleConfigurationTests {
    @Test("configuration holds all values")
    func configurationHoldsValues() {
        let theme = DFTheme.default
        let config = DFTextFieldStyleConfiguration(
            label: "Email",
            placeholder: "you@example.com",
            fieldContent: AnyView(EmptyView()),
            leadingContent: nil,
            trailingContent: nil,
            isFocused: true,
            isDisabled: false,
            validationState: .error("Invalid email"),
            theme: theme
        )
        #expect(config.label == "Email")
        #expect(config.placeholder == "you@example.com")
        #expect(config.isFocused == true)
        #expect(config.isDisabled == false)
        if case .error(let msg) = config.validationState {
            #expect(msg == "Invalid email")
        } else {
            Issue.record("Expected .error validation state")
        }
    }

    @Test("configuration with valid state")
    func configurationValidState() {
        let config = DFTextFieldStyleConfiguration(
            label: "Name",
            placeholder: "",
            fieldContent: AnyView(EmptyView()),
            leadingContent: nil,
            trailingContent: nil,
            isFocused: false,
            isDisabled: false,
            validationState: .valid,
            theme: .default
        )
        if case .valid = config.validationState { } else {
            Issue.record("Expected .valid")
        }
    }
}

@Suite("DFTextField Environment")
struct DFTextFieldEnvironmentTests {
    @Test("dfTextFieldStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfTextFieldStyle
    }
}

@Suite("DFTextField Built-in Styles")
struct DFTextFieldBuiltinStyleTests {
    @Test("outlined style is instantiatable")
    func outlinedStyleInstantiates() {
        let _ = DFOutlinedTextFieldStyle()
    }

    @Test("filled style is instantiatable")
    func filledStyleInstantiates() {
        let _ = DFFilledTextFieldStyle()
    }
}
