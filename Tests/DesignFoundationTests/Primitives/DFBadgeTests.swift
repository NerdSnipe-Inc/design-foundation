import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFBadgeVariant")
struct DFBadgeVariantTests {
    @Test("three variants exist and are distinct")
    func variantsDistinct() {
        let all = DFBadgeVariant.allCases
        #expect(all.count == 3)
        #expect(Set(all.map(\.rawValue)).count == 3)
    }
}

@Suite("DFBadgeStyleConfiguration")
struct DFBadgeStyleConfigurationTests {
    @Test("numeric variant holds count")
    func numericVariantHoldsCount() {
        let config = DFBadgeStyleConfiguration(
            variant: .numeric(5),
            theme: .default
        )
        if case .numeric(let count) = config.variant {
            #expect(count == 5)
        } else {
            Issue.record("Expected .numeric variant")
        }
    }

    @Test("dot variant is representable")
    func dotVariantRepresentable() {
        let config = DFBadgeStyleConfiguration(variant: .dot, theme: .default)
        if case .dot = config.variant {
            // passes
        } else {
            Issue.record("Expected .dot variant")
        }
    }

    @Test("text variant holds string")
    func textVariantHoldsString() {
        let config = DFBadgeStyleConfiguration(variant: .text("New"), theme: .default)
        if case .text(let str) = config.variant {
            #expect(str == "New")
        } else {
            Issue.record("Expected .text variant")
        }
    }
}

@Suite("DFBadge Environment")
struct DFBadgeEnvironmentTests {
    @Test("dfBadgeStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfBadgeStyle
    }
}
