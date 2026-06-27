import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTextScale")
struct DFTextScaleTests {
    @Test("all cases are distinct")
    func allCasesDistinct() {
        let all = DFTextScale.allCases
        #expect(all.count == 6)
        #expect(Set(all.map(\.rawValue)).count == 6)
    }
}

@Suite("DFTextViewStyleConfiguration")
struct DFTextViewStyleConfigurationTests {
    @Test("configuration holds scale and theme")
    func configurationHoldsValues() {
        let config = DFTextViewStyleConfiguration(
            content: "Hello",
            scale: .headline,
            isDisabled: false,
            theme: .default
        )
        #expect(config.content == "Hello")
        #expect(config.scale == .headline)
        #expect(config.isDisabled == false)
    }
}

@Suite("DFText Environment")
struct DFTextEnvironmentTests {
    @Test("dfTextViewStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfTextViewStyle
    }
}
