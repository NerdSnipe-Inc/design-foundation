import SwiftUI

public struct DFSkeleton: View {
    /// nil = use theme.components.skeleton.defaultCornerRadius (falling back to 8) for a rounded rectangle.
    private let shape: DFSkeletonShape?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfSkeletonStyle) private var style
    @State private var animationPhase: Double = 0.0

    public init(shape: DFSkeletonShape? = nil) {
        self.shape = shape
    }

    public var body: some View {
        let resolvedShape = shape ?? .roundedRectangle(
            cornerRadius: theme.components.skeleton.defaultCornerRadius ?? 8
        )
        let duration = theme.components.skeleton.shimmerDuration ?? 1.4
        style.makeBody(configuration: DFSkeletonStyleConfiguration(
            shape: resolvedShape,
            animationPhase: animationPhase,
            theme: theme
        ))
        .onAppear {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
        }
        .accessibilityLabel("Loading")
        .accessibilityHidden(true)
    }
}
