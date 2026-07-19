import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFChipVariant")
struct DFChipVariantTests {
    @Test("text accessor returns underlying label for every case")
    func textAccessor() {
        #expect(DFChipVariant.label("Label").text == "Label")
        #expect(DFChipVariant.labelWithIcon("Filter", systemImage: "line.3.horizontal.decrease").text == "Filter")
        #expect(DFChipVariant.dismissible("Removable", onDismiss: {}).text == "Removable")
        #expect(DFChipVariant.selectable("Selectable").text == "Selectable")
    }
}

@Suite("DFChipStyleConfiguration")
struct DFChipStyleConfigurationTests {
    @Test("label variant holds text")
    func labelVariantHoldsText() {
        let config = DFChipStyleConfiguration(variant: .label("Tag"), isSelected: false, theme: .default)
        if case .label(let text) = config.variant {
            #expect(text == "Tag")
        } else {
            Issue.record("Expected .label variant")
        }
    }

    @Test("isSelected is held independently of variant")
    func isSelectedHeldIndependently() {
        let config = DFChipStyleConfiguration(variant: .selectable("Tag"), isSelected: true, theme: .default)
        #expect(config.isSelected)
    }

    @Test("dismissible variant holds a callback")
    @MainActor
    func dismissibleVariantHoldsCallback() {
        var dismissed = false
        let config = DFChipStyleConfiguration(
            variant: .dismissible("Tag", onDismiss: { dismissed = true }),
            isSelected: false,
            theme: .default
        )
        if case .dismissible(_, let onDismiss) = config.variant {
            onDismiss()
            #expect(dismissed)
        } else {
            Issue.record("Expected .dismissible variant")
        }
    }
}

@Suite("DFChip Environment")
struct DFChipEnvironmentTests {
    @Test("dfChipStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfChipStyle
    }
}

@Suite("DFChipTokens")
struct DFChipTokensTests {
    @Test("default tokens are all nil (inherit from theme)")
    func defaultTokensAreNil() {
        let tokens = DFChipTokens.default
        #expect(tokens.cornerRadius == nil)
        #expect(tokens.horizontalPadding == nil)
        #expect(tokens.verticalPadding == nil)
        #expect(tokens.iconSpacing == nil)
    }
}
