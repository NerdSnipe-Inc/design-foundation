import SwiftUI

public struct DFShadow: Sendable {
    public var color: Color
    public var radius: CGFloat
    public var x: CGFloat
    public var y: CGFloat

    public init(color: Color = .black.opacity(0.15), radius: CGFloat = 0, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    public static let none = DFShadow()
}

public struct DFShadowTokens: Sendable {
    public var none: DFShadow
    public var sm: DFShadow
    public var md: DFShadow
    public var lg: DFShadow

    public init(
        none: DFShadow = .none,
        sm: DFShadow = DFShadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2),
        md: DFShadow = DFShadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4),
        lg: DFShadow = DFShadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 8)
    ) {
        self.none = none
        self.sm = sm
        self.md = md
        self.lg = lg
    }

    public static let `default` = DFShadowTokens()
}
