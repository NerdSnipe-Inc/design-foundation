# Changelog

All notable changes to DesignFoundation are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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

[0.6.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.6.0
[0.5.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.5.0
[0.4.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.4.0
[0.3.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.3.0
[0.2.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.2.0
[0.1.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.1.0
