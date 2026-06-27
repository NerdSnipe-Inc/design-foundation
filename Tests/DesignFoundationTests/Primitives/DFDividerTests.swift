import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFDividerOrientation")
struct DFDividerOrientationTests {
    @Test("two orientations exist")
    func twoOrientations() {
        let all = DFDividerOrientation.allCases
        #expect(all.count == 2)
    }
}

@Suite("DFDividerStyleConfiguration")
struct DFDividerStyleConfigurationTests {
    @Test("configuration holds orientation and label")
    func configurationHoldsValues() {
        let config = DFDividerStyleConfiguration(
            orientation: .horizontal,
            label: "OR",
            theme: .default
        )
        #expect(config.orientation == .horizontal)
        #expect(config.label == "OR")
    }

    @Test("label is optional — nil by default")
    func labelIsOptional() {
        let config = DFDividerStyleConfiguration(
            orientation: .vertical,
            label: nil,
            theme: .default
        )
        #expect(config.label == nil)
    }
}

@Suite("DFDivider Environment")
struct DFDividerEnvironmentTests {
    @Test("dfDividerStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfDividerStyle
    }
}
