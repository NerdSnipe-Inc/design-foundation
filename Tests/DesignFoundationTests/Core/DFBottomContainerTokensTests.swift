import Testing
@testable import DesignFoundation

@Suite("DFBottomContainerTokens")
struct DFBottomContainerTokensTests {
    @Test("default has nil padding and cornerRadius")
    func defaultsAreNil() {
        #expect(DFBottomContainerTokens.default.padding == nil)
        #expect(DFBottomContainerTokens.default.cornerRadius == nil)
    }

    @Test("component tokens expose a bottomContainer field")
    func componentTokensDefault() {
        #expect(DFComponentTokens.default.bottomContainer.padding == nil)
    }

    @Test("custom override is preserved")
    func customOverride() {
        var theme = DFTheme.default
        theme.components.bottomContainer = DFBottomContainerTokens(padding: 20)
        #expect(theme.components.bottomContainer.padding == 20)
    }
}
