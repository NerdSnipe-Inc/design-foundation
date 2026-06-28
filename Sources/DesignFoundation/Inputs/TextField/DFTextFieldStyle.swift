import SwiftUI

// MARK: - Configuration

/// Passed to every DFTextFieldStyle.makeBody.
/// Not Sendable: holds AnyView values.
public struct DFTextFieldStyleConfiguration {
    public let label: String
    public let placeholder: String
    /// The actual SwiftUI TextField, pre-configured with the binding and focus state.
    public let fieldContent: AnyView
    public let leadingContent: AnyView?
    public let trailingContent: AnyView?
    public let isFocused: Bool
    public let isDisabled: Bool
    public let validationState: DFValidationState
    public let theme: DFTheme

    public init(
        label: String,
        placeholder: String,
        fieldContent: AnyView,
        leadingContent: AnyView?,
        trailingContent: AnyView?,
        isFocused: Bool,
        isDisabled: Bool,
        validationState: DFValidationState,
        theme: DFTheme
    ) {
        self.label = label
        self.placeholder = placeholder
        self.fieldContent = fieldContent
        self.leadingContent = leadingContent
        self.trailingContent = trailingContent
        self.isFocused = isFocused
        self.isDisabled = isDisabled
        self.validationState = validationState
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFTextFieldStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFTextFieldStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFTextFieldStyle: DFTextFieldStyle, @unchecked Sendable {
    private let _makeBody: (DFTextFieldStyleConfiguration) -> AnyView

    public init<S: DFTextFieldStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFTextFieldStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFTextFieldStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFTextFieldStyle = AnyDFTextFieldStyle(DFOutlinedTextFieldStyle())
}

public extension EnvironmentValues {
    var dfTextFieldStyle: AnyDFTextFieldStyle {
        get { self[DFTextFieldStyleKey.self] }
        set { self[DFTextFieldStyleKey.self] = newValue }
    }
}

public extension View {
    func dfTextFieldStyle<S: DFTextFieldStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfTextFieldStyle, AnyDFTextFieldStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFTextFieldStyle where Self == DFOutlinedTextFieldStyle {
    static var outlined: DFOutlinedTextFieldStyle { DFOutlinedTextFieldStyle() }
}
public extension DFTextFieldStyle where Self == DFFilledTextFieldStyle {
    static var filled: DFFilledTextFieldStyle { DFFilledTextFieldStyle() }
}

// MARK: - Built-in: Outlined (default)

public struct DFOutlinedTextFieldStyle: DFTextFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFTextFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        let borderColor: Color = {
            if configuration.isDisabled { return theme.colors.border }
            switch configuration.validationState {
            case .error: return theme.colors.destructive
            case .valid: return theme.colors.success
            case .none: return configuration.isFocused ? theme.colors.primary : theme.colors.border
            }
        }()

        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if !configuration.label.isEmpty {
                Text(configuration.label)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(
                        configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textSecondary
                    )
            }
            HStack(spacing: theme.spacing.sm) {
                if let leading = configuration.leadingContent {
                    leading.foregroundStyle(theme.colors.textSecondary)
                }
                configuration.fieldContent
                    .font(theme.typography.body.font)
                    .foregroundStyle(
                        configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary
                    )
                if let trailing = configuration.trailingContent {
                    trailing.foregroundStyle(theme.colors.textSecondary)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .stroke(borderColor, lineWidth: configuration.isFocused ? 2 : 1)
            )
            if case .error(let message) = configuration.validationState {
                Text(message)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.destructive)
            }
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
        .animation(theme.animation.fast, value: configuration.isFocused)
    }
}

// MARK: - Built-in: Filled

public struct DFFilledTextFieldStyle: DFTextFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFTextFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        let strokeColor: Color = {
            if configuration.isDisabled { return .clear }
            switch configuration.validationState {
            case .error: return theme.colors.destructive
            case .valid: return theme.colors.success
            case .none: return configuration.isFocused ? theme.colors.primary : .clear
            }
        }()

        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if !configuration.label.isEmpty {
                Text(configuration.label)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(
                        configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textSecondary
                    )
            }
            HStack(spacing: theme.spacing.sm) {
                if let leading = configuration.leadingContent {
                    leading.foregroundStyle(theme.colors.textSecondary)
                }
                configuration.fieldContent
                    .font(theme.typography.body.font)
                    .foregroundStyle(
                        configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary
                    )
                if let trailing = configuration.trailingContent {
                    trailing.foregroundStyle(theme.colors.textSecondary)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .fill(
                        configuration.isDisabled
                            ? theme.colors.interactiveDisabled
                            : theme.colors.surface
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.md)
                            .stroke(strokeColor, lineWidth: configuration.isFocused ? 2 : 0)
                    )
            )
            if case .error(let message) = configuration.validationState {
                Text(message)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.destructive)
            }
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
        .animation(theme.animation.fast, value: configuration.isFocused)
    }
}
