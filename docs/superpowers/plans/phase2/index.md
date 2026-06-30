# Phase 2 — Screens & Blocks: Master Index

> **For agentic workers:** Use `superpowers:subagent-driven-development` to execute each part in order. Complete all tasks in a part before starting the next. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build 19 production-ready SwiftUI blocks that form the commercial DesignFoundationBlocks product layer.

**Project:** `/Users/nerdsnipe/Projects/DesignFoundationBlocks`

---

## Global Constraints

Apply to every task in every part:

- Swift 6, `StrictConcurrency` enabled on all targets
- Platforms: iOS 18, macOS 15, visionOS 2
- All action closures typed `(@MainActor () -> Void)?`
- Bridge `@MainActor` calls with `Task { @MainActor in action() }` — NEVER `MainActor.assumeIsolated`
- All colors/typography/spacing from `@Environment(\.dfTheme)` — zero hardcoded values
- Color tokens: `.primary`, `.textPrimary`, `.textSecondary`, `.surface`, `.surfaceElevated`, `.border`, `.destructive`, `.success`
- `DFAvatar(_ initials: String)` OR `DFAvatar(image: Image)` — two separate inits, never combined
- `DFBadge(text: String)` — labeled parameter required
- Tests: Swift Testing only — `import Testing`, `@Suite`, `@Test`, `#expect` — NEVER XCTest
- Minimum 4 previews per block: Default Light, Default Dark, + block-specific states
- Configuration pattern: `public struct Configuration` with typed properties
- `@_exported import DesignFoundation` already in package entry point

---

## Development Path

Execute the parts in order. Each part is independent enough to execute without waiting for a later part, but the Dashboard part's `DFActivityFeedBlock` consumes `DFActivityFeedRow` (already built in Phase 1), and the Loading part's `DFSearchResultsBlock` consumes `DFEmptyStateBlock` (already built). All other cross-part dependencies are within-part only.

```
Part 1 → Part 2 → Part 3 → Part 4
```

---

## Part 1 — Dashboard Blocks (Tasks 1–4)

**File:** [part1-dashboard.md](part1-dashboard.md)

| Task | Block | File Path |
|------|-------|-----------|
| 1 | `DFMetricGridBlock` | `Dashboard/DFMetricGridBlock.swift` |
| 2 | `DFActivityFeedBlock` | `Feed/DFActivityFeedBlock.swift` |
| 3 | `DFChartPlaceholderBlock` | `Dashboard/DFChartPlaceholderBlock.swift` |
| 4 | `DFProgressRingBlock` | `Dashboard/DFProgressRingBlock.swift` |

**Key notes:**
- `DFMetricGridBlock` is a `LazyVGrid` wrapper over existing `DFStatCardBlock`
- `DFActivityFeedBlock` consumes the existing `DFActivityFeedRow` — use `.initials:`, `.subtitle:`, `.isUnread:` field names (confirmed from source)
- `DFChartPlaceholderBlock` is generic over `Chart: View` with `@ViewBuilder` init
- `DFProgressRingBlock` uses `Circle().trim` with `.rotationEffect(.degrees(-90))`; clamp value to `0...1`

---

## Part 2 — Auth & Onboarding Blocks (Tasks 5–10)

**File:** [part2-auth-onboarding.md](part2-auth-onboarding.md)

| Task | Block | File Path |
|------|-------|-----------|
| 5 | `DFOTPBlock` | `Auth/DFOTPBlock.swift` |
| 6 | `DFWelcomeBlock` | `Auth/DFWelcomeBlock.swift` |
| 7 | `DFFeatureCarouselBlock` | `Onboarding/DFFeatureCarouselBlock.swift` |
| 8 | `DFPermissionRequestBlock` | `Onboarding/DFPermissionRequestBlock.swift` |
| 9 | `DFPlanSelectionBlock` | `Onboarding/DFPlanSelectionBlock.swift` |
| 10 | `DFSuccessBlock` | `Onboarding/DFSuccessBlock.swift` |

**Key notes:**
- `DFOTPBlock`: hidden `TextField`/`SecureField` with `.textContentType(.oneTimeCode)` + visual digit boxes; auto-submit when `code.count == digitCount`
- `DFFeatureCarouselBlock`: manual themed page dots (HStack of circles) — do NOT use native TabView dots (unthemeable)
- `DFPermissionRequestBlock`: `DFPermissionType` enum provides `defaultIcon`/`defaultTitle`/`defaultDescription`; Configuration overrides are optional
- `DFSuccessBlock`: spring-animated icon entry, `animated: Bool` flag to skip animation

---

## Part 3 — Settings, Lists & Loading Blocks (Tasks 11–15)

**File:** [part3-settings-lists-loading.md](part3-settings-lists-loading.md)

| Task | Block | File Path |
|------|-------|-----------|
| 11 | `DFAccountBlock` | `Settings/DFAccountBlock.swift` |
| 12 | `DFNotificationPreferencesBlock` | `Settings/DFNotificationPreferencesBlock.swift` |
| 13 | `DFDangerZoneBlock` | `Settings/DFDangerZoneBlock.swift` |
| 14 | `DFSearchResultsBlock` | `Lists/DFSearchResultsBlock.swift` |
| 15 | `DFBlockSkeletonBlock` | `Loading/DFBlockSkeletonBlock.swift` |

**Key notes:**
- `DFNotificationPreferencesBlock` and `DFDangerAction` are `@MainActor` due to `Binding<Bool>` not being `Sendable`
- `DFAccountBlock` avatar priority: image > initials > "?" fallback
- `DFDangerZoneBlock` uses `.confirmationDialog` — set `confirmingIndex: Int?` on tap, confirm fires `Task { @MainActor in action() }`, cancel clears it
- `DFBlockSkeletonBlock` uses `DFSkeleton(shape:)` internally — 6 layout cases; use `GeometryReader` (not `UIScreen`) for visionOS-compatible percentage widths

---

## Part 4 — Forms Blocks (Tasks 16–19)

**File:** [part4-forms.md](part4-forms.md)

| Task | Block | File Path |
|------|-------|-----------|
| 16 | `DFTagPickerBlock` | `Forms/DFTagPickerBlock.swift` |
| 17 | `DFDateRangeBlock` | `Forms/DFDateRangeBlock.swift` |
| 18 | `DFAddressBlock` | `Forms/DFAddressBlock.swift` |
| 19 | `DFMultiStepFormBlock` | `Forms/DFMultiStepFormBlock.swift` |

**Key notes:**
- `DFTagPickerBlock`: `LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))])` for pill layout; enforce `maxSelection` on tap
- `DFDateRangeBlock`: end date range constrained to `startDate...Date.distantFuture`; show validation hint in `.destructive` color if end < start
- `DFAddressBlock`: fire `onAddressChange` via `.onChange(of: address)` — one observer, not per-field
- `DFMultiStepFormBlock<Content: View>`: generic over content; Back button hidden on step 0; Next title swaps to `finishTitle` on last step; step progress bar uses ZStack circle indicators with connector `Rectangle` lines

---

## File Layout After Completion

```
Sources/DesignFoundationBlocks/
  Dashboard/
    DFStatCardBlock.swift          ✅ Phase 1
    DFMetricGridBlock.swift        🔲 Task 1
    DFChartPlaceholderBlock.swift  🔲 Task 3
    DFProgressRingBlock.swift      🔲 Task 4
  Feed/
    DFActivityFeedRow.swift        ✅ Phase 1
    DFActivityFeedBlock.swift      🔲 Task 2
  Auth/
    DFSignInBlock.swift            ✅ Phase 1
    DFSignUpBlock.swift            ✅ Phase 1
    DFForgotPasswordBlock.swift    ✅ Phase 1
    DFSocialAuthProvider.swift     ✅ Phase 1
    DFOTPBlock.swift               🔲 Task 5
    DFWelcomeBlock.swift           🔲 Task 6
  Onboarding/
    DFFeatureCarouselBlock.swift   🔲 Task 7
    DFPermissionRequestBlock.swift 🔲 Task 8
    DFPlanSelectionBlock.swift     🔲 Task 9
    DFSuccessBlock.swift           🔲 Task 10
  Settings/
    DFSettingsRow.swift            ✅ Phase 1
    DFSettingsSectionBlock.swift   ✅ Phase 1
    DFAccountBlock.swift           🔲 Task 11
    DFNotificationPreferencesBlock.swift 🔲 Task 12
    DFDangerZoneBlock.swift        🔲 Task 13
  People/
    DFContactRow.swift             ✅ Phase 1
    DFProfileHeaderBlock.swift     ✅ Phase 1
  Notifications/
    DFNotificationCell.swift       ✅ Phase 1
  EmptyState/
    DFEmptyStateBlock.swift        ✅ Phase 1
  Lists/
    DFSearchResultsBlock.swift     🔲 Task 14
  Loading/
    DFBlockSkeletonBlock.swift     🔲 Task 15
  Forms/
    DFTagPickerBlock.swift         🔲 Task 16
    DFDateRangeBlock.swift         🔲 Task 17
    DFAddressBlock.swift           🔲 Task 18
    DFMultiStepFormBlock.swift     🔲 Task 19
```

---

## Progress Ledger

Track completed tasks here as work proceeds:

```
Task 1 (DFMetricGridBlock): 
Task 2 (DFActivityFeedBlock): 
Task 3 (DFChartPlaceholderBlock): 
Task 4 (DFProgressRingBlock): 
Task 5 (DFOTPBlock): 
Task 6 (DFWelcomeBlock): 
Task 7 (DFFeatureCarouselBlock): 
Task 8 (DFPermissionRequestBlock): 
Task 9 (DFPlanSelectionBlock): 
Task 10 (DFSuccessBlock): 
Task 11 (DFAccountBlock): 
Task 12 (DFNotificationPreferencesBlock): 
Task 13 (DFDangerZoneBlock): 
Task 14 (DFSearchResultsBlock): 
Task 15 (DFBlockSkeletonBlock): 
Task 16 (DFTagPickerBlock): 
Task 17 (DFDateRangeBlock): 
Task 18 (DFAddressBlock): 
Task 19 (DFMultiStepFormBlock): 
```
