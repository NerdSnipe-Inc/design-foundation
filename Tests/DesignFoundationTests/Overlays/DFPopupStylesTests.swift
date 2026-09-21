import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFPopupStyle built-ins")
@MainActor
struct DFPopupBuiltInStyleTests {
    private func make<S: DFPopupStyle & Sendable>(_ style: S, kind: DFPopupKind = .center) {
        let config = DFPopupStyleConfiguration(content: AnyView(Text("x")), kind: kind, position: .center, theme: .default)
        _ = AnyDFPopupStyle(style).makeBody(configuration: config)
    }

    @Test("every static member exists, is Sendable and renders for every kind")
    func statics() {
        for kind in [DFPopupKind.center, .toast, .floater, .sheet] {
            make(.standard, kind: kind)
            make(.frosted, kind: kind)
            make(.accent, kind: kind)
            make(.gradient, kind: kind)
            make(.inverse, kind: kind)
            make(.outlined, kind: kind)
            make(.tinted(.info), kind: kind)
            if #available(iOS 26, macOS 26, *) { make(.glass, kind: kind) }
        }
    }

    @Test("styles are distinct types")
    func distinct() {
        let types: [Any.Type] = [
            DFStandardPopupStyle.self, DFFrostedPopupStyle.self, DFAccentPopupStyle.self,
            DFGradientPopupStyle.self, DFInversePopupStyle.self, DFOutlinedPopupStyle.self,
            DFTintedPopupStyle.self,
        ]
        #expect(Set(types.map { ObjectIdentifier($0) }).count == types.count)
    }

    @Test("tinted keeps its severity")
    func tinted() {
        #expect(DFTintedPopupStyle(severity: .error).severity == .error)
        let s: DFTintedPopupStyle = .tinted(.warning)
        #expect(s.severity == .warning)
    }

    @Test("theme preset tokens keep every style renderable")
    func presets() {
        for theme in [DFTheme.slateLight, .auroraDark, .copperLight, .sageDark, .garnetLight] {
            let config = DFPopupStyleConfiguration(content: AnyView(Text("x")), kind: .sheet, position: .bottom, theme: theme)
            _ = DFAccentPopupStyle().makeBody(configuration: config)
            _ = DFGradientPopupStyle().makeBody(configuration: config)
        }
    }
}

@Suite("DFContrast")
@MainActor
struct DFContrastTests {
    @Test("white on dark fills, near-black on light fills")
    func foreground() {
        let env = EnvironmentValues()
        let onDark = DFContrast.foreground(on: [Color(red: 0.05, green: 0.1, blue: 0.3)], in: env)
        let onLight = DFContrast.foreground(on: [Color(red: 0.95, green: 0.9, blue: 1.0)], in: env)
        #expect(DFContrast.luminance(of: onDark, in: env) > 0.9)
        #expect(DFContrast.luminance(of: onLight, in: env) < 0.1)
    }
}

@Suite("On-fill contrast across presets")
@MainActor
struct DFOnFillContrastTests {
    private static let themes: [(String, DFTheme)] = [
        ("slateLight", .slateLight), ("slateDark", .slateDark),
        ("auroraLight", .auroraLight), ("auroraDark", .auroraDark),
        ("copperLight", .copperLight), ("copperDark", .copperDark),
        ("sageLight", .sageLight), ("sageDark", .sageDark),
        ("garnetLight", .garnetLight), ("garnetDark", .garnetDark),
    ]

    private func check(_ stops: [Color], theme: DFTheme, _ name: String) {
        let env = EnvironmentValues()
        let dark = DFContrast.luminance(of: theme.colors.background, in: env) < 0.2
        let r = DFContrast.resolve(stops: stops, darkScheme: dark, in: env)
        let fg = DFContrast.luminance(of: r.foreground, in: env)
        for stop in r.stops {
            let ratio = DFContrast.ratio(fg, DFContrast.luminance(of: stop, in: env))
            #expect(ratio >= 4.5, "\(name): \(ratio)")
        }
        if dark { #expect(r.foreground == .white, "\(name) dark uses light text") }
    }

    @Test("accent and gradient reach 4.5:1 on every stop in every preset")
    func popups() {
        for (name, theme) in Self.themes {
            check([theme.colors.primary], theme: theme, name + " accent")
            check([theme.colors.primary, theme.colors.accent], theme: theme, name + " gradient")
        }
    }

    @Test("filled toast severity colors reach 4.5:1 in every preset")
    func toasts() {
        for (name, theme) in Self.themes {
            for s in [DFToastSeverity.info, .success, .warning, .error] {
                check([s.color(in: theme)], theme: theme, "\(name) \(s)")
            }
        }
    }

    @Test("gray resolves to gamma-encoded components")
    func encoding() {
        let env = EnvironmentValues()
        let l = DFContrast.luminance(of: Color(red: 0.5, green: 0.5, blue: 0.5), in: env)
        #expect(abs(l - 0.2140) < 0.01)
    }
}

@Suite("DFPopupBackdrop")
struct DFPopupBackdropTests {
    @Test("dimsBackground alone still decides the backdrop")
    func legacy() {
        #expect(DFPopupConfiguration(dimsBackground: true).resolvedBackdrop == .dim)
        #expect(DFPopupConfiguration(dimsBackground: false).resolvedBackdrop == .none)
        #expect(DFPopupConfiguration.centered.backdrop == nil)
    }

    @Test("explicit backdrop wins over dimsBackground")
    func precedence() {
        #expect(DFPopupConfiguration(dimsBackground: false, backdrop: .blur).resolvedBackdrop == .blur)
        #expect(DFPopupConfiguration(dimsBackground: true, backdrop: DFPopupBackdrop.none).resolvedBackdrop == .none)
        #expect(DFPopupConfiguration(dimsBackground: false, backdrop: .dim).resolvedBackdrop == .dim)
    }

    @Test("existing presets are unchanged")
    func presets() {
        #expect(DFPopupConfiguration.toast().resolvedBackdrop == .none)
        #expect(DFPopupConfiguration.floater().resolvedBackdrop == .none)
    }
}

@Suite("DFPopupKind.sheet")
struct DFPopupSheetTests {
    @Test("sheet preset is bottom-anchored, dismissable by drag and dimmed")
    func preset() {
        let c = DFPopupConfiguration.sheet()
        #expect(c.kind == .sheet)
        #expect(c.resolvedPosition == .bottom)
        #expect(c.resolvedPosition.exitEdge == .bottom)
        #expect(c.dismissOnDrag)
        #expect(c.resolvedBackdrop == .dim)
        #expect(DFPopupConfiguration.sheet(backdrop: .blur).resolvedBackdrop == .blur)
        #expect(DFPopupConfiguration.sheet(backdrop: DFPopupBackdrop.none).dimsBackground == false)
    }

    @Test("sheet ignores a non-bottom position")
    func forcedBottom() {
        var c = DFPopupConfiguration.sheet()
        c.position = .top
        #expect(c.resolvedPosition == .bottom)
    }

    @Test("sheet needs a longer pull than other kinds")
    func distance() {
        let down = CGSize(width: 0, height: 80)
        #expect(DFPopupDrag.shouldDismiss(translation: down, predictedEnd: .zero, toward: .bottom))
        let shortPull = DFPopupDrag.shouldDismiss(translation: down, predictedEnd: .zero, toward: .bottom, kind: DFPopupKind.sheet)
        #expect(shortPull == false)
        #expect(DFPopupDrag.shouldDismiss(translation: CGSize(width: 0, height: 101), predictedEnd: .zero, toward: .bottom, kind: .sheet))
        #expect(DFPopupDrag.shouldDismiss(translation: CGSize(width: 0, height: 10), predictedEnd: CGSize(width: 0, height: 260), toward: .bottom, kind: .sheet))
        let wrongWay = DFPopupDrag.shouldDismiss(translation: CGSize(width: 0, height: -300), predictedEnd: CGSize(width: 0, height: -900), toward: .bottom, kind: DFPopupKind.sheet)
        #expect(wrongWay == false)
    }
}

@Suite("Animation spring token")
struct DFSpringTokenTests {
    @Test("default theme carries a spring token")
    func spring() {
        _ = DFTheme.default.animation.spring
        _ = DFAnimationTokens(spring: .bouncy)
    }
}

@Suite("DFPopupCard")
@MainActor
struct DFPopupCardTests {
    @Test("init variants compile and build a body")
    func variants() {
        let action = DFPopupAction("Go") {}
        _ = DFPopupCard(title: "Only title")
        _ = DFPopupCard(icon: "star", title: "T", message: "M", primaryAction: action)
        _ = DFPopupCard(icon: "star", iconTint: .severity(.error), title: "T", alignment: .leading,
                        primaryAction: action, secondaryAction: action, tertiaryAction: action, onClose: {})
        _ = DFPopupCard(title: "Custom") { Text("body") }
        _ = DFPopupCard(title: "Hero", media: { Color.red.frame(height: 80) }, content: { Text("body") })
        _ = DFPopupHeader(icon: "star", title: "T", message: "M", alignment: .center)
        _ = DFPopupActions(primary: action, secondary: action, tertiary: action)
        _ = DFPopupIconBadge(systemImage: "star", tint: .soft)
    }

    @Test("action keeps role and runs its closure")
    func action() {
        var ran = false
        let a = DFPopupAction("Delete", role: .destructive) { ran = true }
        a.action()
        #expect(ran)
        #expect(a.role == .destructive)
        #expect(a.title == "Delete")
    }

    @Test("alignment maps to layout values")
    func alignment() {
        #expect(DFPopupCardAlignment.center.text == .center)
        #expect(DFPopupCardAlignment.leading.text == .leading)
    }
}
