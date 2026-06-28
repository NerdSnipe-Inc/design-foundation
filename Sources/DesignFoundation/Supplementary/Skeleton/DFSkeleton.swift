import SwiftUI

public struct DFSkeleton: View {
    private let shape: DFSkeletonShape

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfSkeletonStyle) private var style
    @State private var animationPhase: Double = 0.0

    public init(shape: DFSkeletonShape = .roundedRectangle(cornerRadius: 8)) {
        self.shape = shape
    }

    public var body: some View {
        style.makeBody(configuration: DFSkeletonStyleConfiguration(
            shape: shape,
            animationPhase: animationPhase,
            theme: theme
        ))
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
        }
        .accessibilityLabel("Loading")
        .accessibilityHidden(true)
    }
}
