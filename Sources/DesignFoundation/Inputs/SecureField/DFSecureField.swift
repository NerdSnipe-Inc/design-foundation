import SwiftUI

public struct DFSecureField: View {
    private let label: String
    private let placeholder: String
    @Binding private var text: String
    private let validationState: DFValidationState

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfSecureFieldStyle) private var style
    @FocusState private var isFocused: Bool
    @State private var isRevealed: Bool = false

    public init(
        _ label: String,
        text: Binding<String>,
        placeholder: String = "",
        validationState: DFValidationState = .none
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.validationState = validationState
    }

    public var body: some View {
        let fieldContent: AnyView = isRevealed
            ? AnyView(TextField(placeholder, text: $text).textFieldStyle(.plain).focused($isFocused).focusEffectDisabled())
            : AnyView(SecureField(placeholder, text: $text).textFieldStyle(.plain).focused($isFocused).focusEffectDisabled())

        let config = DFSecureFieldStyleConfiguration(
            label: label,
            placeholder: placeholder,
            fieldContent: fieldContent,
            isRevealed: isRevealed,
            onToggleReveal: { isRevealed.toggle() },
            isFocused: isFocused,
            isDisabled: !isEnabled,
            validationState: validationState,
            theme: theme
        )
        style.makeBody(configuration: config)
            .accessibilityLabel(label.isEmpty ? placeholder : label)
    }
}
