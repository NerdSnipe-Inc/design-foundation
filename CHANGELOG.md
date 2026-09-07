# Changelog

All notable changes to DesignFoundation are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

## [1.4.0] — 2026-09-07 — Content Primitives & Screenshot Catalog

### Added
- **`DFArticleRow`, `DFAuthorView`, `DFRelativeTimeTag`, `DFInlineTagView`, `DFMetadataRow`** (`Supplementary/Article/`): a small family of content-row primitives for feeds/news/docs lists — title + author + relative time + tags, composable standalone or together. `DFRelativeTimeTag` formats via `RelativeDateTimeFormatter`; `DFInlineTagView` is a decorative pill distinct from `DFChip` (no selection/dismiss state).
- **`DFBottomContainer` / `.dfBottomBar { }`** (`Layouts/BottomContainer/`): pins content (a checkout total, a "Continue" CTA) to the bottom of a view on a themed surface.
- **`DFRadioPickerView`** (`Inputs/RadioPicker/`): single-select inline list of labeled radio rows, distinct from `DFPicker`'s menu/wheel presentation.
- **`DFImageGallery` / `.dfImageGallery(isPresented:images:)`** (`Overlays/ImageGallery/`): full-screen swipeable image viewer with a page indicator.
- **`DFComponentTokens` expanded:** two new per-component override structs — `DFArticleRowTokens`, `DFBottomContainerTokens`.
- **Screenshot catalog** (`Content/index.md`, `scripts/generate_screenshot_catalog.py`): a framed, browsable screenshot of every DFPlayground screen/gallery, Pro block, Pro screen, and shell layout — 117 entries, grouped by category, cross-linked with a matching index in `DesignFoundationPro`. Regenerate with `python3 scripts/generate_screenshot_catalog.py` (drives the real desktop for several minutes; see the script's docstring for details). A `df-screenshot-cataloger` subagent (`.claude/agents/`) wraps the safety rules around running it.

## [1.3.3] — 2026-08-20 — Logo Image Size

### Fixed
- Optimized the repo's logo image asset (`docs/images/design-foundation-logo.png`, ~405KB → ~186KB). No public API changes.

## [1.3.2] — 2026-08-19 — SPM Resolution Fix

### Fixed
- **Package graph failed to resolve on a fresh checkout:** the `DocSnippetCheck` target's `path` (`Package.swift`) pointed at `Scripts/DocSnippetCheck/Generated`, a directory that was never actually committed — only its gitignored `snippet_*.swift` contents existed locally, and on this repo's case-insensitive dev machines that silently folded into the already-tracked lowercase `scripts/` directory, masking the problem. On a case-sensitive clone (Swift Package Index's builders included) `resolvePackageDependencies` failed outright with `invalid custom path 'Scripts/DocSnippetCheck/Generated' for target 'DocSnippetCheck'`, breaking `swift package resolve`/`swift build` for every consumer of the package — see the [1.3.1 SPI build log](https://swiftpackageindex.com/NerdSnipe-Inc/design-foundation/builds). Fixed by aligning every reference (`Package.swift`, `.gitignore`, `scripts/check_doc_snippets.py`, `.github/workflows/doc-snippets.yml`) to the one directory that actually exists — lowercase `scripts/` — and committing a tracked `Placeholder.swift` so `scripts/DocSnippetCheck/Generated` is never empty on a fresh checkout. No public API changes.

## [1.3.1] — 2026-08-18 — Button Branding & Card Scroll Fix

### Added
- **`DFBrandedButtonStyle`:** `DFButton`'s internal `ButtonStyle` bridge is now public, so any native `Button` can be branded directly with `.buttonStyle(.df(_:role:))` while keeping its real content — icons via `Label`, custom layouts, anything a plain `Button` supports. Previously only `DFButton`'s `String`-only title was stylable. (#3)

### Fixed
- **`DFCard` blocking scroll:** `DFCard` unconditionally attached `.onTapGesture` and a `simultaneousGesture(DragGesture(minimumDistance: 0))`, even when no `action` was provided. A zero-distance `DragGesture` still participates in gesture resolution regardless of what its handlers do, and was winning against a parent `ScrollView`'s own drag recognizer — silently blocking scrolling in any scrollable stack of non-interactive cards. Both gestures are now only attached when `action != nil`. (#2)

## [1.3.0] — 2026-07-19 — Content & Commerce Components

### Added
- **`DFCalendarView`:** a new themed month-grid calendar primitive (`Supplementary/Calendar/`) — single-date `selection: Binding<Date>`, optional external `displayedMonth` control, `minimumDate`/`maximumDate` bounds with disabled out-of-range days, and a generic `@ViewBuilder dayContent: (Date) -> Content` slot for event dots/badges. Respects `@Environment(\.calendar)`/`\.locale` — no hardcoded first-weekday assumption. Ships one built-in style, `.standard`.
- **`DFEmptyState`:** a free-tier "no results" primitive (`Supplementary/EmptyState/`) — icon + title + optional message + optional action button, all independent optionals beyond the required icon/title. Previously this pattern only existed behind DesignFoundationPro's `DFEmptyStateBlock`.
- **`DFCommandPalette`:** a new Cmd-K-style overlay modifier (`Overlays/CommandPalette/`) — `.dfCommandPalette(isPresented:items:placeholder:onSelect:)`, case-insensitive substring filtering on title/subtitle, and keyboard navigation on macOS (↑/↓ to highlight, Return to select, Escape to dismiss).
- **`DFMaterialTokens` wired in:** `DFTheme.materials: DFMaterialTokens` is now a real theme property, and all 16 `.glass` styles read `theme.materials.surfaceMaterial`/`elevatedMaterial` instead of hardcoding `.regularMaterial`/`.thickMaterial`. Setting `theme.materials.preferLiquidGlass = false` opts every `.glass` style back to its non-glass color-token appearance — useful for accessibility, branding, or pre-26 OS parity testing. `DFMaterialTokens` itself no longer carries an `@available` gate (only the individual `.glass` styles remain iOS/macOS 26+, unchanged).
- **`DFComponentTokens` expanded:** seven new per-component override structs — `DFDividerTokens`, `DFProgressBarTokens`, `DFSkeletonTokens`, `DFToggleTokens`, `DFDatePickerTokens`, `DFSidebarTokens`, `DFTabBarTokens` — following the existing "every field optional, `nil` inherits the theme default" pattern. (Slider, Picker, and NavigationBar were evaluated and intentionally excluded — they're thin native-control wrappers with nothing custom-drawn worth exposing as an override.)
- **`DFChip`:** a new themed chip/tag primitive (`Primitives/Chip/`) — variants `.label`, `.labelWithIcon`, `.dismissible(onDismiss:)`, `.selectable(isSelected:)`; styles `.filled` (default), `.tinted`, `.outlined`. Closes a real gap versus competing SwiftUI component libraries that we had no answer for.
- **`DFRatingView`:** a new themed rating primitive (`Primitives/Rating/`) — `.stars` (default, half-star support) and `.numeric` styles; `.readOnly` and `.interactive(onChange:)` modes, the latter exposing a VoiceOver-adjustable action.
- **`DFPriceView` / `DFPriceSummaryView`:** currency-formatted price display (`Primitives/Price/`, locale-aware via `Decimal.formatted(.currency(code:))`) with an optional strikethrough `compareAtAmount`, plus a line-item order-summary layout (`Layouts/PriceSummary/`) built from `DFPriceLineItem`s with a `.total` emphasis row.
- **`DFEntityRow` / `DFEntityCard`:** a new themed "media + title/subtitle + trailing metadata" summary pair (`Layouts/EntityRow/`) for contacts, orders, and search-result-shaped content — deliberately distinct from `DFListRow` (which stays a plain structural row with arbitrary leading/trailing views and no styling). `DFEntityRow` is the list-context form; `DFEntityCard` is the grid/card-context sibling, built on `DFCard`.
- **`DFGrid` / `DFCarousel`:** themed `LazyVGrid` (`.fixed(Int)` or `.adaptive(minWidth:)` columns) and horizontal-scroll (`Layouts/Grid/`, `Layouts/Carousel/`) container wrappers — no content opinions, spacing read from `DFTheme` unless overridden.
- **`DFQuantityStepper`:** a new themed quantity-stepper input (`Inputs/Stepper/`, named to avoid colliding with SwiftUI's own `Stepper`) — `.bordered` (default) and `.compact` styles, VoiceOver-adjustable.
- **`DFEmptyState` secondary action:** new optional `secondaryActionTitle`/`onSecondaryAction` parameters render a second, ghost-styled button alongside the primary one — covers permission-prompt-shaped two-choice screens (e.g. "Allow" / "Not Now") without introducing a near-duplicate component.
- **`DFBanner`:** a new full-width, persistent, inline banner (`Supplementary/Banner/`) — reuses `DFToastSeverity` (`.info`/`.success`/`.warning`/`.error`), optional action button, optional user-dismiss. Deliberately *not* built on `DFToastQueue` — toast's floating-capsule/auto-dismiss/global-overlay-queue model doesn't fit a banner's full-width/user-dismissed/inline-in-content shape; conflating the two would have meant bolting a persistent mode onto an auto-timeout-only queue. Place `DFBanner` directly in your view hierarchy, the same way `DFAlert`/`DFEmptyState` work.
- **Five theme presets:** `.garnet` was already shipped in code and `CHANGELOG.md`, but README.md, CLAUDE.md, AGENTS.md, `.cursor/rules/design-foundation.mdc`, and the published docs pages still said "four presets" in several places — corrected everywhere to five (`.slate`, `.aurora`, `.copper`, `.sage`, `.garnet`).

### Fixed
- **Swift 6 strict-concurrency build blocker:** `DFProgressBarStyle`, `DFSecureFieldStyle`, `DFSliderStyle`, `DFToggleStyle`, `DFSidebarStyle`, and `DFDatePickerStyle` failed a clean `swift build` on newer toolchains (their `*Style` protocol requirements weren't `@MainActor`, but built-in style implementations called MainActor-isolated SwiftUI statics like `.circular`/`.plain`/`.switch`/`Spacer()`). Fixed by marking each protocol's view-building requirement `@MainActor`, matching the pattern already used by `DFAlert`'s closures. Four test files (`DFTableTests`, `DFListTests`, `DFSidebarTests`, `DFProgressBarTests`, plus the new `DFChipTests`/`DFRatingViewTests`) needed the same `@MainActor` annotation on specific test functions that construct these types directly.
- **Stale `DFTextScale` test assertion:** `DFTextTests.swift` asserted `DFTextScale.allCases.count == 6`; the enum has shipped 8 cases (`display`, `title`, `headline`, `labelLarge`, `body`, `bodySmall`, `label`, `caption`) since `labelLarge`/`bodySmall` were added. Corrected the assertion — unrelated to the concurrency fix above, just test-data drift.

### Docs
- `CLAUDE.md`, `AGENTS.md`, and `.cursor/rules/design-foundation.mdc` updated with reference sections for all of the above, verified against source and mechanically compiled via the doc-snippet CI gate.
- The dedicated `docs/theme-presets/index.html` landing page still needs a Garnet swatch card + screenshot asset (`docs/images/theme-garnet.png` doesn't exist yet) — tracked separately, not done as part of this pass since it needs a real screenshot, not a text fix.

---

## [1.2.0] — 2026-07-05 — Garnet Preset & Verified Documentation

### Added
- **`DFButton` `style:` init parameter:** Convenience initialiser that accepts any `DFButtonStyle` directly — `DFButton("Open", style: .outlined) { }` — in addition to the existing `.dfButtonStyle()` modifier. The modifier path remains unchanged; the init parameter is purely additive and takes precedence over the environment style when set.
- **`.garnet` theme preset:** A fifth preset — bold, saturated red, gallery-clean rather than warm/earthy (contrast with `.copper`). `DFThemePreset.garnet` / `DFTheme.garnetLight` / `DFTheme.garnetDark`.
- **Doc-snippet CI gate:** Every ` ```swift ` code sample in `CLAUDE.md`, `AGENTS.md`, and the Cursor rule is now compiled against the real package on every PR (`Scripts/check_doc_snippets.py`, wired into `.github/workflows/doc-snippets.yml`). A sample that doesn't match the live API now fails CI instead of drifting silently.

### Docs
This release includes a full pass over every AI-agent-facing doc (`CLAUDE.md`, `AGENTS.md`, `.cursor/rules/design-foundation.mdc`) and the published site (`docs/index.html` and friends), verifying every code sample and claim against the current source rather than trusting what was previously written. Highlights:

- **Component reference brought fully in sync with the current API:** button styles, text field/list row accessory closures, skeleton sizing, avatar/badge/card/text initializers, theme preset application, toast queue calls, and the overlay modifiers (`.dfModal()`, `.dfSheet()`, `.dfPopover()`, `.dfTooltip()` — these are view modifiers, not constructible types) all now match the real signatures exactly, and are mechanically re-verified by the new CI gate going forward.
- **New sections for previously under-documented APIs:** `DFFormState` and the five built-in field validators, the six `DFComponentTokens` sub-namespaces (per-component overrides), and `DFPlatformContext` — the actual mechanism behind "no `#if os()` needed" — each now have a real, compiling usage example instead of a passing mention.
- **`DFMaterialTokens` documented as forward-looking:** the type exists for future Liquid Glass customization but isn't wired into `DFTheme` yet — noted explicitly so nobody expects it to configure anything today.
- **Published site (`docs/index.html`):** corrected the component/modifier count (25 components + 6 feedback/overlay modifiers), added the missing token namespaces (Shadows, Animation, Component overrides, Materials) to the Tokens reference, added the `.glass` variant to five component rows that already ship one, corrected `DFDivider`'s real style names, and fixed a `Color(.systemBackground)` example that didn't compile cross-platform. Clarified that DesignFoundation has one commercial add-on (DesignFoundationPro) rather than two, and pointed the "Get Pro access" link at the Pro page instead of an email link.

---

## [1.1.2] — 2026-07-02 — Multiline Text & Typography

This patch rounds out the text input story with a proper multiline field and fills a gap in the type scale that was showing up in real-world layouts.

### Added
- **`DFTextArea`:** Multiline text input styled to match `DFTextField` — same label, placeholder, focus border, validation state, and disabled appearance. Configurable `minLines` / `maxLines` bounds the visible height, and the editor scrolls when content overflows. Closes the last gap in the forms input set.
- **`DFTextScale.labelLarge`:** New scale step between `.headline` and `.label`, rendered as `.callout` semibold. Designed for card section headers, list item titles, and any spot where `.headline` feels too heavy but `.label` doesn't carry enough weight.

### Changed
- **`DFTypographyTokens`:** Added `labelLarge` token with a matching default value so the new scale step is available wherever token access is used.
- **CLAUDE.md component reference:** `DFTextArea` added to the Text Fields section with its full call-site signature and available parameters.

### Docs & Housekeeping
- Added `docs/wiki/Style-System.md` and `wiki/Text-and-Typography.md` — deep-dive references covering the full typography system, color token semantics, and spacing scale.
- Cleaned up stale internal planning documents that had accumulated in `docs/superpowers/plans/`. No public-facing content was removed.
- README updated to reflect current component inventory.

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

[1.2.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/1.2.0
[1.1.2]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/1.1.2
[1.1.1]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/1.1.1
[1.0.3]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/1.0.3
[0.6.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.6.0
[0.5.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.5.0
[0.4.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.4.0
[0.3.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.3.0
[0.2.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.2.0
[0.1.0]: https://github.com/NerdSnipe-Inc/design-foundation/releases/tag/0.1.0
