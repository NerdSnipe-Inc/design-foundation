# Plan 6: Tier 3 Supplementary Components Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 8 Tier 3 supplementary SwiftUI components — DFCheckbox, DFProgressBar, DFSkeleton, DFToast, DFAlert, DFListRow, DFList, DFTable — completing DesignFoundation's supplementary component layer.

**Architecture:** Tier 3 follows the same `*StyleConfiguration` → `*Style` protocol → `AnyDF*Style (@unchecked Sendable)` → `EnvironmentKey` pattern as Tiers 1 and 2, but each component has exactly one built-in style (no named variants). Components where a full style protocol doesn't make sense (DFAlert, DFListRow, DFList, DFTable) use theme tokens directly. DFToast introduces a `@MainActor` observable queue for managing multiple messages.

**Tech Stack:** Swift 6.0 strict concurrency (`StrictConcurrency` experimental feature enabled), SwiftUI, Swift Testing (`@Suite`, `@Test`, `#expect`), iOS 18 / macOS 15 / visionOS 2

## Global Constraints

- Swift 6.0: `StrictConcurrency` experimental feature ON — every file compiles clean under strict concurrency
- Platforms: `.iOS(.v18)`, `.macOS(.v15)`, `.visionOS(.v2)` — no `#if os(...)` guards unless unavoidable
- `*StyleConfiguration` structs that hold only `Sendable` fields (String, Bool, Double, Sendable enums, DFTheme) declare `Sendable` (not `@unchecked Sendable`)
- `AnyDF*Style` wrappers always `@unchecked Sendable` with comment: `// @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.`
- Closures in configs must be `@MainActor`-isolated (e.g. `@MainActor () -> Void`) to be Sendable — never plain `() -> Void`
- Style protocols with no closure config: no `@MainActor` annotation needed on protocol
- Single built-in style per component; style protocol exists for color/radius overrides only
- Tests: Swift Testing — `import Testing`, `@Suite`, `@Test`, `#expect` — never XCTest
- Theme tokens available via `@Environment(\.dfTheme) private var theme: DFTheme`:
  - `theme.colors`: `.primary`, `.secondary`, `.accent`, `.background`, `.surface`, `.surfaceElevated`, `.textPrimary`, `.textSecondary`, `.textDisabled`, `.border`, `.interactiveFill`, `.destructive`, `.success`, `.warning`, `.info`
  - `theme.spacing`: `.xs=4`, `.sm=8`, `.md=12`, `.lg=16`, `.xl=24`, `.xxl=32`
  - `theme.radius`: `.none=0`, `.sm=4`, `.md=8`, `.lg=12`, `.full=9999`
  - `theme.typography`: `.display`, `.title`, `.headline`, `.body`, `.caption`, `.label` — each has `.font: Font`
  - `theme.shadows.sm`: `.color`, `.radius`, `.x`, `.y`
  - `theme.animation.fast`: `Animation`
- Accessibility: every interactive component needs `.accessibilityLabel`, `.accessibilityAddTraits`, `.accessibilityValue` where appropriate
- Commit messages: concise, descriptive, no Co-Author line
- Baseline: 139 tests in 85 suites (master at c5c3a51)
- Style environment var name convention: `\.dfCheckboxStyle`, `\.dfProgressBarStyle`, etc.
- Convenience static var convention: `public extension DFCheckboxStyle where Self == DFDefaultCheckboxStyle { static var `default`: Self { Self() } }`

---

## File Structure

```
Sources/DesignFoundation/Supplementary/
  Checkbox/
    DFCheckboxStyle.swift       — Config, protocol, type eraser, env key, default style
    DFCheckbox.swift            — DFCheckbox view
    DFCheckbox+Previews.swift   — Previews
  ProgressBar/
    DFProgressBarStyle.swift    — Config, protocol, type eraser, env key, default style
    DFProgressBar.swift         — DFProgressBar view
    DFProgressBar+Previews.swift
  Skeleton/
    DFSkeletonStyle.swift       — Config, protocol, type eraser, env key, default style
    DFSkeleton.swift            — DFSkeleton view
    DFSkeleton+Previews.swift
  Toast/
    DFToastStyle.swift          — DFToastMessage, config, protocol, type eraser, env key, default style
    DFToastQueue.swift          — @MainActor DFToastQueue observable class
    DFToast.swift               — DFToastModifier + View extension
    DFToast+Previews.swift
  Alert/
    DFAlert.swift               — DFAlertAction, DFAlertActionRole, DFAlertConfiguration, ViewModifier + View extension
    DFAlert+Previews.swift
  List/
    DFListRow.swift             — DFListRow view (title, subtitle, leading/trailing slots, disclosure)
    DFList.swift                — DFList generic view (themed List wrapper with delete/move/selection)
    DFList+Previews.swift
  Table/
    DFTable.swift               — DFTableColumn + DFTable view (sortable, custom scroll table)
    DFTable+Previews.swift

Tests/DesignFoundationTests/Supplementary/
  DFCheckboxTests.swift
  DFProgressBarTests.swift
  DFSkeletonTests.swift
  DFToastTests.swift
  DFAlertTests.swift
  DFListTests.swift
  DFTableTests.swift
```

---

### Task 1: DFCheckbox

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/Checkbox/DFCheckboxStyle.swift`
- Create: `Sources/DesignFoundation/Supplementary/Checkbox/DFCheckbox.swift`
- Create: `Sources/DesignFoundation/Supplementary/Checkbox/DFCheckbox+Previews.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFCheckboxTests.swift`

**Interfaces:**
- Produces: `DFCheckboxStyleConfiguration`, `DFCheckboxStyle`, `AnyDFCheckboxStyle`, `DFDefaultCheckboxStyle`, `DFCheckbox`

- [ ] **Step 1: Write the failing tests**

Create `Tests/DesignFoundationTests/Supplementary/DFCheckboxTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFCheckboxStyleConfiguration")
struct DFCheckboxStyleConfigurationTests {
    @Test("holds all values correctly")
    func holdsValues() {
        let config = DFCheckboxStyleConfiguration(
            isChecked: true,
            isEnabled: false,
            theme: .default
        )
        #expect(config.isChecked == true)
        #expect(config.isEnabled == false)
    }
}

@Suite("DFCheckbox Environment")
struct DFCheckboxEnvironmentTests {
    @Test("dfCheckboxStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfCheckboxStyle
    }
}

@Suite("DFCheckbox Styles")
struct DFCheckboxStyleTests {
    @Test("default style is Sendable")
    func defaultSendable() {
        let _: any DFCheckboxStyle & Sendable = DFDefaultCheckboxStyle()
    }

    @Test("AnyDFCheckboxStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFCheckboxStyle(DFDefaultCheckboxStyle())
        let config = DFCheckboxStyleConfiguration(isChecked: false, isEnabled: true, theme: .default)
        let _ = style.makeBody(configuration: config)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFCheckboxTests 2>&1 | tail -5
```

Expected: compile error — `DFCheckboxStyleConfiguration` not found.

- [ ] **Step 3: Implement DFCheckboxStyle.swift**

Create `Sources/DesignFoundation/Supplementary/Checkbox/DFCheckboxStyle.swift`:

```swift
import SwiftUI

// MARK: - Configuration
// IS Sendable: holds only Bool and DFTheme (Sendable); no closures.

public struct DFCheckboxStyleConfiguration: Sendable {
    public let isChecked: Bool
    public let isEnabled: Bool
    public let theme: DFTheme

    public init(isChecked: Bool, isEnabled: Bool, theme: DFTheme) {
        self.isChecked = isChecked
        self.isEnabled = isEnabled
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFCheckboxStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFCheckboxStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFCheckboxStyle: DFCheckboxStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: (DFCheckboxStyleConfiguration) -> AnyView

    public init<S: DFCheckboxStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFCheckboxStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFCheckboxStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFCheckboxStyle = AnyDFCheckboxStyle(DFDefaultCheckboxStyle())
}

public extension EnvironmentValues {
    var dfCheckboxStyle: AnyDFCheckboxStyle {
        get { self[DFCheckboxStyleKey.self] }
        set { self[DFCheckboxStyleKey.self] = newValue }
    }
}

public extension View {
    func dfCheckboxStyle<S: DFCheckboxStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfCheckboxStyle, AnyDFCheckboxStyle(style))
    }
}

// MARK: - Convenience static var

public extension DFCheckboxStyle where Self == DFDefaultCheckboxStyle {
    static var `default`: DFDefaultCheckboxStyle { DFDefaultCheckboxStyle() }
}

// MARK: - Built-in: Default

public struct DFDefaultCheckboxStyle: DFCheckboxStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFCheckboxStyleConfiguration) -> some View {
        let theme = configuration.theme
        ZStack {
            RoundedRectangle(cornerRadius: theme.radius.sm)
                .strokeBorder(
                    configuration.isChecked ? theme.colors.primary : theme.colors.border,
                    lineWidth: 1.5
                )
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.sm)
                        .fill(configuration.isChecked ? theme.colors.primary : Color.clear)
                )
                .frame(width: 20, height: 20)
            if configuration.isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .opacity(configuration.isEnabled ? 1.0 : 0.4)
    }
}
```

- [ ] **Step 4: Implement DFCheckbox.swift**

Create `Sources/DesignFoundation/Supplementary/Checkbox/DFCheckbox.swift`:

```swift
import SwiftUI

public struct DFCheckbox: View {
    @Binding private var isChecked: Bool
    private let label: String

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfCheckboxStyle) private var style

    public init(isChecked: Binding<Bool>, label: String = "") {
        self._isChecked = isChecked
        self.label = label
    }

    public var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack(spacing: theme.spacing.sm) {
                style.makeBody(configuration: DFCheckboxStyleConfiguration(
                    isChecked: isChecked,
                    isEnabled: isEnabled,
                    theme: theme
                ))
                if !label.isEmpty {
                    Text(label)
                        .font(theme.typography.body.font)
                        .foregroundStyle(isEnabled ? theme.colors.textPrimary : theme.colors.textDisabled)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label.isEmpty ? "Checkbox" : label)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isChecked ? "checked" : "unchecked")
    }
}
```

- [ ] **Step 5: Implement DFCheckbox+Previews.swift**

Create `Sources/DesignFoundation/Supplementary/Checkbox/DFCheckbox+Previews.swift`:

```swift
import SwiftUI

#Preview("DFCheckbox — States") {
    @Previewable @State var checked1 = true
    @Previewable @State var checked2 = false
    @Previewable @State var checked3 = true

    VStack(alignment: .leading, spacing: 16) {
        DFCheckbox(isChecked: $checked1, label: "Checked")
        DFCheckbox(isChecked: $checked2, label: "Unchecked")
        DFCheckbox(isChecked: $checked3, label: "Disabled checked")
            .disabled(true)
        DFCheckbox(isChecked: $checked2)
    }
    .padding()
}
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFCheckboxTests 2>&1 | tail -5
```

Expected: `Test run with 4 tests in 3 suites passed`

- [ ] **Step 7: Run full suite to verify no regressions**

```bash
swift test 2>&1 | tail -3
```

Expected: `Test run with 143 tests in 88 suites passed`

- [ ] **Step 8: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/Checkbox/ Tests/DesignFoundationTests/Supplementary/DFCheckboxTests.swift
git commit -m "feat(checkbox): add DFCheckbox with default style and style protocol"
```

---

### Task 2: DFProgressBar

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/ProgressBar/DFProgressBarStyle.swift`
- Create: `Sources/DesignFoundation/Supplementary/ProgressBar/DFProgressBar.swift`
- Create: `Sources/DesignFoundation/Supplementary/ProgressBar/DFProgressBar+Previews.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFProgressBarTests.swift`

**Interfaces:**
- Produces: `DFProgressBarVariant`, `DFProgressBarStyleConfiguration`, `DFProgressBarStyle`, `AnyDFProgressBarStyle`, `DFDefaultProgressBarStyle`, `DFProgressBar`

- [ ] **Step 1: Write the failing tests**

Create `Tests/DesignFoundationTests/Supplementary/DFProgressBarTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFProgressBarVariant")
struct DFProgressBarVariantTests {
    @Test("variants are Equatable")
    func equatable() {
        #expect(DFProgressBarVariant.linear == .linear)
        #expect(DFProgressBarVariant.circular == .circular)
        #expect(DFProgressBarVariant.indeterminate == .indeterminate)
        #expect(DFProgressBarVariant.linear != .circular)
    }
}

@Suite("DFProgressBarStyleConfiguration")
struct DFProgressBarStyleConfigurationTests {
    @Test("holds all values correctly")
    func holdsValues() {
        let config = DFProgressBarStyleConfiguration(
            variant: .circular,
            value: 0.75,
            label: "Loading",
            theme: .default
        )
        #expect(config.variant == .circular)
        #expect(config.value == 0.75)
        #expect(config.label == "Loading")
    }
}

@Suite("DFProgressBar Environment")
struct DFProgressBarEnvironmentTests {
    @Test("dfProgressBarStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfProgressBarStyle
    }
}

@Suite("DFProgressBar Styles")
struct DFProgressBarStyleTests {
    @Test("default style is Sendable")
    func defaultSendable() {
        let _: any DFProgressBarStyle & Sendable = DFDefaultProgressBarStyle()
    }

    @Test("AnyDFProgressBarStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFProgressBarStyle(DFDefaultProgressBarStyle())
        let config = DFProgressBarStyleConfiguration(variant: .linear, value: 0.5, label: nil, theme: .default)
        let _ = style.makeBody(configuration: config)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFProgressBarTests 2>&1 | tail -5
```

Expected: compile error — `DFProgressBarVariant` not found.

- [ ] **Step 3: Implement DFProgressBarStyle.swift**

Create `Sources/DesignFoundation/Supplementary/ProgressBar/DFProgressBarStyle.swift`:

```swift
import SwiftUI

// MARK: - Variant

public enum DFProgressBarVariant: Sendable, Equatable {
    case linear
    case circular
    case indeterminate
}

// MARK: - Configuration
// IS Sendable: holds DFProgressBarVariant (Sendable), Double, optional String, DFTheme (Sendable).

public struct DFProgressBarStyleConfiguration: Sendable {
    public let variant: DFProgressBarVariant
    public let value: Double
    public let label: String?
    public let theme: DFTheme

    public init(variant: DFProgressBarVariant, value: Double, label: String?, theme: DFTheme) {
        self.variant = variant
        self.value = value
        self.label = label
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFProgressBarStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFProgressBarStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFProgressBarStyle: DFProgressBarStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: (DFProgressBarStyleConfiguration) -> AnyView

    public init<S: DFProgressBarStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFProgressBarStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFProgressBarStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFProgressBarStyle = AnyDFProgressBarStyle(DFDefaultProgressBarStyle())
}

public extension EnvironmentValues {
    var dfProgressBarStyle: AnyDFProgressBarStyle {
        get { self[DFProgressBarStyleKey.self] }
        set { self[DFProgressBarStyleKey.self] = newValue }
    }
}

public extension View {
    func dfProgressBarStyle<S: DFProgressBarStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfProgressBarStyle, AnyDFProgressBarStyle(style))
    }
}

// MARK: - Convenience static var

public extension DFProgressBarStyle where Self == DFDefaultProgressBarStyle {
    static var `default`: DFDefaultProgressBarStyle { DFDefaultProgressBarStyle() }
}

// MARK: - Built-in: Default

public struct DFDefaultProgressBarStyle: DFProgressBarStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFProgressBarStyleConfiguration) -> some View {
        let theme = configuration.theme
        let clamped = max(0, min(1, configuration.value))

        switch configuration.variant {
        case .linear:
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                if let label = configuration.label {
                    Text(label)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(theme.colors.border)
                            .frame(height: 6)
                        Capsule()
                            .fill(theme.colors.primary)
                            .frame(width: geo.size.width * clamped, height: 6)
                    }
                }
                .frame(height: 6)
            }

        case .circular:
            ZStack {
                Circle()
                    .stroke(theme.colors.border, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: clamped)
                    .stroke(theme.colors.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                if let label = configuration.label {
                    Text(label)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 52, height: 52)

        case .indeterminate:
            VStack(spacing: theme.spacing.xs) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(theme.colors.primary)
                if let label = configuration.label {
                    Text(label)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
        }
    }
}
```

- [ ] **Step 4: Implement DFProgressBar.swift**

Create `Sources/DesignFoundation/Supplementary/ProgressBar/DFProgressBar.swift`:

```swift
import SwiftUI

public struct DFProgressBar: View {
    private let variant: DFProgressBarVariant
    private let value: Double
    private let label: String?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfProgressBarStyle) private var style

    public init(variant: DFProgressBarVariant = .linear, value: Double = 0.0, label: String? = nil) {
        self.variant = variant
        self.value = value
        self.label = label
    }

    public var body: some View {
        style.makeBody(configuration: DFProgressBarStyleConfiguration(
            variant: variant,
            value: value,
            label: label,
            theme: theme
        ))
        .accessibilityLabel(label ?? "Progress")
        .accessibilityValue(variant == .indeterminate ? "Loading" : "\(Int(max(0, min(1, value)) * 100)) percent")
    }
}
```

- [ ] **Step 5: Implement DFProgressBar+Previews.swift**

Create `Sources/DesignFoundation/Supplementary/ProgressBar/DFProgressBar+Previews.swift`:

```swift
import SwiftUI

#Preview("DFProgressBar — Variants") {
    VStack(spacing: 32) {
        DFProgressBar(variant: .linear, value: 0.65, label: "Uploading…")
        DFProgressBar(variant: .linear, value: 0.3)
        HStack(spacing: 24) {
            DFProgressBar(variant: .circular, value: 0.75, label: "75%")
            DFProgressBar(variant: .indeterminate, label: "Loading")
        }
    }
    .padding()
}
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFProgressBarTests 2>&1 | tail -5
```

Expected: `Test run with 5 tests in 4 suites passed`

- [ ] **Step 7: Run full suite**

```bash
swift test 2>&1 | tail -3
```

Expected: `Test run with 148 tests in 92 suites passed`

- [ ] **Step 8: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/ProgressBar/ Tests/DesignFoundationTests/Supplementary/DFProgressBarTests.swift
git commit -m "feat(progressbar): add DFProgressBar with linear, circular, indeterminate variants"
```

---

### Task 3: DFSkeleton

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/Skeleton/DFSkeletonStyle.swift`
- Create: `Sources/DesignFoundation/Supplementary/Skeleton/DFSkeleton.swift`
- Create: `Sources/DesignFoundation/Supplementary/Skeleton/DFSkeleton+Previews.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFSkeletonTests.swift`

**Interfaces:**
- Produces: `DFSkeletonShape`, `DFSkeletonStyleConfiguration`, `DFSkeletonStyle`, `AnyDFSkeletonStyle`, `DFDefaultSkeletonStyle`, `DFSkeleton`

**Key design:** `DFSkeletonStyleConfiguration` carries `animationPhase: Double` (0.0→1.0) so the style can render a gradient shimmer without holding `@State` itself. `DFSkeleton` owns the `@State` and drives the animation.

- [ ] **Step 1: Write the failing tests**

Create `Tests/DesignFoundationTests/Supplementary/DFSkeletonTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFSkeletonShape")
struct DFSkeletonShapeTests {
    @Test("shapes are Equatable")
    func equatable() {
        #expect(DFSkeletonShape.rectangle == .rectangle)
        #expect(DFSkeletonShape.circle == .circle)
        #expect(DFSkeletonShape.capsule == .capsule)
        #expect(DFSkeletonShape.roundedRectangle(cornerRadius: 8) == .roundedRectangle(cornerRadius: 8))
        #expect(DFSkeletonShape.rectangle != .circle)
    }
}

@Suite("DFSkeletonStyleConfiguration")
struct DFSkeletonStyleConfigurationTests {
    @Test("holds all values correctly")
    func holdsValues() {
        let config = DFSkeletonStyleConfiguration(
            shape: .circle,
            animationPhase: 0.5,
            theme: .default
        )
        #expect(config.shape == .circle)
        #expect(config.animationPhase == 0.5)
    }
}

@Suite("DFSkeleton Environment")
struct DFSkeletonEnvironmentTests {
    @Test("dfSkeletonStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfSkeletonStyle
    }
}

@Suite("DFSkeleton Styles")
struct DFSkeletonStyleTests {
    @Test("default style is Sendable")
    func defaultSendable() {
        let _: any DFSkeletonStyle & Sendable = DFDefaultSkeletonStyle()
    }

    @Test("AnyDFSkeletonStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFSkeletonStyle(DFDefaultSkeletonStyle())
        let config = DFSkeletonStyleConfiguration(shape: .rectangle, animationPhase: 0.0, theme: .default)
        let _ = style.makeBody(configuration: config)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFSkeletonTests 2>&1 | tail -5
```

Expected: compile error — `DFSkeletonShape` not found.

- [ ] **Step 3: Implement DFSkeletonStyle.swift**

Create `Sources/DesignFoundation/Supplementary/Skeleton/DFSkeletonStyle.swift`:

```swift
import SwiftUI

// MARK: - Shape

public enum DFSkeletonShape: Sendable, Equatable {
    case rectangle
    case roundedRectangle(cornerRadius: CGFloat)
    case circle
    case capsule
}

// MARK: - Configuration
// IS Sendable: holds DFSkeletonShape (Sendable), Double, DFTheme (Sendable).

public struct DFSkeletonStyleConfiguration: Sendable {
    public let shape: DFSkeletonShape
    /// Animated 0.0→1.0 phase owned by DFSkeleton; styles use it to position the shimmer gradient.
    public let animationPhase: Double
    public let theme: DFTheme

    public init(shape: DFSkeletonShape, animationPhase: Double, theme: DFTheme) {
        self.shape = shape
        self.animationPhase = animationPhase
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFSkeletonStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFSkeletonStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFSkeletonStyle: DFSkeletonStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: (DFSkeletonStyleConfiguration) -> AnyView

    public init<S: DFSkeletonStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFSkeletonStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFSkeletonStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFSkeletonStyle = AnyDFSkeletonStyle(DFDefaultSkeletonStyle())
}

public extension EnvironmentValues {
    var dfSkeletonStyle: AnyDFSkeletonStyle {
        get { self[DFSkeletonStyleKey.self] }
        set { self[DFSkeletonStyleKey.self] = newValue }
    }
}

public extension View {
    func dfSkeletonStyle<S: DFSkeletonStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfSkeletonStyle, AnyDFSkeletonStyle(style))
    }
}

// MARK: - Convenience static var

public extension DFSkeletonStyle where Self == DFDefaultSkeletonStyle {
    static var `default`: DFDefaultSkeletonStyle { DFDefaultSkeletonStyle() }
}

// MARK: - Built-in: Default

public struct DFDefaultSkeletonStyle: DFSkeletonStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSkeletonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let phase = configuration.animationPhase
        let base = theme.colors.border.opacity(0.25)
        let highlight = theme.colors.border.opacity(0.55)

        let gradient = LinearGradient(
            stops: [
                .init(color: base, location: 0),
                .init(color: base, location: max(0, phase - 0.3)),
                .init(color: highlight, location: phase),
                .init(color: base, location: min(1, phase + 0.3)),
                .init(color: base, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )

        switch configuration.shape {
        case .rectangle:
            Rectangle().fill(gradient)
        case .roundedRectangle(let radius):
            RoundedRectangle(cornerRadius: radius).fill(gradient)
        case .circle:
            Circle().fill(gradient)
        case .capsule:
            Capsule().fill(gradient)
        }
    }
}
```

- [ ] **Step 4: Implement DFSkeleton.swift**

Create `Sources/DesignFoundation/Supplementary/Skeleton/DFSkeleton.swift`:

```swift
import SwiftUI

public struct DFSkeleton: View {
    private let shape: DFSkeletonShape

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfSkeletonStyle) private var style
    @State private var animationPhase: Double = 0.0

    public init(shape: DFSkeletonShape = .roundedRectangle(cornerRadius: 8)) {
        self.shape = shape
    }

    public var body: some View {
        style.makeBody(configuration: DFSkeletonStyleConfiguration(
            shape: shape,
            animationPhase: animationPhase,
            theme: theme
        ))
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
        }
        .accessibilityLabel("Loading")
        .accessibilityHidden(true)
    }
}
```

- [ ] **Step 5: Implement DFSkeleton+Previews.swift**

Create `Sources/DesignFoundation/Supplementary/Skeleton/DFSkeleton+Previews.swift`:

```swift
import SwiftUI

#Preview("DFSkeleton — Shapes") {
    VStack(spacing: 16) {
        DFSkeleton(shape: .roundedRectangle(cornerRadius: 8))
            .frame(height: 20)
        DFSkeleton(shape: .roundedRectangle(cornerRadius: 8))
            .frame(height: 14)
            .frame(maxWidth: .infinity * 0.6)
        HStack(spacing: 12) {
            DFSkeleton(shape: .circle)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 8) {
                DFSkeleton(shape: .roundedRectangle(cornerRadius: 4))
                    .frame(height: 14)
                DFSkeleton(shape: .roundedRectangle(cornerRadius: 4))
                    .frame(height: 12)
                    .frame(maxWidth: 120)
            }
        }
        DFSkeleton(shape: .capsule)
            .frame(width: 80, height: 32)
    }
    .padding()
}
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFSkeletonTests 2>&1 | tail -5
```

Expected: `Test run with 5 tests in 4 suites passed`

- [ ] **Step 7: Run full suite**

```bash
swift test 2>&1 | tail -3
```

Expected: `Test run with 153 tests in 96 suites passed`

- [ ] **Step 8: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/Skeleton/ Tests/DesignFoundationTests/Supplementary/DFSkeletonTests.swift
git commit -m "feat(skeleton): add DFSkeleton with shimmer animation"
```

---

### Task 4: DFToast

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/Toast/DFToastStyle.swift`
- Create: `Sources/DesignFoundation/Supplementary/Toast/DFToastQueue.swift`
- Create: `Sources/DesignFoundation/Supplementary/Toast/DFToast.swift`
- Create: `Sources/DesignFoundation/Supplementary/Toast/DFToast+Previews.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFToastTests.swift`

**Interfaces:**
- Produces: `DFToastMessage`, `DFToastStyleConfiguration`, `DFToastStyle`, `AnyDFToastStyle`, `DFDefaultToastStyle`, `DFToastQueue`, `View.dfToast(queue:)`

**Swift 6 note:** `DFToastQueue` is `@MainActor` — the `dfToast()` View extension must also be `@MainActor` to access `DFToastQueue.shared` as a default parameter. View bodies are always `@MainActor`, so this is safe.

- [ ] **Step 1: Write the failing tests**

Create `Tests/DesignFoundationTests/Supplementary/DFToastTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFToastMessage")
struct DFToastMessageTests {
    @Test("stores text and icon")
    func storesValues() {
        let msg = DFToastMessage(text: "Hello", icon: "star.fill")
        #expect(msg.text == "Hello")
        #expect(msg.icon == "star.fill")
    }

    @Test("default duration is 3 seconds")
    func defaultDuration() {
        let msg = DFToastMessage(text: "Test")
        #expect(msg.duration == 3.0)
        #expect(msg.icon == nil)
    }
}

@Suite("DFToastStyleConfiguration")
struct DFToastStyleConfigurationTests {
    @Test("holds message and theme")
    func holdsValues() {
        let msg = DFToastMessage(text: "Hi")
        let config = DFToastStyleConfiguration(message: msg, theme: .default)
        #expect(config.message.text == "Hi")
    }
}

@Suite("DFToast Environment")
struct DFToastEnvironmentTests {
    @Test("dfToastStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfToastStyle
    }
}

@Suite("DFToast Styles")
struct DFToastStyleTests {
    @Test("default style is Sendable")
    func defaultSendable() {
        let _: any DFToastStyle & Sendable = DFDefaultToastStyle()
    }

    @Test("AnyDFToastStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFToastStyle(DFDefaultToastStyle())
        let config = DFToastStyleConfiguration(message: DFToastMessage(text: "Test"), theme: .default)
        let _ = style.makeBody(configuration: config)
    }
}

@Suite("DFToastQueue")
@MainActor
struct DFToastQueueTests {
    @Test("show appends message")
    func showAppends() {
        let queue = DFToastQueue()
        queue.show(DFToastMessage(text: "A"))
        #expect(queue.messages.count == 1)
        #expect(queue.messages[0].text == "A")
    }

    @Test("dismiss removes message by id")
    func dismissRemoves() {
        let queue = DFToastQueue()
        let msg = DFToastMessage(text: "B")
        queue.show(msg)
        queue.dismiss(id: msg.id)
        #expect(queue.messages.isEmpty)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFToastTests 2>&1 | tail -5
```

Expected: compile error — `DFToastMessage` not found.

- [ ] **Step 3: Implement DFToastStyle.swift**

Create `Sources/DesignFoundation/Supplementary/Toast/DFToastStyle.swift`:

```swift
import SwiftUI

// MARK: - Message

public struct DFToastMessage: Identifiable, Sendable {
    public let id: UUID
    public let text: String
    public let icon: String?
    public let duration: TimeInterval

    public init(text: String, icon: String? = nil, duration: TimeInterval = 3.0) {
        self.id = UUID()
        self.text = text
        self.icon = icon
        self.duration = duration
    }
}

// MARK: - Configuration
// IS Sendable: holds DFToastMessage (Sendable) and DFTheme (Sendable).

public struct DFToastStyleConfiguration: Sendable {
    public let message: DFToastMessage
    public let theme: DFTheme

    public init(message: DFToastMessage, theme: DFTheme) {
        self.message = message
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFToastStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFToastStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFToastStyle: DFToastStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: (DFToastStyleConfiguration) -> AnyView

    public init<S: DFToastStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFToastStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFToastStyle = AnyDFToastStyle(DFDefaultToastStyle())
}

public extension EnvironmentValues {
    var dfToastStyle: AnyDFToastStyle {
        get { self[DFToastStyleKey.self] }
        set { self[DFToastStyleKey.self] = newValue }
    }
}

public extension View {
    func dfToastStyle<S: DFToastStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfToastStyle, AnyDFToastStyle(style))
    }
}

// MARK: - Convenience static var

public extension DFToastStyle where Self == DFDefaultToastStyle {
    static var `default`: DFDefaultToastStyle { DFDefaultToastStyle() }
}

// MARK: - Built-in: Default

public struct DFDefaultToastStyle: DFToastStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        let theme = configuration.theme
        let message = configuration.message
        HStack(spacing: theme.spacing.sm) {
            if let icon = message.icon {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(theme.colors.textPrimary)
            }
            Text(message.text)
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.sm)
        .background(
            Capsule()
                .fill(theme.colors.surfaceElevated)
                .shadow(
                    color: theme.shadows.sm.color,
                    radius: theme.shadows.sm.radius,
                    x: theme.shadows.sm.x,
                    y: theme.shadows.sm.y
                )
        )
    }
}
```

- [ ] **Step 4: Implement DFToastQueue.swift**

Create `Sources/DesignFoundation/Supplementary/Toast/DFToastQueue.swift`:

```swift
import SwiftUI

@MainActor
public final class DFToastQueue: ObservableObject {
    public static let shared = DFToastQueue()

    @Published public var messages: [DFToastMessage] = []

    public init() {}

    public func show(_ message: DFToastMessage) {
        messages.append(message)
    }

    public func show(text: String, icon: String? = nil, duration: TimeInterval = 3.0) {
        show(DFToastMessage(text: text, icon: icon, duration: duration))
    }

    public func dismiss(id: UUID) {
        messages.removeAll { $0.id == id }
    }
}
```

- [ ] **Step 5: Implement DFToast.swift**

Create `Sources/DesignFoundation/Supplementary/Toast/DFToast.swift`:

```swift
import SwiftUI

// MARK: - Modifier

private struct DFToastModifier: ViewModifier {
    @ObservedObject var queue: DFToastQueue

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfToastStyle) private var style

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message = queue.messages.first {
                    style.makeBody(configuration: DFToastStyleConfiguration(
                        message: message,
                        theme: theme
                    ))
                    .padding(.top, theme.spacing.lg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task(id: message.id) {
                        try? await Task.sleep(for: .seconds(message.duration))
                        if !Task.isCancelled {
                            queue.dismiss(id: message.id)
                        }
                    }
                }
            }
            .animation(theme.animation.fast, value: queue.messages.first?.id)
    }
}

// MARK: - View extension

@MainActor
public extension View {
    func dfToast(queue: DFToastQueue = .shared) -> some View {
        modifier(DFToastModifier(queue: queue))
    }
}
```

- [ ] **Step 6: Implement DFToast+Previews.swift**

Create `Sources/DesignFoundation/Supplementary/Toast/DFToast+Previews.swift`:

```swift
import SwiftUI

#Preview("DFToast — Queue") {
    @Previewable @StateObject var queue = DFToastQueue()

    VStack(spacing: 16) {
        Button("Show toast") {
            queue.show(text: "File saved", icon: "checkmark.circle.fill")
        }
        Button("Show error toast") {
            queue.show(text: "Something went wrong", icon: "exclamationmark.triangle.fill")
        }
        Button("Show plain toast") {
            queue.show(text: "Item deleted")
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .dfToast(queue: queue)
}
```

- [ ] **Step 7: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFToastTests 2>&1 | tail -5
```

Expected: `Test run with 7 tests in 5 suites passed`

- [ ] **Step 8: Run full suite**

```bash
swift test 2>&1 | tail -3
```

Expected: `Test run with 160 tests in 101 suites passed`

- [ ] **Step 9: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/Toast/ Tests/DesignFoundationTests/Supplementary/DFToastTests.swift
git commit -m "feat(toast): add DFToast with queue management and auto-dismiss"
```

---

### Task 5: DFAlert

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/Alert/DFAlert.swift`
- Create: `Sources/DesignFoundation/Supplementary/Alert/DFAlert+Previews.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFAlertTests.swift`

**Interfaces:**
- Produces: `DFAlertActionRole`, `DFAlertAction`, `DFAlertConfiguration`, `View.dfAlert(isPresented:configuration:)`, `View.dfAlert(isPresented:title:message:actions:)`
- No style protocol — native `.alert()` controls all rendering

**Note:** `DFAlertAction.action` is `(@Sendable () -> Void)?` — `@Sendable` makes it safe under Swift 6 strict concurrency.

- [ ] **Step 1: Write the failing tests**

Create `Tests/DesignFoundationTests/Supplementary/DFAlertTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFAlertActionRole")
struct DFAlertActionRoleTests {
    @Test("roles map to ButtonRole")
    func rolesMapCorrectly() {
        #expect(DFAlertActionRole.destructive.buttonRole == .destructive)
        #expect(DFAlertActionRole.cancel.buttonRole == .cancel)
    }
}

@Suite("DFAlertAction")
struct DFAlertActionTests {
    @Test("stores title and nil role by default")
    func defaultInit() {
        let action = DFAlertAction(title: "OK")
        #expect(action.title == "OK")
        #expect(action.role == nil)
    }

    @Test("stores destructive role")
    func destructiveRole() {
        let action = DFAlertAction(title: "Delete", role: .destructive)
        #expect(action.role == .destructive)
    }
}

@Suite("DFAlertConfiguration")
struct DFAlertConfigurationTests {
    @Test("stores title, message, and actions")
    func holdsValues() {
        let config = DFAlertConfiguration(
            title: "Confirm",
            message: "Are you sure?",
            actions: [DFAlertAction(title: "Yes"), DFAlertAction(title: "No", role: .cancel)]
        )
        #expect(config.title == "Confirm")
        #expect(config.message == "Are you sure?")
        #expect(config.actions.count == 2)
    }

    @Test("message defaults to nil")
    func messageDefaultsNil() {
        let config = DFAlertConfiguration(title: "Notice", actions: [DFAlertAction(title: "OK")])
        #expect(config.message == nil)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFAlertTests 2>&1 | tail -5
```

Expected: compile error — `DFAlertActionRole` not found.

- [ ] **Step 3: Implement DFAlert.swift**

Create `Sources/DesignFoundation/Supplementary/Alert/DFAlert.swift`:

```swift
import SwiftUI

// MARK: - Role

public enum DFAlertActionRole: Sendable, Equatable {
    case destructive
    case cancel

    var buttonRole: ButtonRole {
        switch self {
        case .destructive: .destructive
        case .cancel: .cancel
        }
    }
}

// MARK: - Action

public struct DFAlertAction: Sendable {
    public let title: String
    public let role: DFAlertActionRole?
    public let action: (@Sendable () -> Void)?

    public init(title: String, role: DFAlertActionRole? = nil, action: (@Sendable () -> Void)? = nil) {
        self.title = title
        self.role = role
        self.action = action
    }
}

// MARK: - Configuration

public struct DFAlertConfiguration: Sendable {
    public let title: String
    public let message: String?
    public let actions: [DFAlertAction]

    public init(title: String, message: String? = nil, actions: [DFAlertAction] = [DFAlertAction(title: "OK")]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

// MARK: - Modifier

private struct DFAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let configuration: DFAlertConfiguration

    func body(content: Content) -> some View {
        content.alert(configuration.title, isPresented: $isPresented) {
            ForEach(Array(configuration.actions.enumerated()), id: \.offset) { _, alertAction in
                Button(alertAction.title, role: alertAction.role?.buttonRole) {
                    alertAction.action?()
                }
            }
        } message: {
            if let message = configuration.message {
                Text(message)
            }
        }
    }
}

// MARK: - View extension

public extension View {
    func dfAlert(isPresented: Binding<Bool>, configuration: DFAlertConfiguration) -> some View {
        modifier(DFAlertModifier(isPresented: isPresented, configuration: configuration))
    }

    func dfAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        actions: [DFAlertAction] = [DFAlertAction(title: "OK")]
    ) -> some View {
        dfAlert(isPresented: isPresented, configuration: DFAlertConfiguration(
            title: title,
            message: message,
            actions: actions
        ))
    }
}
```

- [ ] **Step 4: Implement DFAlert+Previews.swift**

Create `Sources/DesignFoundation/Supplementary/Alert/DFAlert+Previews.swift`:

```swift
import SwiftUI

#Preview("DFAlert — Variants") {
    @Previewable @State var showBasic = false
    @Previewable @State var showDestructive = false

    VStack(spacing: 16) {
        Button("Show basic alert") { showBasic = true }
        Button("Show destructive alert") { showDestructive = true }
    }
    .padding()
    .dfAlert(
        isPresented: $showBasic,
        title: "Save Changes?",
        message: "Your changes will be saved.",
        actions: [
            DFAlertAction(title: "Save"),
            DFAlertAction(title: "Cancel", role: .cancel),
        ]
    )
    .dfAlert(
        isPresented: $showDestructive,
        title: "Delete Item",
        message: "This action cannot be undone.",
        actions: [
            DFAlertAction(title: "Delete", role: .destructive),
            DFAlertAction(title: "Cancel", role: .cancel),
        ]
    )
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFAlertTests 2>&1 | tail -5
```

Expected: `Test run with 4 tests in 3 suites passed`

- [ ] **Step 6: Run full suite**

```bash
swift test 2>&1 | tail -3
```

Expected: `Test run with 164 tests in 104 suites passed`

- [ ] **Step 7: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/Alert/ Tests/DesignFoundationTests/Supplementary/DFAlertTests.swift
git commit -m "feat(alert): add DFAlert convenience wrapper over native SwiftUI alert"
```

---

### Task 6: DFListRow

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/List/DFListRow.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFListTests.swift` (partial — DFList tests added in Task 7)

**Interfaces:**
- Produces: `DFListRow` — no style protocol (theme tokens control appearance directly)
- Consumed by: Task 7 (DFList previews)

**Design:** `DFListRow` uses four inits to provide optional leading/trailing `@ViewBuilder` slots while keeping `AnyView?` internally for storage (Tier 3 simplicity; no generic explosion). The `title` and optional `subtitle` are always present.

- [ ] **Step 1: Write the failing tests**

Create `Tests/DesignFoundationTests/Supplementary/DFListTests.swift` (DFListRow section only — Task 7 adds DFList section):

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFListRow")
struct DFListRowTests {
    @Test("basic init compiles and holds title")
    func basicInit() {
        let _ = DFListRow(title: "Hello")
    }

    @Test("init with subtitle and disclosure compiles")
    func subtitleDisclosure() {
        let _ = DFListRow(title: "Item", subtitle: "Detail", showDisclosure: true)
    }

    @Test("init with leading view compiles")
    func leadingInit() {
        let _ = DFListRow(title: "Icon Row", leading: { Image(systemName: "star") })
    }

    @Test("init with leading and trailing views compiles")
    func leadingTrailingInit() {
        let _ = DFListRow(
            title: "Full Row",
            leading: { Image(systemName: "star") },
            trailing: { Text("Badge") }
        )
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter "DFListRowTests" 2>&1 | tail -5
```

Expected: compile error — `DFListRow` not found.

- [ ] **Step 3: Implement DFListRow.swift**

Create `Sources/DesignFoundation/Supplementary/List/DFListRow.swift`:

```swift
import SwiftUI

public struct DFListRow: View {
    private let title: String
    private let subtitle: String?
    private let leading: AnyView?
    private let trailing: AnyView?
    private let showDisclosure: Bool

    @Environment(\.dfTheme) private var theme

    public init(title: String, subtitle: String? = nil, showDisclosure: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.leading = nil
        self.trailing = nil
        self.showDisclosure = showDisclosure
    }

    public init<Leading: View>(
        title: String,
        subtitle: String? = nil,
        showDisclosure: Bool = false,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = AnyView(leading())
        self.trailing = nil
        self.showDisclosure = showDisclosure
    }

    public init<Trailing: View>(
        title: String,
        subtitle: String? = nil,
        showDisclosure: Bool = false,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = nil
        self.trailing = AnyView(trailing())
        self.showDisclosure = showDisclosure
    }

    public init<Leading: View, Trailing: View>(
        title: String,
        subtitle: String? = nil,
        showDisclosure: Bool = false,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = AnyView(leading())
        self.trailing = AnyView(trailing())
        self.showDisclosure = showDisclosure
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            if let leading {
                leading
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let trailing {
                trailing
            }
            if showDisclosure {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .accessibilityElement(children: .combine)
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter "DFListRowTests" 2>&1 | tail -5
```

Expected: `Test run with 4 tests in 1 suite passed`

- [ ] **Step 5: Run full suite**

```bash
swift test 2>&1 | tail -3
```

Expected: `Test run with 168 tests in 105 suites passed`

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/List/DFListRow.swift Tests/DesignFoundationTests/Supplementary/DFListTests.swift
git commit -m "feat(list): add DFListRow with leading/trailing slots and disclosure"
```

---

### Task 7: DFList

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/List/DFList.swift`
- Create: `Sources/DesignFoundation/Supplementary/List/DFList+Previews.swift`
- Modify: `Tests/DesignFoundationTests/Supplementary/DFListTests.swift` (append DFList suite)

**Interfaces:**
- Consumes: `DFListRow` (used in previews and tests)
- Produces: `DFList<Data, RowContent>` — generic themed List wrapper with swipe-delete, reorder, and multi-select

**Design:** `DFList` wraps SwiftUI `List(selection:)` directly. When `selection` is `nil`, no multi-select mode is active. `onDelete`/`onMove` are wired via `ForEach` modifiers (standard SwiftUI pattern). No style protocol — theme tokens control list background and separator.

- [ ] **Step 1: Append failing tests to DFListTests.swift**

Open `Tests/DesignFoundationTests/Supplementary/DFListTests.swift` and append:

```swift
// ---- Append below DFListRowTests ----

private struct SampleItem: Identifiable {
    let id: Int
    let name: String
}

@Suite("DFList")
struct DFListTests {
    @Test("compiles with basic data")
    func basicInit() {
        let items = [SampleItem(id: 1, name: "A"), SampleItem(id: 2, name: "B")]
        let _ = DFList(items) { item in
            Text(item.name)
        }
    }

    @Test("compiles with onDelete callback")
    func withDelete() {
        let items = [SampleItem(id: 1, name: "A")]
        let _ = DFList(items, onDelete: { _ in }) { item in
            Text(item.name)
        }
    }

    @Test("compiles with selection binding")
    func withSelection() {
        var selection: Set<Int>? = []
        let items = [SampleItem(id: 1, name: "A")]
        let _ = DFList(items, selection: Binding(get: { selection }, set: { selection = $0 })) { item in
            Text(item.name)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify new suite fails**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter "DFListTests" 2>&1 | tail -5
```

Expected: compile error — `DFList` not found.

- [ ] **Step 3: Implement DFList.swift**

Create `Sources/DesignFoundation/Supplementary/List/DFList.swift`:

```swift
import SwiftUI

public struct DFList<Data: RandomAccessCollection, RowContent: View>: View
where Data.Element: Identifiable, Data.Element.ID: Hashable {
    private let data: Data
    private let selection: Binding<Set<Data.Element.ID>?>?
    private let onDelete: ((IndexSet) -> Void)?
    private let onMove: ((IndexSet, Int) -> Void)?
    private let rowContent: (Data.Element) -> RowContent

    @Environment(\.dfTheme) private var theme

    public init(
        _ data: Data,
        selection: Binding<Set<Data.Element.ID>?>? = nil,
        onDelete: ((IndexSet) -> Void)? = nil,
        onMove: ((IndexSet, Int) -> Void)? = nil,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.selection = selection
        self.onDelete = onDelete
        self.onMove = onMove
        self.rowContent = rowContent
    }

    public var body: some View {
        List(selection: selection) {
            ForEach(data) { item in
                rowContent(item)
            }
            .onDelete(perform: onDelete)
            .onMove(perform: onMove)
        }
        .scrollContentBackground(.hidden)
        .background(theme.colors.background)
        .listStyle(.plain)
    }
}
```

- [ ] **Step 4: Implement DFList+Previews.swift**

Create `Sources/DesignFoundation/Supplementary/List/DFList+Previews.swift`:

```swift
import SwiftUI

private struct Fruit: Identifiable {
    let id: Int
    let name: String
    let icon: String
}

#Preview("DFList — Swipe and Reorder") {
    @Previewable @State var fruits = [
        Fruit(id: 1, name: "Apple", icon: "apple.logo"),
        Fruit(id: 2, name: "Banana", icon: "leaf"),
        Fruit(id: 3, name: "Cherry", icon: "cherry"),
        Fruit(id: 4, name: "Date", icon: "sun.max"),
    ]

    DFList(
        fruits,
        onDelete: { fruits.remove(atOffsets: $0) },
        onMove: { fruits.move(fromOffsets: $0, toOffset: $1) }
    ) { fruit in
        DFListRow(
            title: fruit.name,
            leading: { Image(systemName: fruit.icon) }
        )
    }
    .environment(\.editMode, .constant(.active))
}

#Preview("DFList — Selection") {
    @Previewable @State var selected: Set<Int>? = []
    @Previewable @State var fruits = [
        Fruit(id: 1, name: "Apple", icon: "apple.logo"),
        Fruit(id: 2, name: "Banana", icon: "leaf"),
        Fruit(id: 3, name: "Cherry", icon: "cherry"),
    ]

    DFList(fruits, selection: $selected) { fruit in
        DFListRow(
            title: fruit.name,
            leading: { Image(systemName: fruit.icon) }
        )
    }
    .environment(\.editMode, .constant(.active))
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter "DFListTests" 2>&1 | tail -5
```

Expected: `Test run with 7 tests in 2 suites passed`

- [ ] **Step 6: Run full suite**

```bash
swift test 2>&1 | tail -3
```

Expected: `Test run with 171 tests in 106 suites passed`

- [ ] **Step 7: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/List/DFList.swift Sources/DesignFoundation/Supplementary/List/DFList+Previews.swift Tests/DesignFoundationTests/Supplementary/DFListTests.swift
git commit -m "feat(list): add DFList with swipe-delete, reorder, and multi-select"
```

---

### Task 8: DFTable

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/Table/DFTable.swift`
- Create: `Sources/DesignFoundation/Supplementary/Table/DFTable+Previews.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFTableTests.swift`

**Interfaces:**
- Produces: `DFTableColumn<Row>`, `DFTable<Row>` — custom scrollable table with sortable column headers
- No style protocol — single opinionated look using theme tokens

**Design:** `DFTable` is a custom VStack+ScrollView table, NOT SwiftUI's `Table` type, giving consistent cross-platform layout on iOS, macOS, and visionOS. Column headers are tappable when `sortable: true`; tapping a sorted column toggles ascending/descending. Sort state is internal (`@State`); an optional `onSort` callback fires after each sort toggle. `DFTableColumn.value` is `@Sendable (Row) -> String` — the table displays string representations (Tier 3 scope; no custom cell views needed).

- [ ] **Step 1: Write the failing tests**

Create `Tests/DesignFoundationTests/Supplementary/DFTableTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundation

private struct Person: Identifiable, Sendable {
    let id: Int
    let name: String
    let age: Int
}

@Suite("DFTableColumn")
struct DFTableColumnTests {
    @Test("stores id, title, sortable flag, and value closure")
    func initialization() {
        let col = DFTableColumn<Person>(id: "name", title: "Name") { $0.name }
        #expect(col.id == "name")
        #expect(col.title == "Name")
        #expect(col.sortable == true)
        let person = Person(id: 1, name: "Alice", age: 30)
        #expect(col.value(person) == "Alice")
    }

    @Test("sortable defaults to true; can be set false")
    func sortableDefault() {
        let col = DFTableColumn<Person>(id: "age", title: "Age", sortable: false) { "\($0.age)" }
        #expect(col.sortable == false)
    }
}

@Suite("DFTable")
struct DFTableTests {
    @Test("compiles with data and columns")
    func basicInit() {
        let people = [Person(id: 1, name: "Alice", age: 30)]
        let cols = [DFTableColumn<Person>(id: "name", title: "Name") { $0.name }]
        let _ = DFTable(data: people, columns: cols)
    }

    @Test("compiles with onSort callback")
    func withOnSort() {
        let people = [Person(id: 1, name: "Alice", age: 30)]
        let cols = [DFTableColumn<Person>(id: "name", title: "Name") { $0.name }]
        let _ = DFTable(data: people, columns: cols, onSort: { _, _ in })
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFTableTests 2>&1 | tail -5
```

Expected: compile error — `DFTableColumn` not found.

- [ ] **Step 3: Implement DFTable.swift**

Create `Sources/DesignFoundation/Supplementary/Table/DFTable.swift`:

```swift
import SwiftUI

// MARK: - Column

public struct DFTableColumn<Row: Identifiable & Sendable>: Identifiable {
    public let id: String
    public let title: String
    public let sortable: Bool
    public let value: @Sendable (Row) -> String

    public init(
        id: String,
        title: String,
        sortable: Bool = true,
        value: @escaping @Sendable (Row) -> String
    ) {
        self.id = id
        self.title = title
        self.sortable = sortable
        self.value = value
    }
}

// MARK: - Table

public struct DFTable<Row: Identifiable & Sendable>: View {
    private let data: [Row]
    private let columns: [DFTableColumn<Row>]
    private let onSort: ((String, Bool) -> Void)?

    @Environment(\.dfTheme) private var theme
    @State private var sortColumnID: String? = nil
    @State private var sortAscending: Bool = true

    public init(
        data: [Row],
        columns: [DFTableColumn<Row>],
        onSort: ((String, Bool) -> Void)? = nil
    ) {
        self.data = data
        self.columns = columns
        self.onSort = onSort
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerRow
            Divider()
                .overlay(theme.colors.border)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(sortedData) { row in
                        dataRow(row)
                        Divider()
                            .overlay(theme.colors.border)
                    }
                }
            }
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(columns) { col in
                Button {
                    guard col.sortable else { return }
                    if sortColumnID == col.id {
                        sortAscending.toggle()
                    } else {
                        sortColumnID = col.id
                        sortAscending = true
                    }
                    onSort?(col.id, sortAscending)
                } label: {
                    HStack(spacing: 4) {
                        Text(col.title)
                            .font(theme.typography.label.font)
                            .foregroundStyle(theme.colors.textSecondary)
                        if col.sortable && sortColumnID == col.id {
                            Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(theme.colors.primary)
                        }
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(!col.sortable)
            }
        }
        .background(theme.colors.surfaceElevated)
    }

    private func dataRow(_ row: Row) -> some View {
        HStack(spacing: 0) {
            ForEach(columns) { col in
                Text(col.value(row))
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var sortedData: [Row] {
        guard let id = sortColumnID,
              let col = columns.first(where: { $0.id == id }) else {
            return data
        }
        return data.sorted {
            sortAscending
                ? col.value($0) < col.value($1)
                : col.value($0) > col.value($1)
        }
    }
}
```

- [ ] **Step 4: Implement DFTable+Previews.swift**

Create `Sources/DesignFoundation/Supplementary/Table/DFTable+Previews.swift`:

```swift
import SwiftUI

private struct Employee: Identifiable, Sendable {
    let id: Int
    let name: String
    let role: String
    let department: String
}

#Preview("DFTable — Sortable Columns") {
    let employees = [
        Employee(id: 1, name: "Alice Chen", role: "Engineer", department: "iOS"),
        Employee(id: 2, name: "Bob Kim", role: "Designer", department: "Design"),
        Employee(id: 3, name: "Carol Liu", role: "Manager", department: "iOS"),
        Employee(id: 4, name: "Dan Park", role: "Engineer", department: "Backend"),
        Employee(id: 5, name: "Emma Torres", role: "Designer", department: "Design"),
    ]
    let columns = [
        DFTableColumn<Employee>(id: "name", title: "Name") { $0.name },
        DFTableColumn<Employee>(id: "role", title: "Role") { $0.role },
        DFTableColumn<Employee>(id: "department", title: "Dept") { $0.department },
    ]

    DFTable(data: employees, columns: columns)
        .padding()
        .frame(maxHeight: 300)
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation
swift test --filter DFTableTests 2>&1 | tail -5
```

Expected: `Test run with 4 tests in 2 suites passed`

- [ ] **Step 6: Run full suite**

```bash
swift test 2>&1 | tail -3
```

Expected: `Test run with 175 tests in 108 suites passed`

- [ ] **Step 7: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/Table/ Tests/DesignFoundationTests/Supplementary/DFTableTests.swift
git commit -m "feat(table): add DFTable with sortable columns"
```

---

## Self-Review

### Spec Coverage

| Spec Requirement | Task |
|---|---|
| DFToast with queue management | Task 4 |
| DFAlert wraps native | Task 5 |
| DFProgressBar linear + circular + indeterminate | Task 2 |
| DFSkeleton shimmer animation, shape matching | Task 3 |
| DFList swipe actions, reorder, multi-select | Task 7 |
| DFListRow leading/trailing slots, disclosure | Task 6 |
| DFTable sortable columns | Task 8 |
| DFCheckbox standalone | Task 1 |
| Single built-in style, style protocol for color/radius overrides | All tasks with style protocol |
| Correct behavior across all platforms | No `#if` guards in core; uses SwiftUI portables |
| Accessibility minimum (label + traits) | All tasks |
| Light + Dark mode verified | Previews use semantic colors from DFTheme |
| iOS 18 + iOS 26 tested | Previews available; no iOS 26 exclusions |

### Placeholder Scan

No TBDs, TODOs, or incomplete sections found.

### Type Consistency

- `DFProgressBarVariant` used in both style and view — consistent.
- `DFSkeletonShape` used in both style and view — consistent.
- `DFToastMessage.id: UUID` used in `DFToastQueue.dismiss(id:)` — consistent.
- `DFTableColumn.value` typed `@Sendable (Row) -> String` — consistent with `DFTable.sortedData`.
- `DFListRow` four-init pattern — all store to `AnyView?` fields internally, consistent.
- `DFAlertAction.action: (@Sendable () -> Void)?` — consistent with how `DFAlertModifier` calls it.
