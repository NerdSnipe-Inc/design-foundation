import SwiftUI

public struct DFAnimationTokens: Sendable {
    public var fast: Animation
    public var `default`: Animation
    public var slow: Animation
    /// Springy entrance used by popups. Additive token; reduce-motion falls back to a short fade.
    public var spring: Animation

    public init(
        fast: Animation = .easeInOut(duration: 0.15),
        default: Animation = .easeInOut(duration: 0.25),
        slow: Animation = .easeInOut(duration: 0.4),
        spring: Animation = .spring(response: 0.42, dampingFraction: 0.82)
    ) {
        self.fast = fast
        self.default = `default`
        self.slow = slow
        self.spring = spring
    }

    public static let `default` = DFAnimationTokens()
}
