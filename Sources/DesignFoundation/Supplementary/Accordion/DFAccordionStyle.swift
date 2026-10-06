import SwiftUI

// MARK: - Configuration

/// Not Sendable: holds AnyView (main-thread only).
public struct DFAccordionStyleConfiguration {
    public let title: String
    public let subtitle: String?
    public let isExpanded: Bool
    /// The header's leading content (optional icon + title + optional subtitle). It does not include
    /// the chevron: the style adds that, wraps the header in a button and calls `toggle`.
    public let label: AnyView
    /// The collapsible content. Only show it while `isExpanded` is true.
    public let content: AnyView
    /// Apply to the content's root inside the `if isExpanded` branch (`.transition(configuration.contentTransition)`);
    /// it is a plain fade under Reduce Motion.
    public let contentTransition: AnyTransition
    public let toggle: @MainActor () -> Void
    public let theme: DFTheme

    public init(
        title: String,
        subtitle: String? = nil,
        isExpanded: Bool,
        label: AnyView,
        content: AnyView,
        contentTransition: AnyTransition = .opacity,
        toggle: @escaping @MainActor () -> Void,
        theme: DFTheme
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isExpanded = isExpanded
        self.label = label
        self.content = content
        self.contentTransition = contentTransition
        self.toggle = toggle
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFAccordionStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFAccordionStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFAccordionStyle: DFAccordionStyle, @unchecked Sendable {
    private let _makeBody: @MainActor (DFAccordionStyleConfiguration) -> AnyView

    public init<S: DFAccordionStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFAccordionStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFAccordionStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFAccordionStyle(DFStandardAccordionStyle())
}

public extension EnvironmentValues {
    var dfAccordionStyle: AnyDFAccordionStyle {
        get { self[DFAccordionStyleKey.self] }
        set { self[DFAccordionStyleKey.self] = newValue }
    }
}

public extension View {
    func dfAccordionStyle<S: DFAccordionStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfAccordionStyle, AnyDFAccordionStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFAccordionStyle where Self == DFStandardAccordionStyle {
    static var standard: DFStandardAccordionStyle { DFStandardAccordionStyle() }
}

public extension DFAccordionStyle where Self == DFCardAccordionStyle {
    static var card: DFCardAccordionStyle { DFCardAccordionStyle() }
}

public extension DFAccordionStyle where Self == DFPlainAccordionStyle {
    static var plain: DFPlainAccordionStyle { DFPlainAccordionStyle() }
}

// MARK: - Shared header

/// Header button shared by the built-in styles: label + rotating chevron, a minimum 44pt touch
/// height on iOS, and VoiceOver state (value + hint).
struct DFAccordionHeader: View {
    let configuration: DFAccordionStyleConfiguration

    @MainActor
    var body: some View {
        let theme = configuration.theme
        let verticalPadding = theme.components.accordion.headerPadding ?? theme.spacing.md
        let accessibilityTitle: String = configuration.subtitle.map { "\(configuration.title), \($0)" } ?? configuration.title
        let stateValue: String = configuration.isExpanded ? "Expanded" : "Collapsed"
        let stateHint: String = configuration.isExpanded ? "Double tap to collapse" : "Double tap to expand"

        Button {
            configuration.toggle()
        } label: {
            HStack(spacing: theme.spacing.sm) {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(theme.typography.caption.font.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
                    .accessibilityHidden(true)
            }
            .padding(.vertical, verticalPadding)
            .dfMinimumTouchHeight()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityTitle)
        .accessibilityValue(stateValue)
        .accessibilityHint(stateHint)
    }
}

// MARK: - Built-in: Standard (default)

/// Divider-separated rows: header, collapsible content, then a hairline divider.
public struct DFStandardAccordionStyle: DFAccordionStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFAccordionStyleConfiguration) -> some View {
        let theme = configuration.theme
        let contentPadding = theme.components.accordion.contentPadding ?? theme.spacing.md

        VStack(spacing: 0) {
            DFAccordionHeader(configuration: configuration)

            if configuration.isExpanded {
                configuration.content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, contentPadding)
                    .transition(configuration.contentTransition)
            }

            DFDivider()
        }
    }
}

// MARK: - Built-in: Card

/// Each accordion is wrapped in a `DFCard` (so it follows the active `dfCardStyle`).
public struct DFCardAccordionStyle: DFAccordionStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFAccordionStyleConfiguration) -> some View {
        let theme = configuration.theme
        let contentPadding = theme.components.accordion.contentPadding ?? theme.spacing.md

        DFCard {
            VStack(spacing: 0) {
                DFAccordionHeader(configuration: configuration)

                if configuration.isExpanded {
                    configuration.content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, contentPadding)
                        .transition(configuration.contentTransition)
                }
            }
        }
        .padding(.vertical, theme.spacing.xs)
    }
}

// MARK: - Built-in: Plain

/// No dividers or surface: just the header and its content.
public struct DFPlainAccordionStyle: DFAccordionStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFAccordionStyleConfiguration) -> some View {
        let theme = configuration.theme
        let contentPadding = theme.components.accordion.contentPadding ?? theme.spacing.md

        VStack(spacing: 0) {
            DFAccordionHeader(configuration: configuration)

            if configuration.isExpanded {
                configuration.content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, contentPadding)
                    .transition(configuration.contentTransition)
            }
        }
    }
}
