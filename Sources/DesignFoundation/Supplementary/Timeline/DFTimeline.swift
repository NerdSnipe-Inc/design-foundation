import SwiftUI

/// One entry of a `DFTimeline`. Value-driven: no arbitrary views, like `DFEntityRow`.
/// `trailing` reuses `DFEntityTrailing` (`.text`, `.badge`, `.chevron`).
public struct DFTimelineItem: Sendable, Identifiable {
    public let id: String
    public var title: String
    public var detail: String?
    /// Preformatted text such as "Oct 5, 9:41 AM". For a relative time, format the date yourself.
    public var timestamp: String?
    /// SF Symbol shown in the marker while the item is current or upcoming.
    public var systemImage: String?
    public var state: DFStepState
    public var trailing: DFEntityTrailing?

    /// - Parameter id: Stable identity; defaults to `title`.
    public init(
        id: String? = nil,
        title: String,
        detail: String? = nil,
        timestamp: String? = nil,
        systemImage: String? = nil,
        state: DFStepState = .upcoming,
        trailing: DFEntityTrailing? = nil
    ) {
        self.id = id ?? title
        self.title = title
        self.detail = detail
        self.timestamp = timestamp
        self.systemImage = systemImage
        self.state = state
        self.trailing = trailing
    }
}

/// A vertical activity / order-tracking timeline: a marker column joined by connectors, beside
/// title, detail, timestamp and optional trailing content. Each item is one VoiceOver element
/// ("Order shipped, Left the warehouse, Oct 5, complete").
public struct DFTimeline: View {
    private let items: [DFTimelineItem]

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfTimelineStyle) private var style

    public init(items: [DFTimelineItem]) {
        self.items = items
    }

    public var body: some View {
        style.makeBody(configuration: DFTimelineStyleConfiguration(items: items, theme: theme))
            .accessibilityElement(children: .contain)
    }
}
