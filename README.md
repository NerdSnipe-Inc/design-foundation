<p align="center">
  <img alt="DesignFoundation" src="docs/images/design-foundation-logo.png" width="100%" />
</p>

# DesignFoundation

A SwiftUI design system I built because every new project I started, I was rebuilding the same buttons, inputs, cards, and modals, losing another two weeks to it.

![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![iOS 18+](https://img.shields.io/badge/iOS-18%2B-blue?logo=apple)
![macOS 15+](https://img.shields.io/badge/macOS-15%2B-blue?logo=apple)
![visionOS 2+](https://img.shields.io/badge/visionOS-2%2B-blue?logo=apple)
[![MIT License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)

---

DesignFoundation gives you a token-based theming engine and 50+ SwiftUI components that all read from the same theme. Set the theme once at the app root, every component underneath updates. That's the whole idea.

Five presets, each with a light and a dark variant. A style protocol for every styleable component, including Liquid Glass styles for iOS/macOS 26+. One popup engine that powers toasts, floaters, centered cards and bottom sheets. Swift 6 strict concurrency safe.

---

## Requirements

- iOS 18+, macOS 15+, visionOS 2+
- Xcode 16+ (Swift tools 6.0)
- Liquid Glass (`.glass`) styles only take effect on iOS/macOS 26+. Everything else works on the minimums above.

## Installation

Add the package via Swift Package Manager.

**Xcode:** File → Add Package Dependencies → `https://github.com/NerdSnipe-Inc/design-foundation` → Up to Next Major Version from `1.7.0`

**Package.swift:**

```swift nocheck
dependencies: [
    .package(url: "https://github.com/NerdSnipe-Inc/design-foundation", from: "1.7.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "DesignFoundation", package: "design-foundation")
        ]
    )
]
```

Then `import DesignFoundation`. The package is named `design-foundation` (the repo name) and the library product is `DesignFoundation`, so use the `.product(name:package:)` form; the bare `"DesignFoundation"` shorthand doesn't resolve against the GitHub URL.

---

## Quick Start

Set a theme preset at the root, then use components. This is the whole setup:

```swift
import SwiftUI
import DesignFoundation

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .dfToast()                    // once, at the root: enables toasts
                .dfThemePreset(.slate)        // theme at or outside .dfToast() so toasts are themed too
        }
    }
}

struct HomeView: View {
    @Environment(\.dfTheme) private var theme
    @State private var email = ""

    var body: some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                DFText("Welcome", scale: .title)
                DFTextField("Email", text: $email, placeholder: "you@example.com")
                DFButton("Get started") {
                    DFToastQueue.shared.show(text: "Saved", severity: .success)
                }
            }
        }
        .padding(theme.spacing.lg)
    }
}
```

---

## Theme System

One `DFTheme` struct sits in SwiftUI's environment and drives every component. Set it at the app root, override it anywhere below. It has eight token namespaces: `colors`, `typography`, `spacing`, `radius`, `shadows`, `animation`, `components` (26 per-component override structs such as `DFButtonTokens`, `DFCardTokens`, `DFPopupTokens`) and `materials`.

```swift
// Build a theme from tokens; anything you leave out keeps its default
var custom = DFTheme(
    spacing: DFSpacingTokens(md: 20),
    radius: DFRadiusTokens(md: 12)
)
custom.colors.primary = .indigo
custom.components.button = DFButtonTokens(cornerRadius: 4)   // sharper buttons only
HomeView().dfTheme(custom)
```

Every component reads from the nearest `DFTheme` in the environment. Change a token, everything that uses it updates. No manual wiring.

### Preset themes

Five presets ship in the box. Each one pairs a light and dark `DFTheme` and switches automatically based on `@Environment(\.colorScheme)`.

```swift
HomeView().dfThemePreset(.aurora)
```

| Preset | Notes | Fits well with |
|---|---|---|
| `.slate` | Navy-slate primary, default radii and shadows | SaaS dashboards, developer tools |
| `.aurora` | Violet primary, larger corner radii, softer shadows | Creative tools, social apps |
| `.copper` | Warm copper primary, tight radii, stronger shadows | Finance, content readers |
| `.sage` | Deep green primary, generous radii, subtle shadows | Health, wellness |
| `.garnet` | Bold, saturated deep garnet red (#C8102E), white cards, off-white background | Bold consumer brands, retail, sports |

The differences read better in a preview than in a description, spin them up and see which one feels right for your app.

```swift
// Force a specific variant (previews, sub-tree overrides)
HomeView().dfTheme(.copperDark)

// Build a preset from any two themes
let myPreset = DFThemePreset(light: .slateLight, dark: .auroraDark)
HomeView().dfThemePreset(myPreset)

// Mutate one token, keep the rest
var tweaked = DFTheme.sageLight
tweaked.colors.primary = .purple
HomeView().dfTheme(tweaked)
```

---

## Components

### Primitives

| Component | Built-in styles / notes |
|---|---|
| `DFButton` | `.filled`, `.outlined`, `.ghost`, `.tinted`, `.glass`¹; `role:` `.destructive` / `.cancel`; `.buttonStyle(.df(_:role:))` brands a native `Button` |
| `DFText` | eight scales (`display`, `title`, `headline`, `labelLarge`, `body`, `bodySmall`, `label`, `caption`); styles `.standard`, `.secondary`, `.muted` |
| `DFIcon` | SF Symbol or image with token-driven size; `.standard`, `.tinted`, `.secondary` |
| `DFBadge` | `.filled`, `.tinted`, `.outlined`, `.glass`¹; count, dot or text variants |
| `DFAvatar` | `.circle`, `.rounded`, `.ring`, `.glass`¹; image or initials, presence indicators |
| `DFDivider` | `.standard`, `.subtle`, `.thick`; horizontal or vertical, optional label |
| `DFChip` | `.filled`, `.tinted`, `.outlined`; label, icon, dismissible and selectable variants |
| `DFRatingView` | `.stars`, `.numeric`; read-only or interactive |
| `DFPriceView` | `.standard`, `.compact`; optional strikethrough compare-at price |

### Inputs

| Component | Built-in styles / notes |
|---|---|
| `DFTextField` | `.outlined`, `.filled`, `.glass`¹; optional leading / trailing views |
| `DFSecureField` | `.outlined`, `.filled`, `.glass`¹; show/hide toggle built in |
| `DFTextArea` | Multiline text with min / max lines |
| `DFToggle` | `.switch`, `.checkbox`, `.glass`¹ |
| `DFSlider` | `.standard`, `.labeled`, `.glass`¹ |
| `DFPicker` | `.menu`, `.segmented`, `.wheel`, `.glass`¹ |
| `DFDatePicker` | `.compact`, `.graphical`, `.wheel`, `.glass`¹ |
| `DFCheckbox` | `.default` |
| `DFQuantityStepper` | `.bordered`, `.compact` |
| `DFRadioPickerView` | Inline single-select list of radio rows |
| `DFFormState` + `DFValidatedTextField` | Keyed form state with `DFRequiredValidator`, `DFEmailValidator`, `DFMinLengthValidator`, `DFMaxLengthValidator`, `DFRegexValidator`, or your own `DFFieldValidator` |

All text inputs share `DFValidationState` (`.none`, `.valid`, `.error(String)`) so error display looks consistent everywhere.

### Layout

| Component | Built-in styles / notes |
|---|---|
| `DFCard` | `.elevated`, `.outlined`, `.filled`, `.glass`¹; optional tap action |
| `DFEntityRow` / `DFEntityCard` | Themed "media + title/subtitle + trailing" summary rows and cards |
| `DFGrid` / `DFCarousel` | Themed `LazyVGrid` (fixed or adaptive columns) and horizontal scroller |
| `DFPriceSummaryView` | Line items with an emphasized total row |
| `.dfBottomBar { }` | Pins a total or CTA to the bottom of a view on a themed surface |

### Navigation

| Component | Built-in styles / notes |
|---|---|
| `DFTabBar` | `.standard`, `.minimal`, `.glass`¹ |
| `DFNavigationBar` (`.dfNavigationBar(title:)`) | `.standard`, `.transparent`, `.glass`¹ |
| `DFSidebar` | `.standard`, `.plain`, `.glass`¹ |

### Overlays

| Component | Built-in styles / notes |
|---|---|
| `.dfModal` / `.dfFullscreenModal` | `.standard` (a glass variant exists as `DFGlassModalStyle()`)¹ |
| `.dfSheet` | `.standard`, `.compact`, `.glass`¹ |
| `.dfPopover` | `.arrow`, `.compact`, `.glass`¹ |
| `.dfTooltip` | `.bubble`, `.glass`¹ |
| `.dfPopup` | Centered, toast, floater and bottom-sheet kinds; see [Popups & toasts](#popups--toasts) |
| `.dfCommandPalette` | Searchable command list with keyboard navigation on macOS |
| `.dfImageGallery` | Full-screen swipeable image viewer with a page indicator |

### Feedback & data

| Component | Notes |
|---|---|
| `.dfAlert` | Convenience wrapper over the native SwiftUI alert |
| `DFToastQueue` + `.dfToast()` | Queue management and auto-dismiss; nine positions, eight styles, optional title and action. See [Popups & toasts](#popups--toasts) |
| `DFBanner` | Full-width, persistent, inline banner with an optional action |
| `DFEmptyState` | Icon, title, message and up to two actions |
| `DFSkeleton` | Shimmer animation in rectangle, rounded rectangle, circle or capsule |
| `DFProgressBar` | Linear, circular, and indeterminate variants |
| `DFList` / `DFListRow` | Selection, swipe-delete and reorder; leading / trailing slots and disclosure indicator |
| `DFTable` / `DFDataTable` / `DFDataGrid` | Sortable columns; selection and filtering; editable cells, column visibility and paging |
| `DFCalendarView` | Month grid with min / max dates and per-day content |
| `DFArticleRow`, `DFAuthorView`, `DFRelativeTimeTag`, `DFInlineTagView`, `DFMetadataRow` | Content-row primitives for feeds, news and docs lists |

¹ `.glass` styles require iOS 26+ / macOS 26+ and honor `theme.materials.preferLiquidGlass`.

---

## Popups & toasts

One engine, `.dfPopup(isPresented:)` / `.dfPopup(item:)`, presents centered cards, edge-flush toasts, inset floaters and bottom sheets, in nine positions, with slide, scale, fade or custom transitions, none / dim / blur backdrops, auto-dismiss, and tap, outside-tap or drag to dismiss. `DFToastQueue` and `.dfToast()` run on the same engine.

```swift
HomeView()
    .dfPopup(isPresented: $showPopup, configuration: .sheet(backdrop: .blur)) {
        DFPopupCard(
            icon: "sparkles",
            title: "Upgrade to Pro",
            message: "Unlock unlimited projects.",
            primaryAction: DFPopupAction("Upgrade") { },
            secondaryAction: DFPopupAction("Later") { }
        )
    }
    .dfPopupStyle(.frosted)              // .standard .frosted .glass¹ .accent .gradient .inverse .outlined .tinted(_:)
    .dfToast(style: .tinted)             // .default .tinted .filled .inverse .frosted .glass¹ .banner .compact

DFToastQueue.shared.show(text: "Moved to the trash", severity: .error, position: .bottom,
                         title: "Deleted", actionTitle: "Undo", action: { restore() })
```

Surface styles, toast styles, `DFPopupCard`, the bottom-sheet kind and `DFPopupBackdrop` are new in 1.7.0. Colored styles pick foregrounds that reach WCAG AA contrast in every preset, light and dark. Every recording in the docs was captured from the real DFPlayground Popup Lab: [popups with real recordings](https://nerdsnipe-inc.github.io/design-foundation/#popups), or the [Popups wiki page](https://github.com/NerdSnipe-Inc/design-foundation/wiki/Popups).

---

## Style System

Every styleable component exposes a `makeBody(configuration:)` style protocol, the same pattern SwiftUI uses for `ButtonStyle`: 33 style protocols in all, each with built-in styles, a `.dfXxxStyle(_:)` modifier and an environment key. Styles compose, propagate through the environment, and apply hierarchically.

```swift
// Apply a style to an entire section
VStack { DFButton("Save") { }; DFCard { DFText("Body") } }
    .dfButtonStyle(.outlined)
    .dfCardStyle(.outlined)

// Override for a single component
DFButton("Delete", role: .destructive) { }
    .dfButtonStyle(.ghost)

// Liquid Glass across your whole UI (iOS/macOS 26+)
HomeView()
    .dfButtonStyle(.glass)
    .dfCardStyle(.glass)
    .dfTooltipStyle(.glass)
```

Writing a custom style means implementing one function. Built-in styles are concrete structs, copy any of them as a starting point. The full list of styles per component is in [CLAUDE.md](CLAUDE.md#style-system) and the [Style System wiki page](https://github.com/NerdSnipe-Inc/design-foundation/wiki/Style-System).

---

## Platforms

| Platform | Minimum Version |
|---|---|
| iOS | 18.0 |
| macOS | 15.0 |
| visionOS | 2.0 |

Platform differences are handled inside the components (via `DFPlatformContext`, which `.dfTheme()` and `.dfThemePreset()` inject), so you don't need `#if os()` guards to use them. Liquid Glass (`.glass` styles) requires iOS 26+ / macOS 26+.

---

## Try it: DFPlayground and example apps

**DFPlayground** is a free macOS app that browses every component, block, screen and theme live, and includes the Popup Lab used for the recordings above. [Download it from the docs site](https://nerdsnipe-inc.github.io/design-foundation/DFPlayground.dmg) (macOS 15+). Prefer to browse without installing? The [Screenshot Library](Content/index.md) has a framed shot of every screen.

Five full, open-source example apps show what a real app looks like on top of DesignFoundation. They also use DesignFoundation Pro, so **building them requires a Pro license**; the source is public and readable either way.

- [AICompleteChat](https://github.com/NerdSnipe-Inc/AICompleteChat): on-device AI chat with Apple's Foundation Models framework (`LanguageModelSession`, `@Generable` structured output, streaming), no server round-trip.
- [BudgetLens](https://github.com/NerdSnipe-Inc/BudgetLens): iOS + macOS budget tracker on Pro's `Analytics` vertical, SwiftData, with on-device spending insights.
- [ScanLens](https://github.com/NerdSnipe-Inc/ScanLens): document and receipt scanner on Pro's `Documents` vertical, with on-device Vision OCR and Foundation Models categorization.
- [ClientLens](https://github.com/NerdSnipe-Inc/ClientLens): SwiftUI CRM on Pro's `CRM` vertical (`DFCRMRootView`) with SwiftData and on-device follow-up drafting.
- [BookLens](https://github.com/NerdSnipe-Inc/BookLens): appointment booking on Pro's `Booking` vertical with SwiftData, EventKit and an on-device scheduling assistant.

---

## DesignFoundation Pro

There's a paid tier that adds pre-built screens and blocks composed from these same primitives: 32 blocks (auth, dashboards and charts, forms, settings, feeds), 55 screens across 12 verticals (AI Chat, Analytics, Booking, CRM, Documents, E-commerce, Food, News, Onboarding, Project Manager, Settings, Social), 18 navigation shells, 12 composition roots, and advanced popups (unified overlay / sheet / window presentation, scroll popups with detents, a priority queue, celebration, permission, promo, rating, input, consent and action popups, undo and progress toasts, notification banners, a live capsule, coachmark tours, motion presets and haptics). DesignFoundationPro 2.3.0 requires DesignFoundation 1.7.0.

Details and purchase: [nerdsnipe-inc.github.io/design-foundation/pro](https://nerdsnipe-inc.github.io/design-foundation/pro/) ([advanced popups](https://nerdsnipe-inc.github.io/design-foundation/pro/#popups)). It's optional. The primitives on this repo stay MIT and get maintained regardless.

---

## Docs, wiki and AI agents

- [Documentation site](https://nerdsnipe-inc.github.io/design-foundation/): installation, theming, every component, popups with recordings, platform support. Also the [integration guide](https://nerdsnipe-inc.github.io/design-foundation/integration/) and [theme presets](https://nerdsnipe-inc.github.io/design-foundation/theme-presets/).
- [Wiki](https://github.com/NerdSnipe-Inc/design-foundation/wiki): one page per topic ([Getting Started](https://github.com/NerdSnipe-Inc/design-foundation/wiki/Getting-Started), [Theming](https://github.com/NerdSnipe-Inc/design-foundation/wiki/Theming), [Popups](https://github.com/NerdSnipe-Inc/design-foundation/wiki/Popups), and more).
- [Changelog](CHANGELOG.md).
- AI coding agents: [CLAUDE.md](CLAUDE.md) is the compile-checked API reference; [AGENTS.md](AGENTS.md) and [`.cursor/rules/design-foundation.mdc`](.cursor/rules/design-foundation.mdc) describe the same surface. They tell agents to use these components instead of rebuilding them.
- Token lint: [`Tooling/swiftlint-design-foundation-tokens.yml`](Tooling/swiftlint-design-foundation-tokens.yml) is a drop-in SwiftLint `custom_rules` block that flags raw `Color(...)`, `.font(.system(...))` and hardcoded corner radii in your own views.

---

## Why I built this

Short version: every SwiftUI project I started ended up rebuilding the same primitives. Buttons that needed 40 lines of styling to match brand. Text fields with validation states I always got slightly wrong. The design system would drift within months because there was no single source of truth for spacing, radius, color, or elevation. Six months in, half my app used one theme and half used whatever I shipped in a busy sprint.

DesignFoundation makes the tokens the source of truth. Components read from the environment. Brand refreshes are a theme file edit, not a file hunt.

Feedback and issues are welcome, especially on the theme API. If something's rough, open an issue.

---

## License

MIT © 2026 NerdSnipe Inc. See [LICENSE](LICENSE).
