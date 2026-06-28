import SwiftUI

public struct DFDatePicker: View {
    private let label: String
    @Binding private var selection: Date
    private let dateRange: ClosedRange<Date>?
    private let displayedComponents: DatePickerComponents

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfDatePickerStyle) private var style

    public init(
        _ label: String,
        selection: Binding<Date>,
        in dateRange: ClosedRange<Date>? = nil,
        displayedComponents: DatePickerComponents = [.date]
    ) {
        self.label = label
        self._selection = selection
        self.dateRange = dateRange
        self.displayedComponents = displayedComponents
    }

    public var body: some View {
        let nativePicker: AnyView
        if let range = dateRange {
            nativePicker = AnyView(
                DatePicker(label, selection: $selection, in: range, displayedComponents: displayedComponents)
            )
        } else {
            nativePicker = AnyView(
                DatePicker(label, selection: $selection, displayedComponents: displayedComponents)
            )
        }
        let config = DFDatePickerStyleConfiguration(
            label: label,
            content: nativePicker,
            isDisabled: !isEnabled,
            theme: theme
        )
        return style.makeBody(configuration: config)
            .accessibilityLabel(label)
    }
}
