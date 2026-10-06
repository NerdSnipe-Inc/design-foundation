import SwiftUI

// MARK: - Configuration
// IS Sendable: holds [DFTimelineItem] (Sendable) and DFTheme (Sendable).

public struct DFTimelineStyleConfiguration: Sendable {
    public let items: [DFTimelineItem]
    public let theme: DFTheme

    public init(items: [DFTimelineItem], theme: DFTheme) {
        self.items = items
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFTimelineStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFTimelineStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFTimelineStyle: DFTimelineStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: @MainActor (DFTimelineStyleConfiguration) -> AnyView

    public init<S: DFTimelineStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFTimelineStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFTimelineStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFTimelineStyle = AnyDFTimelineStyle(DFStandardTimelineStyle())
}

public extension EnvironmentValues {
    var dfTimelineStyle: AnyDFTimelineStyle {
        get { self[DFTimelineStyleKey.self] }
        set { self[DFTimelineStyleKey.self] = newValue }
    }
}

public extension View {
    func dfTimelineStyle<S: DFTimelineStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfTimelineStyle, AnyDFTimelineStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFTimelineStyle where Self == DFStandardTimelineStyle {
    static var standard: DFStandardTimelineStyle { DFStandardTimelineStyle() }
}

public extension DFTimelineStyle where Self == DFCompactTimelineStyle {
    static var compact: DFCompactTimelineStyle { DFCompactTimelineStyle() }
}

// MARK: - Built-in: Standard

public struct DFStandardTimelineStyle: DFTimelineStyle, Sendable {
    public init() {}

    @MainActor
    public func makeBody(configuration: DFTimelineStyleConfiguration) -> some View {
        DFTimelineLayout(
            configuration: configuration,
            markerSize: configuration.theme.components.timeline.markerSize ?? 28,
            isCompact: false
        )
    }
}

// MARK: - Built-in: Compact

public struct DFCompactTimelineStyle: DFTimelineStyle, Sendable {
    public init() {}

    @MainActor
    public func makeBody(configuration: DFTimelineStyleConfiguration) -> some View {
        DFTimelineLayout(
            configuration: configuration,
            markerSize: configuration.theme.components.timeline.markerSize ?? 20,
            isCompact: true
        )
    }
}

// MARK: - Shared layout

/// Renders both built-in timeline styles; `.compact` uses a smaller marker, tighter rows and an inline timestamp.
struct DFTimelineLayout: View {
    let configuration: DFTimelineStyleConfiguration
    let markerSize: CGFloat
    let isCompact: Bool

    nonisolated init(configuration: DFTimelineStyleConfiguration, markerSize: CGFloat, isCompact: Bool) {
        self.configuration = configuration
        self.markerSize = markerSize
        self.isCompact = isCompact
    }

    private var theme: DFTheme { configuration.theme }
    private var connectorThickness: CGFloat { theme.components.timeline.connectorThickness ?? 2 }

    var body: some View {
        let items = configuration.items
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                row(item: item, index: index, isLast: index == items.count - 1)
            }
        }
    }

    @ViewBuilder
    private func row(item: DFTimelineItem, index: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: isCompact ? theme.spacing.sm : theme.spacing.md) {
            DFStepMarker(
                kind: .filled,
                state: item.state,
                position: index + 1,
                systemImage: item.systemImage,
                size: markerSize,
                theme: theme
            )
            content(item)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let trailing = item.trailing {
                trailingView(trailing)
            }
        }
        .padding(.bottom, isLast ? 0 : (isCompact ? theme.spacing.md : theme.spacing.lg))
        .background(alignment: .topLeading) {
            if !isLast {
                DFStepConnector(
                    axis: .vertical,
                    isComplete: item.state == .complete,
                    thickness: connectorThickness,
                    minLength: 8,
                    theme: theme
                )
                .padding(.top, markerSize + theme.spacing.xs)
                .padding(.leading, (markerSize - connectorThickness) / 2)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel(item))
        .accessibilityValue(item.state.accessibilityValue)
    }

    @ViewBuilder
    private func content(_ item: DFTimelineItem) -> some View {
        let titleFont = item.state == .current
            ? theme.typography.label.font.weight(.bold)
            : theme.typography.label.font
        let titleColor = item.state == .error
            ? theme.colors.destructive
            : (item.state == .upcoming ? theme.colors.textSecondary : theme.colors.textPrimary)

        VStack(alignment: .leading, spacing: 2) {
            if isCompact, let timestamp = item.timestamp {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    Text(item.title)
                        .font(titleFont)
                        .foregroundStyle(titleColor)
                    Spacer(minLength: theme.spacing.xs)
                    Text(timestamp)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            } else {
                Text(item.title)
                    .font(titleFont)
                    .foregroundStyle(titleColor)
                if let timestamp = item.timestamp {
                    Text(timestamp)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            if let detail = item.detail {
                Text(detail)
                    .font(isCompact ? theme.typography.caption.font : theme.typography.bodySmall.font)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func trailingView(_ trailing: DFEntityTrailing) -> some View {
        switch trailing {
        case .text(let text):
            Text(text)
                .font(theme.typography.caption.font)
                .foregroundStyle(theme.colors.textSecondary)
        case .badge(let text):
            DFBadge(text: text)
        case .chevron:
            Image(systemName: "chevron.right")
                .font(theme.typography.caption.font.weight(.medium))
                .foregroundStyle(theme.colors.textSecondary)
        }
    }

    private func accessibilityLabel(_ item: DFTimelineItem) -> String {
        var parts = [item.title]
        if let detail = item.detail { parts.append(detail) }
        if let timestamp = item.timestamp { parts.append(timestamp) }
        switch item.trailing {
        case .text(let text)?, .badge(let text)?: parts.append(text)
        case .chevron?, nil: break
        }
        return parts.joined(separator: ", ")
    }
}
