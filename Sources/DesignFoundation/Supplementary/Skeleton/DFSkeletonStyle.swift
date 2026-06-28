import SwiftUI

// MARK: - Shape

public enum DFSkeletonShape: Sendable, Equatable {
    case rectangle
    case roundedRectangle(cornerRadius: CGFloat)
    case circle
    case capsule
}

// MARK: - Configuration
// IS Sendable: holds DFSkeletonShape (Sendable), Double, DFTheme (Sendable).

public struct DFSkeletonStyleConfiguration: Sendable {
    public let shape: DFSkeletonShape
    /// Animated 0.0→1.0 phase owned by DFSkeleton; styles use it to position the shimmer gradient.
    public let animationPhase: Double
    public let theme: DFTheme

    public init(shape: DFSkeletonShape, animationPhase: Double, theme: DFTheme) {
        self.shape = shape
        self.animationPhase = animationPhase
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFSkeletonStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFSkeletonStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFSkeletonStyle: DFSkeletonStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: (DFSkeletonStyleConfiguration) -> AnyView

    public init<S: DFSkeletonStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFSkeletonStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFSkeletonStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFSkeletonStyle = AnyDFSkeletonStyle(DFDefaultSkeletonStyle())
}

public extension EnvironmentValues {
    var dfSkeletonStyle: AnyDFSkeletonStyle {
        get { self[DFSkeletonStyleKey.self] }
        set { self[DFSkeletonStyleKey.self] = newValue }
    }
}

public extension View {
    func dfSkeletonStyle<S: DFSkeletonStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfSkeletonStyle, AnyDFSkeletonStyle(style))
    }
}

// MARK: - Convenience static var

public extension DFSkeletonStyle where Self == DFDefaultSkeletonStyle {
    static var `default`: DFDefaultSkeletonStyle { DFDefaultSkeletonStyle() }
}

// MARK: - Built-in: Default

public struct DFDefaultSkeletonStyle: DFSkeletonStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSkeletonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let phase = configuration.animationPhase
        let base = theme.colors.border.opacity(0.25)
        let highlight = theme.colors.border.opacity(0.55)

        let gradient = LinearGradient(
            stops: [
                .init(color: base, location: 0),
                .init(color: base, location: max(0, phase - 0.3)),
                .init(color: highlight, location: phase),
                .init(color: base, location: min(1, phase + 0.3)),
                .init(color: base, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )

        switch configuration.shape {
        case .rectangle:
            Rectangle().fill(gradient)
        case .roundedRectangle(let radius):
            RoundedRectangle(cornerRadius: radius).fill(gradient)
        case .circle:
            Circle().fill(gradient)
        case .capsule:
            Capsule().fill(gradient)
        }
    }
}
