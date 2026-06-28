import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFSkeletonShape")
struct DFSkeletonShapeTests {
    @Test("shapes are Equatable")
    func equatable() {
        #expect(DFSkeletonShape.rectangle == .rectangle)
        #expect(DFSkeletonShape.circle == .circle)
        #expect(DFSkeletonShape.capsule == .capsule)
        #expect(DFSkeletonShape.roundedRectangle(cornerRadius: 8) == .roundedRectangle(cornerRadius: 8))
        #expect(DFSkeletonShape.rectangle != .circle)
    }
}

@Suite("DFSkeletonStyleConfiguration")
struct DFSkeletonStyleConfigurationTests {
    @Test("holds all values correctly")
    func holdsValues() {
        let config = DFSkeletonStyleConfiguration(
            shape: .circle,
            animationPhase: 0.5,
            theme: .default
        )
        #expect(config.shape == .circle)
        #expect(config.animationPhase == 0.5)
    }
}

@Suite("DFSkeleton Environment")
struct DFSkeletonEnvironmentTests {
    @Test("dfSkeletonStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfSkeletonStyle
    }
}

@Suite("DFSkeleton Styles")
struct DFSkeletonStyleTests {
    @Test("default style is Sendable")
    func defaultSendable() {
        let _: any DFSkeletonStyle & Sendable = DFDefaultSkeletonStyle()
    }

    @Test("AnyDFSkeletonStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFSkeletonStyle(DFDefaultSkeletonStyle())
        let config = DFSkeletonStyleConfiguration(shape: .rectangle, animationPhase: 0.0, theme: .default)
        let _ = style.makeBody(configuration: config)
    }
}
