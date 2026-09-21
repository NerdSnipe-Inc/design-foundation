import SwiftUI

// MARK: - Severity colors

extension DFToastSeverity {
    /// The theme's semantic color for this severity.
    func color(in theme: DFTheme) -> Color {
        switch self {
        case .info:    return theme.colors.info
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .error:   return theme.colors.destructive
        }
    }

    /// Accessibility spoken prefix for severities that carry meaning.
    var spokenName: String {
        switch self {
        case .info:    return "Information"
        case .success: return "Success"
        case .warning: return "Warning"
        case .error:   return "Error"
        }
    }
}

// MARK: - Contrast

/// WCAG-style contrast helpers used to pick a legible foreground for filled surfaces.
enum DFContrast {
    static func luminance(of color: Color, in environment: EnvironmentValues) -> Double {
        let c = color.resolve(in: environment)
        func lin(_ v: Float) -> Double {
            let d = Double(v)
            return d <= 0.04045 ? d / 12.92 : pow((d + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * lin(c.red) + 0.7152 * lin(c.green) + 0.0722 * lin(c.blue)
    }

    static func ratio(_ a: Double, _ b: Double) -> Double {
        (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }

    /// White or near-black, whichever reads better across every color in `fills`.
    static func foreground(on fills: [Color], in environment: EnvironmentValues) -> Color {
        let lums = fills.map { luminance(of: $0, in: environment) }
        let white = lums.map { ratio(1, $0) }.min() ?? 1
        let dark = lums.map { ratio(0.005, $0) }.min() ?? 1
        return white >= dark ? Color.white : Color(white: 0.07)
    }

    /// WCAG AA for body text.
    static let bodyRatio: Double = 4.5
    /// Near-black used on light fills.
    static let darkForeground = Color(white: 0.07)
    private static let darkLuminance = 0.006

    /// Fill stops and the foreground that reads on all of them.
    struct OnFill {
        var stops: [Color]
        var foreground: Color
    }

    /// Picks a foreground that reaches at least 4.5:1 on every stop, adjusting the stops
    /// when no single foreground passes.
    ///
    /// White wins whenever it passes. Failing that, a gentle darkening (down to 70%
    /// brightness) is tried so brand colors keep their character. Next, near-black is used
    /// on light schemes when it passes on the untouched stops. Otherwise each stop is
    /// deepened just enough for white to pass. Dark schemes never use near-black fills'
    /// text: pastel dark-mode brand colors are deepened instead, so colored surfaces read
    /// as rich, deep tones rather than pastel slabs.
    static func resolve(stops: [Color], darkScheme: Bool, in environment: EnvironmentValues) -> OnFill {
        let rgb = stops.map { channels($0, in: environment) }
        func whitePasses(_ c: [(Double, Double, Double)]) -> Bool {
            c.allSatisfy { ratio(1, lum($0)) >= bodyRatio }
        }
        if whitePasses(rgb) { return OnFill(stops: stops, foreground: .white) }
        if let mild = deepen(rgb, floor: 0.7) { return OnFill(stops: mild.map(color), foreground: .white) }
        if !darkScheme, rgb.allSatisfy({ ratio(darkLuminance, lum($0)) >= bodyRatio }) {
            return OnFill(stops: stops, foreground: darkForeground)
        }
        let deep = deepen(rgb, floor: 0.25) ?? rgb
        return OnFill(stops: deep.map(color), foreground: .white)
    }

    private static func channels(_ c: Color, in env: EnvironmentValues) -> (Double, Double, Double) {
        let r = c.resolve(in: env)
        return (Double(r.red), Double(r.green), Double(r.blue))
    }

    private static func lum(_ c: (Double, Double, Double)) -> Double {
        func lin(_ d: Double) -> Double { d <= 0.04045 ? d / 12.92 : pow((d + 0.055) / 1.055, 2.4) }
        return 0.2126 * lin(c.0) + 0.7152 * lin(c.1) + 0.0722 * lin(c.2)
    }

    private static func color(_ c: (Double, Double, Double)) -> Color {
        Color(.sRGB, red: c.0, green: c.1, blue: c.2, opacity: 1)
    }

    /// Deepens each stop until white text reaches the AA ratio on it: brightness falls and
    /// saturation rises a little, so pastels become rich jewel tones instead of muddy grays.
    /// nil if that needs going below `floor` of the original brightness.
    private static func deepen(_ stops: [(Double, Double, Double)], floor: Double) -> [(Double, Double, Double)]? {
        var out: [(Double, Double, Double)] = []
        for stop in stops {
            let (h, sat, br) = hsb(stop)
            var factor = 1.0
            var scaled = stop
            while ratio(1, lum(scaled)) < bodyRatio + 0.1 {
                factor -= 0.02
                if factor < floor { return nil }
                let boosted = min(1, sat + (1 - sat) * min(1, (1 - factor) * 1.6))
                scaled = rgb(h: h, s: boosted, b: br * factor)
            }
            out.append(scaled)
        }
        return out
    }

    private static func hsb(_ c: (Double, Double, Double)) -> (Double, Double, Double) {
        let mx = max(c.0, c.1, c.2), mn = min(c.0, c.1, c.2), d = mx - mn
        var h = 0.0
        if d > 0 {
            if mx == c.0 { h = ((c.1 - c.2) / d).truncatingRemainder(dividingBy: 6) }
            else if mx == c.1 { h = (c.2 - c.0) / d + 2 }
            else { h = (c.0 - c.1) / d + 4 }
            h /= 6
            if h < 0 { h += 1 }
        }
        return (h, mx == 0 ? 0 : d / mx, mx)
    }

    private static func rgb(h: Double, s: Double, b: Double) -> (Double, Double, Double) {
        let i = Int(h * 6) % 6
        let f = h * 6 - Double(Int(h * 6))
        let p = b * (1 - s), q = b * (1 - f * s), t = b * (1 - (1 - f) * s)
        switch i {
        case 0: return (b, t, p)
        case 1: return (q, b, p)
        case 2: return (p, b, t)
        case 3: return (p, q, b)
        case 4: return (t, p, b)
        default: return (b, p, q)
        }
    }
}

// MARK: - On-fill environment

/// Set by popup and toast surfaces drawn in a solid or gradient fill so that rich
/// content (icon badges, buttons) knows to draw against a colored backdrop.
private struct DFOnFillLabelKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

/// The insets the popup surface applies around its content; lets `DFPopupCard`
/// bleed its hero media to the surface edges.
private struct DFPopupInsetsKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    /// Non-nil when content sits on a filled surface; the color to draw on top of a
    /// foreground-colored shape (the surface's own fill color).
    var dfOnFillLabel: Color? {
        get { self[DFOnFillLabelKey.self] }
        set { self[DFOnFillLabelKey.self] = newValue }
    }

    var dfPopupInsets: CGFloat {
        get { self[DFPopupInsetsKey.self] }
        set { self[DFPopupInsetsKey.self] = newValue }
    }
}

extension DFTheme {
    /// A theme for content drawn on a colored surface: text, brand and border tokens
    /// are re-pointed at `foreground` so every DF component inside stays legible.
    func onFill(foreground: Color) -> DFTheme {
        var t = self
        t.colors.textPrimary = foreground
        t.colors.textSecondary = foreground.opacity(0.78)
        t.colors.textDisabled = foreground.opacity(0.45)
        t.colors.border = foreground.opacity(0.28)
        t.colors.primary = foreground
        t.colors.accent = foreground
        t.colors.interactiveFill = foreground
        t.colors.surface = foreground.opacity(0.12)
        t.colors.surfaceElevated = foreground.opacity(0.16)
        return t
    }
}

/// Secondary action: `textPrimary` label (always legible, whatever the surface) on a
/// translucent primary-tinted pill.
struct DFPopupSecondaryButtonStyle: DFButtonStyle, Sendable {
    func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.button.cornerRadius ?? theme.radius.md
        let hPad = theme.components.button.horizontalPadding ?? theme.spacing.lg
        let vPad = theme.components.button.verticalPadding ?? theme.spacing.md
        let tint = configuration.role == .destructive ? theme.colors.destructive : theme.colors.primary

        return configuration.label
            .font((theme.components.button.labelStyle ?? theme.typography.label).font)
            .foregroundStyle(configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(tint.opacity(configuration.isPressed ? 0.28 : 0.16))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

/// Primary action on a normal surface when white text would not reach AA on the brand
/// fill: the same pill with `fill` (gently deepened) and a contrast-picked label.
struct DFPopupPrimaryButtonStyle: DFButtonStyle, Sendable {
    let fill: Color
    let labelColor: Color

    func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.button.cornerRadius ?? theme.radius.md
        let hPad = theme.components.button.horizontalPadding ?? theme.spacing.lg
        let vPad = theme.components.button.verticalPadding ?? theme.spacing.md

        return configuration.label
            .font((theme.components.button.labelStyle ?? theme.typography.label).font)
            .foregroundStyle(configuration.isDisabled ? theme.colors.textDisabled : labelColor)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(configuration.isDisabled
                          ? theme.colors.interactiveDisabled
                          : (configuration.isPressed ? fill.opacity(0.8) : fill))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
    }
}

/// Tertiary action: plain text in the theme's secondary text color, legible on any surface.
struct DFPopupTertiaryButtonStyle: DFButtonStyle, Sendable {
    func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let hPad = theme.components.button.horizontalPadding ?? theme.spacing.lg
        let vPad = theme.components.button.verticalPadding ?? theme.spacing.md

        return configuration.label
            .font((theme.components.button.labelStyle ?? theme.typography.label).font)
            .foregroundStyle(configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textSecondary)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .opacity(configuration.isPressed ? 0.6 : (configuration.isDisabled ? 0.5 : 1.0))
            .animation(theme.animation.fast, value: configuration.isPressed)
    }
}

/// Filled button used by default inside colored surfaces: a `foreground` pill with
/// the surface color as its label.
struct DFOnFillFilledButtonStyle: DFButtonStyle, Sendable {
    let labelColor: Color
    /// Use `labelColor` even for destructive buttons (which otherwise get a white label).
    var forcesLabel = false

    func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.button.cornerRadius ?? theme.radius.md
        let hPad = theme.components.button.horizontalPadding ?? theme.spacing.lg
        let vPad = theme.components.button.verticalPadding ?? theme.spacing.md
        let fill = configuration.role == .destructive ? theme.colors.destructive : theme.colors.interactiveFill
        let label = (configuration.role == .destructive && !forcesLabel) ? Color.white : labelColor

        return configuration.label
            .font((theme.components.button.labelStyle ?? theme.typography.label).font)
            .foregroundStyle(configuration.isDisabled
                             ? theme.colors.textDisabled
                             : label)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(configuration.isPressed ? fill.opacity(0.8) : fill)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Shadows

extension DFShadow {
    func scaled(_ factor: Double) -> DFShadow {
        DFShadow(color: color.opacity(factor), radius: radius, x: x, y: y)
    }
}

extension DFTheme {
    /// Tight contact shadow plus a wide ambient one, both derived from the theme's tokens.
    var layeredShadows: [DFShadow] {
        [shadows.sm, shadows.lg.scaled(0.9)]
    }
}

// MARK: - Appearance

/// Everything a popup style decides; the shared `DFPopupChrome` turns it into pixels
/// for every popup kind (center, toast, floater, sheet).
struct DFPopupAppearance {
    /// Drawn bottom to top.
    var fills: [AnyShapeStyle]
    /// Solid border. nil = none.
    var border: Color?
    var borderWidth: CGFloat?
    /// Soft light rim along the top edge, for glassy surfaces.
    var rimHighlight: Bool = false
    var shadows: [DFShadow]
    /// The fills are translucent, so shadows are knocked out beneath the surface.
    var translucent: Bool = false
    /// Brand colors the fill is made of (one = solid, two = diagonal gradient). When set,
    /// content is drawn on a colored surface: the chrome resolves a foreground that reaches
    /// AA contrast on every stop, adjusting the stops if needed, and builds the fill itself.
    var onFillColors: [Color]?
    var resolvedOnFill: DFContrast.OnFill?
    /// Opacity of the colored glow under an on-fill surface. 0 = none.
    var glowOpacity: Double = 0
    /// Explicit foreground for non-derived cases (e.g. inverse).
    var explicitForeground: Color?
    var tint: Color?
    /// Uses Liquid Glass instead of fills.
    var glassTint: Color?
    var usesGlass: Bool = false
}

/// Environment-aware renderer shared by all popup styles.
struct DFPopupChrome: View {
    // Written once in the nonisolated init and only read on the main actor by `body`.
    nonisolated(unsafe) let configuration: DFPopupStyleConfiguration
    nonisolated(unsafe) let base: DFPopupAppearance

    @Environment(\.self) private var environment
    @Environment(\.displayScale) private var displayScale

    nonisolated init(configuration: DFPopupStyleConfiguration, appearance: DFPopupAppearance) {
        self.configuration = configuration
        self.base = appearance
    }

    /// The style's appearance with on-fill stops resolved for contrast.
    private var appearance: DFPopupAppearance {
        var a = base
        guard let stops = base.onFillColors else { return a }
        let theme = configuration.theme
        let resolved = DFContrast.resolve(stops: stops, darkScheme: isDark(theme), in: environment)
        a.resolvedOnFill = resolved
        if resolved.stops.count > 1 {
            a.fills = [AnyShapeStyle(LinearGradient(colors: resolved.stops, startPoint: .topLeading, endPoint: .bottomTrailing))]
        } else if let only = resolved.stops.first {
            a.fills = [AnyShapeStyle(only)]
        }
        var shadows = [theme.shadows.sm]
        if base.glowOpacity > 0, let glow = resolved.stops.first {
            shadows.append(DFShadow(color: glow.opacity(base.glowOpacity), radius: 22, x: 0, y: 11))
        }
        a.shadows = shadows
        return a
    }

    private func isDark(_ theme: DFTheme) -> Bool {
        DFContrast.luminance(of: theme.colors.background, in: environment) < 0.2
    }

    var body: some View {
        let theme = configuration.theme
        let tokens = theme.components.popup
        let padding = tokens.padding ?? theme.spacing.lg
        let radius = tokens.cornerRadius ?? theme.radius.lg
        let kind = configuration.kind
        let foreground = resolvedForeground(theme: theme)
        let contentTheme = appearance.onFillColors != nil || appearance.explicitForeground != nil
            ? theme.onFill(foreground: foreground)
            : theme

        let inner = configuration.content
            .environment(\.dfTheme, contentTheme)
            .environment(\.dfPopupInsets, padding)
            .foregroundStyle(foreground)
            .tint(appearance.tint ?? (appearance.onFillColors != nil ? foreground : theme.colors.primary))
            .modifier(OnFillEnvironment(active: appearance.onFillColors != nil || appearance.explicitForeground != nil,
                                        foreground: foreground,
                                        label: appearance.explicitForeground != nil ? theme.colors.textPrimary : nil,
                                        fillColors: appearance.resolvedOnFill?.stops))

        switch kind {
        case .toast:
            let bleed: Edge.Set = configuration.position.exitEdge == .top ? .top : .bottom
            inner
                .padding(padding)
                .frame(maxWidth: .infinity)
                .background(
                    surface(Rectangle(), theme: theme, hairline: 1 / displayScale)
                        .ignoresSafeArea(edges: bleed)
                )
        case .center, .floater:
            let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
            inner
                .padding(padding)
                .clipShape(shape)
                .background(surface(shape, theme: theme, hairline: 1 / displayScale))
        case .sheet:
            let top = max(radius, theme.radius.lg) + 8
            let shape = UnevenRoundedRectangle(
                topLeadingRadius: top, bottomLeadingRadius: 0,
                bottomTrailingRadius: 0, topTrailingRadius: top,
                style: .continuous
            )
            VStack(spacing: 0) {
                inner
                    .padding(.horizontal, padding)
                    .padding(.top, padding + theme.spacing.lg)
                    .padding(.bottom, padding)
            }
            .frame(maxWidth: .infinity)
            .clipShape(shape)
            .overlay(alignment: .top) {
                Capsule()
                    .fill(foreground.opacity(0.28))
                    .frame(width: 36, height: 5)
                    .padding(.top, theme.spacing.sm)
                    .accessibilityHidden(true)
            }
            .background(
                surface(shape, theme: theme, hairline: 1 / displayScale)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    // MARK: Surface

    @ViewBuilder
    private func surface<S: InsettableShape>(_ shape: S, theme: DFTheme, hairline: CGFloat) -> some View {
        if appearance.usesGlass, #available(iOS 26, macOS 26, *) {
            // An even surface tint under the glass keeps busy content behind the popup from
            // showing through as blobs, so labels always sit on a calm ground.
            ZStack {
                shape.fill(theme.colors.surfaceElevated.opacity(0.72))
                shape
                    .fill(Color.clear)
                    .glassEffect(
                        appearance.glassTint.map { Glass.regular.tint($0) } ?? .regular,
                        in: shape
                    )
            }
                .overlay { border(shape, theme: theme, hairline: hairline) }
                .shadow(color: theme.shadows.md.color.opacity(0.6), radius: theme.shadows.md.radius, x: theme.shadows.md.x, y: theme.shadows.md.y)
        } else {
            ZStack {
                shadowLayer(shape)
                ForEach(Array(appearance.fills.enumerated()), id: \.offset) { _, fill in
                    shape.fill(fill)
                }
            }
            .overlay { border(shape, theme: theme, hairline: hairline) }
        }
    }

    @ViewBuilder
    private func shadowLayer<S: InsettableShape>(_ shape: S) -> some View {
        let layers = ZStack {
            ForEach(Array(appearance.shadows.enumerated()), id: \.offset) { _, s in
                if let base = appearance.fills.first {
                    shape.fill(appearance.translucent ? AnyShapeStyle(Color.black) : base).shadow(color: s.color, radius: s.radius, x: s.x, y: s.y)
                }
            }
        }
        if appearance.translucent {
            // Translucent surfaces would show their own shadow through the blur, so the
            // shadow is cut out from underneath the shape.
            layers.mask {
                ZStack {
                    Rectangle().padding(-160)
                    shape.blendMode(.destinationOut)
                }
                .compositingGroup()
            }
        } else {
            layers
        }
    }

    @ViewBuilder
    private func border<S: InsettableShape>(_ shape: S, theme: DFTheme, hairline: CGFloat) -> some View {
        if let color = appearance.border {
            shape.strokeBorder(color, lineWidth: appearance.borderWidth ?? hairline)
        }
        if appearance.rimHighlight {
            shape.strokeBorder(
                LinearGradient(
                    colors: [Color.white.opacity(0.45), Color.white.opacity(0.05), theme.colors.border.opacity(0.6)],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: max(hairline, 1)
            )
        }
    }

    private func resolvedForeground(theme: DFTheme) -> Color {
        if let explicit = appearance.explicitForeground { return explicit }
        if let resolved = appearance.resolvedOnFill { return resolved.foreground }
        return theme.colors.textPrimary
    }
}

/// Publishes the on-fill environment for content on colored surfaces.
private struct OnFillEnvironment: ViewModifier {
    let active: Bool
    let foreground: Color
    let label: Color?
    let fillColors: [Color]?

    func body(content: Content) -> some View {
        if active {
            // The label color drawn on top of foreground-colored shapes is the surface color.
            let surfaceLabel = label ?? fillColors?.first ?? .clear
            content
                .environment(\.dfOnFillLabel, surfaceLabel)
                .environment(\.dfButtonStyle, AnyDFButtonStyle(DFOnFillFilledButtonStyle(labelColor: surfaceLabel)))
        } else {
            content
        }
    }
}

/// Proposes at most `maxWidth` to its child and hugs the result, so a view can wrap
/// long text at a readable width without stretching short content to that width.
struct DFCappedWidth: Layout {
    let maxWidth: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let child = subviews.first else { return .zero }
        return child.sizeThatFits(capped(proposal))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let child = subviews.first else { return }
        let size = child.sizeThatFits(capped(proposal))
        child.place(at: bounds.origin, anchor: .topLeading, proposal: ProposedViewSize(size))
    }

    private func capped(_ proposal: ProposedViewSize) -> ProposedViewSize {
        ProposedViewSize(width: proposal.width.map { min($0, maxWidth) }, height: proposal.height)
    }
}
