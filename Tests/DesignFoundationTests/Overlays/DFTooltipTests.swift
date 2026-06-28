import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTooltipPlacement")
struct DFTooltipPlacementTests {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let cases: [DFTooltipPlacement] = [.top, .bottom, .leading, .trailing]
        #expect(Set(cases.map { "\($0)" }).count == 4)
    }
}

@Suite("DFTooltipStyleConfiguration")
struct DFTooltipStyleConfigurationTests {
    @Test("holds all values")
    func holdsValues() {
        let config = DFTooltipStyleConfiguration(
            text: "Hello",
            placement: .top,
            theme: .default
        )
        #expect(config.text == "Hello")
        #expect(config.placement == .top)
    }
}

@Suite("DFTooltip Environment")
struct DFTooltipEnvironmentTests {
    @Test("dfTooltipStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfTooltipStyle
    }
}

@Suite("DFTooltip Styles")
struct DFTooltipStyleTests {
    @Test("bubble style is Sendable")
    func bubbleSendable() {
        let _: any DFTooltipStyle & Sendable = DFBubbleTooltipStyle()
    }
}

@Suite("DFGlassTooltipStyle")
struct DFGlassTooltipStyleTests {
    @Test("glass style is instantiatable")
    func glassInstantiates() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassTooltipStyle()
        }
    }
}
