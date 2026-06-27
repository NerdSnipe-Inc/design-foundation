import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFColorTokens")
struct DFColorTokensTests {

    @Test("default primary color is not clear")
    func defaultPrimaryIsNotClear() {
        let tokens = DFColorTokens.default
        #expect(tokens.primary != .clear)
    }

    @Test("tokens are mutatable")
    func tokensAreMutatable() {
        var tokens = DFColorTokens.default
        tokens.primary = .red
        #expect(tokens.primary == .red)
    }

    @Test("respectsColorScheme defaults to true")
    func respectsColorSchemeDefault() {
        #expect(DFColorTokens.default.respectsColorScheme == true)
    }
}
