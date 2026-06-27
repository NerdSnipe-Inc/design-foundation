import Foundation
import SwiftUI

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

// MARK: - Root

public struct DFComponentTokens: Sendable {
    public var button: DFButtonTokens
    public var textField: DFTextFieldTokens
    public var card: DFCardTokens
    public var avatar: DFAvatarTokens
    public var badge: DFBadgeTokens
    public var icon: DFIconTokens

    public init(
        button: DFButtonTokens = .default,
        textField: DFTextFieldTokens = .default,
        card: DFCardTokens = .default,
        avatar: DFAvatarTokens = .default,
        badge: DFBadgeTokens = .default,
        icon: DFIconTokens = .default
    ) {
        self.button = button
        self.textField = textField
        self.card = card
        self.avatar = avatar
        self.badge = badge
        self.icon = icon
    }

    public static let `default` = DFComponentTokens()
}
