import SwiftUI

public struct DFTextField: View {
    private let label: String
    private let placeholder: String
    @Binding private var text: String
    private let validationState: DFValidationState
    private let leading: AnyView?
    private let trailing: AnyView?

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfTextFieldStyle) private var style
    @FocusState private var isFocused: Bool

    /// Plain text field with optional validation state.
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
        self.leading = nil
        self.trailing = nil
    }

    /// Text field with leading and/or trailing accessory views.
    public init<Leading: View, Trailing: View>(
        _ label: String,
        text: Binding<String>,
        placeholder: String = "",
        validationState: DFValidationState = .none,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.validationState = validationState
        self.leading = AnyView(leading())
        self.trailing = AnyView(trailing())
    }

    /// Text field with a leading accessory view only.
    public init<Leading: View>(
        _ label: String,
        text: Binding<String>,
        placeholder: String = "",
        validationState: DFValidationState = .none,
        @ViewBuilder leading: () -> Leading
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.validationState = validationState
        self.leading = AnyView(leading())
        self.trailing = nil
    }

    /// Text field with a trailing accessory view only.
    public init<Trailing: View>(
        _ label: String,
        text: Binding<String>,
        placeholder: String = "",
        validationState: DFValidationState = .none,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.validationState = validationState
        self.leading = nil
        self.trailing = AnyView(trailing())
    }

    public var body: some View {
        let config = DFTextFieldStyleConfiguration(
            label: label,
            placeholder: placeholder,
            fieldContent: AnyView(
                TextField(placeholder, text: $text)
                    .focused($isFocused)
            ),
            leadingContent: leading,
            trailingContent: trailing,
            isFocused: isFocused,
            isDisabled: !isEnabled,
            validationState: validationState,
            theme: theme
        )
        style.makeBody(configuration: config)
            .accessibilityLabel(label.isEmpty ? placeholder : label)
    }
}
