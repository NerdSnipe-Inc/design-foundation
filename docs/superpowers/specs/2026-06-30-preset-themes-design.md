# Preset Themes — Design Spec
**Date:** 2026-06-30
**Status:** Approved

---

## Overview

Add a first-class preset theme system to DesignFoundation. Presets give developers a one-liner way to apply a complete, opinionated visual identity — including colors, corner radius, and shadows — with automatic light/dark adaptation. Four themes ship in the box: Slate, Aurora, Copper, and Sage.

---

## Architecture

### `DFThemePreset`

A new `Sendable` struct that pairs a `light: DFTheme` with a `dark: DFTheme`. Static presets hang off it as named constants.

```swift
public struct DFThemePreset: Sendable {
    public let light: DFTheme
    public let dark: DFTheme

    public static let slate  = DFThemePreset(light: .slateLight,  dark: .slateDark)
    public static let aurora = DFThemePreset(light: .auroraLight, dark: .auroraDark)
    public static let copper = DFThemePreset(light: .copperLight, dark: .copperDark)
    public static let sage   = DFThemePreset(light: .sageLight,   dark: .sageDark)
}
```

### `dfThemePreset()` View Modifier

A new `View` extension that reads `@Environment(\.colorScheme)` and delegates to the existing `.dfTheme()` modifier — so platform context resolution and environment injection work for free with no duplication.

```swift
// Common case — auto adapts to system light/dark
ContentView().dfThemePreset(.aurora)

// Power-user cases — force a specific appearance or override a sub-tree
PreviewView().dfTheme(.auroraDark)
SidebarView().dfTheme(.slateLight)
```

SwiftUI's environment reactivity means the modifier re-evaluates automatically when the system color scheme changes — no extra work needed.

### What a `DFTheme` preset varies

| Token group   | Varies per preset? | Notes |
|---------------|-------------------|-------|
| Colors        | Yes               | Full color palette, `respectsColorScheme: false` |
| Radius        | Yes               | Drives the sharp/rounded personality axis |
| Shadows       | Yes               | Depth and weight reinforce each theme's character |
| Typography    | No                | SF Pro does the heavy lifting; varying weights fights the platform |
| Spacing       | No                | Consistent spacing keeps layout muscle-memory intact |
| Animation     | No                | Platform-native timing stays consistent |
| Components    | No                | Component token overrides remain available for app-level customization |

`respectsColorScheme: false` is set on all preset `DFColorTokens` instances because the `DFThemePreset` modifier handles light/dark switching at the theme level — the tokens themselves are explicit static values.

### File layout

```
Sources/DesignFoundation/Core/Theme/
  DFThemePreset.swift              ← DFThemePreset struct + dfThemePreset() modifier
  Presets/
    DFTheme+Slate.swift
    DFTheme+Aurora.swift
    DFTheme+Copper.swift
    DFTheme+Sage.swift
```

Each preset file:
- Adds `public extension DFTheme` statics (e.g. `.slateLight`, `.slateDark`)
- Defines a `fileprivate` computed `DFColorTokens` property with all explicit color values
- Defines a `fileprivate` `DFRadiusTokens` and `DFShadowTokens` where they differ from default

**Derived interactive states:** `interactiveHover` and `interactivePressed` are always derived from `interactiveFill` using `.opacity(0.85)` and `.opacity(0.7)` respectively — consistent with the existing default pattern. They are not listed in the per-theme tables below.

---

## The Four Themes

### 1. Slate — Professional, balanced, tech-forward

**Target:** SaaS dashboards, productivity tools, developer-facing apps.

**Personality:** Neither sharp nor playful — balanced and trustworthy. The blue-slate brand communicates reliability. Default radius keeps it neutral enough to feel at home in any professional context.

**Radius:** `sm=4, md=8, lg=12` (default — no change)
**Shadows:** Default — `sm(opacity:0.08, radius:4, y:2)`, `md(0.12, 8, 4)`, `lg(0.18, 16, 8)`

| Token              | Light                     | Dark                      |
|--------------------|---------------------------|---------------------------|
| primary            | `#1C3D5A` deep navy-slate | `#64B5F6` sky blue        |
| secondary          | `#546E7A` blue-gray       | `#78909C` muted blue-gray |
| accent             | `#2979FF` electric blue   | `#82C4FF` light blue      |
| background         | `#FAFAFA`                 | `#0F1923`                 |
| surface            | `#F2F2F7`                 | `#1C2B3A`                 |
| surfaceElevated    | `#FFFFFF`                 | `#243447`                 |
| textPrimary        | `#0D1B2A`                 | `#E8F0F8`                 |
| textSecondary      | `#546E7A`                 | `#90A4AE`                 |
| textDisabled       | `#9EAAB5`                 | `#4A6070`                 |
| border             | `#D1D9E0`                 | `#2E4057`                 |
| interactiveFill    | `#2979FF`                 | `#64B5F6`                 |
| interactiveDisabled| `#E2E8ED`                 | `#1F3348`                 |
| destructive        | `#E53935`                 | `#EF5350`                 |
| success            | `#2E7D32`                 | `#66BB6A`                 |
| warning            | `#F57C00`                 | `#FFA726`                 |
| info               | `#0277BD`                 | `#29B6F6`                 |

---

### 2. Aurora — Vibrant, creative, modern

**Target:** Creative tools, consumer apps, entertainment, social platforms.

**Personality:** Electric violet brand with lavender-tinted surfaces. Rounded corners amplify the playful, modern feel. Shadows are intentionally soft — the colors carry the energy.

**Radius:** `sm=4, md=10, lg=16` (more rounded than default)
**Shadows:** Soft — `sm(opacity:0.06, radius:6, y:2)`, `md(0.08, 12, 4)`, `lg(0.12, 20, 6)`

| Token              | Light                       | Dark                        |
|--------------------|-----------------------------|-----------------------------|
| primary            | `#6C47FF` electric violet   | `#A78BFA` soft violet       |
| secondary          | `#9B72CF` medium purple     | `#7C6BAD` muted purple      |
| accent             | `#A78BFA` soft violet       | `#C4B5FD` light lavender    |
| background         | `#FAFAFA`                   | `#0D0A1E`                   |
| surface            | `#F3F0FF` lavender tint     | `#1A1535`                   |
| surfaceElevated    | `#FFFFFF`                   | `#241D47`                   |
| textPrimary        | `#1A0A4F` deep purple       | `#EDE9FF`                   |
| textSecondary      | `#6B5FA0`                   | `#9D8FD4`                   |
| textDisabled       | `#B3A9D9`                   | `#4A3F7A`                   |
| border             | `#D9D1F5`                   | `#2E2557`                   |
| interactiveFill    | `#6C47FF`                   | `#A78BFA`                   |
| interactiveDisabled| `#E8E3FF`                   | `#1F1940`                   |
| destructive        | `#E53935`                   | `#EF5350`                   |
| success            | `#2E7D32`                   | `#66BB6A`                   |
| warning            | `#F57C00`                   | `#FFA726`                   |
| info               | `#6C47FF` (matches brand)   | `#A78BFA` (matches brand)   |

---

### 3. Copper — Warm, editorial, premium

**Target:** Finance apps, content/magazine readers, premium lifestyle products.

**Personality:** Copper and amber tones against warm cream surfaces. Sharper corners signal editorial precision. More defined shadows add weight and gravitas — this theme means business.

**Radius:** `sm=3, md=6, lg=10` (sharper than default)
**Shadows:** Defined — `sm(opacity:0.12, radius:3, y:3)`, `md(0.16, 6, 5)`, `lg(0.22, 12, 10)`

| Token              | Light                       | Dark                        |
|--------------------|-----------------------------|-----------------------------|
| primary            | `#C4622D` copper            | `#F4A261` warm amber        |
| secondary          | `#8D6E63` warm brown-gray   | `#A1887F` light brown       |
| accent             | `#E8894B` amber             | `#FFB74D` golden amber      |
| background         | `#FBF8F5` warm white        | `#1A1008` espresso          |
| surface            | `#F5EDE3` warm cream        | `#2C1F12`                   |
| surfaceElevated    | `#FFFAF6`                   | `#3D2C1C`                   |
| textPrimary        | `#2C1810` dark espresso     | `#FFF3E8`                   |
| textSecondary      | `#8D6E63`                   | `#BFA090`                   |
| textDisabled       | `#BCA89C`                   | `#5C4030`                   |
| border             | `#E3D0C3`                   | `#4A3020`                   |
| interactiveFill    | `#C4622D`                   | `#F4A261`                   |
| interactiveDisabled| `#F0E0D0`                   | `#2E1C10`                   |
| destructive        | `#C62828` deep red          | `#EF5350`                   |
| success            | `#2E7D32`                   | `#66BB6A`                   |
| warning            | `#E65100` deep orange       | `#FFA726`                   |
| info               | `#1565C0` deep blue         | `#64B5F6`                   |

---

### 4. Sage — Calm, natural, organic

**Target:** Health, wellness, meditation, lifestyle, environmental apps.

**Personality:** Deep sage green brand against lightly tinted green-white surfaces. The most rounded corners of any preset — organic and approachable. Very soft shadows keep things airy and calm.

**Radius:** `sm=6, md=12, lg=18` (most rounded)
**Shadows:** Very soft — `sm(opacity:0.04, radius:8, y:1)`, `md(0.06, 16, 3)`, `lg(0.10, 24, 5)`

| Token              | Light                       | Dark                        |
|--------------------|-----------------------------|-----------------------------|
| primary            | `#2D6A4F` deep sage         | `#74C69D` mint green        |
| secondary          | `#52796F` teal-gray         | `#6B9E8F` muted teal        |
| accent             | `#52B788` mint              | `#95D5B2` light mint        |
| background         | `#F7FAF7` green-white tint  | `#0A1A0F` deep forest       |
| surface            | `#EDF4EE` soft green        | `#162B1C`                   |
| surfaceElevated    | `#FFFFFF`                   | `#1F3D27`                   |
| textPrimary        | `#0A2318` deep forest       | `#E8F5EC`                   |
| textSecondary      | `#52796F`                   | `#80B090`                   |
| textDisabled       | `#9FB8AF`                   | `#3A5C42`                   |
| border             | `#C8DFCC`                   | `#1F4A2C`                   |
| interactiveFill    | `#2D6A4F`                   | `#74C69D`                   |
| interactiveDisabled| `#D8EDE0`                   | `#152A1A`                   |
| destructive        | `#C62828`                   | `#EF5350`                   |
| success            | `#1B5E20` deep forest green | `#66BB6A`                   |
| warning            | `#F57C00`                   | `#FFA726`                   |
| info               | `#01579B` deep blue         | `#64B5F6`                   |

---

## Developer API Summary

```swift
// Automatic light/dark — recommended default
MyApp()
    .dfThemePreset(.aurora)

// Force a specific appearance (Previews, sub-tree overrides)
MyView()
    .dfTheme(.copperDark)

// Build a custom preset from existing themes
let myPreset = DFThemePreset(light: .slateLight, dark: .auroraDark)

// Compose from a preset with one override
var custom = DFTheme.sageLight
custom.colors.primary = .purple
MyView().dfTheme(custom)
```

---

## Out of Scope

- Typography variation between presets (SF Pro handles this at the platform level)
- Spacing variation (breaks layout muscle-memory for developers)
- Animation variation (platform-native timing stays consistent)
- Dynamic color composition within a single `DFTheme` (UIColor dynamic providers) — the preset modifier handles switching instead
