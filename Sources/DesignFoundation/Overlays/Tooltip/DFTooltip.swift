import SwiftUI

private struct DFTooltipModifier: ViewModifier {
    let text: String
    let delay: Double
    let placement: DFTooltipPlacement

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfTooltipStyle) private var style

    @State private var isVisible = false
    @State private var hideTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        #if os(macOS)
        content.help(text)
        #else
        content
            .overlay(alignment: overlayAlignment) {
                if isVisible {
                    style.makeBody(configuration: DFTooltipStyleConfiguration(
                        text: text,
                        placement: placement,
                        theme: theme
                    ))
                    .offset(placementOffset)
                    .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: scaleAnchor)))
                    .zIndex(999)
                }
            }
            .animation(theme.animation.fast, value: isVisible)
            .onLongPressGesture(minimumDuration: delay) {
                isVisible = true
                hideTask?.cancel()
                hideTask = Task {
                    try? await Task.sleep(for: .seconds(2))
                    if !Task.isCancelled { isVisible = false }
                }
            }
            .onTapGesture {
                if isVisible {
                    hideTask?.cancel()
                    isVisible = false
                }
            }
        #endif
    }

    private var overlayAlignment: Alignment {
        switch placement {
        case .top:      return .top
        case .bottom:   return .bottom
        case .leading:  return .leading
        case .trailing: return .trailing
        }
    }

    private var placementOffset: CGSize {
        let gap: CGFloat = 40
        switch placement {
        case .top:      return CGSize(width: 0, height: -gap)
        case .bottom:   return CGSize(width: 0, height: gap)
        case .leading:  return CGSize(width: -gap, height: 0)
        case .trailing: return CGSize(width: gap, height: 0)
        }
    }

    private var scaleAnchor: UnitPoint {
        switch placement {
        case .top:      return .bottom
        case .bottom:   return .top
        case .leading:  return .trailing
        case .trailing: return .leading
        }
    }
}

public extension View {
    /// Attaches a tooltip to this view.
    /// - Parameters:
    ///   - text: The tooltip label.
    ///   - delay: Long-press duration before showing (iOS only; macOS uses system hover delay).
    ///   - placement: Direction the tooltip bubble extends from the anchor (iOS only).
    func dfTooltip(
        _ text: String,
        delay: Double = 0.5,
        placement: DFTooltipPlacement = .top
    ) -> some View {
        modifier(DFTooltipModifier(text: text, delay: delay, placement: placement))
    }
}
