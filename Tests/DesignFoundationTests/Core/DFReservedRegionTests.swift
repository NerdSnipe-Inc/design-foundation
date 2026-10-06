import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFReservedRegions")
struct DFReservedRegionsTests {
    private let screen = CGRect(x: 0, y: 0, width: 800, height: 600)

    /// A tall, thin fold down the middle of an 800x600 screen: panes sit side by side.
    private var verticalFold: DFReservedRegion {
        DFReservedRegion(id: 0, kind: .division, frame: CGRect(x: 396, y: 0, width: 8, height: 600))
    }

    /// A wide, thin fold across the middle: panes are stacked.
    private var horizontalFold: DFReservedRegion {
        DFReservedRegion(id: 0, kind: .division, frame: CGRect(x: 0, y: 296, width: 800, height: 8))
    }

    @Test("no regions means not split")
    func noRegions() {
        let regions = DFReservedRegions.none
        #expect(regions.isSplit == false)
        #expect(regions.splitAxis == nil)
        #expect(regions.panes(in: screen) == nil)
        #expect(regions.divisions.isEmpty)
        #expect(regions.occlusions.isEmpty)
    }

    @Test("a tall fold splits side by side")
    func tallFold() {
        let regions = DFReservedRegions([verticalFold])
        #expect(regions.isSplit)
        #expect(regions.splitAxis == .horizontal)
        let panes = regions.panes(in: screen)
        #expect(panes?.first == CGRect(x: 0, y: 0, width: 396, height: 600))
        #expect(panes?.second == CGRect(x: 404, y: 0, width: 396, height: 600))
    }

    @Test("a wide fold splits top and bottom")
    func wideFold() {
        let regions = DFReservedRegions([horizontalFold])
        #expect(regions.splitAxis == .vertical)
        let panes = regions.panes(in: screen)
        #expect(panes?.first == CGRect(x: 0, y: 0, width: 800, height: 296))
        #expect(panes?.second == CGRect(x: 0, y: 304, width: 800, height: 296))
    }

    @Test("an inactive division does not split")
    func inactiveDivision() {
        let flat = DFReservedRegion(id: 0, kind: .division, frame: verticalFold.frame, isActive: false)
        let regions = DFReservedRegions([flat])
        #expect(regions.isSplit == false)
        #expect(regions.divisions.isEmpty)
        #expect(regions.panes(in: screen) == nil)
    }

    @Test("an occlusion never splits")
    func occlusionDoesNotSplit() {
        let camera = DFReservedRegion(id: 0, kind: .occlusion, frame: CGRect(x: 380, y: 0, width: 40, height: 40))
        let regions = DFReservedRegions([camera])
        #expect(regions.isSplit == false)
        #expect(regions.occlusions.count == 1)
    }

    @Test("a division that misses the bounds yields no panes")
    func divisionOutsideBounds() {
        let regions = DFReservedRegions([verticalFold])
        #expect(regions.panes(in: CGRect(x: 0, y: 0, width: 300, height: 600)) == nil)
    }

    @Test("panes are computed inside offset bounds")
    func offsetBounds() {
        let bounds = CGRect(x: 100, y: 50, width: 700, height: 500)
        let regions = DFReservedRegions([verticalFold])
        let panes = regions.panes(in: bounds)
        #expect(panes?.first == CGRect(x: 100, y: 50, width: 296, height: 500))
        #expect(panes?.second == CGRect(x: 404, y: 50, width: 396, height: 500))
    }

    @Test("intersects honors kind and active state")
    func intersects() {
        let camera = DFReservedRegion(id: 1, kind: .occlusion, frame: CGRect(x: 380, y: 0, width: 40, height: 40))
        let inactive = DFReservedRegion(id: 2, kind: .occlusion, frame: CGRect(x: 0, y: 500, width: 50, height: 50), isActive: false)
        let regions = DFReservedRegions([verticalFold, camera, inactive])
        #expect(regions.intersects(CGRect(x: 390, y: 10, width: 10, height: 10)))
        #expect(regions.intersects(CGRect(x: 385, y: 10, width: 5, height: 5), kind: .occlusion))
        #expect(regions.intersects(CGRect(x: 10, y: 10, width: 10, height: 10)) == false)
        #expect(regions.intersects(CGRect(x: 0, y: 500, width: 20, height: 20)) == false)
        #expect(regions.intersects(CGRect(x: 396, y: 300, width: 4, height: 4), kind: .occlusion) == false)
    }

    @Test("region ids and defaults")
    func regionDefaults() {
        let region = DFReservedRegion(kind: .division, frame: .zero)
        #expect(region.isActive)
        #expect(region.id == 0)
        #expect(region.margins == EdgeInsets())
    }
}

@Suite("DFPlatformContext vertical toolbar edge")
struct DFPlatformContextToolbarEdgeTests {
    @Test("defaults to no vertical toolbar")
    @MainActor
    func defaultsToNil() {
        let context = DFPlatformContext.current
        #expect(context.toolbarVerticalEdge == nil)
        #expect(context.hasVerticalToolbar == false)
    }

    @Test("an explicit edge is reported")
    func explicitEdge() {
        #if canImport(UIKit)
        let context = DFPlatformContext(
            idiom: .phone,
            horizontalSizeClass: .compact,
            isLiquidGlassAvailable: true,
            toolbarVerticalEdge: .trailing
        )
        #else
        let context = DFPlatformContext(
            idiom: 0,
            horizontalSizeClass: .compact,
            isLiquidGlassAvailable: true,
            toolbarVerticalEdge: .trailing
        )
        #endif
        #expect(context.toolbarVerticalEdge == .trailing)
        #expect(context.hasVerticalToolbar)
    }
}
