import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFAccordionGroupState")
struct DFAccordionGroupStateTests {
    @Test("starts collapsed by default and defaults to exclusive")
    func defaults() {
        let state = DFAccordionGroupState()
        #expect(state.expandedIDs.isEmpty)
        #expect(!state.allowsMultipleExpanded)
        #expect(!state.isExpanded("a"))
    }

    @Test("exclusive: expanding another id collapses the previous one")
    func exclusiveSwapsOpenItem() {
        var state = DFAccordionGroupState()
        state.toggle("a")
        #expect(state.isExpanded("a"))
        state.toggle("b")
        #expect(state.isExpanded("b"))
        #expect(!state.isExpanded("a"))
        #expect(state.expandedIDs == ["b"])
    }

    @Test("exclusive: toggling the open id collapses it, leaving none open")
    func exclusiveToggleClosesOpenItem() {
        var state = DFAccordionGroupState()
        state.toggle("a")
        state.toggle("a")
        #expect(state.expandedIDs.isEmpty)
    }

    @Test("exclusive: seeding more than one id keeps only one")
    func exclusiveSeedIsTrimmed() {
        let state = DFAccordionGroupState(expandedIDs: ["b", "a", "c"])
        #expect(state.expandedIDs == ["a"])
    }

    @Test("multi: several ids can be open at once")
    func multiAllowsSeveral() {
        var state = DFAccordionGroupState(allowsMultipleExpanded: true)
        state.toggle("a")
        state.toggle("b")
        #expect(state.expandedIDs == ["a", "b"])
        state.toggle("a")
        #expect(state.expandedIDs == ["b"])
    }

    @Test("multi: seed is kept as-is")
    func multiSeedIsKept() {
        let state = DFAccordionGroupState(allowsMultipleExpanded: true, expandedIDs: ["a", "b"])
        #expect(state.expandedIDs == ["a", "b"])
    }

    @Test("expand, collapse and collapseAll")
    func explicitMutations() {
        var state = DFAccordionGroupState(allowsMultipleExpanded: true)
        state.expand("a")
        state.expand("a")
        state.expand("b")
        #expect(state.expandedIDs == ["a", "b"])
        state.collapse("a")
        #expect(state.expandedIDs == ["b"])
        state.collapse("missing")
        #expect(state.expandedIDs == ["b"])
        state.collapseAll()
        #expect(state.expandedIDs.isEmpty)
    }

    @Test("setExpanded(false) on a closed id is a no-op")
    func collapseClosedIsNoOp() {
        var state = DFAccordionGroupState()
        state.setExpanded(false, for: "a")
        #expect(state.expandedIDs.isEmpty)
    }

    @Test("states with the same contents are equal")
    func equality() {
        #expect(DFAccordionGroupState(expandedIDs: ["a"]) == DFAccordionGroupState(expandedIDs: ["a"]))
        #expect(DFAccordionGroupState(expandedIDs: ["a"]) != DFAccordionGroupState(allowsMultipleExpanded: true, expandedIDs: ["a"]))
    }
}

@Suite("DFAccordionStyleConfiguration")
struct DFAccordionStyleConfigurationTests {
    @Test("holds values and the toggle action fires")
    @MainActor
    func holdsValuesAndToggles() {
        var toggled = false
        let config = DFAccordionStyleConfiguration(
            title: "Shipping",
            subtitle: "2-4 days",
            isExpanded: true,
            label: AnyView(Text("Shipping")),
            content: AnyView(Text("Body")),
            toggle: { toggled = true },
            theme: .default
        )
        #expect(config.title == "Shipping")
        #expect(config.subtitle == "2-4 days")
        #expect(config.isExpanded)
        config.toggle()
        #expect(toggled)
    }

    @Test("subtitle defaults to nil")
    func subtitleDefaultsToNil() {
        let config = DFAccordionStyleConfiguration(
            title: "T",
            isExpanded: false,
            label: AnyView(EmptyView()),
            content: AnyView(EmptyView()),
            toggle: {},
            theme: .default
        )
        #expect(config.subtitle == nil)
        #expect(!config.isExpanded)
    }
}

@Suite("DFAccordion Environment")
struct DFAccordionEnvironmentTests {
    @Test("dfAccordionStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfAccordionStyle
    }

    @Test("built-in style shorthands resolve")
    func shorthandsResolve() {
        let _: DFStandardAccordionStyle = .standard
        let _: DFCardAccordionStyle = .card
        let _: DFPlainAccordionStyle = .plain
    }
}

@Suite("DFAccordionTokens")
struct DFAccordionTokensTests {
    @Test("default tokens are nil (inherit from theme)")
    func defaultTokensAreNil() {
        #expect(DFAccordionTokens.default.headerPadding == nil)
        #expect(DFAccordionTokens.default.contentPadding == nil)
        #expect(DFComponentTokens.default.accordion.headerPadding == nil)
    }
}
