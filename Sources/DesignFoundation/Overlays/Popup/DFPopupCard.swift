import SwiftUI

// MARK: - Action

/// A button in a `DFPopupCard` or `DFPopupActions`.
public struct DFPopupAction: Identifiable {
    public let id = UUID()
    public let title: String
    public let role: DFButtonRole?
    public let action: () -> Void

    public init(_ title: String, role: DFButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.action = action
    }
}

// MARK: - Alignment

/// How a `DFPopupCard`'s text and icon are aligned. `.leading` follows the layout direction.
public enum DFPopupCardAlignment: Sendable {
    case center
    case leading

    var horizontal: HorizontalAlignment { self == .center ? .center : .leading }
    var text: TextAlignment { self == .center ? .center : .leading }
    var frame: Alignment { self == .center ? .center : .leading }
}

// MARK: - Icon badge

/// Tint of a `DFPopupIconBadge`.
public enum DFPopupIconTint: Sendable {
    /// Primary-to-accent gradient with a soft glow.
    case brand
    /// Primary at low opacity behind a primary glyph.
    case soft
    /// Semantic color at low opacity behind a matching glyph.
    case severity(DFToastSeverity)
}

/// A round icon badge, used as the hero of a `DFPopupCard`.
public struct DFPopupIconBadge: View {
    private let systemImage: String
    private let tint: DFPopupIconTint

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfOnFillLabel) private var onFillLabel
    @Environment(\.self) private var environment
    @ScaledMetric(relativeTo: .title) private var size: CGFloat = 56

    public init(systemImage: String, tint: DFPopupIconTint = .brand) {
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
        let glyphFont = Font.title2.weight(.semibold)
        ZStack {
            switch resolved {
            case .onFill:
                Circle().fill(theme.colors.textPrimary.opacity(0.2))
                glyph(glyphFont, theme.colors.textPrimary)
            case .brand:
                let stops = [theme.colors.primary, theme.colors.accent]
                Circle()
                    .fill(LinearGradient(colors: stops, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: theme.colors.primary.opacity(0.35), radius: 10, x: 0, y: 5)
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.22), lineWidth: 1))
                glyph(glyphFont, DFContrast.foreground(on: stops, in: environment))
            case .soft(let color):
                Circle().fill(color.opacity(0.14))
                glyph(glyphFont, color)
            }
        }
        .frame(width: size, height: size)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .accessibilityHidden(true)
    }

    private func glyph(_ font: Font, _ color: Color) -> some View {
        Image(systemName: systemImage).font(font).foregroundStyle(color)
    }

    private enum Resolved {
        case onFill, brand
        case soft(Color)
    }

    private var resolved: Resolved {
        if onFillLabel != nil { return .onFill }
        switch tint {
        case .brand: return .brand
        case .soft: return .soft(theme.colors.primary)
        case .severity(let s): return .soft(s.color(in: theme))
        }
    }
}

// MARK: - Header

/// Optional icon badge, title and message, aligned as a unit.
public struct DFPopupHeader: View {
    private let icon: String?
    private let iconTint: DFPopupIconTint
    private let title: String?
    private let message: String?
    private let alignment: DFPopupCardAlignment

    @Environment(\.dfTheme) private var theme

    public init(
        icon: String? = nil,
        iconTint: DFPopupIconTint = .brand,
        title: String? = nil,
        message: String? = nil,
        alignment: DFPopupCardAlignment = .center
    ) {
        self.icon = icon
        self.iconTint = iconTint
        self.title = title
        self.message = message
        self.alignment = alignment
    }

    public var body: some View {
        VStack(alignment: alignment.horizontal, spacing: theme.spacing.md) {
            if let icon {
                DFPopupIconBadge(systemImage: icon, tint: iconTint)
            }
            if title != nil || message != nil {
                VStack(alignment: alignment.horizontal, spacing: theme.spacing.xs + 2) {
                    if let title {
                        Text(title)
                            .font(theme.typography.title.font)
                            .foregroundStyle(theme.colors.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    if let message {
                        Text(message)
                            .font(theme.typography.body.font)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                .multilineTextAlignment(alignment.text)
                .frame(maxWidth: .infinity, alignment: alignment.frame)
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment.frame)
    }
}

// MARK: - Actions

/// Up to three actions: a filled primary, a tinted secondary and a text tertiary.
/// Primary and secondary share a row when they fit and stack otherwise (large Dynamic Type).
public struct DFPopupActions: View {
    private let primary: DFPopupAction?
    private let secondary: DFPopupAction?
    private let tertiary: DFPopupAction?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfButtonStyle) private var envButtonStyle
    @Environment(\.dynamicTypeSize) private var typeSize

    public init(primary: DFPopupAction? = nil, secondary: DFPopupAction? = nil, tertiary: DFPopupAction? = nil) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }

    public var body: some View {
        if primary != nil || secondary != nil || tertiary != nil {
            VStack(spacing: theme.spacing.sm) {
                if let primary, let secondary, typeSize.isAccessibilitySize {
                    // Side-by-side buttons would hyphenate their labels at accessibility sizes.
                    button(primary, envButtonStyle)
                    button(secondary, AnyDFButtonStyle(DFTintedButtonStyle()))
                } else if let primary, let secondary {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: theme.spacing.sm) {
                            button(secondary, AnyDFButtonStyle(DFTintedButtonStyle()))
                            button(primary, envButtonStyle)
                        }
                        VStack(spacing: theme.spacing.sm) {
                            button(primary, envButtonStyle)
                            button(secondary, AnyDFButtonStyle(DFTintedButtonStyle()))
                        }
                    }
                } else if let primary {
                    button(primary, envButtonStyle)
                } else if let secondary {
                    button(secondary, AnyDFButtonStyle(DFTintedButtonStyle()))
                }
                if let tertiary {
                    button(tertiary, AnyDFButtonStyle(DFGhostButtonStyle()))
                }
            }
        }
    }

    private func button(_ action: DFPopupAction, _ style: AnyDFButtonStyle) -> some View {
        Button(action: action.action) {
            Text(action.title)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 20)
        }
        .buttonStyle(DFBrandedButtonStyle(style, role: action.role))
    }
}

// MARK: - Card

/// A fully composed popup card: optional bleeding hero media or icon badge, title,
/// message, custom content, up to three actions and an optional close button.
///
/// Designed to be the content of `.dfPopup`; it adapts to the active `DFPopupStyle`
/// (including colored ones) and lets hero media run edge to edge inside a popup surface.
public struct DFPopupCard<Media: View, Content: View>: View {
    private let icon: String?
    private let iconTint: DFPopupIconTint
    private let title: String?
    private let message: String?
    private let alignment: DFPopupCardAlignment
    private let primaryAction: DFPopupAction?
    private let secondaryAction: DFPopupAction?
    private let tertiaryAction: DFPopupAction?
    private let onClose: (() -> Void)?
    private let hasMedia: Bool
    private let media: Media
    private let content: Content
    private let hasContent: Bool

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfPopupInsets) private var insets

    init(
        icon: String?, iconTint: DFPopupIconTint, title: String?, message: String?,
        alignment: DFPopupCardAlignment,
        primaryAction: DFPopupAction?, secondaryAction: DFPopupAction?, tertiaryAction: DFPopupAction?,
        onClose: (() -> Void)?,
        hasMedia: Bool, media: Media, hasContent: Bool, content: Content
    ) {
        self.icon = icon
        self.iconTint = iconTint
        self.title = title
        self.message = message
        self.alignment = alignment
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.tertiaryAction = tertiaryAction
        self.onClose = onClose
        self.hasMedia = hasMedia
        self.media = media
        self.hasContent = hasContent
        self.content = content
    }

    /// Full builder form: hero `media` bleeds to the surface edges, `content` sits between the message and the actions.
    public init(
        icon: String? = nil,
        iconTint: DFPopupIconTint = .brand,
        title: String? = nil,
        message: String? = nil,
        alignment: DFPopupCardAlignment = .center,
        primaryAction: DFPopupAction? = nil,
        secondaryAction: DFPopupAction? = nil,
        tertiaryAction: DFPopupAction? = nil,
        onClose: (() -> Void)? = nil,
        @ViewBuilder media: () -> Media,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            icon: icon, iconTint: iconTint, title: title, message: message, alignment: alignment,
            primaryAction: primaryAction, secondaryAction: secondaryAction, tertiaryAction: tertiaryAction,
            onClose: onClose, hasMedia: true, media: media(), hasContent: true, content: content()
        )
    }

    public var body: some View {
        VStack(alignment: alignment.horizontal, spacing: 0) {
            if hasMedia {
                media
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding(.horizontal, -insets)
                    .padding(.top, -insets)
                    .padding(.bottom, theme.spacing.lg)
                    .accessibilityHidden(true)
            }
            VStack(alignment: alignment.horizontal, spacing: theme.spacing.lg) {
                if icon != nil || title != nil || message != nil {
                    DFPopupHeader(icon: icon, iconTint: iconTint, title: title, message: message, alignment: alignment)
                        .padding(.trailing, onClose != nil && !hasMedia && alignment == .leading ? 32 : 0)
                }
                if hasContent { content }
                DFPopupActions(primary: primaryAction, secondary: secondaryAction, tertiary: tertiaryAction)
                    .padding(.top, theme.spacing.xs)
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            if let onClose {
                closeButton(onClose)
                    .offset(x: theme.spacing.sm, y: hasMedia ? -theme.spacing.sm - insets : -theme.spacing.sm)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func closeButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.caption.weight(.bold))
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .foregroundStyle(hasMedia ? Color.primary : theme.colors.textSecondary)
                .frame(width: 28, height: 28)
                .background {
                    if hasMedia {
                        Circle().fill(.ultraThinMaterial)
                    } else {
                        Circle().fill(theme.colors.textPrimary.opacity(0.1))
                    }
                }
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }
}

// MARK: - Convenience inits

public extension DFPopupCard where Media == EmptyView, Content == EmptyView {
    /// Icon, title, message and actions. The default choice for confirmations and prompts.
    init(
        icon: String? = nil,
        iconTint: DFPopupIconTint = .brand,
        title: String? = nil,
        message: String? = nil,
        alignment: DFPopupCardAlignment = .center,
        primaryAction: DFPopupAction? = nil,
        secondaryAction: DFPopupAction? = nil,
        tertiaryAction: DFPopupAction? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.init(
            icon: icon, iconTint: iconTint, title: title, message: message, alignment: alignment,
            primaryAction: primaryAction, secondaryAction: secondaryAction, tertiaryAction: tertiaryAction,
            onClose: onClose, hasMedia: false, media: EmptyView(), hasContent: false, content: EmptyView()
        )
    }
}

public extension DFPopupCard where Media == EmptyView {
    /// Like the default init, with custom `content` between the message and the actions.
    init(
        icon: String? = nil,
        iconTint: DFPopupIconTint = .brand,
        title: String? = nil,
        message: String? = nil,
        alignment: DFPopupCardAlignment = .center,
        primaryAction: DFPopupAction? = nil,
        secondaryAction: DFPopupAction? = nil,
        tertiaryAction: DFPopupAction? = nil,
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            icon: icon, iconTint: iconTint, title: title, message: message, alignment: alignment,
            primaryAction: primaryAction, secondaryAction: secondaryAction, tertiaryAction: tertiaryAction,
            onClose: onClose, hasMedia: false, media: EmptyView(), hasContent: true, content: content()
        )
    }
}
