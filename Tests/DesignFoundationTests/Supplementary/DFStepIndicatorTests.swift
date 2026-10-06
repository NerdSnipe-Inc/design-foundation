import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFStepState resolution")
struct DFStepStateResolveTests {
    @Test("middle index: earlier complete, current, later upcoming")
    func middle() {
        #expect(DFStepState.resolve(count: 4, currentIndex: 2) == [.complete, .complete, .current, .upcoming])
    }

    @Test("first index: nothing complete")
    func first() {
        #expect(DFStepState.resolve(count: 3, currentIndex: 0) == [.current, .upcoming, .upcoming])
    }

    @Test("last index: final step current")
    func last() {
        #expect(DFStepState.resolve(count: 3, currentIndex: 2) == [.complete, .complete, .current])
    }

    @Test("index equal to count marks every step complete")
    func finished() {
        #expect(DFStepState.resolve(count: 3, currentIndex: 3) == [.complete, .complete, .complete])
    }

    @Test("negative index clamps to the first step")
    func negativeClamps() {
        #expect(DFStepState.resolve(count: 3, currentIndex: -5) == [.current, .upcoming, .upcoming])
    }

    @Test("index beyond count clamps to all complete")
    func overflowClamps() {
        #expect(DFStepState.resolve(count: 2, currentIndex: 99) == [.complete, .complete])
    }

    @Test("empty input yields empty output for any index")
    func empty() {
        #expect(DFStepState.resolve(count: 0, currentIndex: 0).isEmpty)
        #expect(DFStepState.resolve(count: 0, currentIndex: 5).isEmpty)
        #expect(DFStepState.resolve(count: -1, currentIndex: 0).isEmpty)
        #expect(DFStepState.resolve(steps: [], currentIndex: 1).isEmpty)
    }

    @Test("error indices override position and out-of-range entries are ignored")
    func errors() {
        let states = DFStepState.resolve(count: 3, currentIndex: 1, errorIndices: [1, 7, -2])
        #expect(states == [.complete, .error, .upcoming])
    }

    @Test("steps overload honours hasError")
    func stepsOverload() {
        let steps = [DFStep(title: "A"), DFStep(title: "B", hasError: true), DFStep(title: "C")]
        #expect(DFStepState.resolve(steps: steps, currentIndex: 0) == [.current, .error, .upcoming])
    }

    @Test("result always has one state per step")
    func countMatches() {
        for index in -2...6 {
            #expect(DFStepState.resolve(count: 4, currentIndex: index).count == 4)
        }
    }
}

@Suite("DFStep")
struct DFStepModelTests {
    @Test("id defaults to the title")
    func idDefaultsToTitle() {
        #expect(DFStep(title: "Shipping").id == "Shipping")
        #expect(DFStep(id: "ship", title: "Shipping").id == "ship")
    }

    @Test("optional fields default to nil / false")
    func defaults() {
        let step = DFStep(title: "Cart")
        #expect(step.subtitle == nil)
        #expect(step.systemImage == nil)
        #expect(step.hasError == false)
    }

    @Test("accessibility strings read as 'Step 2 of 4, Shipping, current'")
    func accessibilityStrings() {
        let label = DFStep.accessibilityLabel(position: 2, of: 4, title: "Shipping")
        #expect(label == "Step 2 of 4, Shipping")
        #expect("\(label), \(DFStepState.current.accessibilityValue)" == "Step 2 of 4, Shipping, current")
    }

    @Test("every state has a distinct accessibility value")
    func distinctValues() {
        let values = Set(DFStepState.allCases.map(\.accessibilityValue))
        #expect(values.count == DFStepState.allCases.count)
    }
}

@Suite("DFStepIndicatorStyleConfiguration")
struct DFStepIndicatorStyleConfigurationTests {
    @Test("holds all values correctly")
    func holdsValues() {
        let steps = [DFStep(title: "A"), DFStep(title: "B")]
        let config = DFStepIndicatorStyleConfiguration(
            steps: steps,
            states: [.complete, .current],
            axis: .vertical,
            isCompact: true,
            theme: .default
        )
        #expect(config.steps == steps)
        #expect(config.states == [.complete, .current])
        #expect(config.axis == .vertical)
        #expect(config.isCompact)
    }
}

@Suite("DFStepIndicator Environment")
struct DFStepIndicatorEnvironmentTests {
    @Test("dfStepIndicatorStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfStepIndicatorStyle
    }
}

@Suite("DFStepIndicator Styles")
struct DFStepIndicatorStyleTests {
    @Test("built-in styles are Sendable")
    func sendable() {
        let _: any DFStepIndicatorStyle & Sendable = DFStandardStepIndicatorStyle()
        let _: any DFStepIndicatorStyle & Sendable = DFMinimalStepIndicatorStyle()
        let _: any DFStepIndicatorStyle & Sendable = DFNumberedStepIndicatorStyle()
    }

    @Test("static shorthands resolve")
    func shorthands() {
        let _: DFStandardStepIndicatorStyle = .standard
        let _: DFMinimalStepIndicatorStyle = .minimal
        let _: DFNumberedStepIndicatorStyle = .numbered
    }

    @Test("every built-in style builds a body for both axes, compact and empty input")
    @MainActor
    func buildsBodies() {
        let steps = [DFStep(title: "A", subtitle: "a"), DFStep(title: "B", systemImage: "star"), DFStep(title: "C")]
        let states = DFStepState.resolve(steps: steps, currentIndex: 1)
        for axis in [Axis.horizontal, Axis.vertical] {
            for compact in [false, true] {
                let config = DFStepIndicatorStyleConfiguration(
                    steps: steps, states: states, axis: axis, isCompact: compact, theme: .default
                )
                let _ = AnyDFStepIndicatorStyle(DFStandardStepIndicatorStyle()).makeBody(configuration: config)
                let _ = AnyDFStepIndicatorStyle(DFMinimalStepIndicatorStyle()).makeBody(configuration: config)
                let _ = AnyDFStepIndicatorStyle(DFNumberedStepIndicatorStyle()).makeBody(configuration: config)
            }
        }
        let empty = DFStepIndicatorStyleConfiguration(steps: [], states: [], axis: .horizontal, isCompact: false, theme: .default)
        let _ = AnyDFStepIndicatorStyle(DFStandardStepIndicatorStyle()).makeBody(configuration: empty)
    }

    @Test("a mismatched states array does not trap")
    @MainActor
    func mismatchedStates() {
        let config = DFStepIndicatorStyleConfiguration(
            steps: [DFStep(title: "A"), DFStep(title: "B")],
            states: [],
            axis: .vertical,
            isCompact: false,
            theme: .default
        )
        let _ = AnyDFStepIndicatorStyle(DFStandardStepIndicatorStyle()).makeBody(configuration: config)
    }
}

@Suite("DFStepIndicator view")
struct DFStepIndicatorViewTests {
    @Test("initializes with default axis")
    @MainActor
    func initializes() {
        let _ = DFStepIndicator(steps: [DFStep(title: "A")], currentIndex: 0)
        let _ = DFStepIndicator(steps: [], currentIndex: 3, axis: .vertical)
    }
}

@Suite("DFStepIndicatorTokens")
struct DFStepIndicatorTokensTests {
    @Test("defaults are nil so styles inherit")
    func defaultsNil() {
        let tokens = DFComponentTokens.default.stepIndicator
        #expect(tokens.markerSize == nil)
        #expect(tokens.connectorThickness == nil)
    }

    @Test("overrides are stored on the root")
    func overrides() {
        let tokens = DFComponentTokens(stepIndicator: DFStepIndicatorTokens(markerSize: 36, connectorThickness: 3))
        #expect(tokens.stepIndicator.markerSize == 36)
        #expect(tokens.stepIndicator.connectorThickness == 3)
    }
}
