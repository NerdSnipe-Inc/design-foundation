import SwiftUI

// MARK: - Variant

public enum DFChipVariant: Sendable {
    case label(String)
    case labelWithIcon(String, systemImage: String)
    case dismissible(String, onDismiss: @MainActor @Sendable () -> Void)
    case selectable(String)

    public var text: String {
        switch self {
        case .label(let text): return text
        case .labelWithIcon(let text, _): return text
        case .dismissible(let text, _): return text
        case .selectable(let text): return text
        }
    }
}

// MARK: - Configuration

public struct DFChipStyleConfiguration: Sendable {
    public let variant: DFChipVariant
    public let isSelected: Bool
    public let theme: DFTheme

    public init(variant: DFChipVariant, isSelected: Bool, theme: DFTheme) {
        self.variant = variant
        self.isSelected = isSelected
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFChipStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFChipStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFChipStyle: DFChipStyle, @unchecked Sendable {
    private let _makeBody: @MainActor (DFChipStyleConfiguration) -> AnyView

    public init<S: DFChipStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFChipStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFChipStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFChipStyle(DFFilledChipStyle())
}

public extension EnvironmentValues {
    var dfChipStyle: AnyDFChipStyle {
        get { self[DFChipStyleKey.self] }
        set { self[DFChipStyleKey.self] = newValue }
    }
}

public extension View {
    func dfChipStyle<S: DFChipStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfChipStyle, AnyDFChipStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFChipStyle where Self == DFFilledChipStyle {
    static var filled: DFFilledChipStyle { DFFilledChipStyle() }
}
public extension DFChipStyle where Self == DFTintedChipStyle {
    static var tinted: DFTintedChipStyle { DFTintedChipStyle() }
}
public extension DFChipStyle where Self == DFOutlinedChipStyle {
    static var outlined: DFOutlinedChipStyle { DFOutlinedChipStyle() }
}

// MARK: - Helper: shared content

@ViewBuilder
private func chipLabel(_ configuration: DFChipStyleConfiguration, foreground: Color) -> some View {
    let theme = configuration.theme
    HStack(spacing: theme.components.chip.iconSpacing ?? theme.spacing.xs) {
        if case .labelWithIcon(_, let systemImage) = configuration.variant {
            Image(systemName: systemImage)
                .font(theme.typography.label.font)
        }
        Text(configuration.variant.text)
            .font(theme.typography.label.font)
        if case .dismissible = configuration.variant {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .semibold))
        }
    }
    .foregroundStyle(foreground)
}

private func chipTapAction(_ variant: DFChipVariant) -> (@MainActor @Sendable () -> Void)? {
    if case .dismissible(_, let onDismiss) = variant {
        return onDismiss
    }
    return nil
}

// MARK: - Built-in: Filled (default)

public struct DFFilledChipStyle: DFChipStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFChipStyleConfiguration) -> some View {
        let theme = configuration.theme
        let hPad = theme.components.chip.horizontalPadding ?? theme.spacing.sm
        let vPad = theme.components.chip.verticalPadding ?? theme.spacing.xs
        let cornerRadius = theme.components.chip.cornerRadius ?? theme.radius.full
        let background = configuration.isSelected ? theme.colors.primary : theme.colors.surfaceElevated
        let foreground = configuration.isSelected ? Color.white : theme.colors.textPrimary

        let content = chipLabel(configuration, foreground: foreground)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(background))

        if let onTap = chipTapAction(configuration.variant) {
            Button(action: onTap) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }
}

// MARK: - Built-in: Tinted

public struct DFTintedChipStyle: DFChipStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFChipStyleConfiguration) -> some View {
        let theme = configuration.theme
        let hPad = theme.components.chip.horizontalPadding ?? theme.spacing.sm
        let vPad = theme.components.chip.verticalPadding ?? theme.spacing.xs
        let cornerRadius = theme.components.chip.cornerRadius ?? theme.radius.full
        let opacity = configuration.isSelected ? 0.3 : 0.15

        let content = chipLabel(configuration, foreground: theme.colors.primary)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(theme.colors.primary.opacity(opacity))
            )

        if let onTap = chipTapAction(configuration.variant) {
            Button(action: onTap) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }
}

// MARK: - Built-in: Outlined

public struct DFOutlinedChipStyle: DFChipStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFChipStyleConfiguration) -> some View {
        let theme = configuration.theme
        let hPad = theme.components.chip.horizontalPadding ?? theme.spacing.sm
        let vPad = theme.components.chip.verticalPadding ?? theme.spacing.xs
        let cornerRadius = theme.components.chip.cornerRadius ?? theme.radius.full
        let borderColor = configuration.isSelected ? theme.colors.primary : theme.colors.border
        let foreground = configuration.isSelected ? theme.colors.primary : theme.colors.textPrimary

        let content = chipLabel(configuration, foreground: foreground)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: configuration.isSelected ? 1.5 : 1)
            )

        if let onTap = chipTapAction(configuration.variant) {
            Button(action: onTap) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }
}
