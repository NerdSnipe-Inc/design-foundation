import SwiftUI

// MARK: - Placement

public enum DFTooltipPlacement: Sendable, Equatable {
    case top
    case bottom
    case leading
    case trailing
}

// MARK: - Configuration

/// Sendable: holds only String, DFTooltipPlacement (Sendable), and DFTheme (Sendable).
public struct DFTooltipStyleConfiguration: Sendable {
    public let text: String
    public let placement: DFTooltipPlacement
    public let theme: DFTheme
}

// MARK: - Protocol

public protocol DFTooltipStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFTooltipStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFTooltipStyle: DFTooltipStyle, @unchecked Sendable {
    private let _makeBody: (DFTooltipStyleConfiguration) -> AnyView

    public init<S: DFTooltipStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFTooltipStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFTooltipStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFTooltipStyle = AnyDFTooltipStyle(DFBubbleTooltipStyle())
}

public extension EnvironmentValues {
    var dfTooltipStyle: AnyDFTooltipStyle {
        get { self[DFTooltipStyleKey.self] }
        set { self[DFTooltipStyleKey.self] = newValue }
    }
}

public extension View {
    func dfTooltipStyle<S: DFTooltipStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfTooltipStyle, AnyDFTooltipStyle(style))
    }
}

// MARK: - Convenience static var

public extension DFTooltipStyle where Self == DFBubbleTooltipStyle {
    static var bubble: DFBubbleTooltipStyle { DFBubbleTooltipStyle() }
}

// MARK: - Built-in: Bubble (default)

/// Rounded bubble tooltip. Draws the badge only; the modifier handles position and timing.
public struct DFBubbleTooltipStyle: DFTooltipStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFTooltipStyleConfiguration) -> some View {
        let theme = configuration.theme
        Text(configuration.text)
            .font(theme.typography.caption.font)
            .foregroundStyle(theme.colors.textPrimary)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .fixedSize()
            .background(
                RoundedRectangle(cornerRadius: theme.radius.sm)
                    .fill(theme.colors.surfaceElevated)
                    .shadow(
                        color: theme.shadows.sm.color,
                        radius: theme.shadows.sm.radius,
                        x: theme.shadows.sm.x,
                        y: theme.shadows.sm.y
                    )
            )
    }
}

// MARK: - Built-in: Glass (stub for Task 6)

@available(iOS 26, macOS 26, *)
public struct DFGlassTooltipStyle: DFTooltipStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFTooltipStyleConfiguration) -> some View {
        Text(configuration.text)
    }
}
