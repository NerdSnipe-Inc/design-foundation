# DesignFoundation

**The design system for serious SwiftUI apps.**

DesignFoundation is a production-grade Swift Package that gives iOS, macOS, and visionOS developers a fully themed, style-swappable component library — ready to drop into any project, instantly consistent across every screen, and built to grow with you from first commit to App Store.

---

## The problem it solves

Every SwiftUI app starts the same way: you write a button. Then you write another one. Then someone changes the brand color, and you spend two days hunting down every `.foregroundStyle(.blue)` in the codebase. Design tokens exist to solve this. Theming engines exist to enforce them. But building one correctly — with protocol-based style overrides, Swift 6 concurrency safety, and real accessibility support — takes weeks you don't have.

DesignFoundation ships all of that, done.

---

## What's included

### Token-Based Theming Engine

A single `DFTheme` struct propagates through SwiftUI's environment and drives every component in the library. Seven token namespaces cover everything a production app needs:

| Token Group | What it controls |
|---|---|
| `DFColorTokens` | Brand, surfaces, text, interactive states, feedback colors |
| `DFTypographyTokens` | Display, title, headline, body, caption, label — with font, line spacing, and tracking |
| `DFSpacingTokens` | xs → xxl scale (4 / 8 / 12 / 16 / 24 / 32 pt defaults) |
| `DFRadiusTokens` | Corner radius scale from none to full pill |
| `DFShadowTokens` | sm / md / lg shadow presets with color, radius, and offset |
| `DFAnimationTokens` | fast / default / slow animation curves, reduced-motion aware |
| `DFComponentTokens` | Per-component overrides (button padding, card radius, avatar size, etc.) |

Inject your theme once at the app root. Override it at any subtree. Every component respects the nearest theme in the environment automatically.

```swift
MyApp()
    .dfTheme(DFTheme(
        colors: DFColorTokens(primary: .indigo),
        radius: DFRadiusTokens(md: 10)
    ))
```

---

### Protocol-Based Style System

Every component exposes the same pattern SwiftUI uses for its own controls — a `makeBody(configuration:)` protocol that receives all the state the style needs and returns a `View`. Type-erased with `Any*Style` wrappers so styles compose, propagate through the environment, and apply hierarchically.

```swift
// Apply a style to the whole section
VStack { ... }
    .dfButtonStyle(.outlined)

// Or swap a single component's style
DFButton("Delete", role: .destructive) { }
    .dfButtonStyle(.ghost)
```

Built-in styles ship for every component. Writing a custom style requires implementing one function.

---

### Component Library

#### Primitives

| Component | Built-in Styles |
|---|---|
| `DFButton` | filled, outlined, ghost, tinted, glass¹ |
| `DFText` | Wraps `DFTextStyle` tokens — display, title, headline, body, caption, label |
| `DFIcon` | SF Symbol wrapper with token-driven size and color |
| `DFBadge` | Default, subtle, outlined, glass¹ |
| `DFAvatar` | circle, rounded, ring, glass¹ — supports image or initials + presence indicators (online/away/busy) |
| `DFDivider` | solid, dashed, gradient |

#### Inputs

| Component | Built-in Styles |
|---|---|
| `DFTextField` | outlined, filled, underline, glass¹ |
| `DFSecureField` | outlined, filled, underline, glass¹ — reveal toggle built-in |
| `DFToggle` | switch, checkbox, pill |
| `DFSlider` | default, tinted |
| `DFPicker` | segmented, menu, inline |
| `DFDatePicker` | compact, graphical, inline |

All input components share a `DFValidationState` enum (`idle / valid / error(String)`) that drives error display consistently without custom glue code.

#### Layout

| Component | Built-in Styles |
|---|---|
| `DFCard` | elevated, outlined, filled, glass¹ — optional tap interaction with press animation |

#### Overlays

| Component | Built-in Styles |
|---|---|
| `DFModal` | standard, glass¹ |
| `DFSheet` | standard, glass¹ |
| `DFPopover` | arrow, compact, glass¹ |
| `DFTooltip` | bubble, glass¹ |

---

### Liquid Glass — First-Class iOS 26 / macOS 26 Support

Every component ships a `.glass` style variant built on Apple's Liquid Glass material system, available on iOS 26+ and macOS 26+. One modifier brings your entire app's design language up to the new visual standard — no forked codebases, no conditional logic scattered across files.

```swift
VStack { ... }
    .dfButtonStyle(.glass)
    .dfCardStyle(.glass)
    .dfTooltipStyle(.glass)
```

---

### Accessibility, Built In

DesignFoundation is not accessibility-compatible after the fact — it's accessibility-native. Every component:

- Carries correct `accessibilityElement`, `accessibilityLabel`, and `accessibilityAddTraits` by default
- Reads `\.accessibilityReduceMotion` and disables press animations when the user has enabled it
- Uses semantic `DFButtonRole` (`.destructive`, `.cancel`) to provide `accessibilityHint` context automatically
- Ships Avatar presence indicators as accessible state via the `DFAvatarPresence` enum

---

### Swift 6 Strict Concurrency

The entire package compiles with `StrictConcurrency` enabled. All value types are `Sendable`. Style protocols and type-erased wrappers use `@unchecked Sendable` only where `AnyView` requires it (main-actor-only use paths). Drop it into any Swift 6 project with zero suppression pragmas.

---

### Multi-Platform by Default

| Platform | Minimum Version |
|---|---|
| iOS | 18.0 |
| macOS | 15.0 |
| visionOS | 2.0 |

The `DFPlatformVariant` enum (`automatic / compact / expanded / immersive`) lets components choose their form factor at runtime, or lets you force a specific layout for testing or design overrides. The same codebase, the same components, the same themes — on phone, desktop, and spatial.

---

## Integration

Add the package via Swift Package Manager:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/your-org/DesignFoundation", from: "1.0.0")
]
```

Apply your theme at the app root and start using components immediately. No code generation. No configuration files. No build scripts.

---

## Design Philosophy

**Every component is a token consumer, not a token owner.** Components read from the theme — they never define their own defaults in isolation. This means changing one token propagates everywhere correctly, every time.

**Styles are first-class, not afterthoughts.** The protocol-based style system mirrors how SwiftUI itself works. If you know how to write a `ButtonStyle` in SwiftUI, you already know how to write a `DFButtonStyle`. The learning curve is zero for any experienced SwiftUI developer.

**Escape hatches, not lock-in.** Every built-in style is a concrete struct you can read, copy, and fork. The protocol is open. If a built-in doesn't fit, extend it or replace it — you're working with a system, not fighting a black box.

---

## What's Next — Screens & Blocks

The component layer is the foundation. The next phase brings ready-made screens, dashboard layouts, and composable UI blocks — production-quality templates you can drop into your project and customize from the design token level up.

Planned additions include:

- **Dashboard layouts** — stat cards, chart containers, metric grids, activity feeds
- **Auth screens** — sign-in, sign-up, forgot password, 2FA confirmation
- **Onboarding flows** — feature highlights, permission requests, welcome sequences
- **Settings screens** — profile, account, preferences, notification controls
- **List & detail blocks** — feed items, contact rows, notification cells, search results
- **Empty states & loading skeletons** — consistent placeholder patterns across screen types
- **Form blocks** — multi-step forms, address entry, payment fields (UI only)

Every screen and block is themeable from the same `DFTheme` that drives the primitives. A brand color change ripples through components and screens identically — because they're all reading the same tokens.

---

## Summary

DesignFoundation is a professional-grade SwiftUI design system that eliminates the overhead of building one from scratch, without locking you into a rigid visual language. It gives teams:

- A consistent token-based theme they define once and apply everywhere
- A full set of production-ready components that respect that theme automatically
- A familiar protocol-based style system for customization without hacks
- Native Liquid Glass support for the latest Apple platforms
- Accessibility and Swift 6 safety included, not bolted on
- A growing library of screens and blocks to accelerate feature development

Ship faster. Design consistently. Build on a real foundation.
