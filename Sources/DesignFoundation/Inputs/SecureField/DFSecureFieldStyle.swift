import SwiftUI

// MARK: - Configuration

/// Passed to every DFSecureFieldStyle.makeBody.
/// Not Sendable: holds AnyView and a closure.
public struct DFSecureFieldStyleConfiguration {
    public let label: String
    public let placeholder: String
    /// The field content — already switched between SecureField/TextField based on isRevealed.
    public let fieldContent: AnyView
    public let isRevealed: Bool
    /// Call this to toggle the reveal state. Styles use it to build their own reveal button.
    public let onToggleReveal: () -> Void
    public let isFocused: Bool
    public let isDisabled: Bool
    public let validationState: DFValidationState
    public let theme: DFTheme

    public init(
        label: String,
        placeholder: String,
        fieldContent: AnyView,
        isRevealed: Bool,
        onToggleReveal: @escaping () -> Void,
        isFocused: Bool,
        isDisabled: Bool,
        validationState: DFValidationState,
        theme: DFTheme
    ) {
        self.label = label
        self.placeholder = placeholder
        self.fieldContent = fieldContent
        self.isRevealed = isRevealed
        self.onToggleReveal = onToggleReveal
        self.isFocused = isFocused
        self.isDisabled = isDisabled
        self.validationState = validationState
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFSecureFieldStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFSecureFieldStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFSecureFieldStyle: DFSecureFieldStyle, @unchecked Sendable {
    private let _makeBody: (DFSecureFieldStyleConfiguration) -> AnyView

    public init<S: DFSecureFieldStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFSecureFieldStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFSecureFieldStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFSecureFieldStyle = AnyDFSecureFieldStyle(DFOutlinedSecureFieldStyle())
}

public extension EnvironmentValues {
    var dfSecureFieldStyle: AnyDFSecureFieldStyle {
        get { self[DFSecureFieldStyleKey.self] }
        set { self[DFSecureFieldStyleKey.self] = newValue }
    }
}

public extension View {
    func dfSecureFieldStyle<S: DFSecureFieldStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfSecureFieldStyle, AnyDFSecureFieldStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFSecureFieldStyle where Self == DFOutlinedSecureFieldStyle {
    static var outlined: DFOutlinedSecureFieldStyle { DFOutlinedSecureFieldStyle() }
}
public extension DFSecureFieldStyle where Self == DFFilledSecureFieldStyle {
    static var filled: DFFilledSecureFieldStyle { DFFilledSecureFieldStyle() }
}

// MARK: - Private helper

private func revealButton(isRevealed: Bool, isDisabled: Bool, theme: DFTheme, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image(systemName: isRevealed ? "eye.slash" : "eye")
            .foregroundStyle(isDisabled ? theme.colors.textDisabled : theme.colors.textSecondary)
    }
    .buttonStyle(.plain)
    .disabled(isDisabled)
    .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
}

// MARK: - Built-in: Outlined (default)

public struct DFOutlinedSecureFieldStyle: DFSecureFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSecureFieldStyleConfiguration) -> some View {
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
                configuration.fieldContent
                    .font(theme.typography.body.font)
                    .foregroundStyle(
                        configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary
                    )
                revealButton(
                    isRevealed: configuration.isRevealed,
                    isDisabled: configuration.isDisabled,
                    theme: theme,
                    action: configuration.onToggleReveal
                )
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

public struct DFFilledSecureFieldStyle: DFSecureFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSecureFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        let strokeColor: Color = {
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
                configuration.fieldContent
                    .font(theme.typography.body.font)
                    .foregroundStyle(
                        configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary
                    )
                revealButton(
                    isRevealed: configuration.isRevealed,
                    isDisabled: configuration.isDisabled,
                    theme: theme,
                    action: configuration.onToggleReveal
                )
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

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFSecureFieldStyle where Self == DFGlassSecureFieldStyle {
    static var glass: DFGlassSecureFieldStyle { DFGlassSecureFieldStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

@available(iOS 26, macOS 26, *)
public struct DFGlassSecureFieldStyle: DFSecureFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSecureFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        let strokeColor: Color = {
            switch configuration.validationState {
            case .error: return theme.colors.destructive.opacity(0.8)
            case .valid: return theme.colors.success.opacity(0.8)
            case .none: return configuration.isFocused ? .white.opacity(0.5) : .white.opacity(0.2)
            }
        }()

        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if !configuration.label.isEmpty {
                Text(configuration.label)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(.white.opacity(0.7))
            }
            HStack(spacing: theme.spacing.sm) {
                configuration.fieldContent
                    .font(theme.typography.body.font)
                    .foregroundStyle(configuration.isDisabled ? .white.opacity(0.4) : .white)
                Button(action: configuration.onToggleReveal) {
                    Image(systemName: configuration.isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(.white.opacity(configuration.isDisabled ? 0.3 : 0.7))
                }
                .buttonStyle(.plain)
                .disabled(configuration.isDisabled)
                .accessibilityLabel(configuration.isRevealed ? "Hide password" : "Show password")
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .stroke(strokeColor, lineWidth: configuration.isFocused ? 2 : 1)
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
