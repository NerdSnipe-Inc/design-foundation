import SwiftUI

// MARK: - Variant

public enum DFBadgeVariant: Sendable, CaseIterable {
    case numeric(Int)
    case dot
    case text(String)

    // CaseIterable requires static allCases with concrete values
    public static let allCases: [DFBadgeVariant] = [.numeric(0), .dot, .text("")]

    public var rawValue: String {
        switch self {
        case .numeric: return "numeric"
        case .dot: return "dot"
        case .text: return "text"
        }
    }
}

// MARK: - Configuration

public struct DFBadgeStyleConfiguration: Sendable {
    public let variant: DFBadgeVariant
    public let theme: DFTheme

    public init(variant: DFBadgeVariant, theme: DFTheme) {
        self.variant = variant
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFBadgeStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFBadgeStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFBadgeStyle: DFBadgeStyle, @unchecked Sendable {
    private let _makeBody: (DFBadgeStyleConfiguration) -> AnyView

    public init<S: DFBadgeStyle>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFBadgeStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFBadgeStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFBadgeStyle(DFFilledBadgeStyle())
}

public extension EnvironmentValues {
    var dfBadgeStyle: AnyDFBadgeStyle {
        get { self[DFBadgeStyleKey.self] }
        set { self[DFBadgeStyleKey.self] = newValue }
    }
}

public extension View {
    func dfBadgeStyle<S: DFBadgeStyle>(_ style: S) -> some View {
        environment(\.dfBadgeStyle, AnyDFBadgeStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFBadgeStyle where Self == DFFilledBadgeStyle {
    static var filled: DFFilledBadgeStyle { DFFilledBadgeStyle() }
}
public extension DFBadgeStyle where Self == DFTintedBadgeStyle {
    static var tinted: DFTintedBadgeStyle { DFTintedBadgeStyle() }
}
public extension DFBadgeStyle where Self == DFOutlinedBadgeStyle {
    static var outlined: DFOutlinedBadgeStyle { DFOutlinedBadgeStyle() }
}

// MARK: - Helper: label content from variant

private func badgeLabel(_ variant: DFBadgeVariant, theme: DFTheme) -> String? {
    switch variant {
    case .numeric(let n): return n > 99 ? "99+" : "\(n)"
    case .dot: return nil
    case .text(let s): return s
    }
}

// MARK: - Built-in: Filled (default)

public struct DFFilledBadgeStyle: DFBadgeStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFBadgeStyleConfiguration) -> some View {
        let theme = configuration.theme
        let hPad = theme.components.badge.horizontalPadding ?? theme.spacing.xs
        let vPad = theme.components.badge.verticalPadding ?? 2

        if case .dot = configuration.variant {
            return AnyView(
                Circle()
                    .fill(theme.colors.destructive)
                    .frame(width: 8, height: 8)
            )
        }

        let text = badgeLabel(configuration.variant, theme: theme) ?? ""
        return AnyView(
            Text(text)
                .font(theme.typography.label.font)
                .foregroundStyle(.white)
                .padding(.horizontal, hPad)
                .padding(.vertical, vPad)
                .background(
                    Capsule().fill(theme.colors.destructive)
                )
        )
    }
}

// MARK: - Built-in: Tinted

public struct DFTintedBadgeStyle: DFBadgeStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFBadgeStyleConfiguration) -> some View {
        let theme = configuration.theme
        let hPad = theme.components.badge.horizontalPadding ?? theme.spacing.xs
        let vPad = theme.components.badge.verticalPadding ?? 2

        if case .dot = configuration.variant {
            return AnyView(
                Circle()
                    .fill(theme.colors.primary.opacity(0.2))
                    .overlay(Circle().stroke(theme.colors.primary, lineWidth: 1))
                    .frame(width: 8, height: 8)
            )
        }

        let text = badgeLabel(configuration.variant, theme: theme) ?? ""
        return AnyView(
            Text(text)
                .font(theme.typography.label.font)
                .foregroundStyle(theme.colors.primary)
                .padding(.horizontal, hPad)
                .padding(.vertical, vPad)
                .background(Capsule().fill(theme.colors.primary.opacity(0.15)))
        )
    }
}

// MARK: - Built-in: Outlined

public struct DFOutlinedBadgeStyle: DFBadgeStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFBadgeStyleConfiguration) -> some View {
        let theme = configuration.theme
        let hPad = theme.components.badge.horizontalPadding ?? theme.spacing.xs
        let vPad = theme.components.badge.verticalPadding ?? 2

        if case .dot = configuration.variant {
            return AnyView(
                Circle()
                    .stroke(theme.colors.border, lineWidth: 1.5)
                    .frame(width: 8, height: 8)
            )
        }

        let text = badgeLabel(configuration.variant, theme: theme) ?? ""
        return AnyView(
            Text(text)
                .font(theme.typography.label.font)
                .foregroundStyle(theme.colors.textPrimary)
                .padding(.horizontal, hPad)
                .padding(.vertical, vPad)
                .background(Capsule().stroke(theme.colors.border, lineWidth: 1))
        )
    }
}
