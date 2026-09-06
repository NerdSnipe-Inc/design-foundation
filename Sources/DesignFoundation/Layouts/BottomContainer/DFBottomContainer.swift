import SwiftUI

private struct DFBottomContainerModifier<BarContent: View>: ViewModifier {
    @ViewBuilder let barContent: () -> BarContent

    @Environment(\.dfTheme) private var theme

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            barContent()
                .padding(theme.components.bottomContainer.padding ?? theme.spacing.md)
                .frame(maxWidth: .infinity)
                .background(
                    theme.colors.surface,
                    in: RoundedRectangle(
                        cornerRadius: theme.components.bottomContainer.cornerRadius ?? theme.radius.lg
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: theme.components.bottomContainer.cornerRadius ?? theme.radius.lg
                    )
                    .stroke(theme.colors.border, lineWidth: 0.5)
                )
        }
    }
}

public extension View {
    /// Pins `content` (e.g. a "Continue" CTA or checkout total bar) to the bottom
    /// of this view, on a themed surface.
    func dfBottomBar<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(DFBottomContainerModifier(barContent: content))
    }
}
