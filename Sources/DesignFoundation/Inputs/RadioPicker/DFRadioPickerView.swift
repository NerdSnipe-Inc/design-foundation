import SwiftUI

public struct DFRadioPickerOption: Identifiable, Hashable, Sendable {
    public let id: String
    public let label: String

    public init(id: String, label: String) {
        self.id = id
        self.label = label
    }
}

/// A single-select list of labeled radio rows — an inline list, distinct from
/// `DFPicker`'s menu/wheel presentation.
public struct DFRadioPickerView: View {
    private let options: [DFRadioPickerOption]
    private let selection: Binding<String>

    @Environment(\.dfTheme) private var theme

    public init(options: [DFRadioPickerOption], selection: Binding<String>) {
        self.options = options
        self.selection = selection
    }

    /// Programmatically selects the option with the given id — exposed so callers
    /// (and tests) can drive selection without simulating a tap gesture.
    public func select(optionID: String) {
        selection.wrappedValue = optionID
    }

    public var body: some View {
        VStack(spacing: theme.spacing.sm) {
            ForEach(options) { option in
                Button {
                    select(optionID: option.id)
                } label: {
                    HStack {
                        Text(option.label)
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer()
                        Image(systemName: selection.wrappedValue == option.id ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(
                                selection.wrappedValue == option.id ? theme.colors.primary : theme.colors.border
                            )
                    }
                    .padding(theme.spacing.md)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection.wrappedValue == option.id ? [.isSelected] : [])
            }
        }
    }
}
