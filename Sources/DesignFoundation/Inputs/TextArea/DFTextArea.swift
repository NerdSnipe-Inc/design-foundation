import SwiftUI

/// A multiline text input styled to match `DFTextField`.
///
/// Use when you need more than one line — bio, artist statement, notes, etc.
/// Single-line input should continue to use `DFTextField`.
///
/// ```swift
/// DFTextArea("Bio", text: $bio, placeholder: "Tell your story…", minLines: 4)
/// ```
public struct DFTextArea: View {
    private let label: String
    private let placeholder: String
    @Binding private var text: String
    private let minLines: Int
    private let maxLines: Int
    private let validationState: DFValidationState

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    public init(
        _ label: String,
        text: Binding<String>,
        placeholder: String = "",
        minLines: Int = 3,
        maxLines: Int = 8,
        validationState: DFValidationState = .none
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.minLines = minLines
        self.maxLines = maxLines
        self.validationState = validationState
    }

    public var body: some View {
        let borderColor: Color = {
            if !isEnabled { return theme.colors.border }
            switch validationState {
            case .error: return theme.colors.destructive
            case .valid: return theme.colors.success
            case .none:  return isFocused ? theme.colors.primary : theme.colors.border
            }
        }()

        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if !label.isEmpty {
                Text(label)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(isEnabled ? theme.colors.textSecondary : theme.colors.textDisabled)
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.textSecondary.opacity(0.5))
                        .padding(.horizontal, theme.spacing.md)
                        .padding(.vertical, theme.spacing.sm + 1)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                    .focused($isFocused)
                    .font(theme.typography.body.font)
                    .foregroundStyle(isEnabled ? theme.colors.textPrimary : theme.colors.textDisabled)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xs)
                    .frame(
                        minHeight: lineHeight * CGFloat(minLines),
                        maxHeight: lineHeight * CGFloat(maxLines)
                    )
            }
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .fill(theme.colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.md)
                            .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
                    )
            )

            if case .error(let message) = validationState {
                Text(message)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.destructive)
            }
        }
        .opacity(isEnabled ? 1 : 0.5)
        .animation(theme.animation.fast, value: isFocused)
        .accessibilityLabel(label.isEmpty ? placeholder : label)
    }

    // Approximate line height based on the body font + line spacing
    private var lineHeight: CGFloat {
        theme.typography.body.lineSpacing + 22
    }
}
