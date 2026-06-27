import Foundation

public struct DFRadiusTokens: Sendable {
    public var none: CGFloat
    public var sm: CGFloat
    public var md: CGFloat
    public var lg: CGFloat
    public var full: CGFloat

    public init(
        none: CGFloat = 0,
        sm: CGFloat = 4,
        md: CGFloat = 8,
        lg: CGFloat = 12,
        full: CGFloat = 9999
    ) {
        self.none = none
        self.sm = sm
        self.md = md
        self.lg = lg
        self.full = full
    }

    public static let `default` = DFRadiusTokens()
}
