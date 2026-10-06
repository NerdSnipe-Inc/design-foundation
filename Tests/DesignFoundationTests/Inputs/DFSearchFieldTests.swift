import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFSearchFieldStyleConfiguration")
struct DFSearchFieldStyleConfigurationTests {
    @Test("configuration holds all values")
    func configurationHoldsValues() {
        var clearCalled = false
        var cancelCalled = false
        let config = DFSearchFieldStyleConfiguration(
            label: "Search",
            placeholder: "Find a contact",
            fieldContent: AnyView(EmptyView()),
            hasText: true,
            onClear: { clearCalled = true },
            clearAccessibilityLabel: "Clear search",
            showsCancelButton: true,
            cancelTitle: "Cancel",
            onCancel: { cancelCalled = true },
            isFocused: true,
            isDisabled: false,
            theme: .default
        )
        #expect(config.label == "Search")
        #expect(config.placeholder == "Find a contact")
        #expect(config.hasText == true)
        #expect(config.clearAccessibilityLabel == "Clear search")
        #expect(config.showsCancelButton == true)
        #expect(config.cancelTitle == "Cancel")
        #expect(config.isFocused == true)
        #expect(config.isDisabled == false)
        config.onClear()
        config.onCancel()
        #expect(clearCalled == true)
        #expect(cancelCalled == true)
    }

    @Test("empty query reports no text")
    func emptyQuery() {
        let config = DFSearchFieldStyleConfiguration(
            label: "Search",
            placeholder: "",
            fieldContent: AnyView(EmptyView()),
            hasText: false,
            onClear: { },
            clearAccessibilityLabel: "Clear search",
            showsCancelButton: false,
            cancelTitle: "Cancel",
            onCancel: { },
            isFocused: false,
            isDisabled: true,
            theme: .default
        )
        #expect(config.hasText == false)
        #expect(config.showsCancelButton == false)
        #expect(config.isDisabled == true)
    }
}

@Suite("DFSearchField Environment")
struct DFSearchFieldEnvironmentTests {
    @Test("dfSearchFieldStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfSearchFieldStyle
    }
}

@Suite("DFSearchField Built-in Styles")
struct DFSearchFieldBuiltinStyleTests {
    @Test("outlined search style is instantiatable")
    func outlinedInstantiates() {
        let _ = DFOutlinedSearchFieldStyle()
    }

    @Test("filled search style is instantiatable")
    func filledInstantiates() {
        let _ = DFFilledSearchFieldStyle()
    }

    @Test("static shorthands resolve")
    func shorthandsResolve() {
        let _: DFOutlinedSearchFieldStyle = .outlined
        let _: DFFilledSearchFieldStyle = .filled
    }

    @available(iOS 26, macOS 26, *)
    @Test("glass search style is instantiatable")
    func glassInstantiates() {
        let _ = DFGlassSearchFieldStyle()
        let _: DFGlassSearchFieldStyle = .glass
    }

    @Test("built-in styles are Sendable and erase")
    func stylesAreSendable() {
        func requireSendable<S: DFSearchFieldStyle & Sendable>(_ style: S) -> AnyDFSearchFieldStyle {
            AnyDFSearchFieldStyle(style)
        }
        let _ = requireSendable(DFOutlinedSearchFieldStyle())
        let _ = requireSendable(DFFilledSearchFieldStyle())
    }
}

@Suite("DFSearchField View")
struct DFSearchFieldViewTests {
    @MainActor
    @Test("view initialises with defaults and with every option")
    func viewInitialises() {
        let _ = DFSearchField(text: .constant(""))
        let _ = DFSearchField(
            "Contacts",
            text: .constant("jo"),
            placeholder: "Search contacts",
            isFocused: .constant(true),
            showsCancelButton: true,
            cancelTitle: "Done",
            clearAccessibilityLabel: "Clear contacts search",
            onSubmit: { },
            onCancel: { }
        )
    }
}
