import Foundation

// MARK: - Button

public struct DFButtonTokens: Sendable {
    /// nil = inherit from DFRadiusTokens.md
    public var cornerRadius: CGFloat?
    /// nil = inherit from DFSpacingTokens.lg
    public var horizontalPadding: CGFloat?
    /// nil = inherit from DFSpacingTokens.md
    public var verticalPadding: CGFloat?
    /// nil = inherit from DFTypographyTokens.label
    public var labelStyle: DFTextStyle?

    public init(
        cornerRadius: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        labelStyle: DFTextStyle? = nil
    ) {
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.labelStyle = labelStyle
    }

    public static let `default` = DFButtonTokens()
}

// MARK: - TextField

public struct DFTextFieldTokens: Sendable {
    /// nil = inherit from DFRadiusTokens.md
    public var cornerRadius: CGFloat?
    /// nil = inherit from DFSpacingTokens.md
    public var horizontalPadding: CGFloat?
    /// nil = inherit from DFSpacingTokens.sm
    public var verticalPadding: CGFloat?
    /// nil = inherit from DFTypographyTokens.body
    public var inputStyle: DFTextStyle?
    /// nil = inherit from DFTypographyTokens.caption
    public var labelStyle: DFTextStyle?

    public init(
        cornerRadius: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        inputStyle: DFTextStyle? = nil,
        labelStyle: DFTextStyle? = nil
    ) {
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.inputStyle = inputStyle
        self.labelStyle = labelStyle
    }

    public static let `default` = DFTextFieldTokens()
}

// MARK: - Card

public struct DFCardTokens: Sendable {
    /// nil = inherit from DFRadiusTokens.lg
    public var cornerRadius: CGFloat?
    /// nil = inherit from DFSpacingTokens.lg
    public var padding: CGFloat?

    public init(cornerRadius: CGFloat? = nil, padding: CGFloat? = nil) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    public static let `default` = DFCardTokens()
}

// MARK: - Avatar

public struct DFAvatarTokens: Sendable {
    public var defaultSize: CGFloat?    // nil = 40
    public var borderWidth: CGFloat?    // nil = 0 (no border)

    public init(defaultSize: CGFloat? = nil, borderWidth: CGFloat? = nil) {
        self.defaultSize = defaultSize
        self.borderWidth = borderWidth
    }

    public static let `default` = DFAvatarTokens()
}

// MARK: - Badge

public struct DFBadgeTokens: Sendable {
    public var cornerRadius: CGFloat?   // nil = inherit DFRadiusTokens.full
    public var horizontalPadding: CGFloat?
    public var verticalPadding: CGFloat?

    public init(
        cornerRadius: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil
    ) {
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    public static let `default` = DFBadgeTokens()
}

// MARK: - Chip

public struct DFChipTokens: Sendable {
    public var cornerRadius: CGFloat?   // nil = inherit DFRadiusTokens.full
    public var horizontalPadding: CGFloat?
    public var verticalPadding: CGFloat?
    public var iconSpacing: CGFloat?

    public init(
        cornerRadius: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        iconSpacing: CGFloat? = nil
    ) {
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.iconSpacing = iconSpacing
    }

    public static let `default` = DFChipTokens()
}

// MARK: - Rating

public struct DFRatingTokens: Sendable {
    public var starSize: CGFloat?   // nil = 16
    public var spacing: CGFloat?    // nil = inherit DFSpacingTokens.xs

    public init(starSize: CGFloat? = nil, spacing: CGFloat? = nil) {
        self.starSize = starSize
        self.spacing = spacing
    }

    public static let `default` = DFRatingTokens()
}

// MARK: - Price

public struct DFPriceTokens: Sendable {
    public var spacing: CGFloat?    // nil = inherit DFSpacingTokens.xs, gap between amount and compare-at text

    public init(spacing: CGFloat? = nil) {
        self.spacing = spacing
    }

    public static let `default` = DFPriceTokens()
}

// MARK: - PriceSummary

public struct DFPriceSummaryTokens: Sendable {
    public var rowSpacing: CGFloat?   // nil = inherit DFSpacingTokens.xs

    public init(rowSpacing: CGFloat? = nil) {
        self.rowSpacing = rowSpacing
    }

    public static let `default` = DFPriceSummaryTokens()
}

// MARK: - EntityRow

public struct DFEntityRowTokens: Sendable {
    public var mediaSize: CGFloat?   // nil = 40

    public init(mediaSize: CGFloat? = nil) {
        self.mediaSize = mediaSize
    }

    public static let `default` = DFEntityRowTokens()
}

// MARK: - EntityCard

public struct DFEntityCardTokens: Sendable {
    public var mediaHeight: CGFloat?   // nil = 120

    public init(mediaHeight: CGFloat? = nil) {
        self.mediaHeight = mediaHeight
    }

    public static let `default` = DFEntityCardTokens()
}

// MARK: - Grid

public struct DFGridTokens: Sendable {
    public var spacing: CGFloat?   // nil = inherit DFSpacingTokens.sm

    public init(spacing: CGFloat? = nil) {
        self.spacing = spacing
    }

    public static let `default` = DFGridTokens()
}

// MARK: - Carousel

public struct DFCarouselTokens: Sendable {
    public var spacing: CGFloat?   // nil = inherit DFSpacingTokens.sm

    public init(spacing: CGFloat? = nil) {
        self.spacing = spacing
    }

    public static let `default` = DFCarouselTokens()
}

// MARK: - QuantityStepper

public struct DFQuantityStepperTokens: Sendable {
    public var buttonSize: CGFloat?     // nil = 28 (.bordered) / 24 (.compact)
    public var cornerRadius: CGFloat?   // nil = inherit DFRadiusTokens.full

    public init(buttonSize: CGFloat? = nil, cornerRadius: CGFloat? = nil) {
        self.buttonSize = buttonSize
        self.cornerRadius = cornerRadius
    }

    public static let `default` = DFQuantityStepperTokens()
}

// MARK: - Banner

public struct DFBannerTokens: Sendable {
    public var cornerRadius: CGFloat?   // nil = inherit DFRadiusTokens.md
    public var padding: CGFloat?        // nil = inherit DFSpacingTokens.md

    public init(cornerRadius: CGFloat? = nil, padding: CGFloat? = nil) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    public static let `default` = DFBannerTokens()
}

// MARK: - Icon

public struct DFIconTokens: Sendable {
    public var defaultSize: CGFloat?    // nil = 24

    public init(defaultSize: CGFloat? = nil) {
        self.defaultSize = defaultSize
    }

    public static let `default` = DFIconTokens()
}

// MARK: - Divider

public struct DFDividerTokens: Sendable {
    /// nil = 1 (DFStandardDividerStyle's line thickness)
    public var lineWidth: CGFloat?

    public init(lineWidth: CGFloat? = nil) {
        self.lineWidth = lineWidth
    }

    public static let `default` = DFDividerTokens()
}

// MARK: - ProgressBar

public struct DFProgressBarTokens: Sendable {
    /// nil = 6 (DFDefaultProgressBarStyle's linear track/fill height)
    public var trackHeight: CGFloat?

    public init(trackHeight: CGFloat? = nil) {
        self.trackHeight = trackHeight
    }

    public static let `default` = DFProgressBarTokens()
}

// MARK: - Skeleton

public struct DFSkeletonTokens: Sendable {
    /// nil = 8 (DFSkeleton's default shape corner radius when no shape is specified)
    public var defaultCornerRadius: CGFloat?
    /// nil = 0.25 (DFDefaultSkeletonStyle's base shimmer gradient opacity)
    public var shimmerBaseOpacity: Double?
    /// nil = 0.55 (DFDefaultSkeletonStyle's highlight shimmer gradient opacity)
    public var shimmerHighlightOpacity: Double?
    /// nil = 1.4 (DFSkeleton's shimmer animation duration, in seconds)
    public var shimmerDuration: Double?

    public init(
        defaultCornerRadius: CGFloat? = nil,
        shimmerBaseOpacity: Double? = nil,
        shimmerHighlightOpacity: Double? = nil,
        shimmerDuration: Double? = nil
    ) {
        self.defaultCornerRadius = defaultCornerRadius
        self.shimmerBaseOpacity = shimmerBaseOpacity
        self.shimmerHighlightOpacity = shimmerHighlightOpacity
        self.shimmerDuration = shimmerDuration
    }

    public static let `default` = DFSkeletonTokens()
}

// MARK: - Toggle

public struct DFToggleTokens: Sendable {
    /// nil = 20 (DFCheckboxToggleStyle's checkbox box frame size)
    public var checkboxSize: CGFloat?

    public init(checkboxSize: CGFloat? = nil) {
        self.checkboxSize = checkboxSize
    }

    public static let `default` = DFToggleTokens()
}

// MARK: - DatePicker

public struct DFDatePickerTokens: Sendable {
    /// nil = inherit from DFSpacingTokens.md
    public var horizontalPadding: CGFloat?
    /// nil = inherit from DFSpacingTokens.sm
    public var verticalPadding: CGFloat?

    public init(horizontalPadding: CGFloat? = nil, verticalPadding: CGFloat? = nil) {
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    public static let `default` = DFDatePickerTokens()
}

// MARK: - Sidebar

public struct DFSidebarTokens: Sendable {
    /// nil = inherit from DFRadiusTokens.md
    public var itemCornerRadius: CGFloat?
    /// nil = 16 (icon font point size in sidebar item rows)
    public var iconSize: CGFloat?

    public init(itemCornerRadius: CGFloat? = nil, iconSize: CGFloat? = nil) {
        self.itemCornerRadius = itemCornerRadius
        self.iconSize = iconSize
    }

    public static let `default` = DFSidebarTokens()
}

// MARK: - TabBar

public struct DFTabBarTokens: Sendable {
    /// nil = 22 (standard style) / 24 (minimal style) — tab bar icon font point size
    public var iconSize: CGFloat?

    public init(iconSize: CGFloat? = nil) {
        self.iconSize = iconSize
    }

    public static let `default` = DFTabBarTokens()
}

// MARK: - Root

public struct DFComponentTokens: Sendable {
    public var button: DFButtonTokens
    public var textField: DFTextFieldTokens
    public var card: DFCardTokens
    public var avatar: DFAvatarTokens
    public var badge: DFBadgeTokens
    public var chip: DFChipTokens
    public var rating: DFRatingTokens
    public var price: DFPriceTokens
    public var priceSummary: DFPriceSummaryTokens
    public var entityRow: DFEntityRowTokens
    public var entityCard: DFEntityCardTokens
    public var grid: DFGridTokens
    public var carousel: DFCarouselTokens
    public var quantityStepper: DFQuantityStepperTokens
    public var banner: DFBannerTokens
    public var icon: DFIconTokens
    public var divider: DFDividerTokens
    public var progressBar: DFProgressBarTokens
    public var skeleton: DFSkeletonTokens
    public var toggle: DFToggleTokens
    public var datePicker: DFDatePickerTokens
    public var sidebar: DFSidebarTokens
    public var tabBar: DFTabBarTokens

    public init(
        button: DFButtonTokens = .default,
        textField: DFTextFieldTokens = .default,
        card: DFCardTokens = .default,
        avatar: DFAvatarTokens = .default,
        badge: DFBadgeTokens = .default,
        chip: DFChipTokens = .default,
        rating: DFRatingTokens = .default,
        price: DFPriceTokens = .default,
        priceSummary: DFPriceSummaryTokens = .default,
        entityRow: DFEntityRowTokens = .default,
        entityCard: DFEntityCardTokens = .default,
        grid: DFGridTokens = .default,
        carousel: DFCarouselTokens = .default,
        quantityStepper: DFQuantityStepperTokens = .default,
        banner: DFBannerTokens = .default,
        icon: DFIconTokens = .default,
        divider: DFDividerTokens = .default,
        progressBar: DFProgressBarTokens = .default,
        skeleton: DFSkeletonTokens = .default,
        toggle: DFToggleTokens = .default,
        datePicker: DFDatePickerTokens = .default,
        sidebar: DFSidebarTokens = .default,
        tabBar: DFTabBarTokens = .default
    ) {
        self.button = button
        self.textField = textField
        self.card = card
        self.avatar = avatar
        self.badge = badge
        self.chip = chip
        self.rating = rating
        self.price = price
        self.priceSummary = priceSummary
        self.entityRow = entityRow
        self.entityCard = entityCard
        self.grid = grid
        self.carousel = carousel
        self.quantityStepper = quantityStepper
        self.banner = banner
        self.icon = icon
        self.divider = divider
        self.progressBar = progressBar
        self.skeleton = skeleton
        self.toggle = toggle
        self.datePicker = datePicker
        self.sidebar = sidebar
        self.tabBar = tabBar
    }

    public static let `default` = DFComponentTokens()
}
