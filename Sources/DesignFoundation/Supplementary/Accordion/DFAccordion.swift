import SwiftUI

// MARK: - Group context (internal)

/// Injected by `DFAccordionGroup` so member accordions can read and flip their group's state.
struct DFAccordionGroupContext {
    let isExpanded: @MainActor (String) -> Bool
    let toggle: @MainActor (String) -> Void
}

private struct DFAccordionGroupContextKey: EnvironmentKey {
    static var defaultValue: DFAccordionGroupContext? { nil }
}

extension EnvironmentValues {
    var dfAccordionGroupContext: DFAccordionGroupContext? {
        get { self[DFAccordionGroupContextKey.self] }
        set { self[DFAccordionGroupContextKey.self] = newValue }
    }
}

// MARK: - DFAccordion

/// An expandable section: a header (title, optional subtitle and leading icon, rotating chevron)
/// above collapsible content.
///
/// Three ways to drive it:
/// - controlled: `DFAccordion("Title", isExpanded: $flag) { ... }`
/// - uncontrolled: `DFAccordion("Title") { ... }` (owns its own state)
/// - inside a `DFAccordionGroup`: `DFAccordion("Title", id: "a") { ... }`
public struct DFAccordion<Content: View>: View {
    private let title: String
    private let subtitle: String?
    private let icon: String?
    private let groupID: String?
    private let externalBinding: Binding<Bool>?
    private let content: Content

    @State private var localExpanded: Bool

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfAccordionStyle) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dfAccordionGroupContext) private var group

    /// Controlled: the caller owns the expanded state.
    public init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.groupID = nil
        self.externalBinding = isExpanded
        self.content = content()
        _localExpanded = State(initialValue: false)
    }

    /// Uncontrolled: the accordion owns its own expanded state.
    public init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        isInitiallyExpanded: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.groupID = nil
        self.externalBinding = nil
        self.content = content()
        _localExpanded = State(initialValue: isInitiallyExpanded)
    }

    /// Group member: expanded state lives in the enclosing `DFAccordionGroup`, keyed by `id`.
    /// Outside a group it falls back to its own state.
    public init(
        _ title: String,
        id: String,
        subtitle: String? = nil,
        icon: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.groupID = id
        self.externalBinding = nil
        self.content = content()
        _localExpanded = State(initialValue: false)
    }

    @MainActor
    private var isExpanded: Bool {
        if let id = groupID, let group {
            return group.isExpanded(id)
        }
        if let externalBinding {
            return externalBinding.wrappedValue
        }
        return localExpanded
    }

    @MainActor
    private func toggle() {
        // Reduce Motion: a short fade (opacity-only transition, `fast` token) instead of the slide.
        let animation: Animation = reduceMotion ? theme.animation.fast : theme.animation.default
        withAnimation(animation) {
            if let id = groupID, let group {
                group.toggle(id)
            } else if let externalBinding {
                externalBinding.wrappedValue.toggle()
            } else {
                localExpanded.toggle()
            }
        }
    }

    @MainActor
    public var body: some View {
        let label = HStack(spacing: theme.spacing.sm) {
            if let icon {
                DFIcon(icon)
                    .dfIconStyle(.tinted)
            }
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                DFText(title, scale: .headline)
                if let subtitle {
                    DFText(subtitle, scale: .bodySmall)
                        .dfTextViewStyle(.secondary)
                }
            }
        }
        let transition: AnyTransition = reduceMotion
            ? .opacity
            : .opacity.combined(with: .move(edge: .top))

        let config = DFAccordionStyleConfiguration(
            title: title,
            subtitle: subtitle,
            isExpanded: isExpanded,
            label: AnyView(label),
            content: AnyView(content),
            contentTransition: transition,
            toggle: { toggle() },
            theme: theme
        )
        style.makeBody(configuration: config)
    }
}

// MARK: - DFAccordionGroup

/// A stack of `DFAccordion`s that coordinate their open state. By default only one accordion is
/// open at a time (exclusive); pass `allowsMultipleExpanded: true` to let several stay open.
/// Members join the group with `DFAccordion("Title", id: "unique-id") { ... }`.
public struct DFAccordionGroup<Content: View>: View {
    private let content: Content

    @State private var state: DFAccordionGroupState

    public init(
        allowsMultipleExpanded: Bool = false,
        initiallyExpanded: Set<String> = [],
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        _state = State(initialValue: DFAccordionGroupState(
            allowsMultipleExpanded: allowsMultipleExpanded,
            expandedIDs: initiallyExpanded
        ))
    }

    @MainActor
    public var body: some View {
        let context = DFAccordionGroupContext(
            isExpanded: { id in state.isExpanded(id) },
            toggle: { id in state.toggle(id) }
        )
        VStack(spacing: 0) {
            content
        }
        .environment(\.dfAccordionGroupContext, context)
    }
}
