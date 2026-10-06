# Preparing for iPhone Duo

iPhone Duo is a two-display iPhone: a large inner display that can be folded closed, and an outer display. Layout, safe areas, and the system bars all change with how the device is held and folded. This page covers what DesignFoundation gives you for it, what the system does on its own, and what stays your job.

Everything described here that depends on the new SDK needs **Xcode 27.1 or later** (the 27.1 SDK). On every older toolchain the same code builds and runs; the iPhone Duo parts are simply inactive. See [How the SDK gate works](#how-the-sdk-gate-works).

**See also:** [[Theming]] for `DFPlatformContext` · [[Navigation]] for `DFTabBar`, `DFNavigationBar` and `DFSidebar` · Apple's *Preparing your app for iPhone Duo* technology overview.

---

## Contents

1. [What changes on iPhone Duo](#what-changes-on-iphone-duo)
2. [Testing](#testing)
3. [Two-pane layouts: DFArrangement](#two-pane-layouts-dfarrangement)
4. [The fold and the camera: reserved regions](#the-fold-and-the-camera-reserved-regions)
5. [Bars that run down a side](#bars-that-run-down-a-side)
6. [Size classes and safe areas](#size-classes-and-safe-areas)
7. [How the SDK gate works](#how-the-sdk-gate-works)
8. [Checklist](#checklist)

---

## What changes on iPhone Duo

- **There is no "pose" value.** You cannot ask "is the device folded?". The fold and the camera are described as *geometry*: rectangles of the screen that content should be arranged around. DesignFoundation surfaces them as `DFReservedRegions`.
- **Two kinds of reserved region.** A *division* is where content should split into two separate regions (the fold). An *occlusion* is a spot covered by hardware or system UI, such as a camera. Each has a `frame`, `margins`, and an `isActive` flag (a flat inner display has no active division).
- **Bars can run vertically.** On the outer display, and in some inner-display positions, navigation bars, toolbars and tab bars run down one side instead of across the top and bottom.
- **Safe areas and margins are asymmetric.** An app built with Xcode 26 or earlier does not extend under the status bar and camera.
- **Size classes follow the display.** Inner display: regular by regular. Outer display: regular vertical and compact horizontal in portrait, compact by compact in landscape.

## Testing

Xcode 27.1 beta includes an iPhone Duo simulator in Device Hub, with controls to open, close, rotate and fold it. Test at least: inner display flat, inner display folded, outer display portrait, outer display landscape, and right-to-left layout (region frames are mirrored for right-to-left by default).

GitHub-hosted CI runners do not have Xcode 27 yet, so a continuous-integration build proves only that the gated code stays out of older builds. Run the simulator yourself before shipping iPhone Duo work.

## Two-pane layouts: DFArrangement

`DFArrangement` places a primary and a secondary view: side by side when the space is wider than tall, stacked when taller, or layered with `.overlay`.

```swift
DFArrangement {
    InboxList()
} secondary: {
    MessageDetail()
}

DFArrangement(.split(axes: .horizontal)) { List() } secondary: { Detail() }   // never stack
DFArrangement(.overlay) { Controls() } secondary: { Canvas() }               // primary layered over secondary
```

- On the 27.1 SDK it is SwiftUI's `ArrangementView`. In `.split` it divides around the fold; in `.overlay` it layers primary over secondary, and when the screen is partially folded puts primary in the trailing or bottom part and secondary in the leading or top part.
- On every other SDK, and on OS versions before 27.1, it is a plain stack that picks its orientation from the available size with the same `.split` rule. `.overlay` is a layered `ZStack`.
- Apple advises against placing an `ArrangementView` inside a navigation split view, a list or a scroll view. The same applies to `DFArrangement`. For a sidebar-detail app shell keep using `NavigationSplitView` (or `DFSidebar`); use `DFArrangement` for the content inside a screen.

## The fold and the camera: reserved regions

`DFReservedRegionReader` reads the regions that intersect its own bounds and hands them to its content:

```swift
DFReservedRegionReader { regions in
    VStack {
        Text(regions.isSplit ? "Folded" : "Flat")
        if let axis = regions.splitAxis {
            Text(axis == .horizontal ? "Panes sit side by side" : "Panes are stacked")
        }
    }
}
```

`DFReservedRegions` is a plain value type with pure helpers, so the logic is easy to test without a device:

| Member | Meaning |
|---|---|
| `regions` | Every region reported, active or not |
| `divisions`, `occlusions` | Active regions of each kind |
| `activeDivision`, `isSplit` | The first active division, and whether there is one |
| `splitAxis` | `.horizontal` when the panes are side by side (a tall, thin fold), `.vertical` when stacked, `nil` when not split |
| `panes(in:)` | The two rectangles either side of the division inside a given rect, or `nil` |
| `intersects(_:kind:)` | Whether a rect overlaps any active region, optionally of one kind |

```swift
// Keep a floating control off the fold and out from under the camera.
func isSafeSpot(_ rect: CGRect, in regions: DFReservedRegions) -> Bool {
    !regions.intersects(rect)
}

// Test a layout against a made-up fold.
let fold = DFReservedRegion(kind: .division, frame: CGRect(x: 396, y: 0, width: 8, height: 600))
let panes = DFReservedRegions([fold]).panes(in: CGRect(x: 0, y: 0, width: 800, height: 600))
```

Frames are in the reader's own coordinate space. Before the 27.1 SDK the reader always passes `DFReservedRegions.none`.

## Bars that run down a side

When the system shows a bar vertically, it picks a side. `DFPlatformContext.toolbarVerticalEdge` (a `HorizontalEdge?`) reports it, and is `nil` where the system never shows a vertical bar in the current context, and always on SDKs before 27.1:

```swift
struct DuoAwareRow: View {
    @Environment(\.dfPlatformContext) private var platform

    var body: some View {
        Text(platform.hasVerticalToolbar ? "Bars run down a side" : "Bars run across the top and bottom")
    }
}
```

How the DesignFoundation navigation components behave:

- **`DFNavigationBar`** is built on native toolbar placements, so the system lays out its bars, vertical or not. The system only shows a toolbar item vertically when it has an icon and a title and is not a custom view. A bare text title, or a view you build by hand in `leading:` or `trailing:`, will not appear in a vertical bar. Prefer `Button("Save", systemImage: "checkmark") { }` or a `Label`.
- **`DFTabBar`** is a custom bar pinned to the bottom edge, not the system tab bar. It stays horizontal on every device. If you want the tab bar that moves to a side on iPhone Duo, use SwiftUI's own `TabView` and style it with your theme.
- **`DFSidebar`** shows in regular width as before. Inspectors keep their bars horizontal; in split views the detail view is the one that shows bars vertically.

SwiftUI (27.1 SDK) also gives you per-bar and per-item control, which you can apply in your own code behind the same gate shown below: `.toolbarVerticalBehavior(.automatic | .disabled)` on a container, and `.axisBehavior(.automatic | .horizontalOnly | .verticalPreferred)` and `.visibilityPriority(.low | .high)` on toolbar items.

## Size classes and safe areas

Use size classes, container geometry and reserved regions to decide layout. Do not read `UIScreen.main`: there are two displays, and an app can be in a window smaller than either. Remember that safe areas and margins are not the same on every side, so use the system's safe-area and margin APIs rather than a fixed inset.

## How the SDK gate works

The iPhone Duo APIs (`ArrangementView`, `ReservedRegion`, `GeometryProxy.reservedRegions(kind:options:layoutDirectionBehavior:)`, `EnvironmentValues.toolbarVerticalEdge`) exist only in the 27.1 SDK. A symbol that does not exist cannot be called behind `if #available`; it must be hidden from the compiler. DesignFoundation wraps every use in:

```swift
#if compiler(>=6.4) && canImport(SwiftUI, _version: 8.1) && !targetEnvironment(macCatalyst)
// iPhone Duo code, plus @available(iOS 27.1, macOS 27.1, visionOS 27.1, *)
#endif
```

- `compiler(>=6.4)`: Xcode 27 and 27.1 ship Swift 6.4; Xcode 26.x ships up to Swift 6.3.
- `canImport(SwiftUI, _version: 8.1)`: the compiler version cannot tell Xcode 27.0 from 27.1, but SwiftUI's module version tracks the SDK (SDK 26.0 to 26.5 report 7.0 to 7.5, SDK 18.0 to 18.5 report 6.0 to 6.5), so 8.1 means the 27.1 SDK.
- `!targetEnvironment(macCatalyst)`: Apple lists a known problem where 27.1 APIs fail to compile for Mac Catalyst.

If you write your own iPhone Duo code in an app, use the same condition. If the threshold is ever wrong in the cautious direction the effect is that the iPhone Duo path stays off and the plain-stack fallbacks are used; it cannot break an older build.

## Checklist

- Build with Xcode 27.1 and run in the iPhone Duo simulator: flat, folded, outer display in both orientations, right-to-left.
- Use `DFArrangement` for two-pane screens, and keep controls off `DFReservedRegions` divisions and occlusions.
- Give toolbar items an icon and a title; avoid custom views in toolbar slots that must also work vertically.
- Use `TabView` when you want the system tab bar to follow the device; `DFTabBar` stays at the bottom.
- Decide layout from size classes and geometry; never from `UIScreen.main`.
- Rebuild with Xcode 26 and Xcode 16 to confirm nothing else changed.
