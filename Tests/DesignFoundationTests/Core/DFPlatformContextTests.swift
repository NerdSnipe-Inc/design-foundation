import Testing
import SwiftUI
@testable import DesignFoundation

#if canImport(UIKit)
import UIKit
#endif

@Suite("DFPlatformContext")
struct DFPlatformContextTests {

    @Test("default platform context has a valid idiom")
    @MainActor
    func defaultContextHasIdiom() {
        let ctx = DFPlatformContext.current
        // idiom must be one of the known values — not an uninitialized int
        #if canImport(UIKit)
        let knownIdioms: [UIUserInterfaceIdiom] = [.phone, .pad, .mac, .vision, .unspecified]
        #expect(knownIdioms.contains(ctx.idiom))
        #else
        // On non-UIKit platforms, just verify it's a valid Int
        #expect(ctx.idiom >= 0)
        #endif
    }

    @Test("isLiquidGlassAvailable matches OS version")
    @MainActor
    func liquidGlassAvailability() {
        let ctx = DFPlatformContext.current
        if #available(iOS 26, macOS 26, *) {
            #expect(ctx.isLiquidGlassAvailable == true)
        } else {
            #expect(ctx.isLiquidGlassAvailable == false)
        }
    }

    @Test("DFPlatformVariant all cases are distinct")
    func variantCasesDistinct() {
        let all: [DFPlatformVariant] = [.automatic, .compact, .expanded, .immersive]
        #expect(Set(all.map(\.rawValue)).count == 4)
    }
}
