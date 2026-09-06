import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFRadioPickerOption")
struct DFRadioPickerOptionTests {
    @Test("stores id and label")
    func storesFields() {
        let option = DFRadioPickerOption(id: "sm", label: "Small")
        #expect(option.id == "sm")
        #expect(option.label == "Small")
    }
}

@Suite("DFRadioPickerView")
struct DFRadioPickerViewTests {
    @Test("selecting an option updates the binding")
    @MainActor
    func selectionUpdatesBinding() {
        var selected = "sm"
        let binding = Binding<String>(get: { selected }, set: { selected = $0 })
        let options = [
            DFRadioPickerOption(id: "sm", label: "Small"),
            DFRadioPickerOption(id: "lg", label: "Large")
        ]
        let view = DFRadioPickerView(options: options, selection: binding)
        view.select(optionID: "lg")
        #expect(selected == "lg")
    }
}
