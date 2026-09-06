import Testing
@testable import DesignFoundation

@Suite("DFArticleRowTokens")
struct DFArticleRowTokensTests {
    @Test("default has nil titleLines (inherits 2-line default)")
    func defaultIsNil() {
        #expect(DFArticleRowTokens.default.titleLines == nil)
    }

    @Test("component tokens expose an articleRow field defaulting to .default")
    func componentTokensDefault() {
        let tokens = DFComponentTokens.default
        #expect(tokens.articleRow.titleLines == nil)
    }

    @Test("custom titleLines override is preserved")
    func customOverride() {
        var theme = DFTheme.default
        theme.components.articleRow = DFArticleRowTokens(titleLines: 1)
        #expect(theme.components.articleRow.titleLines == 1)
    }
}
