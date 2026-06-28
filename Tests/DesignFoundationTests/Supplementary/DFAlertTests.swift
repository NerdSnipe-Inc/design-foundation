import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFAlertActionRole")
struct DFAlertActionRoleTests {
    @Test("roles map to ButtonRole")
    func rolesMapCorrectly() {
        #expect(DFAlertActionRole.destructive.buttonRole == .destructive)
        #expect(DFAlertActionRole.cancel.buttonRole == .cancel)
    }
}

@Suite("DFAlertAction")
struct DFAlertActionTests {
    @Test("stores title and nil role by default")
    func defaultInit() {
        let action = DFAlertAction(title: "OK")
        #expect(action.title == "OK")
        #expect(action.role == nil)
    }

    @Test("stores destructive role")
    func destructiveRole() {
        let action = DFAlertAction(title: "Delete", role: .destructive)
        #expect(action.role == .destructive)
    }
}

@Suite("DFAlertConfiguration")
struct DFAlertConfigurationTests {
    @Test("stores title, message, and actions")
    func holdsValues() {
        let config = DFAlertConfiguration(
            title: "Confirm",
            message: "Are you sure?",
            actions: [DFAlertAction(title: "Yes"), DFAlertAction(title: "No", role: .cancel)]
        )
        #expect(config.title == "Confirm")
        #expect(config.message == "Are you sure?")
        #expect(config.actions.count == 2)
    }

    @Test("message defaults to nil")
    func messageDefaultsNil() {
        let config = DFAlertConfiguration(title: "Notice", actions: [DFAlertAction(title: "OK")])
        #expect(config.message == nil)
    }
}
