import SwiftUI

// MARK: - Configuration

/// Passed to every DFSearchFieldStyle.makeBody.
/// Not Sendable: holds AnyView values and closures.
public struct DFSearchFieldStyleConfiguration {
    public let label: String
    public let placeholder: String
    /// The actual SwiftUI TextField, pre-configured with the binding, focus state, submit handling and accessibility label.
    public let fieldContent: AnyView
    /// True while the query is non-empty. Styles show the clear button only then.
    public let hasText: Bool
    /// Clears the query and keeps focus in the field. Styles call it from their own clear button.
    public let onClear: () -> Void
    /// VoiceOver label for the clear button.
    public let clearAccessibilityLabel: String
    public let showsCancelButton: Bool
    public let cancelTitle: String
    /// Clears the query, resigns focus and notifies the caller. Styles call it from their own cancel button.
    public let onCancel: () -> Void
    public let isFocused: Bool
    public let isDisabled: Bool
    public let theme: DFTheme

    public init(
        label: String,
        placeholder: String,
        fieldContent: AnyView,
        hasText: Bool,
        onClear: @escaping () -> Void,
        clearAccessibilityLabel: String,
        showsCancelButton: Bool,
        cancelTitle: String,
        onCancel: @escaping () -> Void,
        isFocused: Bool,
        isDisabled: Bool,
        theme: DFTheme
    ) {
        self.label = label
        self.placeholder = placeholder
        self.fieldContent = fieldContent
        self.hasText = hasText
        self.onClear = onClear
        self.clearAccessibilityLabel = clearAccessibilityLabel
        self.showsCancelButton = showsCancelButton
        self.cancelTitle = cancelTitle
        self.onCancel = onCancel
        self.isFocused = isFocused
        self.isDisabled = isDisabled
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFSearchFieldStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFSearchFieldStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFSearchFieldStyle: DFSearchFieldStyle, @unchecked Sendable {
    private let _makeBody: @MainActor (DFSearchFieldStyleConfiguration) -> AnyView

    public init<S: DFSearchFieldStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFSearchFieldStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFSearchFieldStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFSearchFieldStyle = AnyDFSearchFieldStyle(DFOutlinedSearchFieldStyle())
}

public extension EnvironmentValues {
    var dfSearchFieldStyle: AnyDFSearchFieldStyle {
        get { self[DFSearchFieldStyleKey.self] }
        set { self[DFSearchFieldStyleKey.self] = newValue }
    }
}

public extension View {
    func dfSearchFieldStyle<S: DFSearchFieldStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfSearchFieldStyle, AnyDFSearchFieldStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFSearchFieldStyle where Self == DFOutlinedSearchFieldStyle {
    static var outlined: DFOutlinedSearchFieldStyle { DFOutlinedSearchFieldStyle() }
}
public extension DFSearchFieldStyle where Self == DFFilledSearchFieldStyle {
    static var filled: DFFilledSearchFieldStyle { DFFilledSearchFieldStyle() }
}

// MARK: - Shared building blocks (internal)

/// Magnifier + field + clear button. Each style supplies its own colors and wraps this in its own chrome.
struct DFSearchFieldRow: View {
    let configuration: DFSearchFieldStyleConfiguration
    let iconColor: Color
    let textColor: Color

    var body: some View {
        let theme = configuration.theme
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(theme.typography.body.font)
                .foregroundStyle(iconColor)
                .accessibilityHidden(true)
            configuration.fieldContent
                .font(theme.typography.body.font)
                .foregroundStyle(textColor)
            if configuration.hasText && !configuration.isDisabled {
                Button {
                    configuration.onClear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(theme.typography.body.font)
                        .foregroundStyle(iconColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(configuration.clearAccessibilityLabel)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .dfMinimumTouchHeight()
    }
}

/// Optional trailing cancel button, drawn with the theme's ghost button style.
struct DFSearchFieldCancelButton: View {
    let configuration: DFSearchFieldStyleConfiguration

    var body: some View {
        if configuration.showsCancelButton {
            Button(configuration.cancelTitle) {
                configuration.onCancel()
            }
            .buttonStyle(.df(.ghost))
            .disabled(configuration.isDisabled)
        }
    }
}

// MARK: - Built-in: Outlined (default)

public struct DFOutlinedSearchFieldStyle: DFSearchFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSearchFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        let borderColor: Color = {
            if configuration.isDisabled { return theme.colors.border }
            return configuration.isFocused ? theme.colors.primary : theme.colors.border
        }()

        HStack(spacing: theme.spacing.sm) {
            DFSearchFieldRow(
                configuration: configuration,
                iconColor: theme.colors.textSecondary,
                textColor: configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary
            )
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .fill(theme.colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.md)
                            .stroke(borderColor, lineWidth: configuration.isFocused ? 2 : 1)
                    )
            )
            DFSearchFieldCancelButton(configuration: configuration)
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
        .animation(theme.animation.fast, value: configuration.isFocused)
    }
}

// MARK: - Built-in: Filled

public struct DFFilledSearchFieldStyle: DFSearchFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSearchFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        let strokeColor: Color = {
            if configuration.isDisabled { return .clear }
            return configuration.isFocused ? theme.colors.primary : .clear
        }()

        HStack(spacing: theme.spacing.sm) {
            DFSearchFieldRow(
                configuration: configuration,
                iconColor: theme.colors.textSecondary,
                textColor: configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary
            )
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
            DFSearchFieldCancelButton(configuration: configuration)
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
        .animation(theme.animation.fast, value: configuration.isFocused)
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFSearchFieldStyle where Self == DFGlassSearchFieldStyle {
    static var glass: DFGlassSearchFieldStyle { DFGlassSearchFieldStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

/// Translucent material surface. When `theme.materials.preferLiquidGlass` is false it falls back to the
/// opaque `theme.colors.surface` appearance. Uses only `Material` (no iOS/macOS 26 SDK symbols), exactly
/// like `DFGlassTextFieldStyle`, so it compiles on every supported toolchain.
@available(iOS 26, macOS 26, *)
public struct DFGlassSearchFieldStyle: DFSearchFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSearchFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        let useGlass = theme.materials.preferLiquidGlass
        let strokeColor: Color = {
            if configuration.isDisabled { return theme.colors.border }
            if useGlass {
                return configuration.isFocused ? theme.colors.primary : theme.colors.border.opacity(0.6)
            }
            return configuration.isFocused ? theme.colors.primary : theme.colors.border
        }()
        let background: AnyShapeStyle = useGlass
            ? AnyShapeStyle(theme.materials.surfaceMaterial)
            : AnyShapeStyle(theme.colors.surface)

        HStack(spacing: theme.spacing.sm) {
            DFSearchFieldRow(
                configuration: configuration,
                iconColor: theme.colors.textSecondary,
                textColor: configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary
            )
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .stroke(strokeColor, lineWidth: configuration.isFocused ? 2 : 1)
            )
            DFSearchFieldCancelButton(configuration: configuration)
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
        .animation(theme.animation.fast, value: configuration.isFocused)
    }
}
