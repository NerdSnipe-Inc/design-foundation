import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFInlineTagView")
struct DFInlineTagViewTests {
    @Test("stores the label text verbatim")
    func storesText() {
        let tag = DFInlineTagView("Design")
        #expect(tag.text == "Design")
    }

    @Test("does not mutate or trim the given text")
    func doesNotTrim() {
        let tag = DFInlineTagView("  Spaced  ")
        #expect(tag.text == "  Spaced  ")
    }
}
