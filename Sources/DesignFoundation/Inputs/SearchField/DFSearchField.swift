import SwiftUI

/// Themed search input: leading magnifier, a clear button while the field is non-empty, an optional
/// cancel button, a submit callback and focus support.
///
/// Appearance comes from the active `DFSearchFieldStyle` (`.outlined` default, `.filled`, `.glass`).
public struct DFSearchField: View {
    private let label: String
    private let placeholder: String
    @Binding private var text: String
    private let focusBinding: Binding<Bool>?
    private let showsCancelButton: Bool
    private let cancelTitle: String
    private let clearAccessibilityLabel: String
    private let onSubmit: (() -> Void)?
    private let onCancel: (() -> Void)?

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfSearchFieldStyle) private var style
    @FocusState private var isFocused: Bool

    /// - Parameters:
    ///   - label: Accessibility label of the field. Falls back to `placeholder` when empty.
    ///   - text: The query.
    ///   - placeholder: Prompt shown while the field is empty.
    ///   - isFocused: Optional external focus state. Set it to `true` to focus the field; it follows the
    ///     field's real focus. Omit it and the field manages its own focus.
    ///   - showsCancelButton: Shows a trailing cancel button. It clears the text, resigns focus and calls `onCancel`.
    ///   - cancelTitle: Title of the cancel button.
    ///   - clearAccessibilityLabel: VoiceOver label of the clear button.
    ///   - onSubmit: Called when the user submits the query (Return / Search key).
    ///   - onCancel: Called after the cancel button has cleared the text and resigned focus.
    public init(
        _ label: String = "Search",
        text: Binding<String>,
        placeholder: String = "Search",
        isFocused: Binding<Bool>? = nil,
        showsCancelButton: Bool = false,
        cancelTitle: String = "Cancel",
        clearAccessibilityLabel: String = "Clear search",
        onSubmit: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.focusBinding = isFocused
        self.showsCancelButton = showsCancelButton
        self.cancelTitle = cancelTitle
        self.clearAccessibilityLabel = clearAccessibilityLabel
        self.onSubmit = onSubmit
        self.onCancel = onCancel
    }

    public var body: some View {
        let config = DFSearchFieldStyleConfiguration(
            label: label,
            placeholder: placeholder,
            fieldContent: AnyView(
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .focusEffectDisabled()
                    .submitLabel(.search)
                    .onSubmit { onSubmit?() }
                    // The label belongs on the field itself, not on the styled container (which would
                    // overwrite the label of the clear and cancel buttons).
                    .accessibilityLabel(label.isEmpty ? placeholder : label)
                    .accessibilityAddTraits(.isSearchField)
            ),
            hasText: !text.isEmpty,
            onClear: {
                text = ""
                isFocused = true
            },
            clearAccessibilityLabel: clearAccessibilityLabel,
            showsCancelButton: showsCancelButton,
            cancelTitle: cancelTitle,
            onCancel: {
                text = ""
                isFocused = false
                onCancel?()
            },
            isFocused: isFocused,
            isDisabled: !isEnabled,
            theme: theme
        )
        style.makeBody(configuration: config)
            .onChange(of: isFocused) { _, newValue in
                if let focusBinding, focusBinding.wrappedValue != newValue {
                    focusBinding.wrappedValue = newValue
                }
            }
            .onChange(of: focusBinding?.wrappedValue ?? false) { _, newValue in
                if isFocused != newValue {
                    isFocused = newValue
                }
            }
            .onAppear {
                if let focusBinding, focusBinding.wrappedValue {
                    isFocused = true
                }
            }
            #if os(iOS)
            // Tapping anywhere in the control (its padding, not only the text) focuses it.
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
            #endif
    }
}
