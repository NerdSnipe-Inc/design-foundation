# Changelog

All notable changes to DesignFoundation are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

<!-- Accumulate here until release — do not tag until product says so. -->

---

## [1.1.1] — 2026-07-01 — Data Tables, Validation, and AI Agent Guidance

### Added
- **`DFDataTable`:** Sortable data table with single/multi-row selection (`Set<ID>`), shared `DFDataTableColumn` API, `@ViewBuilder` empty state slot, optional `filterQuery` for client-side row filtering, `onRowActivate` on Return/double-click (macOS) and tap (iOS), and arrow-key row navigation on macOS. Native SwiftUI `Table` on macOS, scrollable row layout on iOS.
- **`DFDataGrid`:** Power-user grid built on `DFDataTable` patterns — sort, filter, multi-select, bulk toolbar slot, column visibility menu, and inline cell edit with `DFFormState` / `DFFieldValidator`. Supports `.renderAll` lazy stack and `.paged` client windowing via `DFDataGridLargeDatasetStrategy`.
- **Forms validation:** `DFFieldValidator` protocol with built-in `Required`, `Email`, `MinLength`, `MaxLength`, and `Regex` validators. `DFFormState` provides observable state with field keys, values, errors, and touched tracking (`validate()` / `validate(field:)`). `DFValidatedTextField` wraps `DFTextField` with form binding and themed error display via `DFValidationState`.
- **AI agent guidance files:** `CLAUDE.md` and `AGENTS.md` at the package root give AI coding assistants (Claude Code, OpenAI Codex) a full component reference and the rule against building what the package already provides. Cursor rules at `.cursor/rules/design-foundation.mdc` with `alwaysApply: true` on all `.swift` files.

### Changed
- **Docs (`docs/index.html`):** Added `DFValidatedTextField`, `DFDataTable`, and `DFDataGrid` to component tables; added `.glass` style to `DFSidebar` and `DFTabBar` entries; removed stale `DesignFoundationScreens` package reference; updated FAQ to reflect accurate Pro inventory.
- **Docs (`docs/pro/index.html`):** Updated block count 26 → 29; expanded Dashboard block grid to include `DFLineChartBlock`, `DFBarChartBlock`, and `DFDonutChartBlock` as first-class Swift Charts blocks; added Composition Examples section; added cross-platform note to technical contract.
- **Docs (`docs/llms.txt`):** Full rewrite with accurate component list, block count, chart blocks, composition examples, cross-platform behavior, and AI agent file mention.

---

## [1.0.3] — 2026-06-30 — Typography & macOS Surface Tokens

### Fixed
- **DFTypographyTokens:** Replaced fixed point sizes with SwiftUI semantic text styles (`.largeTitle`, `.title2`, `.headline`, `.body`, `.caption`, `.subheadline`) so typography adapts per platform (e.g. macOS body ≈ 13 pt, iOS body ≈ 17 pt). Added role guide doc comment.
- **DFColorTokens (macOS):** Corrected surface hierarchy — `background` uses `textBackgroundColor` (not `windowBackgroundColor`), `surface` uses `controlBackgroundColor`, `surfaceElevated` uses `windowBackgroundColor`. Added doc comments explaining the canvas → grouped surface → elevated card stack.
- **DFColorTokens (iOS):** `interactiveDisabled` uses `systemGray5` for a more visible disabled state.
- **DFButtonStyle:** Removed redundant `.opacity()` on filled buttons (disabled state already handled by `isDisabled`).
- **DFTheme+Slate (light):** Updated Slate light preset test to match deep-navy interactive fill from the Slate differentiation pass.

---

## [0.6.0] — 2026-06-28 — Tier 3 Supplementary

### Added
- `DFTable` with sortable columns
- `DFList` with swipe-delete, reorder, and multi-select
- `DFListRow` with leading/trailing slots and disclosure indicator
- `DFAlert` convenience wrapper over native SwiftUI alert
- `DFToast` with queue management and auto-dismiss
- `DFSkeleton` with shimmer animation
- `DFProgressBar` with linear, circular, and indeterminate variants
- `DFCheckbox` with default style and style protocol

### Fixed
- `DFTable`: accessibility label on sort direction chevron
- `DFTable`: removed unreachable guard in disabled column button

---

## [0.5.0] — 2026-06-28 — Navigation

### Added
- Liquid Glass previews for TabBar, NavigationBar, and Sidebar
- `DFSidebar` with standard and plain styles
- `DFNavigationBar` with standard and transparent styles
- `DFTabBar` with standard and minimal styles

### Fixed
- `DFNavigationBar`: added `Equatable` to `DFNavigationBarDisplayMode`; documented macOS phantom ToolbarItem
- `DFTabBar`: removed dead `DFTabBarGlassButton`, eliminated `AnyView` in glass style, used `@unchecked Sendable`

---

## [0.4.0] — 2026-06-28 — Overlays

### Added
- Liquid Glass styles for Card, Sheet, Modal, Popover, Tooltip, and all Tier 2 input components
- `DFTooltip` with bubble style and placement control
- `DFPopover` with arrow and compact styles
- `DFModal` with dialog and fullscreen presentation
- `DFSheet` with standard and compact styles
- `DFCard` with elevated, outlined, and filled styles

### Fixed
- `DFTooltip`: added missing `.glass` convenience static var to `DFTooltipStyle`
- `DFTooltip`: added `Hashable` conformance to `DFTooltipPlacement`
- `DFSheet`: applied presentation modifiers in `DFStandardSheetStyle` and `DFCompactSheetStyle`

---

## [0.3.0] — 2026-06-28 — Inputs

### Added
- `DFDatePicker` with compact, graphical, and wheel built-in styles
- `DFPicker` with segmented, menu, and wheel built-in styles
- `DFSlider` with standard and labeled built-in styles
- `DFToggle` with switch and checkbox built-in styles
- `DFSecureField` with built-in reveal toggle
- `DFTextField` with outlined and filled built-in styles

### Fixed
- `DFTextField`: single-accessory inits, filled-style disabled stroke
- `DFTextScale.style(from:)` made public; added `Sendable` constraint to all `Any*Style` inits

---

## [0.2.0] — 2026-06-28 — Primitives

### Added
- Liquid Glass built-in styles for `DFButton`, `DFBadge`, and `DFAvatar` (iOS/macOS 26+)
- `DFAvatar` with initials/image sources, presence ring, and 3 built-in styles
- `DFBadge` with numeric, dot, and text variants; 3 built-in styles; accessibility
- `DFDivider` with horizontal/vertical orientations, labeled variant, and 3 built-in styles
- `DFIcon` with SF Symbol and custom image support and 3 built-in styles
- `DFText` with scale system, 3 built-in styles, and accessibility
- `DFButton` with style protocol, 4 built-in styles, and accessibility

### Fixed
- `DFAvatar`: removed `AnyView` double-wrap in body
- `DFBadge`: removed `AnyView` double-wrap, removed redundant `clipShape` from filled style
- `DFDividerStyleConfiguration`: explicit `Sendable` conformance
- `DFIcon`: size resolution priority, `Sendable` conformances, removed `AnyView` double-wrap
- `DFText`: removed `AnyView` double-wrap, fixed accessibility, explicit `Sendable`
- `DFButton`: accessibility, gesture cancellation, opacity consistency, Swift 6 sendability

---

## [0.1.0] — 2026-06-28 — Core Foundation

### Added
- `DFPlatformContext` and `DFPlatformVariant` for adaptive component rendering
- `\.dfTheme` environment key and `.dfTheme()` view modifier
- `DFTheme` root container with value semantics
- `DFMaterialTokens` for iOS/macOS 26+ Liquid Glass
- Per-component token namespaces for all six primitives
- Typography, spacing, radius, shadow, and animation token structs
- `DFColorTokens` with semantic color system
- SPM package targeting iOS 18, macOS 15, visionOS 2

### Fixed
- Resolved strict concurrency in `EnvironmentKey.defaultValue`
- Resolved `horizontalSizeClass` dynamic resolution in `DFThemeModifier`
- Used platform-agnostic system dynamic colors in `DFColorTokens` defaults
- Removed unnecessary `SwiftUI` import from `DFComponentTokens`

---

[1.1.1]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/1.1.1
[1.0.3]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/1.0.3
[0.6.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.6.0
[0.5.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.5.0
[0.4.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.4.0
[0.3.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.3.0
[0.2.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.2.0
[0.1.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.1.0
