import SwiftUI

public struct DFTextStyle: Sendable {
    public var font: Font
    public var lineSpacing: CGFloat
    public var tracking: CGFloat

    public init(font: Font, lineSpacing: CGFloat = 0, tracking: CGFloat = 0) {
        self.font = font
        self.lineSpacing = lineSpacing
        self.tracking = tracking
    }
}

public struct DFTypographyTokens: Sendable {
    public var display: DFTextStyle
    public var title: DFTextStyle
    public var headline: DFTextStyle
    public var body: DFTextStyle
    public var caption: DFTextStyle
    public var label: DFTextStyle

    public init(
        display: DFTextStyle = DFTextStyle(font: .system(size: 34, weight: .bold), lineSpacing: 4, tracking: -0.5),
        title: DFTextStyle = DFTextStyle(font: .system(size: 28, weight: .semibold), lineSpacing: 2),
        headline: DFTextStyle = DFTextStyle(font: .system(size: 17, weight: .semibold)),
        body: DFTextStyle = DFTextStyle(font: .system(size: 17, weight: .regular), lineSpacing: 2),
        caption: DFTextStyle = DFTextStyle(font: .system(size: 12, weight: .regular), lineSpacing: 1),
        label: DFTextStyle = DFTextStyle(font: .system(size: 13, weight: .medium))
    ) {
        self.display = display
        self.title = title
        self.headline = headline
        self.body = body
        self.caption = caption
        self.label = label
    }

    public static let `default` = DFTypographyTokens()
}
