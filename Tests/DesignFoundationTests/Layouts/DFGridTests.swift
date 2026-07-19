import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFGridColumns")
struct DFGridColumnsTests {
    @Test("fixed and adaptive cases are representable")
    func casesRepresentable() {
        let fixed = DFGridColumns.fixed(3)
        if case .fixed(let count) = fixed {
            #expect(count == 3)
        } else {
            Issue.record("Expected .fixed")
        }

        let adaptive = DFGridColumns.adaptive(minWidth: 120)
        if case .adaptive(let minWidth) = adaptive {
            #expect(minWidth == 120)
        } else {
            Issue.record("Expected .adaptive")
        }
    }
}

@Suite("DFGridTokens")
struct DFGridTokensTests {
    @Test("default tokens are nil (inherit from theme)")
    func defaultTokensAreNil() {
        #expect(DFGridTokens.default.spacing == nil)
    }
}

@Suite("DFCarouselTokens")
struct DFCarouselTokensTests {
    @Test("default tokens are nil (inherit from theme)")
    func defaultTokensAreNil() {
        #expect(DFCarouselTokens.default.spacing == nil)
    }
}
