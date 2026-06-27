import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFButtonRole")
struct DFButtonRoleTests {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let all: [DFButtonRole] = [.destructive, .cancel]
        #expect(Set(all.map(\.rawValue)).count == 2)
    }
}

@Suite("DFButtonStyleConfiguration")
struct DFButtonStyleConfigurationTests {
    @Test("configuration holds all values correctly")
    func configurationHoldsValues() {
        let theme = DFTheme.default
        let config = DFButtonStyleConfiguration(
            label: AnyView(Text("OK")),
            isPressed: true,
            isDisabled: false,
            role: .destructive,
            theme: theme
        )
        #expect(config.isPressed == true)
        #expect(config.isDisabled == false)
        #expect(config.role == .destructive)
        #expect(config.theme.spacing.md == theme.spacing.md)
    }

    @Test("configuration with nil role")
    func configurationNilRole() {
        let config = DFButtonStyleConfiguration(
            label: AnyView(Text("OK")),
            isPressed: false,
            isDisabled: false,
            role: nil,
            theme: .default
        )
        #expect(config.role == nil)
    }
}

@Suite("DFButton Environment")
struct DFButtonEnvironmentTests {
    @Test("dfButtonStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        // Must not crash — verifies the key and default style exist
        let _ = values.dfButtonStyle
    }
}

@Suite("DFGlassButtonStyle")
struct DFGlassButtonStyleTests {
    @Test("glass style is instantiatable")
    func glassStyleInstantiates() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassButtonStyle()
        }
        // On earlier OS, this test passes trivially — glass is unavailable
    }
}
