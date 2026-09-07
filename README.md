<p align="center">
  <img alt="DesignFoundation" src="docs/images/design-foundation-logo.png" width="100%" />
</p>

# DesignFoundation

A SwiftUI design system I built because every new project I started, I was rebuilding the same buttons, inputs, cards, and modals, losing another two weeks to it.

![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![iOS 18+](https://img.shields.io/badge/iOS-18%2B-blue?logo=apple)
![macOS 15+](https://img.shields.io/badge/macOS-15%2B-blue?logo=apple)
![visionOS 2+](https://img.shields.io/badge/visionOS-2%2B-blue?logo=apple)
![MIT License](https://img.shields.io/badge/license-MIT-green)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNerdSnipe-Inc%2Fdesign-foundation%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/NerdSnipe-Inc/design-foundation)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNerdSnipe-Inc%2Fdesign-foundation%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/NerdSnipe-Inc/design-foundation)

<!-- demo GIF goes here once recorded -->

---

DesignFoundation gives you a token-based theming engine and 30+ SwiftUI components that all read from the same theme. Set the theme once at the app root, every component underneath updates. That's the whole idea.

Works on iOS 18+, macOS 15+, visionOS 2+. Swift 6 strict concurrency safe. Liquid Glass styles included for iOS/macOS 26+.

---

## View All Screens

[Screenshot Library](/Content/index.md)

## Installation

Add the package via Swift Package Manager in Xcode or `Package.swift`:

**Xcode:** File → Add Package Dependencies → `https://github.com/NerdSnipe-Inc/design-foundation` → from version `1.0.0`

**Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/NerdSnipe-Inc/design-foundation", from: "1.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: ["DesignFoundation"])
]
```

---

## Quick Start

```swift
import DesignFoundation

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .dfThemePreset(.slate)
        }
    }
}

struct ContentView: View {
    var body: some View {
        DFButton("Get started") { print("tapped") }
    }
}
```

Five presets ship: `.slate`, `.aurora`, `.copper`, `.sage`, `.garnet`. Each swaps automatically for light and dark mode. Build your own from tokens if none of them fit, see the Theme System section below.

---

## Component Reference

### Primitives

| Component | Built-in Styles |
|---|---|
| `DFButton` | `.filled`, `.outlined`, `.ghost`, `.tinted`, `.glass`¹ |
| `DFText` | display, title, headline, body, caption, label |
| `DFIcon` | SF Symbol wrapper with token-driven size and color |
| `DFBadge` | `.default`, `.subtle`, `.outlined`, `.glass`¹ |
| `DFAvatar` | `.circle`, `.rounded`, `.ring`, `.glass`¹ (image or initials, presence indicators) |
| `DFDivider` | `.solid`, `.dashed`, `.gradient` (horizontal/vertical, labeled variant) |

### Inputs

| Component | Built-in Styles |
|---|---|
| `DFTextField` | `.outlined`, `.filled` |
| `DFSecureField` | `.outlined`, `.filled` (reveal toggle built in) |
| `DFToggle` | `.switch`, `.checkbox` |
| `DFSlider` | `.standard`, `.labeled` |
| `DFPicker` | `.segmented`, `.menu`, `.wheel` |
| `DFDatePicker` | `.compact`, `.graphical`, `.wheel` |
| `DFCheckbox` | `.default` |

All input components share `DFValidationState` (`.idle / .valid / .error(String)`) so error display looks consistent everywhere.

### Layout

| Component | Built-in Styles |
|---|---|
| `DFCard` | `.elevated`, `.outlined`, `.filled`, `.glass`¹ |

### Overlays

| Component | Built-in Styles |
|---|---|
| `DFModal` | `.standard`, `.glass`¹ |
| `DFSheet` | `.standard`, `.compact`, `.glass`¹ |
| `DFPopover` | `.arrow`, `.compact`, `.glass`¹ |
| `DFTooltip` | `.bubble`, `.glass`¹ |

### Navigation

| Component | Built-in Styles |
|---|---|
| `DFTabBar` | `.standard`, `.minimal` |
| `DFNavigationBar` | `.standard`, `.transparent` |
| `DFSidebar` | `.standard`, `.plain` |

### Supplementary

| Component | Notes |
|---|---|
| `DFAlert` | Convenience wrapper over the native SwiftUI alert |
| `DFToast` | Queue management and auto-dismiss |
| `DFSkeleton` | Shimmer animation |
| `DFProgressBar` | Linear, circular, and indeterminate variants |
| `DFList` | Swipe-delete, reorder, and multi-select |
| `DFListRow` | Leading/trailing slots and disclosure indicator |
| `DFTable` | Sortable columns |

¹ `.glass` styles require iOS 26+ / macOS 26+.

---

## Theme System

One `DFTheme` struct sits in SwiftUI's environment and drives every component. Set it at the app root, override it anywhere below.

```swift
// Token namespaces: colors, typography, spacing, radius, shadow, animation, components
MyApp()
    .dfTheme(DFTheme(
        colors: DFColorTokens(
            primary: .indigo,
            surface: Color(.systemBackground)
        ),
        spacing: DFSpacingTokens(md: 20),
        radius: DFRadiusTokens(md: 12)
    ))
```

Every component reads from the nearest `DFTheme` in the environment. Change a token, everything that uses it updates. No manual wiring.

---

## Preset Themes

Five presets ship in the box. Each one pairs a light and dark `DFTheme` and switches automatically based on `@Environment(\.colorScheme)`.

```swift
MyApp()
    .dfThemePreset(.aurora)
```

| Preset | Notes | Fits well with |
|---|---|---|
| `.slate` | Closest to Apple system defaults, neutral palette | SaaS dashboards, developer tools |
| `.aurora` | Violet primary, larger corner radii, softer shadows | Creative tools, social apps |
| `.copper` | Warm orange-brown palette | Finance, content readers |
| `.sage` | Muted green, calmer contrast | Health, wellness |
| `.garnet` | Bold, saturated deep garnet red (#C8102E), white cards, off-white background | Bold consumer brands, retail, sports |

The differences read better in a preview than in a description, spin them up and see which one feels right for your app.

```swift
// Automatic light/dark
MyApp().dfThemePreset(.slate)

// Force a specific variant (previews, sub-tree overrides)
MyView().dfTheme(.copperDark)

// Build a custom preset from named themes
let myPreset = DFThemePreset(light: .slateLight, dark: .auroraDark)

// Mutate one token, keep the rest
var custom = DFTheme.sageLight
custom.colors.primary = .purple
MyView().dfTheme(custom)
```

---

## Style System

Every component exposes a `makeBody(configuration:)` style protocol, the same pattern SwiftUI uses for `ButtonStyle`. Styles compose, propagate through the environment, and apply hierarchically.

```swift
// Apply a style to an entire section
VStack { ... }
    .dfButtonStyle(.outlined)
    .dfCardStyle(.glass)

// Override for a single component
DFButton("Delete", role: .destructive) { }
    .dfButtonStyle(.ghost)

// Liquid Glass across your whole UI
ContentView()
    .dfButtonStyle(.glass)
    .dfCardStyle(.glass)
    .dfTooltipStyle(.glass)
```

Writing a custom style means implementing one function. Built-in styles are concrete structs, copy any of them as a starting point.

---

## Platforms

| Platform | Minimum Version |
|---|---|
| iOS | 18.0 |
| macOS | 15.0 |
| visionOS | 2.0 |

Liquid Glass (`.glass` styles) requires iOS 26+ / macOS 26+. Everything else works on the minimums above.

The `DFPlatformVariant` enum (`automatic / compact / expanded / immersive`) lets components adapt their form factor at runtime, or lets you force a specific layout for previews and testing.

---

## Why I built this

Short version: every SwiftUI project I started ended up rebuilding the same primitives. Buttons that needed 40 lines of styling to match brand. Text fields with validation states I always got slightly wrong. The design system would drift within months because there was no single source of truth for spacing, radius, color, or elevation. Six months in, half my app used one theme and half used whatever I shipped in a busy sprint.

DesignFoundation makes the tokens the source of truth. Components read from the environment. Brand refreshes are a theme file edit, not a file hunt.

There's a paid tier at [nerdsnipe-inc.github.io/design-foundation/pro](https://nerdsnipe-inc.github.io/design-foundation/pro/) that adds pre-built screens for auth, dashboard, CRM, analytics, and other verticals, composed from these same primitives. That's optional. The primitives on this repo stay MIT and get maintained regardless.

Feedback and issues are welcome, especially on the theme API. If something's rough, open an issue.

---

## License

MIT © 2026 NerdSnipe Inc. See [LICENSE](LICENSE).
