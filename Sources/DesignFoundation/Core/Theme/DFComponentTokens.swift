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
