import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFArrangement rules")
struct DFArrangementRulesTests {
    private let both: Axis.Set = [.horizontal, .vertical]

    @Test("wider than tall goes side by side")
    func wide() {
        #expect(DFArrangementRules.splitAxis(for: CGSize(width: 800, height: 600), axes: both) == .horizontal)
    }

    @Test("taller than wide stacks")
    func tall() {
        #expect(DFArrangementRules.splitAxis(for: CGSize(width: 390, height: 800), axes: both) == .vertical)
    }

    @Test("a square stacks")
    func square() {
        #expect(DFArrangementRules.splitAxis(for: CGSize(width: 500, height: 500), axes: both) == .vertical)
    }

    @Test("a single allowed axis always wins")
    func singleAxis() {
        #expect(DFArrangementRules.splitAxis(for: CGSize(width: 390, height: 800), axes: .horizontal) == .horizontal)
        #expect(DFArrangementRules.splitAxis(for: CGSize(width: 800, height: 390), axes: .vertical) == .vertical)
    }

    @Test("kinds map to their allowed axes")
    func kindAxes() {
        #expect(DFArrangementRules.axes(for: .automatic) == both)
        #expect(DFArrangementRules.axes(for: .split()) == both)
        #expect(DFArrangementRules.axes(for: .split(axes: .horizontal)) == .horizontal)
        #expect(DFArrangementRules.axes(for: .overlay).isEmpty)
    }

    @Test("kinds are comparable values")
    func kindsAreValues() {
        #expect(DFArrangementKind.split() == DFArrangementKind.split(axes: [.horizontal, .vertical]))
        #expect(DFArrangementKind.overlay != DFArrangementKind.automatic)
    }
}
