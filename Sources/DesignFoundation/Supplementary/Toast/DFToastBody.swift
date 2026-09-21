import SwiftUI

/// Which built-in appearance `DFToastBody` draws.
enum DFToastLook: Sendable {
    case standard, tinted, filled, inverse, frosted, glass, banner, compact
}

/// Shared renderer behind every built-in toast style: icon badge, title/text stack,
/// optional action button, and the look-specific surface.
struct DFToastBody: View {
    let configuration: DFToastStyleConfiguration
    let look: DFToastLook

    @Environment(\.self) private var environment
    @Environment(\.displayScale) private var displayScale
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .body) private var badgeSize: CGFloat = 28

    nonisolated init(configuration: DFToastStyleConfiguration, look: DFToastLook) {
        self.configuration = configuration
        self.look = look
    }

    var body: some View {
        let theme = configuration.theme
        let message = configuration.message
        let palette = palette(theme: theme)
        let compact = look == .compact
        let hairline = 1 / displayScale
        let multiline = message.title != nil
        let hPad = compact ? theme.spacing.md : theme.spacing.lg - 2
        let vPad = compact ? theme.spacing.sm : theme.spacing.md - 2

        let stacked = typeSize.isAccessibilitySize
        let content = Group {
            badge(theme: theme, palette: palette, compact: compact)
            texts(theme: theme, palette: palette, compact: compact)
            if message.hasAction, let actionTitle = message.actionTitle {
                actionButton(title: actionTitle, theme: theme, palette: palette)
            }
        }
        // At accessibility sizes a single row leaves no room for text, so the pieces stack.
        let row = AnyLayout(stacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: theme.spacing.sm))
            : AnyLayout(HStackLayout(alignment: multiline && !compact ? .top : .center, spacing: compact ? theme.spacing.sm : theme.spacing.md - 2))) {
            content
        }
        .padding(.leading, hPad)
        .padding(.trailing, message.hasAction ? (look == .banner ? theme.spacing.md : theme.spacing.sm) : hPad)
        .padding(.vertical, vPad)
        .frame(maxWidth: look == .banner ? .infinity : nil, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background { background(theme: theme, palette: palette, hairline: hairline, multiline: multiline) }
        .accessibilityElement(children: .contain)

        if look == .banner {
            row
        } else {
            DFCappedWidth(maxWidth: 460) { row }
        }
    }

    // MARK: Pieces

    @ViewBuilder
    private func badge(theme: DFTheme, palette: Palette, compact: Bool) -> some View {
        if let icon = configuration.message.icon {
            let size = compact ? badgeSize * 0.8 : badgeSize
            ZStack {
                Circle().fill(palette.badgeFill)
                Image(systemName: icon)
                    .font((compact ? Font.caption : Font.footnote).weight(.semibold))
                    .foregroundStyle(palette.badgeGlyph)
            }
            .frame(width: size, height: size)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .accessibilityHidden(true)
        }
    }

    private func texts(theme: DFTheme, palette: Palette, compact: Bool) -> some View {
        let message = configuration.message
        return VStack(alignment: .leading, spacing: 2) {
            if let title = message.title {
                Text(title)
                    .font(theme.typography.labelLarge.font)
                    .foregroundStyle(palette.foreground)
                    .accessibilityAddTraits(.isHeader)
            }
            Text(message.text)
                .font(compact ? theme.typography.label.font : (message.title == nil ? theme.typography.label.font : theme.typography.bodySmall.font))
                .foregroundStyle(message.title == nil ? palette.foreground : palette.secondary)
                .lineLimit(typeSize.isAccessibilitySize ? nil : (compact ? 1 : 3))
        }
        .frame(maxWidth: look == .banner ? .infinity : nil, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenLabel)
    }

    private var spokenLabel: String {
        let m = configuration.message
        let severity = m.severity == .info ? "" : "\(m.severity.spokenName). "
        return severity + [m.title, m.text].compactMap { $0 }.joined(separator: ". ")
    }

    private func actionButton(title: String, theme: DFTheme, palette: Palette) -> some View {
        Button {
            configuration.performAction()
        } label: {
            Text(title)
                .font(theme.typography.label.font.weight(.semibold))
                .foregroundStyle(palette.action)
                .padding(.horizontal, theme.spacing.md)
                .frame(minHeight: 32)
                .background(Capsule().fill(palette.actionFill))
                .contentShape(.interaction, Rectangle().inset(by: -8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    // MARK: Surface

    @ViewBuilder
    private func background(theme: DFTheme, palette: Palette, hairline: CGFloat, multiline: Bool) -> some View {
        switch look {
        case .banner:
            let bleed: Edge.Set = configuration.message.position.exitEdge == .top ? .top : .bottom
            ZStack(alignment: .leading) {
                Rectangle().fill(theme.colors.surfaceElevated)
                Rectangle().fill(palette.stripe).frame(width: 4)
            }
            .shadow(color: theme.shadows.md.color, radius: theme.shadows.md.radius, x: 0, y: theme.shadows.md.y)
            .overlay(alignment: bleed == .top ? .bottom : .top) {
                Rectangle().fill(theme.colors.border).frame(height: hairline)
            }
            .ignoresSafeArea(edges: bleed)
        default:
            if multiline && look != .banner {
                surface(RoundedRectangle(cornerRadius: theme.radius.lg + 8, style: .continuous), theme: theme, palette: palette, hairline: hairline)
            } else {
                surface(Capsule(style: .continuous), theme: theme, palette: palette, hairline: hairline)
            }
        }
    }

    @ViewBuilder
    private func surface<S: InsettableShape>(_ shape: S, theme: DFTheme, palette: Palette, hairline: CGFloat) -> some View {
        if look == .glass, #available(iOS 26, macOS 26, *) {
            shape.fill(Color.clear)
                .glassEffect(.regular.tint(palette.stripe.opacity(0.14)), in: shape)
                .shadow(color: theme.shadows.md.color.opacity(0.6), radius: theme.shadows.md.radius, x: 0, y: theme.shadows.md.y)
        } else {
            let translucent = look == .frosted
            ZStack {
                if translucent {
                    ForEach(Array(palette.shadows.enumerated()), id: \.offset) { _, s in
                        shape.fill(Color.black).shadow(color: s.color, radius: s.radius, x: s.x, y: s.y)
                    }
                    .mask {
                        ZStack {
                            Rectangle().padding(-160)
                            shape.blendMode(.destinationOut)
                        }
                        .compositingGroup()
                    }
                } else if let base = palette.fills.first {
                    ForEach(Array(palette.shadows.enumerated()), id: \.offset) { _, s in
                        shape.fill(base).shadow(color: s.color, radius: s.radius, x: s.x, y: s.y)
                    }
                }
                ForEach(Array(palette.fills.enumerated()), id: \.offset) { _, fill in
                    shape.fill(fill)
                }
            }
            .overlay {
                if let border = palette.border {
                    shape.strokeBorder(border, lineWidth: hairline)
                }
                if look == .frosted {
                    shape.strokeBorder(
                        LinearGradient(colors: [Color.white.opacity(0.45), Color.white.opacity(0.05), theme.colors.border.opacity(0.6)],
                                       startPoint: .top, endPoint: .bottom),
                        lineWidth: max(hairline, 1)
                    )
                }
            }
        }
    }

    // MARK: Palette

    struct Palette {
        var fills: [AnyShapeStyle]
        var border: Color?
        var shadows: [DFShadow]
        var foreground: Color
        var secondary: Color
        var badgeFill: Color
        var badgeGlyph: Color
        var action: Color
        var actionFill: Color
        var stripe: Color
    }

    private func palette(theme: DFTheme) -> Palette {
        let color = configuration.message.severity.color(in: theme)
        switch look {
        case .standard, .compact:
            return Palette(
                fills: [AnyShapeStyle(theme.colors.surfaceElevated)],
                border: theme.colors.border,
                shadows: theme.layeredShadows,
                foreground: theme.colors.textPrimary, secondary: theme.colors.textSecondary,
                badgeFill: color.opacity(0.16), badgeGlyph: color,
                action: theme.colors.textPrimary, actionFill: theme.colors.primary.opacity(0.16),
                stripe: color)
        case .banner:
            return Palette(
                fills: [], border: nil, shadows: [],
                foreground: theme.colors.textPrimary, secondary: theme.colors.textSecondary,
                badgeFill: color.opacity(0.16), badgeGlyph: color,
                action: theme.colors.textPrimary, actionFill: theme.colors.primary.opacity(0.16),
                stripe: color)
        case .tinted:
            return Palette(
                fills: [AnyShapeStyle(theme.colors.surfaceElevated), AnyShapeStyle(color.opacity(0.12))],
                border: color.opacity(0.4),
                shadows: [theme.shadows.sm, DFShadow(color: color.opacity(0.16), radius: 14, x: 0, y: 6)],
                foreground: theme.colors.textPrimary, secondary: theme.colors.textSecondary,
                badgeFill: color.opacity(0.22), badgeGlyph: color,
                action: theme.colors.textPrimary, actionFill: color.opacity(0.18),
                stripe: color)
        case .filled:
            let dark = DFContrast.luminance(of: theme.colors.background, in: environment) < 0.2
            let resolved = DFContrast.resolve(stops: [color], darkScheme: dark, in: environment)
            let fill = resolved.stops[0]
            let fg = resolved.foreground
            return Palette(
                fills: [AnyShapeStyle(fill)],
                border: Color.white.opacity(0.14),
                shadows: [theme.shadows.sm, DFShadow(color: fill.opacity(0.35), radius: 16, x: 0, y: 8)],
                foreground: fg, secondary: fg.opacity(0.88),
                badgeFill: fg.opacity(0.2), badgeGlyph: fg,
                action: fill, actionFill: fg,
                stripe: fill)
        case .inverse:
            return Palette(
                fills: [AnyShapeStyle(theme.colors.textPrimary)],
                border: theme.colors.background.opacity(0.12),
                shadows: theme.layeredShadows,
                foreground: theme.colors.background, secondary: theme.colors.background.opacity(0.75),
                badgeFill: color, badgeGlyph: DFContrast.foreground(on: [color], in: environment),
                action: theme.colors.textPrimary, actionFill: theme.colors.background,
                stripe: color)
        case .frosted, .glass:
            return Palette(
                fills: [AnyShapeStyle(theme.materials.elevatedMaterial), AnyShapeStyle(theme.colors.surfaceElevated.opacity(0.62))],
                border: nil,
                shadows: [theme.shadows.lg.scaled(0.8)],
                foreground: theme.colors.textPrimary, secondary: theme.colors.textPrimary.opacity(0.72),
                badgeFill: color.opacity(0.2), badgeGlyph: color,
                action: theme.colors.textPrimary, actionFill: theme.colors.textPrimary.opacity(0.12),
                stripe: color)
        }
    }
}
