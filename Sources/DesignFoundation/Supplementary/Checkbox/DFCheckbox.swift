import SwiftUI

public struct DFCheckbox: View {
    @Binding private var isChecked: Bool
    private let label: String

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfCheckboxStyle) private var style

    public init(isChecked: Binding<Bool>, label: String = "") {
        self._isChecked = isChecked
        self.label = label
    }

    public var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack(spacing: theme.spacing.sm) {
                style.makeBody(configuration: DFCheckboxStyleConfiguration(
                    isChecked: isChecked,
                    isEnabled: isEnabled,
                    theme: theme
                ))
                if !label.isEmpty {
                    Text(label)
                        .font(theme.typography.body.font)
                        .foregroundStyle(isEnabled ? theme.colors.textPrimary : theme.colors.textDisabled)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label.isEmpty ? "Checkbox" : label)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isChecked ? "checked" : "unchecked")
    }
}
