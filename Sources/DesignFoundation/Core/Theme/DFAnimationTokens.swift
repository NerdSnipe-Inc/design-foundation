import SwiftUI

public struct DFAnimationTokens: Sendable {
    public var fast: Animation
    public var `default`: Animation
    public var slow: Animation

    public init(
        fast: Animation = .easeInOut(duration: 0.15),
        default: Animation = .easeInOut(duration: 0.25),
        slow: Animation = .easeInOut(duration: 0.4)
    ) {
        self.fast = fast
        self.default = `default`
        self.slow = slow
    }

    public static let `default` = DFAnimationTokens()
}
