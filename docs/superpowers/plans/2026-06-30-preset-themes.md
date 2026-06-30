# Preset Themes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `DFThemePreset` — a paired light/dark theme struct with a `dfThemePreset()` SwiftUI modifier — and ship four built-in presets: Slate, Aurora, Copper, and Sage.

**Architecture:** A new `DFThemePreset` struct pairs `light: DFTheme` and `dark: DFTheme`. A `dfThemePreset()` view modifier reads `@Environment(\.colorScheme)` and delegates to the existing `.dfTheme()` modifier, so platform context resolution is automatic. Each preset varies colors, radius, and shadows; typography, spacing, and animation are unchanged.

**Tech Stack:** Swift 6 (strict concurrency), Swift Testing (`import Testing`), SwiftUI, SPM.

## Global Constraints

- Swift Tools Version: 6.0 — `StrictConcurrency` experimental feature is enabled
- Platforms: iOS 18+, macOS 15+, visionOS 2+
- All new types must be `public` and `Sendable`
- `DFColorTokens` inits are platform-conditional (`#if os(iOS)`) but both branches have identical parameter labels — call with all explicit named arguments so it compiles on every platform
- `respectsColorScheme: false` on all preset color tokens — the preset modifier handles light/dark switching, tokens must not double-adapt
- `interactiveHover` = `interactiveFill.opacity(0.85)`, `interactivePressed` = `interactiveFill.opacity(0.70)` — derive from the fill, not hardcoded
- Test framework: Swift Testing (`import Testing`, `@Suite`, `@Test`, `#expect`)
- Test command: `swift test` from the package root
- No new dependencies — zero additions to `Package.swift`

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `Sources/DesignFoundation/Core/Theme/DFThemePreset.swift` | `DFThemePreset` struct + `dfThemePreset()` modifier |
| Create | `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Slate.swift` | `DFTheme.slateLight`, `DFTheme.slateDark`, fileprivate color/radius/shadow tokens |
| Create | `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Aurora.swift` | `DFTheme.auroraLight`, `DFTheme.auroraDark`, fileprivate tokens |
| Create | `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Copper.swift` | `DFTheme.copperLight`, `DFTheme.copperDark`, fileprivate tokens |
| Create | `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Sage.swift` | `DFTheme.sageLight`, `DFTheme.sageDark`, fileprivate tokens |
| Create | `Tests/DesignFoundationTests/Core/DFThemePresetTests.swift` | Tests for `DFThemePreset` struct and custom init |
| Create | `Tests/DesignFoundationTests/Core/Presets/DFThemeSlateTests.swift` | Tests for Slate preset token values |
| Create | `Tests/DesignFoundationTests/Core/Presets/DFThemeAuroraTests.swift` | Tests for Aurora preset token values |
| Create | `Tests/DesignFoundationTests/Core/Presets/DFThemeCopperTests.swift` | Tests for Copper preset token values |
| Create | `Tests/DesignFoundationTests/Core/Presets/DFThemeSageTests.swift` | Tests for Sage preset token values |

---

## Task 1: `DFThemePreset` struct + `dfThemePreset()` modifier

**Files:**
- Create: `Sources/DesignFoundation/Core/Theme/DFThemePreset.swift`
- Create: `Tests/DesignFoundationTests/Core/DFThemePresetTests.swift`

**Interfaces:**
- Produces: `public struct DFThemePreset: Sendable { public let light: DFTheme; public let dark: DFTheme; public init(light:dark:) }` 
- Produces: `public extension DFThemePreset { static let slate, aurora, copper, sage }`
- Produces: `public extension View { func dfThemePreset(_ preset: DFThemePreset) -> some View }`

- [ ] **Step 1: Write the failing test**

Create `Tests/DesignFoundationTests/Core/DFThemePresetTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFThemePreset")
struct DFThemePresetTests {

    @Test("custom init stores light and dark themes")
    func customInitStoresThemes() {
        var light = DFTheme.default
        light.colors.primary = .red
        var dark = DFTheme.default
        dark.colors.primary = .blue

        let preset = DFThemePreset(light: light, dark: dark)

        #expect(preset.light.colors.primary == .red)
        #expect(preset.dark.colors.primary == .blue)
    }

    @Test("slate preset light and dark primaries differ")
    func slatePresetHasTwoDistinctThemes() {
        let preset = DFThemePreset.slate
        #expect(preset.light.colors.primary != preset.dark.colors.primary)
    }

    @Test("aurora preset light and dark primaries differ")
    func auroraPresetHasTwoDistinctThemes() {
        let preset = DFThemePreset.aurora
        #expect(preset.light.colors.primary != preset.dark.colors.primary)
    }

    @Test("copper preset light and dark primaries differ")
    func copperPresetHasTwoDistinctThemes() {
        let preset = DFThemePreset.copper
        #expect(preset.light.colors.primary != preset.dark.colors.primary)
    }

    @Test("sage preset light and dark primaries differ")
    func sagePresetHasTwoDistinctThemes() {
        let preset = DFThemePreset.sage
        #expect(preset.light.colors.primary != preset.dark.colors.primary)
    }

    @Test("preset light theme matches named DFTheme static")
    func presetLightMatchesNamedStatic() {
        #expect(DFThemePreset.slate.light.radius.md == DFTheme.slateLight.radius.md)
        #expect(DFThemePreset.slate.dark.radius.md  == DFTheme.slateDark.radius.md)
    }
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
swift test --filter DFThemePresetTests 2>&1 | tail -20
```

Expected: compile error — `DFThemePreset` not found.

- [ ] **Step 3: Create `DFThemePreset.swift`**

Create `Sources/DesignFoundation/Core/Theme/DFThemePreset.swift`:

```swift
import SwiftUI

public struct DFThemePreset: Sendable {
    public let light: DFTheme
    public let dark: DFTheme

    public init(light: DFTheme, dark: DFTheme) {
        self.light = light
        self.dark = dark
    }

    public static let slate  = DFThemePreset(light: .slateLight,  dark: .slateDark)
    public static let aurora = DFThemePreset(light: .auroraLight, dark: .auroraDark)
    public static let copper = DFThemePreset(light: .copperLight, dark: .copperDark)
    public static let sage   = DFThemePreset(light: .sageLight,   dark: .sageDark)
}

public extension View {
    func dfThemePreset(_ preset: DFThemePreset) -> some View {
        modifier(DFThemePresetModifier(preset: preset))
    }
}

private struct DFThemePresetModifier: ViewModifier {
    let preset: DFThemePreset
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.dfTheme(colorScheme == .dark ? preset.dark : preset.light)
    }
}
```

Note: `DFThemePreset.slate` etc. reference `DFTheme.slateLight` — those statics are defined in Tasks 2–5. The Swift compiler allows forward references within a module; these properties initialise lazily when first accessed at runtime.

- [ ] **Step 4: Run tests to confirm they pass** (Tasks 2–5 must be complete first for preset statics to compile)

Skip until after Task 5, then run:

```bash
swift test --filter DFThemePresetTests 2>&1 | tail -20
```

Expected: `Test run with 5 tests passed in …`

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Core/Theme/DFThemePreset.swift \
        Tests/DesignFoundationTests/Core/DFThemePresetTests.swift
git commit -m "feat: add DFThemePreset struct and dfThemePreset() modifier"
```

---

## Task 2: Slate preset

**Files:**
- Create: `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Slate.swift`
- Create: `Tests/DesignFoundationTests/Core/Presets/DFThemeSlateTests.swift`

**Interfaces:**
- Consumes: `DFTheme(colors:radius:shadows:)`, `DFColorTokens(primary:...respectsColorScheme:)`, `DFRadiusTokens(none:sm:md:lg:full:)`, `DFShadowTokens(none:sm:md:lg:)`, `DFShadow(color:radius:x:y:)`
- Produces: `public extension DFTheme { static let slateLight: DFTheme; static let slateDark: DFTheme }`

**Slate personality:** Professional, balanced. Default radius (sm=4, md=8, lg=12). Default shadows (sm opacity 0.08 radius 4 y 2, md 0.12/8/4, lg 0.18/16/8).

- [ ] **Step 1: Write the failing test**

Create `Tests/DesignFoundationTests/Core/Presets/DFThemeSlateTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Slate")
struct DFThemeSlateTests {

    // MARK: Structure

    @Test("slateLight and slateDark are distinct themes")
    func slateVariantsAreDistinct() {
        #expect(DFTheme.slateLight.colors.primary != DFTheme.slateDark.colors.primary)
    }

    // MARK: Color tokens

    @Test("slateLight respectsColorScheme is false")
    func slateLightDoesNotRespectColorScheme() {
        #expect(DFTheme.slateLight.colors.respectsColorScheme == false)
    }

    @Test("slateDark respectsColorScheme is false")
    func slateDarkDoesNotRespectColorScheme() {
        #expect(DFTheme.slateDark.colors.respectsColorScheme == false)
    }

    @Test("slateLight primary is deep navy-slate")
    func slateLightPrimary() {
        #expect(DFTheme.slateLight.colors.primary == Color(red: 0.110, green: 0.239, blue: 0.353))
    }

    @Test("slateDark primary is sky blue")
    func slateDarkPrimary() {
        #expect(DFTheme.slateDark.colors.primary == Color(red: 0.392, green: 0.710, blue: 0.965))
    }

    @Test("slateLight interactive fill matches accent intent")
    func slateLightInteractiveFill() {
        #expect(DFTheme.slateLight.colors.interactiveFill == Color(red: 0.161, green: 0.475, blue: 1.0))
    }

    // MARK: Radius tokens

    @Test("slate radius sm is 4")
    func slateRadiusSm() {
        #expect(DFTheme.slateLight.radius.sm == 4)
        #expect(DFTheme.slateDark.radius.sm  == 4)
    }

    @Test("slate radius md is 8")
    func slateRadiusMd() {
        #expect(DFTheme.slateLight.radius.md == 8)
        #expect(DFTheme.slateDark.radius.md  == 8)
    }

    @Test("slate radius lg is 12")
    func slateRadiusLg() {
        #expect(DFTheme.slateLight.radius.lg == 12)
        #expect(DFTheme.slateDark.radius.lg  == 12)
    }

    // MARK: Shadow tokens

    @Test("slate sm shadow radius is 4")
    func slateShadowSmRadius() {
        #expect(DFTheme.slateLight.shadows.sm.radius == 4)
    }

    @Test("slate md shadow radius is 8")
    func slateShadowMdRadius() {
        #expect(DFTheme.slateLight.shadows.md.radius == 8)
    }

    @Test("slate lg shadow y-offset is 8")
    func slateShadowLgY() {
        #expect(DFTheme.slateLight.shadows.lg.y == 8)
    }
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
swift test --filter DFThemeSlateTests 2>&1 | tail -20
```

Expected: compile error — `DFTheme.slateLight` not found.

- [ ] **Step 3: Create `DFTheme+Slate.swift`**

Create `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Slate.swift`:

```swift
import SwiftUI

public extension DFTheme {
    // Slate uses default radius and shadows — DFTheme() defaults apply.
    static let slateLight = DFTheme(colors: .slateLight)
    static let slateDark  = DFTheme(colors: .slateDark)
}

private extension DFColorTokens {

    static var slateLight: DFColorTokens {
        let fill = Color(red: 0.161, green: 0.475, blue: 1.0)
        return DFColorTokens(
            primary:             Color(red: 0.110, green: 0.239, blue: 0.353),
            secondary:           Color(red: 0.329, green: 0.431, blue: 0.478),
            accent:              Color(red: 0.161, green: 0.475, blue: 1.0),
            background:          Color(white: 0.980),
            surface:             Color(red: 0.949, green: 0.949, blue: 0.969),
            surfaceElevated:     .white,
            textPrimary:         Color(red: 0.051, green: 0.106, blue: 0.165),
            textSecondary:       Color(red: 0.329, green: 0.431, blue: 0.478),
            textDisabled:        Color(red: 0.620, green: 0.667, blue: 0.710),
            border:              Color(red: 0.820, green: 0.851, blue: 0.878),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.886, green: 0.910, blue: 0.929),
            destructive:         Color(red: 0.898, green: 0.224, blue: 0.208),
            success:             Color(red: 0.180, green: 0.490, blue: 0.196),
            warning:             Color(red: 0.961, green: 0.486, blue: 0.0),
            info:                Color(red: 0.008, green: 0.467, blue: 0.741),
            respectsColorScheme: false
        )
    }

    static var slateDark: DFColorTokens {
        let fill = Color(red: 0.392, green: 0.710, blue: 0.965)
        return DFColorTokens(
            primary:             Color(red: 0.392, green: 0.710, blue: 0.965),
            secondary:           Color(red: 0.471, green: 0.565, blue: 0.612),
            accent:              Color(red: 0.510, green: 0.769, blue: 1.0),
            background:          Color(red: 0.059, green: 0.098, blue: 0.137),
            surface:             Color(red: 0.110, green: 0.169, blue: 0.227),
            surfaceElevated:     Color(red: 0.141, green: 0.204, blue: 0.278),
            textPrimary:         Color(red: 0.910, green: 0.941, blue: 0.973),
            textSecondary:       Color(red: 0.565, green: 0.643, blue: 0.682),
            textDisabled:        Color(red: 0.290, green: 0.376, blue: 0.439),
            border:              Color(red: 0.180, green: 0.251, blue: 0.341),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.122, green: 0.200, blue: 0.282),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.655, blue: 0.149),
            info:                Color(red: 0.161, green: 0.714, blue: 0.965),
            respectsColorScheme: false
        )
    }
}
```

- [ ] **Step 4: Run Slate tests**

```bash
swift test --filter DFThemeSlateTests 2>&1 | tail -20
```

Expected: `Test run with 10 tests passed in …`

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Slate.swift \
        Tests/DesignFoundationTests/Core/Presets/DFThemeSlateTests.swift
git commit -m "feat: add Slate preset theme (light + dark)"
```

---

## Task 3: Aurora preset

**Files:**
- Create: `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Aurora.swift`
- Create: `Tests/DesignFoundationTests/Core/Presets/DFThemeAuroraTests.swift`

**Interfaces:**
- Consumes: same token types as Task 2
- Produces: `public extension DFTheme { static let auroraLight: DFTheme; static let auroraDark: DFTheme }`

**Aurora personality:** Vibrant, creative. Rounded radius (sm=4, md=10, lg=16). Soft shadows (sm opacity 0.06 radius 6 y 2, md 0.08/12/4, lg 0.12/20/6).

- [ ] **Step 1: Write the failing test**

Create `Tests/DesignFoundationTests/Core/Presets/DFThemeAuroraTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Aurora")
struct DFThemeAuroraTests {

    @Test("auroraLight and auroraDark are distinct themes")
    func auroraVariantsAreDistinct() {
        #expect(DFTheme.auroraLight.colors.primary != DFTheme.auroraDark.colors.primary)
    }

    @Test("auroraLight respectsColorScheme is false")
    func auroraLightNoAdaptation() {
        #expect(DFTheme.auroraLight.colors.respectsColorScheme == false)
    }

    @Test("auroraDark respectsColorScheme is false")
    func auroraDarkNoAdaptation() {
        #expect(DFTheme.auroraDark.colors.respectsColorScheme == false)
    }

    @Test("auroraLight primary is electric violet")
    func auroraLightPrimary() {
        #expect(DFTheme.auroraLight.colors.primary == Color(red: 0.424, green: 0.278, blue: 1.0))
    }

    @Test("auroraDark primary is soft violet")
    func auroraDarkPrimary() {
        #expect(DFTheme.auroraDark.colors.primary == Color(red: 0.655, green: 0.545, blue: 0.980))
    }

    // MARK: Radius — more rounded than default

    @Test("aurora radius sm is 4")
    func auroraRadiusSm() {
        #expect(DFTheme.auroraLight.radius.sm == 4)
    }

    @Test("aurora radius md is 10")
    func auroraRadiusMd() {
        #expect(DFTheme.auroraLight.radius.md == 10)
        #expect(DFTheme.auroraDark.radius.md  == 10)
    }

    @Test("aurora radius lg is 16")
    func auroraRadiusLg() {
        #expect(DFTheme.auroraLight.radius.lg == 16)
        #expect(DFTheme.auroraDark.radius.lg  == 16)
    }

    // MARK: Shadows — soft

    @Test("aurora sm shadow radius is 6")
    func auroraShadowSmRadius() {
        #expect(DFTheme.auroraLight.shadows.sm.radius == 6)
    }

    @Test("aurora md shadow radius is 12")
    func auroraShadowMdRadius() {
        #expect(DFTheme.auroraLight.shadows.md.radius == 12)
    }

    @Test("aurora lg shadow y-offset is 6")
    func auroraShadowLgY() {
        #expect(DFTheme.auroraLight.shadows.lg.y == 6)
    }
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
swift test --filter DFThemeAuroraTests 2>&1 | tail -20
```

Expected: compile error — `DFTheme.auroraLight` not found.

- [ ] **Step 3: Create `DFTheme+Aurora.swift`**

Create `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Aurora.swift`:

```swift
import SwiftUI

public extension DFTheme {
    static let auroraLight = DFTheme(colors: .auroraLight, radius: .auroraRadius, shadows: .auroraShadows)
    static let auroraDark  = DFTheme(colors: .auroraDark,  radius: .auroraRadius, shadows: .auroraShadows)
}

private extension DFColorTokens {

    static var auroraLight: DFColorTokens {
        let fill = Color(red: 0.424, green: 0.278, blue: 1.0)
        return DFColorTokens(
            primary:             Color(red: 0.424, green: 0.278, blue: 1.0),
            secondary:           Color(red: 0.608, green: 0.447, blue: 0.812),
            accent:              Color(red: 0.655, green: 0.545, blue: 0.980),
            background:          Color(white: 0.980),
            surface:             Color(red: 0.953, green: 0.941, blue: 1.0),
            surfaceElevated:     .white,
            textPrimary:         Color(red: 0.102, green: 0.039, blue: 0.310),
            textSecondary:       Color(red: 0.420, green: 0.373, blue: 0.627),
            textDisabled:        Color(red: 0.702, green: 0.663, blue: 0.851),
            border:              Color(red: 0.851, green: 0.820, blue: 0.961),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.910, green: 0.890, blue: 1.0),
            destructive:         Color(red: 0.898, green: 0.224, blue: 0.208),
            success:             Color(red: 0.180, green: 0.490, blue: 0.196),
            warning:             Color(red: 0.961, green: 0.486, blue: 0.0),
            info:                Color(red: 0.424, green: 0.278, blue: 1.0),
            respectsColorScheme: false
        )
    }

    static var auroraDark: DFColorTokens {
        let fill = Color(red: 0.655, green: 0.545, blue: 0.980)
        return DFColorTokens(
            primary:             Color(red: 0.655, green: 0.545, blue: 0.980),
            secondary:           Color(red: 0.486, green: 0.420, blue: 0.678),
            accent:              Color(red: 0.769, green: 0.710, blue: 0.992),
            background:          Color(red: 0.051, green: 0.039, blue: 0.118),
            surface:             Color(red: 0.102, green: 0.082, blue: 0.208),
            surfaceElevated:     Color(red: 0.141, green: 0.114, blue: 0.278),
            textPrimary:         Color(red: 0.929, green: 0.914, blue: 1.0),
            textSecondary:       Color(red: 0.616, green: 0.561, blue: 0.831),
            textDisabled:        Color(red: 0.290, green: 0.247, blue: 0.478),
            border:              Color(red: 0.180, green: 0.145, blue: 0.341),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.122, green: 0.098, blue: 0.251),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.655, blue: 0.149),
            info:                Color(red: 0.655, green: 0.545, blue: 0.980),
            respectsColorScheme: false
        )
    }
}

private extension DFRadiusTokens {
    static let auroraRadius = DFRadiusTokens(none: 0, sm: 4, md: 10, lg: 16, full: 9999)
}

private extension DFShadowTokens {
    static let auroraShadows = DFShadowTokens(
        none: .none,
        sm:   DFShadow(color: .black.opacity(0.06), radius: 6,  x: 0, y: 2),
        md:   DFShadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4),
        lg:   DFShadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 6)
    )
}
```

- [ ] **Step 4: Run Aurora tests**

```bash
swift test --filter DFThemeAuroraTests 2>&1 | tail -20
```

Expected: `Test run with 11 tests passed in …`

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Aurora.swift \
        Tests/DesignFoundationTests/Core/Presets/DFThemeAuroraTests.swift
git commit -m "feat: add Aurora preset theme (light + dark)"
```

---

## Task 4: Copper preset

**Files:**
- Create: `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Copper.swift`
- Create: `Tests/DesignFoundationTests/Core/Presets/DFThemeCopperTests.swift`

**Interfaces:**
- Consumes: same token types as Task 2
- Produces: `public extension DFTheme { static let copperLight: DFTheme; static let copperDark: DFTheme }`

**Copper personality:** Warm, editorial, premium. Sharp radius (sm=3, md=6, lg=10). Defined shadows (sm opacity 0.12 radius 3 y 3, md 0.16/6/5, lg 0.22/12/10).

- [ ] **Step 1: Write the failing test**

Create `Tests/DesignFoundationTests/Core/Presets/DFThemeCopperTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Copper")
struct DFThemeCopperTests {

    @Test("copperLight and copperDark are distinct themes")
    func copperVariantsAreDistinct() {
        #expect(DFTheme.copperLight.colors.primary != DFTheme.copperDark.colors.primary)
    }

    @Test("copperLight respectsColorScheme is false")
    func copperLightNoAdaptation() {
        #expect(DFTheme.copperLight.colors.respectsColorScheme == false)
    }

    @Test("copperDark respectsColorScheme is false")
    func copperDarkNoAdaptation() {
        #expect(DFTheme.copperDark.colors.respectsColorScheme == false)
    }

    @Test("copperLight primary is copper")
    func copperLightPrimary() {
        #expect(DFTheme.copperLight.colors.primary == Color(red: 0.769, green: 0.384, blue: 0.176))
    }

    @Test("copperDark primary is warm amber")
    func copperDarkPrimary() {
        #expect(DFTheme.copperDark.colors.primary == Color(red: 0.957, green: 0.635, blue: 0.380))
    }

    // MARK: Radius — sharper than default

    @Test("copper radius sm is 3")
    func copperRadiusSm() {
        #expect(DFTheme.copperLight.radius.sm == 3)
        #expect(DFTheme.copperDark.radius.sm  == 3)
    }

    @Test("copper radius md is 6")
    func copperRadiusMd() {
        #expect(DFTheme.copperLight.radius.md == 6)
        #expect(DFTheme.copperDark.radius.md  == 6)
    }

    @Test("copper radius lg is 10")
    func copperRadiusLg() {
        #expect(DFTheme.copperLight.radius.lg == 10)
        #expect(DFTheme.copperDark.radius.lg  == 10)
    }

    // MARK: Shadows — more defined

    @Test("copper sm shadow radius is 3")
    func copperShadowSmRadius() {
        #expect(DFTheme.copperLight.shadows.sm.radius == 3)
    }

    @Test("copper md shadow y-offset is 5")
    func copperShadowMdY() {
        #expect(DFTheme.copperLight.shadows.md.y == 5)
    }

    @Test("copper lg shadow y-offset is 10")
    func copperShadowLgY() {
        #expect(DFTheme.copperLight.shadows.lg.y == 10)
    }
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
swift test --filter DFThemeCopperTests 2>&1 | tail -20
```

Expected: compile error — `DFTheme.copperLight` not found.

- [ ] **Step 3: Create `DFTheme+Copper.swift`**

Create `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Copper.swift`:

```swift
import SwiftUI

public extension DFTheme {
    static let copperLight = DFTheme(colors: .copperLight, radius: .copperRadius, shadows: .copperShadows)
    static let copperDark  = DFTheme(colors: .copperDark,  radius: .copperRadius, shadows: .copperShadows)
}

private extension DFColorTokens {

    static var copperLight: DFColorTokens {
        let fill = Color(red: 0.769, green: 0.384, blue: 0.176)
        return DFColorTokens(
            primary:             Color(red: 0.769, green: 0.384, blue: 0.176),
            secondary:           Color(red: 0.553, green: 0.431, blue: 0.388),
            accent:              Color(red: 0.910, green: 0.537, blue: 0.294),
            background:          Color(red: 0.984, green: 0.973, blue: 0.961),
            surface:             Color(red: 0.961, green: 0.929, blue: 0.890),
            surfaceElevated:     Color(red: 1.0,   green: 0.980, blue: 0.965),
            textPrimary:         Color(red: 0.173, green: 0.094, blue: 0.063),
            textSecondary:       Color(red: 0.553, green: 0.431, blue: 0.388),
            textDisabled:        Color(red: 0.737, green: 0.659, blue: 0.612),
            border:              Color(red: 0.890, green: 0.816, blue: 0.765),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.941, green: 0.878, blue: 0.816),
            destructive:         Color(red: 0.776, green: 0.157, blue: 0.157),
            success:             Color(red: 0.180, green: 0.490, blue: 0.196),
            warning:             Color(red: 0.902, green: 0.318, blue: 0.0),
            info:                Color(red: 0.082, green: 0.396, blue: 0.753),
            respectsColorScheme: false
        )
    }

    static var copperDark: DFColorTokens {
        let fill = Color(red: 0.957, green: 0.635, blue: 0.380)
        return DFColorTokens(
            primary:             Color(red: 0.957, green: 0.635, blue: 0.380),
            secondary:           Color(red: 0.631, green: 0.533, blue: 0.498),
            accent:              Color(red: 1.0,   green: 0.718, blue: 0.302),
            background:          Color(red: 0.102, green: 0.063, blue: 0.031),
            surface:             Color(red: 0.173, green: 0.122, blue: 0.071),
            surfaceElevated:     Color(red: 0.239, green: 0.173, blue: 0.110),
            textPrimary:         Color(red: 1.0,   green: 0.953, blue: 0.910),
            textSecondary:       Color(red: 0.749, green: 0.627, blue: 0.565),
            textDisabled:        Color(red: 0.361, green: 0.251, blue: 0.188),
            border:              Color(red: 0.290, green: 0.188, blue: 0.125),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.180, green: 0.110, blue: 0.063),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.655, blue: 0.149),
            info:                Color(red: 0.392, green: 0.710, blue: 0.965),
            respectsColorScheme: false
        )
    }
}

private extension DFRadiusTokens {
    static let copperRadius = DFRadiusTokens(none: 0, sm: 3, md: 6, lg: 10, full: 9999)
}

private extension DFShadowTokens {
    static let copperShadows = DFShadowTokens(
        none: .none,
        sm:   DFShadow(color: .black.opacity(0.12), radius: 3,  x: 0, y: 3),
        md:   DFShadow(color: .black.opacity(0.16), radius: 6,  x: 0, y: 5),
        lg:   DFShadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 10)
    )
}
```

- [ ] **Step 4: Run Copper tests**

```bash
swift test --filter DFThemeCopperTests 2>&1 | tail -20
```

Expected: `Test run with 11 tests passed in …`

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Copper.swift \
        Tests/DesignFoundationTests/Core/Presets/DFThemeCopperTests.swift
git commit -m "feat: add Copper preset theme (light + dark)"
```

---

## Task 5: Sage preset

**Files:**
- Create: `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Sage.swift`
- Create: `Tests/DesignFoundationTests/Core/Presets/DFThemeSageTests.swift`

**Interfaces:**
- Consumes: same token types as Task 2
- Produces: `public extension DFTheme { static let sageLight: DFTheme; static let sageDark: DFTheme }`

**Sage personality:** Calm, natural, organic. Most rounded radius (sm=6, md=12, lg=18). Very soft shadows (sm opacity 0.04 radius 8 y 1, md 0.06/16/3, lg 0.10/24/5).

- [ ] **Step 1: Write the failing test**

Create `Tests/DesignFoundationTests/Core/Presets/DFThemeSageTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTheme+Sage")
struct DFThemeSageTests {

    @Test("sageLight and sageDark are distinct themes")
    func sageVariantsAreDistinct() {
        #expect(DFTheme.sageLight.colors.primary != DFTheme.sageDark.colors.primary)
    }

    @Test("sageLight respectsColorScheme is false")
    func sageLightNoAdaptation() {
        #expect(DFTheme.sageLight.colors.respectsColorScheme == false)
    }

    @Test("sageDark respectsColorScheme is false")
    func sageDarkNoAdaptation() {
        #expect(DFTheme.sageDark.colors.respectsColorScheme == false)
    }

    @Test("sageLight primary is deep sage green")
    func sageLightPrimary() {
        #expect(DFTheme.sageLight.colors.primary == Color(red: 0.176, green: 0.416, blue: 0.310))
    }

    @Test("sageDark primary is mint green")
    func sageDarkPrimary() {
        #expect(DFTheme.sageDark.colors.primary == Color(red: 0.455, green: 0.776, blue: 0.616))
    }

    // MARK: Radius — most rounded

    @Test("sage radius sm is 6")
    func sageRadiusSm() {
        #expect(DFTheme.sageLight.radius.sm == 6)
        #expect(DFTheme.sageDark.radius.sm  == 6)
    }

    @Test("sage radius md is 12")
    func sageRadiusMd() {
        #expect(DFTheme.sageLight.radius.md == 12)
        #expect(DFTheme.sageDark.radius.md  == 12)
    }

    @Test("sage radius lg is 18")
    func sageRadiusLg() {
        #expect(DFTheme.sageLight.radius.lg == 18)
        #expect(DFTheme.sageDark.radius.lg  == 18)
    }

    // MARK: Shadows — very soft

    @Test("sage sm shadow radius is 8")
    func sageShadowSmRadius() {
        #expect(DFTheme.sageLight.shadows.sm.radius == 8)
    }

    @Test("sage md shadow radius is 16")
    func sageShadowMdRadius() {
        #expect(DFTheme.sageLight.shadows.md.radius == 16)
    }

    @Test("sage lg shadow y-offset is 5")
    func sageShadowLgY() {
        #expect(DFTheme.sageLight.shadows.lg.y == 5)
    }
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
swift test --filter DFThemeSageTests 2>&1 | tail -20
```

Expected: compile error — `DFTheme.sageLight` not found.

- [ ] **Step 3: Create `DFTheme+Sage.swift`**

Create `Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Sage.swift`:

```swift
import SwiftUI

public extension DFTheme {
    static let sageLight = DFTheme(colors: .sageLight, radius: .sageRadius, shadows: .sageShadows)
    static let sageDark  = DFTheme(colors: .sageDark,  radius: .sageRadius, shadows: .sageShadows)
}

private extension DFColorTokens {

    static var sageLight: DFColorTokens {
        let fill = Color(red: 0.176, green: 0.416, blue: 0.310)
        return DFColorTokens(
            primary:             Color(red: 0.176, green: 0.416, blue: 0.310),
            secondary:           Color(red: 0.322, green: 0.475, blue: 0.435),
            accent:              Color(red: 0.322, green: 0.718, blue: 0.533),
            background:          Color(red: 0.969, green: 0.980, blue: 0.969),
            surface:             Color(red: 0.929, green: 0.957, blue: 0.933),
            surfaceElevated:     .white,
            textPrimary:         Color(red: 0.039, green: 0.137, blue: 0.094),
            textSecondary:       Color(red: 0.322, green: 0.475, blue: 0.435),
            textDisabled:        Color(red: 0.624, green: 0.722, blue: 0.686),
            border:              Color(red: 0.784, green: 0.875, blue: 0.800),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.847, green: 0.929, blue: 0.878),
            destructive:         Color(red: 0.776, green: 0.157, blue: 0.157),
            success:             Color(red: 0.106, green: 0.369, blue: 0.125),
            warning:             Color(red: 0.961, green: 0.486, blue: 0.0),
            info:                Color(red: 0.004, green: 0.341, blue: 0.608),
            respectsColorScheme: false
        )
    }

    static var sageDark: DFColorTokens {
        let fill = Color(red: 0.455, green: 0.776, blue: 0.616)
        return DFColorTokens(
            primary:             Color(red: 0.455, green: 0.776, blue: 0.616),
            secondary:           Color(red: 0.420, green: 0.620, blue: 0.561),
            accent:              Color(red: 0.584, green: 0.835, blue: 0.698),
            background:          Color(red: 0.039, green: 0.102, blue: 0.059),
            surface:             Color(red: 0.086, green: 0.169, blue: 0.110),
            surfaceElevated:     Color(red: 0.122, green: 0.239, blue: 0.153),
            textPrimary:         Color(red: 0.910, green: 0.961, blue: 0.925),
            textSecondary:       Color(red: 0.502, green: 0.690, blue: 0.565),
            textDisabled:        Color(red: 0.227, green: 0.361, blue: 0.259),
            border:              Color(red: 0.122, green: 0.290, blue: 0.173),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.082, green: 0.165, blue: 0.102),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.655, blue: 0.149),
            info:                Color(red: 0.392, green: 0.710, blue: 0.965),
            respectsColorScheme: false
        )
    }
}

private extension DFRadiusTokens {
    static let sageRadius = DFRadiusTokens(none: 0, sm: 6, md: 12, lg: 18, full: 9999)
}

private extension DFShadowTokens {
    static let sageShadows = DFShadowTokens(
        none: .none,
        sm:   DFShadow(color: .black.opacity(0.04), radius: 8,  x: 0, y: 1),
        md:   DFShadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 3),
        lg:   DFShadow(color: .black.opacity(0.10), radius: 24, x: 0, y: 5)
    )
}
```

- [ ] **Step 4: Run Sage tests, then full suite**

```bash
swift test --filter DFThemeSageTests 2>&1 | tail -20
```

Expected: `Test run with 11 tests passed in …`

Now run the full suite including Task 1's preset tests:

```bash
swift test 2>&1 | tail -30
```

Expected: all tests pass — including `DFThemePresetTests` which can now resolve all four `DFTheme` statics.

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Core/Theme/Presets/DFTheme+Sage.swift \
        Tests/DesignFoundationTests/Core/Presets/DFThemeSageTests.swift
git commit -m "feat: add Sage preset theme (light + dark)"
```
