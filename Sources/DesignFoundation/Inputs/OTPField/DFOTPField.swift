import SwiftUI

/// Segmented one-time-code field.
///
/// One hidden, real text input drives `length` visual cells, so pasting a whole code, the system one-time-code
/// autofill (`.oneTimeCode`), backspace and VoiceOver all go through a single source of truth: the `text` binding.
/// Input is filtered to `allowedCharacters` (digits by default) and clamped to `length`; `onComplete` fires once when
/// the code reaches full length and re-arms when it is edited below `length` again.
public struct DFOTPField: View {
    private let label: String
    @Binding private var text: String
    private let length: Int
    private let validationState: DFValidationState
    private let allowedCharacters: DFOTPCharacterSet
    private let onComplete: ((String) -> Void)?

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfOTPFieldStyle) private var style
    @FocusState private var isFocused: Bool
    @State private var hasCompleted: Bool = false

    /// - Parameters:
    ///   - label: Shown above the cells and read by VoiceOver as the field's name.
    ///   - text: The code typed so far; always sanitized and at most `length` characters.
    ///   - length: Number of cells (at least 1).
    ///   - validationState: `.error(message)` colors the cells and shows the message below them.
    ///   - allowedCharacters: Accepted characters; `.digits` also selects the numeric keyboard on iOS.
    ///   - onComplete: Called once with the full code when it reaches `length`.
    public init(
        _ label: String,
        text: Binding<String>,
        length: Int = 6,
        validationState: DFValidationState = .none,
        allowedCharacters: DFOTPCharacterSet = .digits,
        onComplete: ((String) -> Void)? = nil
    ) {
        self.label = label
        self._text = text
        self.length = max(1, length)
        self.validationState = validationState
        self.allowedCharacters = allowedCharacters
        self.onComplete = onComplete
    }

    public var body: some View {
        let code = DFOTPCode(text, length: length, allowedCharacters: allowedCharacters)
        let config = DFOTPFieldStyleConfiguration(
            label: label,
            fieldContent: AnyView(hiddenField),
            cells: code.cells(isFocused: isFocused && isEnabled),
            isFocused: isFocused,
            isDisabled: !isEnabled,
            validationState: validationState,
            theme: theme
        )
        style.makeBody(configuration: config)
            #if os(iOS)
            // Tapping anywhere in the control (its padding or label), not only on the cells, focuses it.
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
            #endif
            .onChange(of: text) { _, newValue in
                handleChange(newValue, notify: true)
            }
            .onAppear {
                // Normalize an initial value without announcing it as a completion.
                handleChange(text, notify: false)
            }
    }

    /// The single real input. Invisible, but still focusable, hit-testable and exposed to accessibility.
    private var hiddenField: some View {
        TextField("", text: $text)
            .textFieldStyle(.plain)
            .focused($isFocused)
            .focusEffectDisabled()
            .textContentType(.oneTimeCode)
            .autocorrectionDisabled()
            #if os(iOS)
            .keyboardType(allowedCharacters.prefersNumericKeyboard ? .numberPad : .asciiCapable)
            #endif
            .foregroundStyle(Color.clear)
            .tint(Color.clear)
            .opacity(0.01)
            // The label belongs on the field itself. Put on the whole styled container it would overwrite the label
            // of every child, so a validation message was read as the field's own name.
            .accessibilityLabel(label.isEmpty ? "One-time code" : label)
    }

    private func handleChange(_ raw: String, notify: Bool) {
        let result = DFOTPCode.evaluate(
            raw,
            length: length,
            allowedCharacters: allowedCharacters,
            wasComplete: notify ? hasCompleted : true
        )
        if result.text != raw {
            text = result.text
        }
        hasCompleted = result.isComplete
        if notify && result.didComplete {
            onComplete?(result.text)
        }
    }
}
