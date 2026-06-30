# DesignFoundation

**The design system for serious SwiftUI apps.**

![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![iOS 18+](https://img.shields.io/badge/iOS-18%2B-blue?logo=apple)
![macOS 15+](https://img.shields.io/badge/macOS-15%2B-blue?logo=apple)
![visionOS 2+](https://img.shields.io/badge/visionOS-2%2B-blue?logo=apple)
![MIT License](https://img.shields.io/badge/license-MIT-green)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)

<!-- demo GIF coming -->

---

DesignFoundation is a production-grade Swift Package that gives iOS, macOS, and visionOS developers a fully themed, style-swappable component library — ready to drop into any project, instantly consistent across every screen, and built to grow with you from first commit to App Store.

It ships a token-based theming engine, a protocol-based style system that mirrors SwiftUI's own `ButtonStyle` pattern, first-class Liquid Glass support for iOS/macOS 26+, and a full suite of accessible, Swift 6–safe components — all in a single dependency.

---

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
                .dfTheme(DFTheme(colors: DFColorTokens(primary: .indigo)))
        }
    }
}

// In any view:
DFButton("Get Started") { print("tapped") }
```

---

## Component Reference

### Primitives

| Component | Built-in Styles |
|---|---|
| `DFButton` | `.filled`, `.outlined`, `.ghost`, `.tinted`, `.glass`¹ |
| `DFText` | display, title, headline, body, caption, label |
| `DFIcon` | SF Symbol wrapper with token-driven size and color |
| `DFBadge` | `.default`, `.subtle`, `.outlined`, `.glass`¹ |
| `DFAvatar` | `.circle`, `.rounded`, `.ring`, `.glass`¹ — image or initials, presence indicators |
| `DFDivider` | `.solid`, `.dashed`, `.gradient` — horizontal/vertical, labeled variant |

### Inputs

| Component | Built-in Styles |
|---|---|
| `DFTextField` | `.outlined`, `.filled` |
| `DFSecureField` | `.outlined`, `.filled` — reveal toggle built in |
| `DFToggle` | `.switch`, `.checkbox` |
| `DFSlider` | `.standard`, `.labeled` |
| `DFPicker` | `.segmented`, `.menu`, `.wheel` |
| `DFDatePicker` | `.compact`, `.graphical`, `.wheel` |
| `DFCheckbox` | `.default` |

All input components share `DFValidationState` (`.idle / .valid / .error(String)`) for consistent error display.

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
| `DFAlert` | Convenience wrapper over native SwiftUI alert |
| `DFToast` | Queue management and auto-dismiss |
| `DFSkeleton` | Shimmer animation |
| `DFProgressBar` | Linear, circular, and indeterminate variants |
| `DFList` | Swipe-delete, reorder, and multi-select |
| `DFListRow` | Leading/trailing slots and disclosure indicator |
| `DFTable` | Sortable columns |

¹ `.glass` styles require iOS 26+ / macOS 26+.

---

## Theme System

A single `DFTheme` struct propagates through SwiftUI's environment and drives every component. Inject it once at the app root; override it at any subtree.

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

Every component reads from the nearest `DFTheme` in the environment. A token change propagates to every component that uses it — no manual wiring required.

---

## Preset Themes

Four opinionated visual identities ship in the box — each with a distinct color palette, corner radius scale, and shadow weight. Apply one in a single line; it adapts automatically to light and dark mode.

```swift
MyApp()
    .dfThemePreset(.aurora)   // Electric violet, rounded corners, soft shadows
```

| Preset | Personality | Best for |
|---|---|---|
| `.slate` | Professional, tech-forward, neutral | SaaS dashboards, developer tools |
| `.aurora` | Vibrant, creative, modern | Creative tools, social platforms |
| `.copper` | Warm, editorial, premium | Finance apps, content readers |
| `.sage` | Calm, natural, organic | Health, wellness, lifestyle apps |

Each preset pairs a distinct light and dark `DFTheme`. The modifier reads `@Environment(\.colorScheme)` and switches automatically — no manual wiring required.

```swift
// Automatic light/dark — recommended
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

Every component exposes a `makeBody(configuration:)` style protocol — the same pattern SwiftUI uses for `ButtonStyle`. Styles compose, propagate through the environment, and apply hierarchically.

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

Writing a custom style means implementing one function. The protocol is open; built-in styles are concrete structs you can copy and fork.

---

## Platforms

| Platform | Minimum Version |
|---|---|
| iOS | 18.0 |
| macOS | 15.0 |
| visionOS | 2.0 |

Liquid Glass (`.glass` styles) requires iOS 26+ / macOS 26+. All other styles work on the minimum versions above.

The `DFPlatformVariant` enum (`automatic / compact / expanded / immersive`) lets components adapt their form factor at runtime, or lets you force a specific layout for testing or design overrides.

---

## License

MIT © 2026 NerdSnipe Inc. See [LICENSE](LICENSE).
