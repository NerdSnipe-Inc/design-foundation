import SwiftUI

/// A themed horizontal-scrolling container — spacing read from `DFTheme` unless overridden.
/// Native momentum scrolling, no built-in paging/page-indicator (compose with your own
/// `TabView(.page)` if snap-to-page paging is needed).
public struct DFCarousel<Content: View>: View {
    private let spacing: CGFloat?
    private let showsIndicators: Bool
    private let content: Content

    @Environment(\.dfTheme) private var theme

    public init(
        spacing: CGFloat? = nil,
        showsIndicators: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    public var body: some View {
        let gap = spacing ?? theme.components.carousel.spacing ?? theme.spacing.sm
        ScrollView(.horizontal, showsIndicators: showsIndicators) {
            HStack(spacing: gap) {
                content
            }
        }
    }
}
