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

/// Semantic typography tokens backed by SwiftUI text styles so sizes adapt per platform
/// (e.g. macOS body ≈ 13 pt, iOS body ≈ 17 pt) instead of fixed point sizes everywhere.
///
/// **Role guide** — pick by UI job, not by “how big should this feel”:
/// | Token | Use |
/// |---|---|
/// | `display` | Full-screen heroes, onboarding headlines |
/// | `title` | Screen-level focal metrics, modal headers |
/// | `headline` | Screen-level section headers, emphasized KPIs |
/// | `labelLarge` | Card section headers, list group titles |
/// | `body` | Primary reading text, form fields |
/// | `bodySmall` | Supporting body copy, secondary paragraphs |
/// | `label` | Dense row primary text, toolbar labels, table cells |
/// | `caption` | Metadata, timestamps, badges, secondary lines |
///
/// Do **not** use `title` or `display` inside list rows, kanban cards, or sidebar tables.
public struct DFTypographyTokens: Sendable {
    public var display: DFTextStyle
    public var title: DFTextStyle
    public var headline: DFTextStyle
    public var labelLarge: DFTextStyle
    public var body: DFTextStyle
    public var bodySmall: DFTextStyle
    public var label: DFTextStyle
    public var caption: DFTextStyle

    public init(
        display: DFTextStyle = DFTextStyle(
            font: .largeTitle.weight(.bold),
            lineSpacing: 4,
            tracking: -0.5
        ),
        title: DFTextStyle = DFTextStyle(
            font: .title2.weight(.semibold),
            lineSpacing: 2
        ),
        headline: DFTextStyle  = DFTextStyle(font: .headline.weight(.semibold)),
        labelLarge: DFTextStyle = DFTextStyle(font: .callout.weight(.semibold)),
        body: DFTextStyle      = DFTextStyle(font: .body, lineSpacing: 2),
        bodySmall: DFTextStyle = DFTextStyle(font: .callout, lineSpacing: 2),
        label: DFTextStyle     = DFTextStyle(font: .subheadline.weight(.medium)),
        caption: DFTextStyle   = DFTextStyle(font: .caption, lineSpacing: 1)
    ) {
        self.display   = display
        self.title     = title
        self.headline  = headline
        self.labelLarge = labelLarge
        self.body      = body
        self.bodySmall = bodySmall
        self.label     = label
        self.caption   = caption
    }

    public static let `default` = DFTypographyTokens()
}
