import SwiftUI

public struct DFPicker<SelectionValue: Hashable & Sendable, Content: View>: View {
    private let label: String
    @Binding private var selection: SelectionValue
    private let content: Content

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfPickerStyle) private var style

    public init(
        _ label: String,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self._selection = selection
        self.content = content()
    }

    public var body: some View {
        let config = DFPickerStyleConfiguration(
            label: label,
            content: AnyView(
                Picker(label, selection: $selection) {
                    content
                }
            ),
            isDisabled: !isEnabled,
            theme: theme
        )
        style.makeBody(configuration: config)
            .accessibilityLabel(label)
    }
}
