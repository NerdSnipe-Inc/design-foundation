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

## Full Example Apps

[AICompleteChat](https://github.com/NerdSnipe-Inc/AICompleteChat) is a complete [on-device AI chat app](https://github.com/NerdSnipe-Inc/AICompleteChat) built on DesignFoundation Pro and Apple's [Foundation Models framework](https://github.com/NerdSnipe-Inc/AICompleteChat). It wires [`LanguageModelSession`](https://github.com/NerdSnipe-Inc/AICompleteChat), [`@Generable` structured output](https://github.com/NerdSnipe-Inc/AICompleteChat), and streaming generation from [Apple Intelligence's on-device LLM](https://github.com/NerdSnipe-Inc/AICompleteChat) into a fully themed SwiftUI chat UI — no server round-trip, no API key, private [on-device inference](https://github.com/NerdSnipe-Inc/AICompleteChat). A real reference for building an [AI chat / assistant app with SwiftUI](https://github.com/NerdSnipe-Inc/AICompleteChat), not just a components demo.

[BudgetLens](https://github.com/NerdSnipe-Inc/BudgetLens) is a complete, universal (iOS + macOS) [personal finance / budget tracker app](https://github.com/NerdSnipe-Inc/BudgetLens) built on DesignFoundation Pro's `Analytics` vertical, [SwiftData](https://github.com/NerdSnipe-Inc/BudgetLens) persistence, and Apple's [Foundation Models framework](https://github.com/NerdSnipe-Inc/BudgetLens) for on-device spending insights. It wires the same [`LanguageModelSession`](https://github.com/NerdSnipe-Inc/BudgetLens) and [`@Generable` structured output](https://github.com/NerdSnipe-Inc/BudgetLens) APIs as AICompleteChat, but for a structured-output use case — a natural-language monthly spending summary and suggestion generated fully [on-device](https://github.com/NerdSnipe-Inc/BudgetLens), no cloud dependency — assembled around real dashboard/chart/activity-feed blocks instead of a hand-built layout. A real reference for building an [expense tracker app with SwiftUI and SwiftData](https://github.com/NerdSnipe-Inc/BudgetLens), not just a components demo.

[ScanLens](https://github.com/NerdSnipe-Inc/ScanLens) is a complete, universal (iOS + macOS) [document scanner and receipt scanner app](https://github.com/NerdSnipe-Inc/ScanLens) built on DesignFoundation Pro's `Documents` vertical. A scanned photo goes through [on-device Vision OCR](https://github.com/NerdSnipe-Inc/ScanLens), then [`LanguageModelSession`](https://github.com/NerdSnipe-Inc/ScanLens) and [`@Generable` structured output](https://github.com/NerdSnipe-Inc/ScanLens) from [Apple Intelligence](https://github.com/NerdSnipe-Inc/ScanLens) title, categorize, and summarize it — no server round-trip, no cloud OCR or LLM cost, on either platform — landing in a real folder/tag workspace instead of a hand-built list. A real reference for building an [OCR / document scanner app with SwiftUI](https://github.com/NerdSnipe-Inc/ScanLens), not just a components demo.

[ClientLens](https://github.com/NerdSnipe-Inc/ClientLens) is a complete, universal (iOS + macOS) [SwiftUI CRM app](https://github.com/NerdSnipe-Inc/ClientLens) built entirely on DesignFoundation Pro's `CRM` vertical (`DFCRMRootView`), wired up with real [SwiftData](https://github.com/NerdSnipe-Inc/ClientLens)-backed clients and deals instead of fixture data. Its AI Follow-Up feature drafts internal call-prep notes fully [on-device](https://github.com/NerdSnipe-Inc/ClientLens) via Apple's [Foundation Models framework](https://github.com/NerdSnipe-Inc/ClientLens), no server round-trip required. A real reference for building a [SwiftUI CRM app with SwiftData](https://github.com/NerdSnipe-Inc/ClientLens), not just a components demo.

[BookLens](https://github.com/NerdSnipe-Inc/BookLens) is a complete, universal (iOS + macOS) [SwiftUI appointment booking app](https://github.com/NerdSnipe-Inc/BookLens) built on DesignFoundation Pro's `Booking` vertical, with real [SwiftData](https://github.com/NerdSnipe-Inc/BookLens) persistence, zero-permission [EventKitUI calendar integration](https://github.com/NerdSnipe-Inc/BookLens) on iOS, and an on-device [Foundation Models](https://github.com/NerdSnipe-Inc/BookLens) scheduling assistant that runs identically on both platforms. A real reference for building a [booking / scheduling app with SwiftUI and EventKit](https://github.com/NerdSnipe-Inc/BookLens), not just a components demo.

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

Popups and toasts share one engine:

```swift
ContentView()
    .dfToast()   // once at the root
    .dfPopup(isPresented: $showFloater, configuration: .floater(position: .bottomTrailing)) {
        Text("Inset, drag to dismiss")
    }

DFToastQueue.shared.show(text: "Saved", severity: .success, position: .bottom)
DFToastQueue.shared.show(text: "Moved to the trash", severity: .error, title: "Deleted",
                         actionTitle: "Undo", action: { restore() })
```

New in 1.7.0: eight popup surface styles (`.dfPopupStyle(.frosted)`, `.glass`, `.accent`, `.gradient`, `.inverse`, `.outlined`, `.tinted(_:)`), `DFPopupCard` (icon or hero media, title, message, up to three actions), a bottom-sheet kind (`.sheet(backdrop:)`), `DFPopupBackdrop` (`.none`, `.dim`, `.blur`), and eight toast styles (`.dfToast(style: .tinted)`, `.filled`, `.inverse`, `.frosted`, `.glass`, `.banner`, `.compact`) with an optional title and action. See the [popup docs with real recordings](https://nerdsnipe-inc.github.io/design-foundation/#popups).

DesignFoundation Pro 2.3.0 adds unified overlay/sheet/window presentation, scroll popups with detents, a priority queue, celebration, permission, promo, rating, input, consent and action popups, undo and progress toasts, notification banners, a live capsule, coachmark tours, motion presets and haptics ([Advanced Popups](https://nerdsnipe-inc.github.io/design-foundation/pro/#popups)).

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
| `DFPopup` | `.dfPopup(isPresented:)` / `.dfPopup(item:)` — centered, toast, floater and sheet kinds, nine positions, eight surface styles via `.dfPopupStyle(_:)`, `DFPopupCard`, none/dim/blur backdrops, slide/scale/fade/none/asymmetric transitions, auto-dismiss, drag/tap/outside-tap dismissal. [Real recordings](https://nerdsnipe-inc.github.io/design-foundation/#popups) |

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
| `DFToast` | Queue management and auto-dismiss, nine positions, eight styles via `.dfToastStyle(_:)`, optional title and action (Undo) |
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
