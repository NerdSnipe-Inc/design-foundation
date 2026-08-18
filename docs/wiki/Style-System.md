# Style System

Every DesignFoundation component uses the same four-part pattern to separate visual rendering from component logic: a **protocol**, a **configuration struct**, a **view modifier**, and **built-in implementations** exposed via static accessors. This page documents that pattern in full and shows you how to write your own styles.

Token reference: [[Theming]]
Component usage reference: [[Components]]

---

## Overview

SwiftUI's own `ButtonStyle` and `LabelStyle` protocols inspired this design. The core idea is that a component owns its logic — state management, interaction handling, accessibility — while a style protocol owns its appearance. Swapping styles requires one line at the call site or in a parent view.

```swift
// same DFButton, two completely different visual treatments
DFButton("Save") { save() }
    .dfButtonStyle(.filled)   // opaque filled pill — the default

DFButton("Save") { save() }
    .dfButtonStyle(.ghost)    // label-only, no background
```

Every component in DesignFoundation follows this exact pattern. If you understand it for one component you understand it for all of them.

---

## The Pattern Anatomy

### 1. The Protocol

Each component declares a protocol with a single `makeBody(configuration:)` requirement:

```swift
public protocol DFButtonStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFButtonStyleConfiguration) -> Body
}
```

The `associatedtype Body: View` lets implementations return concrete types — no `AnyView` wrapping required in your implementation. `@ViewBuilder` lets you write multi-statement view bodies without explicit `Group {}`.

### 2. The Configuration Struct

The configuration struct carries everything `makeBody` might need: the component's rendered content, its interaction states, and the full active theme. The theme travels directly in the struct — you never need `@Environment(\.dfTheme)` inside a style.

```swift
public struct DFButtonStyleConfiguration {
    public let label:       AnyView        // the button's rendered label
    public let isPressed:   Bool
    public let isDisabled:  Bool
    public let role:        DFButtonRole?  // .destructive, .cancel, or nil
    public let theme:       DFTheme        // full active theme, no @Environment needed
}
```

Configuration structs that hold `AnyView` or closures are deliberately **not** `Sendable` — they are main-thread values. Configurations that hold only value types (enums, `Bool`, `DFTheme`) are marked `Sendable` and can cross actor boundaries safely.

### 3. Type Erasure

Protocols with associated types cannot be stored directly in `EnvironmentValues`. DesignFoundation erases each concrete style into an `AnyDF*Style` wrapper before storing it:

```swift
public struct AnyDFButtonStyle: DFButtonStyle, @unchecked Sendable {
    private let _makeBody: (DFButtonStyleConfiguration) -> AnyView

    public init<S: DFButtonStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}
```

`@unchecked Sendable` is safe here because `_makeBody` is set once at `init` and never mutated. The closure captures the concrete style value, which is `Sendable`. You never interact with `AnyDF*Style` directly — the `.dfButtonStyle(_:)` modifier handles wrapping.

### 4. The View Modifier

Each component exposes a modifier on `View` that writes the style into the environment:

```swift
public extension View {
    func dfButtonStyle<S: DFButtonStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfButtonStyle, AnyDFButtonStyle(style))
    }
}
```

The `& Sendable` constraint is mandatory. All concrete style types you write must conform to `Sendable`. See the [[#Sendable Requirement]] section.

### 5. Static Accessors

Built-in styles are accessed through static members constrained to the concrete type, mirroring Swift's own `ShapeStyle` and `ButtonStyle` conventions:

```swift
extension DFButtonStyle where Self == DFFilledButtonStyle {
    static var filled: DFFilledButtonStyle { DFFilledButtonStyle() }
}

extension DFButtonStyle where Self == DFOutlinedButtonStyle {
    static var outlined: DFOutlinedButtonStyle { DFOutlinedButtonStyle() }
}
```

This constraint enables the dot-shorthand syntax: `.dfButtonStyle(.filled)`. The compiler resolves `.filled` to `DFFilledButtonStyle` based on the expected `S` type at the call site.

---

## Style Cascade

Styles cascade through the SwiftUI view hierarchy via the environment. A style set on a parent applies to all descendant components of that type. A style set on a descendant overrides the parent for that subtree only.

**Before — inconsistent styles across two sections:**

```swift
VStack {
    // Section A — needs outlined buttons
    HStack {
        DFButton("Cancel") { }
            .dfButtonStyle(.outlined)
        DFButton("Back") { }
            .dfButtonStyle(.outlined)
    }

    // Section B — needs ghost buttons
    HStack {
        DFButton("Skip") { }
            .dfButtonStyle(.ghost)
        DFButton("Later") { }
            .dfButtonStyle(.ghost)
    }
}
```

**After — set style on the container, override at one leaf:**

```swift
VStack {
    // Section A inherits .outlined from the HStack modifier
    HStack {
        DFButton("Cancel") { }
        DFButton("Back") { }
    }
    .dfButtonStyle(.outlined)

    // Section B sets .ghost on its container
    HStack {
        DFButton("Skip") { }
        DFButton("Later") { }
            .dfButtonStyle(.filled)  // leaf override — this one button is filled
    }
    .dfButtonStyle(.ghost)
}
```

The rule: the innermost `.dfButtonStyle(_:)` call wins. Leaf overrides beat parent overrides.

---

## Style Protocols by Component

`*` = requires iOS 26 / macOS 26 or later.

| Component | Style Protocol | Configuration Type | Built-in Styles |
|---|---|---|---|
| `DFButton` | `DFButtonStyle` | `DFButtonStyleConfiguration` | `filled` (default), `outlined`, `ghost`, `tinted`, `glass`* |
| `DFCard` | `DFCardStyle` | `DFCardStyleConfiguration` | `elevated` (default), `outlined`, `filled`, `glass`* |
| `DFTextField` | `DFTextFieldStyle` | `DFTextFieldStyleConfiguration` | `outlined` (default), `filled`, `glass`* |
| `DFSecureField` | `DFSecureFieldStyle` | `DFSecureFieldStyleConfiguration` | `outlined` (default), `filled`, `glass`* |
| `DFToggle` | `DFToggleStyle` | `DFToggleStyleConfiguration` | `switch` (default), `checkbox`, `glass`* |
| `DFSlider` | `DFSliderStyle` | `DFSliderStyleConfiguration` | `standard` (default), `labeled`, `glass`* |
| `DFPicker` | `DFPickerStyle` | `DFPickerStyleConfiguration` | `menu` (default), `segmented`, `wheel`, `glass`* |
| `DFDatePicker` | `DFDatePickerStyle` | `DFDatePickerStyleConfiguration` | `compact` (default), `graphical`, `wheel`, `glass`* |
| `DFAvatar` | `DFAvatarStyle` | `DFAvatarStyleConfiguration` | `circle` (default), `rounded`, `ring`, `glass`* |
| `DFBadge` | `DFBadgeStyle` | `DFBadgeStyleConfiguration` | `filled` (default), `tinted`, `outlined`, `glass`* |
| `DFIcon` | `DFIconStyle` | `DFIconStyleConfiguration` | `standard` (default), `tinted`, `secondary` |
| `DFText` | `DFTextViewStyle` | `DFTextViewStyleConfiguration` | `standard` (default), `secondary`, `muted` |
| `DFDivider` | `DFDividerStyle` | `DFDividerStyleConfiguration` | `standard` (default), `thick`, `subtle` |
| `DFCheckbox` | `DFCheckboxStyle` | `DFCheckboxStyleConfiguration` | `default` |
| `DFProgressBar` | `DFProgressBarStyle` | `DFProgressBarStyleConfiguration` | `default` (handles `.linear`, `.circular`, `.indeterminate` via `variant`) |
| `DFSkeleton` | `DFSkeletonStyle` | `DFSkeletonStyleConfiguration` | `default` |
| `DFSidebar` | `DFSidebarStyle` | `DFSidebarItemStyleConfiguration` | `standard` (default), `plain`, `glass`* |
| `DFTabBar` | `DFTabBarStyle` | `DFTabBarStyleConfiguration` | `standard` (default), `minimal`, `glass`* |
| `DFNavigationBar` | `DFNavigationBarStyle` | `DFNavigationBarStyleConfiguration` | `standard` (default), `transparent`, `glass`* |
| `DFModal` | `DFModalStyle` | `DFModalStyleConfiguration` | `standard` (default), `glass`* |
| `DFSheet` | `DFSheetStyle` | `DFSheetStyleConfiguration` | `standard` (default), `compact`, `glass`* |
| `DFPopover` | `DFPopoverStyle` | `DFPopoverStyleConfiguration` | `arrow` (default), `compact`, `glass`* |

> **Note on `DFSidebar`:** `DFSidebarStyle` controls how individual item rows are rendered, not the sidebar's overall chrome. Its protocol is slightly different — it declares `makeItemBody(configuration:)` (not `makeBody`) and provides an optional `sidebarBackground(theme:) -> AnyView` method with a default implementation. See [[#Writing Custom Styles]] for details.

> **Note on `DFTabBar`:** `DFTabBarStyle` is `@MainActor`-isolated. Custom tab bar styles and their containing structs must be `@MainActor` or `nonisolated init` as appropriate.

> **Note on `DFButton`:** its style bridge doubles as a real SwiftUI `ButtonStyle` (`DFBrandedButtonStyle`, public) that you can apply to a native `Button` directly via `.buttonStyle(.df(_:role:))` — see [[#Branding a Native Button Directly]].

---

## Branding a Native Button Directly

`DFButton` only accepts a `String` title — for an icon, spinner, or any other custom content, brand a native SwiftUI `Button` directly instead. `DFButton`'s internal style bridge is public as `DFBrandedButtonStyle`, and it reads the button's actual rendered content (`configuration.label`) rather than re-synthesizing a `Text` from a string, so a `Button` styled this way keeps everything SwiftUI gives it for free:

```swift
Button {
    save()
} label: {
    Label("Save", systemImage: "checkmark")
}
.buttonStyle(.df(.outlined, role: .destructive))   // any DFButtonStyle: .filled .outlined .ghost .tinted .glass
```

`DFButton("Save") { }` is unaffected — it's implemented on top of the same `DFBrandedButtonStyle`, so both paths render identically for the plain-text case. Use `DFButton` when a string title is all you need; brand a native `Button` when you need icons or custom layouts.

---

## Writing Custom Styles

The workflow is always the same: conform to the protocol, implement `makeBody`, add `Sendable` conformance, and optionally add a static accessor.

### Custom `DFCardStyle` — Neon Dashed Card

```swift
import SwiftUI
import DesignFoundation

struct NeonDashedCardStyle: DFCardStyle, Sendable {
    let glowColor: Color

    func makeBody(configuration: DFCardStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.radius.lg

        configuration.content
            .padding(theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(theme.colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(
                        glowColor.opacity(configuration.isPressed ? 1.0 : 0.6),
                        style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                    )
            )
            .shadow(
                color: glowColor.opacity(configuration.isPressed ? 0.5 : 0.2),
                radius: configuration.isPressed ? 12 : 6
            )
            .scaleEffect(configuration.isInteractive && configuration.isPressed ? 0.97 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.4 : 1.0)
    }
}

// Optional static accessor — enables dot-shorthand
extension DFCardStyle where Self == NeonDashedCardStyle {
    static func neonDashed(color: Color) -> NeonDashedCardStyle {
        NeonDashedCardStyle(glowColor: color)
    }
}

// Usage
DFCard { Text("Content") }
    .dfCardStyle(.neonDashed(color: .cyan))
```

### Custom `DFButtonStyle` — Glowing Neon Button

```swift
struct GlowingNeonButtonStyle: DFButtonStyle, Sendable {
    let neonColor: Color

    func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.button.cornerRadius ?? theme.radius.md
        let hPad  = theme.components.button.horizontalPadding ?? theme.spacing.lg
        let vPad  = theme.components.button.verticalPadding ?? theme.spacing.md

        configuration.label
            .font((theme.components.button.labelStyle ?? theme.typography.label).font)
            .foregroundStyle(configuration.isDisabled ? theme.colors.textDisabled : neonColor)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(neonColor.opacity(configuration.isPressed ? 0.2 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(neonColor.opacity(configuration.isDisabled ? 0.2 : 0.9), lineWidth: 1.5)
                    )
            )
            .shadow(
                color: neonColor.opacity(configuration.isPressed ? 0.7 : 0.3),
                radius: configuration.isPressed ? 14 : 6
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

extension DFButtonStyle where Self == GlowingNeonButtonStyle {
    static func glowingNeon(color: Color) -> GlowingNeonButtonStyle {
        GlowingNeonButtonStyle(neonColor: color)
    }
}

// Usage
DFButton("Launch") { launch() }
    .dfButtonStyle(.glowingNeon(color: .green))
```

### Custom `DFTextFieldStyle` — Underline Only

```swift
struct UnderlineTextFieldStyle: DFTextFieldStyle, Sendable {

    func makeBody(configuration: DFTextFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        let lineColor: Color = {
            if configuration.isDisabled { return theme.colors.border }
            switch configuration.validationState {
            case .error: return theme.colors.destructive
            case .valid: return theme.colors.success
            case .none:  return configuration.isFocused ? theme.colors.primary : theme.colors.border
            }
        }()

        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if !configuration.label.isEmpty {
                Text(configuration.label)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            HStack(spacing: theme.spacing.sm) {
                if let leading = configuration.leadingContent {
                    leading.foregroundStyle(theme.colors.textSecondary)
                }
                configuration.fieldContent
                    .font(theme.typography.body.font)
                    .foregroundStyle(
                        configuration.isDisabled
                            ? theme.colors.textDisabled
                            : theme.colors.textPrimary
                    )
                if let trailing = configuration.trailingContent {
                    trailing.foregroundStyle(theme.colors.textSecondary)
                }
            }
            .padding(.vertical, theme.spacing.xs)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(lineColor)
                    .frame(height: configuration.isFocused ? 2 : 1)
            }
            if case .error(let message) = configuration.validationState {
                Text(message)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.destructive)
            }
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
        .animation(theme.animation.fast, value: configuration.isFocused)
    }
}

extension DFTextFieldStyle where Self == UnderlineTextFieldStyle {
    static var underline: UnderlineTextFieldStyle { UnderlineTextFieldStyle() }
}

// Usage
DFTextField("Username", text: $username)
    .dfTextFieldStyle(.underline)
```

### Custom `DFToastStyle` — Full-Width Banner

`DFToastStyleConfiguration` is fully `Sendable` — it holds `DFToastMessage` and `DFTheme`, both value types. No `AnyView` involved.

```swift
struct BannerToastStyle: DFToastStyle, Sendable {

    func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        let theme = configuration.theme
        let message = configuration.message

        HStack(spacing: theme.spacing.sm) {
            if let icon = message.icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(severityColor(message.severity, theme: theme))
            }
            Text(message.text)
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.md)
        .background(
            Rectangle()
                .fill(theme.colors.surface)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(severityColor(message.severity, theme: theme))
                        .frame(height: 3)
                }
        )
        .shadow(
            color: theme.shadows.sm.color,
            radius: theme.shadows.sm.radius,
            x: theme.shadows.sm.x,
            y: theme.shadows.sm.y
        )
    }

    private func severityColor(_ severity: DFToastSeverity, theme: DFTheme) -> Color {
        switch severity {
        case .info:    return theme.colors.info
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .error:   return theme.colors.destructive
        }
    }
}

extension DFToastStyle where Self == BannerToastStyle {
    static var banner: BannerToastStyle { BannerToastStyle() }
}

// Usage — apply to the root view alongside .dfToast(queue:)
ContentView()
    .dfToast(queue: DFToastQueue.shared)
    .dfToastStyle(.banner)
```

---

## Configuration Properties Reference

Each configuration struct gives your style precisely what it needs to render. Here is what every struct provides:

### Content / Label

| Config | Property | Type | Description |
|---|---|---|---|
| `DFButtonStyleConfiguration` | `label` | `AnyView` | The button's rendered label view |
| `DFCardStyleConfiguration` | `content` | `AnyView` | The card's child content |
| `DFTextFieldStyleConfiguration` | `fieldContent` | `AnyView` | The pre-configured `TextField`, ready to lay out |
| `DFTextFieldStyleConfiguration` | `leadingContent` | `AnyView?` | Optional leading icon/view |
| `DFTextFieldStyleConfiguration` | `trailingContent` | `AnyView?` | Optional trailing icon/view |
| `DFTextFieldStyleConfiguration` | `label` | `String` | The field's label string (empty if none) |
| `DFTextFieldStyleConfiguration` | `placeholder` | `String` | The field's placeholder string |
| `DFSecureFieldStyleConfiguration` | `fieldContent` | `AnyView` | The pre-switched `SecureField`/`TextField` |
| `DFSecureFieldStyleConfiguration` | `onToggleReveal` | `() -> Void` | Call this to toggle password visibility |
| `DFToastStyleConfiguration` | `message` | `DFToastMessage` | Full message object: `.text`, `.icon`, `.severity`, `.duration` |
| `DFSidebarItemStyleConfiguration` | `item` | `DFSidebarItem` | The sidebar item: `.id`, `.icon`, `.label` |
| `DFTabBarStyleConfiguration` | `items` | `[DFTabItem]` | All tab items |
| `DFTabBarStyleConfiguration` | `selectedID` | `String` | The currently selected tab's ID |
| `DFTabBarStyleConfiguration` | `onSelect` | `@MainActor (String) -> Void` | Call with an item ID to change selection |

### Interaction States

Every configuration that represents an interactive component carries Boolean state flags:

| Property | Meaning |
|---|---|
| `isPressed` | The user is actively pressing (button, card) |
| `isDisabled` | The component has been disabled |
| `isFocused` | The field currently holds keyboard focus |
| `isInteractive` | The card has an action attached (DFCard-specific) |
| `isChecked` | The checkbox is checked |
| `isOn` | Toggle's current value (`Binding<Bool>`) |
| `isSelected` | The sidebar item is the active selection |
| `isRevealed` | The secure field is showing plain text |
| `isEnabled` | The sidebar item is interactive |

### The Theme

Every configuration carries a `theme: DFTheme` property. This is the full active theme as of the moment the component rendered. You can access any token:

```swift
func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
    let theme = configuration.theme

    configuration.label
        .foregroundStyle(theme.colors.primary)          // color tokens
        .font(theme.typography.label.font)              // typography tokens
        .padding(theme.spacing.md)                      // spacing tokens
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md)  // radius tokens
                .shadow(
                    color:   theme.shadows.sm.color,
                    radius:  theme.shadows.sm.radius,
                    x:       theme.shadows.sm.x,
                    y:       theme.shadows.sm.y
                )
        )
        .animation(theme.animation.fast, value: configuration.isPressed)
}
```

**Why theme is in the configuration, not `@Environment`:** Styles are instantiated ahead of time and stored in the environment as type-erased closures. The captured closure runs when the component body renders — at that moment the component reads `@Environment(\.dfTheme)` and injects it into the configuration before calling `makeBody`. This means your custom style always gets the correct active theme without needing `@Environment` inside the style struct itself. It also makes styles easier to test in isolation.

---

## Static Accessors vs Parameterized Struct Instances

### Zero-argument styles — use a static var

When a style takes no configuration, a static var on the protocol is the right choice:

```swift
// Declaration
extension DFButtonStyle where Self == DFGhostButtonStyle {
    static var ghost: DFGhostButtonStyle { DFGhostButtonStyle() }
}

// Usage
.dfButtonStyle(.ghost)
```

### Parameterized styles — use a static func

When a style takes parameters, declare a static function instead:

```swift
// Declaration
extension DFButtonStyle where Self == GlowingNeonButtonStyle {
    static func glowingNeon(color: Color) -> GlowingNeonButtonStyle {
        GlowingNeonButtonStyle(neonColor: color)
    }
}

// Usage — still reads like a dot-shorthand call
.dfButtonStyle(.glowingNeon(color: .purple))
```

You can also pass the concrete struct instance directly without a static accessor at all:

```swift
.dfButtonStyle(GlowingNeonButtonStyle(neonColor: .purple))
```

Static accessors are purely ergonomic. They are not required.

---

## Sendable Requirement

The `.dfButtonStyle<S: DFButtonStyle & Sendable>(_ style: S)` modifier requires `S: Sendable`. This is not optional — the modifier will not compile without it.

**Why:** Style instances are captured into `@Sendable` closures inside `AnyDF*Style` and can cross Swift concurrency actor boundaries (for example, into `@MainActor` view rendering). A non-`Sendable` style would break Swift 6's data isolation guarantees.

**How to conform:** A struct whose stored properties are all `Sendable` (value types, `Sendable` classes, `Color`, `CGFloat`, `String`, etc.) conforms to `Sendable` automatically or with an explicit declaration:

```swift
struct MyCardStyle: DFCardStyle, Sendable {
    let cornerRadius: CGFloat   // CGFloat is Sendable
    let strokeColor: Color      // Color is Sendable

    func makeBody(configuration: DFCardStyleConfiguration) -> some View {
        // ...
    }
}
```

**What breaks conformance — and how to fix it:**

If your style holds a non-`Sendable` reference type or a closure that captures non-`Sendable` state, the compiler will reject `Sendable`:

```swift
// BROKEN — UIImage is not Sendable
struct BadStyle: DFCardStyle, Sendable {
    let backgroundImage: UIImage  // compile error
}

// FIXED — use SwiftUI Image or move to config time
struct FixedStyle: DFCardStyle, Sendable {
    let imageName: String  // String is Sendable; resolve at render time
    func makeBody(configuration: DFCardStyleConfiguration) -> some View {
        Image(imageName)   // resolved inside makeBody on the main thread
    }
}
```

Never use `@unchecked Sendable` on your own styles unless you are certain the stored state is never mutated after init. That annotation suppresses compiler checks; misuse causes data races.

---

## Environment Key Mechanism (Advanced)

This section is for contributors modifying DesignFoundation internals.

Each style type is stored in `EnvironmentValues` via a private `EnvironmentKey`:

```swift
// Private — never exposed publicly
private struct DFButtonStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFButtonStyle = AnyDFButtonStyle(DFFilledButtonStyle())
}

public extension EnvironmentValues {
    var dfButtonStyle: AnyDFButtonStyle {
        get { self[DFButtonStyleKey.self] }
        set { self[DFButtonStyleKey.self] = newValue }
    }
}
```

`defaultValue` is the style that applies when no `.dfButtonStyle(_:)` modifier appears anywhere in the ancestor hierarchy. Changing `defaultValue` changes what every un-styled component in the app looks like.

Inside `DFButton` (or any component), the style is read from the environment and applied. `DFButton` specifically bridges through a real SwiftUI `ButtonStyle` (`DFBrandedButtonStyle`, public — see [[#Branding a Native Button Directly]]) rather than applying `makeBody` straight to a plain view, so it gets `isPressed`/`isEnabled` from an actual `Button` instead of a hand-rolled gesture:

```swift
// Simplified internal component body
struct DFButton: View {
    @Environment(\.dfButtonStyle) private var envStyle

    var body: some View {
        Button(action: action) {
            Text(label)                              // real content — configuration.label sees this
        }
        .buttonStyle(DFBrandedButtonStyle(styleOverride ?? envStyle, role: role))
    }
}

// DFBrandedButtonStyle reads dfTheme/isEnabled from @Environment itself and
// constructs DFButtonStyleConfiguration(label: AnyView(configuration.label), ...)
// before calling the active DFButtonStyle's makeBody(configuration:).
```

The environment read gives you the nearest ancestor's value, which is exactly the cascade behavior described in [[#Style Cascade]].

To add a new styleable component to DesignFoundation, the checklist is:
1. Define the configuration struct
2. Define the protocol
3. Implement `AnyDF*Style` type erasure with `@unchecked Sendable`
4. Define a private `EnvironmentKey` with the default built-in style as `defaultValue`
5. Add the `EnvironmentValues` computed property
6. Add the `View` extension modifier
7. Write at least one built-in style with a `Sendable` conformance
8. Add static accessors for each built-in

---

## Style Composition

You can wrap a built-in style inside a custom one to extend rather than replace its rendering. Call the built-in's `makeBody` and post-process the result.

```swift
// Wrap DFOutlinedCardStyle and add a colored top border accent
struct AccentedCardStyle: DFCardStyle, Sendable {
    let accentColor: Color
    private let base = DFOutlinedCardStyle()

    func makeBody(configuration: DFCardStyleConfiguration) -> some View {
        let theme = configuration.theme

        base.makeBody(configuration: configuration)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(accentColor)
                    .frame(height: 3)
                    .clipShape(
                        .rect(
                            topLeadingRadius: theme.radius.lg,
                            topTrailingRadius: theme.radius.lg
                        )
                    )
            }
    }
}

extension DFCardStyle where Self == AccentedCardStyle {
    static func accented(_ color: Color) -> AccentedCardStyle {
        AccentedCardStyle(accentColor: color)
    }
}

// Usage
DFCard { content }
    .dfCardStyle(.accented(.orange))
```

The same pattern works for any style protocol. Call the base style's `makeBody`, receive its `some View` result, and wrap it in another `AnyView` if you need to apply further modifiers — or use a `@ViewBuilder` return to avoid the extra erasure.

> **Tip:** If you only need to adjust opacity, shadow, or transforms on top of a built-in, prefer a plain view modifier on the `DFCard`/`DFButton`/etc. call site rather than a custom style. Reserve custom styles for cases where the core shape or layout needs to change.
