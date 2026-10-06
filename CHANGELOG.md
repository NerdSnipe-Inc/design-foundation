# Changelog

All notable changes to DesignFoundation are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

---

## [1.8.0] — 2026-10-06 — iPhone Duo Basics, Search, Accordion, Menu, OTP Field and Steps

Highlights: five new components (`DFSearchField`, `DFAccordion`/`DFAccordionGroup`, `DFMenu`, `DFOTPField`/`DFValidatedOTPField`, `DFStepIndicator`/`DFTimeline`), iPhone Duo basics (`DFArrangement`, `DFReservedRegionReader`) behind an SDK gate, Xcode 26 as the minimum toolchain, and the first working visionOS build.

### Changed
- **Documentation counts are now derived from code.** README, CLAUDE.md, AGENTS.md, the Cursor rule, `docs/llms.txt` and the docs site (including JSON-LD, meta and Open Graph descriptions) state the same figures: 52 components, 13 presentation and layout modifiers, 39 style protocols with 115 built-in styles, 5 theme presets (10 light/dark themes). Replaced the loose "50+" and the outdated "43 components + 9 modifiers". Pro figures quoted in the free docs are 30 blocks (plus 2 AI Chat components), 55 screens across 12 verticals, 18 shells, 12 composition roots.
- Install snippets, `softwareVersion` and release-note links are checked against the newest `CHANGELOG.md` heading; Pro 2.3.0 is documented as requiring DesignFoundation 1.7.1 or later.
- Liquid Glass wording in `docs/llms.txt` is exact: 22 glass styles, 21 through `.glass` plus `DFGlassModalStyle()`. The typography wiki page says eight `DFTextScale` cases, not six. The popup transition list in the README names the real cases (slide, scale, fade, none, asymmetric).

### Fixed
- **visionOS builds.** `DFColorTokens` imported AppKit on every platform except iOS and tvOS, so the package could not compile for visionOS. It now tests `canImport(UIKit)`. The glass previews also guard on `visionOS 26` (visionOS inherits the iOS availability of `.glass`). The popup, toast, menu and OTP glass surfaces called `glassEffect`, which does not exist on visionOS; they now use their material fill there. `DFGlassOTPFieldStyle` is no longer hidden behind the compiler check, so `.glass` exists on every platform for the OTP field too.

### Added
- **iPhone Duo basics** (Xcode 27.1+, iOS/macOS/visionOS 27.1). `DFArrangement(_ kind:primary:secondary:)` is a two-pane layout (`.automatic`, `.split(axes:)`, `.overlay`): SwiftUI's `ArrangementView` on the 27.1 SDK, a plain stack with the same side-by-side/stacked rule everywhere else. `DFReservedRegionReader` hands its content a `DFReservedRegions` (the fold as `.division`, the camera as `.occlusion`, each with `frame`, `margins` and `isActive`) with pure helpers: `isSplit`, `splitAxis`, `panes(in:)` and `intersects(_:kind:)`. `DFPlatformContext` gains `toolbarVerticalEdge: HorizontalEdge?` and `hasVerticalToolbar`, filled in by `.dfTheme()`/`.dfThemePreset()`. New wiki page `wiki/Preparing-for-iPhone-Duo.md`.
- **iPhone Duo is compiled out of older toolchains.** Every 27.1-only symbol sits behind `#if compiler(>=6.4) && canImport(SwiftUI, _version: 8.1) && !targetEnvironment(macCatalyst)` plus `@available(iOS 27.1, macOS 27.1, visionOS 27.1, *)`, so Xcode 26 builds unchanged and the public API is identical on every SDK (regions are simply empty before 27.1). The `8.1` threshold comes from SwiftUI's module version tracking the SDK (SDK 26.0 to 26.5 report 7.0 to 7.5, SDK 18.0 to 18.5 report 6.0 to 6.5).
- **Minimum toolchain is now Xcode 26.** App Store Connect has required Xcode 26 or later for uploads since 2026-04-28, so every shipping app already builds with it. Deployment targets are unchanged (iOS 18, macOS 15, visionOS 2). `README.md`, `CLAUDE.md` and the site metadata now say Xcode 26+.
- **`.github/workflows/build.yml`** builds the package with Xcode 26.6 for macOS, iOS and visionOS and runs the tests; the doc-snippet job now uses Xcode 26.6 as well. Previously only the doc-snippet job compiled Swift, on Xcode 16 for the macOS host.
- **`DFSearchField`**: themed search input with a leading magnifier, a clear button while the text is non-empty, an optional cancel button, an `onSubmit` callback, an optional `isFocused` binding for two-way focus control, separate VoiceOver labels for the field and the clear button, and a 44pt minimum height on iOS. Styled through the new `DFSearchFieldStyle` protocol (`DFSearchFieldStyleConfiguration`, `\.dfSearchFieldStyle`, `.dfSearchFieldStyle(_:)`) with built-in `.outlined` (default), `.filled` and `.glass` (iOS/macOS 26+, honors `theme.materials.preferLiquidGlass`) styles.
- **`DFAccordion` and `DFAccordionGroup`** (`Supplementary/Accordion/`): an expandable section with a header (title, optional subtitle and leading icon, rotating chevron) over collapsible content. Use it controlled (`DFAccordion("Title", isExpanded: $flag) { ... }`), uncontrolled (`DFAccordion("Title") { ... }`) or inside a `DFAccordionGroup` (`DFAccordion("Title", id: "a") { ... }`), which is exclusive-open by default and multi-open with `allowsMultipleExpanded: true`. `DFAccordionGroupState` is the group's open/closed bookkeeping as a pure `Sendable` value type. The header is a VoiceOver button that reports Expanded or Collapsed with a hint and is at least 44pt tall on iOS; Reduce Motion replaces the slide with a short fade.
- **`DFAccordionStyle`** with `DFAccordionStyleConfiguration`, `.dfAccordionStyle(_:)`, the `dfAccordionStyle` environment key and three built-ins: `.standard` (default, divider-separated), `.card` (wrapped in a `DFCard`) and `.plain`. `DFAccordionTokens` (`headerPadding`, `contentPadding`, both optional) is available at `theme.components.accordion`.
- **`DFOTPField`**, a segmented one-time-code input: `DFOTPField(_:text:length:validationState:allowedCharacters:onComplete:)`. One hidden, real text input drives the visual cells, so pasting a whole code (spaces and dashes are stripped, overflow is clamped), the system `.oneTimeCode` autofill, backspace and VoiceOver all work off a single `text` binding. Digits by default (numeric keyboard on iOS) with `.letters`, `.alphanumeric` and `.custom(Set<Character>)` options; `onComplete` fires exactly once at full length and re-arms when the code is edited below it. Error state shows the `DFValidationState` message under the cells, with the accessibility label on the input and the message keeping its own label. Cells are at least 44pt tall on iOS. Styles: `DFOTPFieldStyle` / `DFOTPFieldStyleConfiguration`, `.dfOTPFieldStyle(_:)`, `.outlined` (default), `.filled`, `.underlined`, and `.glass` (iOS/macOS 26, compiled only with the Xcode 26 toolchain, honors `theme.materials.preferLiquidGlass`). `DFValidatedOTPField` binds it to `DFFormState`. The input-sanitizing, clamping, cell-layout and completion logic is the pure `DFOTPCode` value type (with `DFOTPCharacterSet`), unit-tested without SwiftUI. This is the free primitive; DesignFoundation Pro already ships complete OTP verification screens.
- **`DFStepIndicator`** progress steps (`DFStepIndicator(steps:currentIndex:axis:)`, horizontal by default). `DFStep` carries an id, title, optional subtitle, optional SF Symbol and a `hasError` flag. States resolve from `currentIndex` (`.complete` shows a checkmark, `.current` is ringed and bold, `.upcoming` is hollow and muted, `.error` shows an exclamation mark). Horizontal layouts fall back to numbers-only markers when the titles do not fit; vertical layouts show subtitles. Each step reads to VoiceOver as "Step 2 of 4, Shipping, current". Styles via `.dfStepIndicatorStyle(_:)`: `.standard` (default), `.minimal` (dots and a line), `.numbered`. The state logic is a public pure function, `DFStepState.resolve(count:currentIndex:errorIndices:)`, which clamps out-of-range indices and handles empty input. Named `DFStepIndicator` rather than `DFStepper` to stay clear of `DFQuantityStepper`. Pro multi-step forms can adopt this component for their step header.
- **`DFTimeline`** vertical activity and order-tracking layout. `DFTimelineItem` is a value type (title, optional detail, timestamp and SF Symbol, a `DFStepState`, and a `DFEntityTrailing` value), so it takes no arbitrary views, like `DFEntityRow`. Styles via `.dfTimelineStyle(_:)`: `.standard` (default) and `.compact`.
- `DFStepIndicatorTokens` and `DFTimelineTokens` (`markerSize`, `connectorThickness`, all optional) on `DFComponentTokens` as `stepIndicator` and `timeline`.
- **`DFMenu` and `.dfContextMenu(sections:)`.** A themed menu: a trigger button plus a popover-style list built on `.dfPopover` (stays a popover on iPhone), driven by `DFMenuSection` / `DFMenuItem` values (title, optional SF Symbol, `.destructive` role, `isSelected` checkmark, `isDisabled`, `@MainActor` action). Rows are buttons with selected and destructive accessibility, 44pt on iOS, Escape dismisses on macOS. Style system `DFMenuStyle` / `DFMenuStyleConfiguration` / `.dfMenuStyle(_:)` with `.standard` (default), `.compact` and `.glass` (iOS/macOS 26+, honors `theme.materials.preferLiquidGlass`). `.dfContextMenu` builds a native `.contextMenu` from the same sections; native context menus cannot be themed. Pure helpers in `DFMenuLogic`.
- `scripts/count_facts.py` computes every documented number from `Sources/` and can `--check` docs for wrong numeric claims. A `facts-check` CI job runs it over the agent docs, the docs site and the wiki pages.

### Changed (iOS only; macOS and visionOS rendering is unchanged)
- **Touch targets.** `DFTextField`, `DFSecureField` and every `DFButton` style are now at least 44pt tall on iOS (previously about 37–42pt), and the whole box responds to touches. Tapping anywhere in a text or secure field (its padding or label) now focuses it.
- **`DFEntityRow`** trailing `.text` values use the body-small font on iOS instead of caption.

### Fixed
- **Validation messages and field labels for assistive technology (all platforms, not visual).** `DFTextField`, `DFSecureField` and `DFTextArea` put `.accessibilityLabel` on the whole styled container, which overwrote the label of every child, so an `.error(message)` was read as the field's own name and the message was never exposed. The label is now on the field itself and the message keeps its own label.

## [1.7.1] — 2026-09-21 — Xcode 16 Build Fix

### Fixed
- **Popups now build on Xcode 16 / Swift 6.0** (the minimum this package documents). 1.7.0 referenced the iOS/macOS 26 SDK's `Glass` type and a struct `nonisolated(unsafe) let`, neither of which the Xcode 16 toolchain accepts, so 1.7.0 failed to compile there. The Liquid Glass path is now compiled only with the Xcode 26 SDK (`#if compiler(>=6.2)`), and older toolchains render `.glass` popups with the frosted appearance. No API changes. If you resolved 1.7.0 on Xcode 26, nothing changes for you.

## [1.7.0] — 2026-09-21 — Popup Styles, Cards & Toast Styling

### Added
- **Popup surface styles:** `.dfPopupStyle(_:)` now has `.standard` (upgraded: hairline border, layered soft shadow, continuous corners), `.frosted`, `.glass` (iOS/macOS 26, honors `theme.materials.preferLiquidGlass`), `.accent`, `.gradient`, `.inverse`, `.outlined` and `.tinted(_:)` (per `DFToastSeverity`). Colored styles (`.accent`, `.gradient`, filled toasts) resolve a foreground that reaches WCAG AA (4.5:1) on every fill stop, deepening the stops when no single foreground passes (dark schemes deepen pastel brand colors into rich tones), and re-point the subtree's theme and default `DFButton` at it (inverted primary pill, translucent secondary, plain-text tertiary), so plain content stays legible in every preset, light and dark. `DFPopupActions` picks a contrast-safe primary label on normal surfaces too.
- **`DFPopupKind.sheet` / `DFPopupConfiguration.sheet(...)`:** a bottom-anchored, full-width popup with rounded top corners, a grabber and drag-to-dismiss. `DFPopupDrag` uses a longer commit distance for sheets.
- **`DFPopupBackdrop` (`.none` / `.dim` / `.blur`)** via the additive `DFPopupConfiguration.backdrop`. `nil` (default) keeps deriving from `dimsBackground`; a non-nil value wins. `resolvedBackdrop` reports the result.
- **`DFPopupCard`, `DFPopupHeader`, `DFPopupActions`, `DFPopupIconBadge`, `DFPopupAction`:** ready-made popup content with an icon badge or edge-to-edge hero media, title, message, up to three actions and an optional close button.
- **Toast styles:** `.dfToast(style:)` and `.dfToastStyle(_:)` gain `.tinted`, `.filled`, `.inverse`, `.frosted`, `.glass` (26+), `.banner` (full-width, flush, severity stripe) and `.compact`; `.default` is upgraded. `DFToastStyle.layout` (default `.floating`) lets a style ask for a flush host.
- **`DFToastMessage.title` / `actionTitle` / `action`** and matching `DFToastQueue.show(...)` parameters (all optional, existing calls unchanged). Tapping the action runs it, then dismisses the toast (`DFToastStyleConfiguration.performAction()`). New toasts are announced to VoiceOver.
- **`DFAnimationTokens.spring`:** additive spring token used for popup entrances; Reduce Motion falls back to a short fade.
- Escape key dismisses popups on macOS.
- **`.dfToast(style:)`:** styles the toast layer directly. Toasts are drawn in an overlay owned by `.dfToast()`, so they read the environment from outside that modifier: `content.dfToastStyle(.tinted).dfToast()` does **not** restyle them, while `content.dfToast(style: .tinted)` and `content.dfToast().dfToastStyle(.tinted)` do.

### Fixed
- **`DFDataTable` keyboard selection anchor:** arrow-key movement from a multi-row selection anchored on `Set.first`, whose order is arbitrary and differs per process, so it could start from a random selected row. It now anchors on the first selected row in table order (regression test added).

### Docs
- **Popups and toasts documented with real recordings:** a Popups section on the docs site (free and Pro, including a clip index at `docs/videos/popups/MANIFEST.md`), captured from the DFPlayground Popup Lab on iOS 26; the earlier HTML/CSS/JS mock popup demos were removed.
- **README rewritten:** correct install snippet (`.product(name: "DesignFoundation", package: "design-foundation")`; the bare `"DesignFoundation"` shorthand does not resolve against the GitHub URL), corrected counts and style lists and links, and new popup, Pro and sample-app sections.
- **`CLAUDE.md` / `AGENTS.md` / `.cursor/rules` / `docs/llms.txt`:** document the full theme, style and token surface, the popup and toast styles and the `.dfToast(style:)` ordering rule, and corrected Pro counts.
- **Installation and version references** on the docs site (install snippets, integration guide, structured data) now point at 1.7.0 and the `.product(...)` form; the Pro page states exactly which popups accept `display:` and a dismiss reason.
- **Doc snippet checker** (`scripts/check_doc_snippets.py`, `.github/workflows/doc-snippets.yml`) now also compiles the Swift fences in `README.md`.
- **Notarized DFPlayground** download (`docs/DFPlayground.dmg` / `.zip`) refreshed with the new Popup Lab.

## [1.6.0] — 2026-09-21 — Popups & Positioned Toasts

### Added
- **`.dfPopup(isPresented:)` / `.dfPopup(item:)`:** a themed popup engine with three kinds (`.center`, `.toast`, `.floater`), nine `DFPopupPosition` values, slide/scale/fade/none transitions, auto-dismiss, tap / outside-tap / drag-to-dismiss and an optional dimmed backdrop. Configured through `DFPopupConfiguration` (with `.toast(...)` and `.floater(...)` presets), restyled through `DFPopupStyle` (`.dfPopupStyle(_:)`), and tunable per theme via `theme.components.popup` (`DFPopupTokens`). `DFPopupHost` is public for embedding the layer in custom containers.
- **`DFToastMessage.position` / `DFToastQueue.show(...position:)`:** toasts can now appear at any of the nine positions (default `.top`).

### Changed
- **`DFToastQueue` / `.dfToast()`:** now rendered by the popup engine. Source-compatible; toasts additionally support tap-to-dismiss and swipe-to-dismiss toward their edge.

## [1.5.0] — 2026-09-10 — Token Lint Rules, Sidebar & Table Polish

### Added
- **`Tooling/swiftlint-design-foundation-tokens.yml`:** a drop-in SwiftLint `custom_rules` block for consuming apps. DesignFoundation can't make the compiler reject a raw `Color(...)`/`.font(.system(...))`/hardcoded corner-radius literal in a consumer's own views — there's no language mechanism for that — so this ships as an opt-in lint layer instead: flags raw `Color(red:/hue:/white:/hex:)`, named `Color` literals (`.red`, `.gray`, etc.), raw `.font(.system(...))`/`Font.system(...)`, and hardcoded `cornerRadius:` values, all as warnings (regex-based `custom_rules`, not an AST check, so false positives on legitimate raw values are expected and should be silenced per-line, not by disabling the rule). Documented in `CLAUDE.md`/`AGENTS.md`/`.cursor/rules/design-foundation.mdc`, `docs/wiki/Style-System.md`, and the integration checklist. Prompted by a developer question on whether token usage is enforced at compile time — it isn't, and can't be; this is the practical middle ground.

### Fixed
- **`DFElevatedCardStyle`:** a fill + shadow alone read as flat on themes where `surface` and `background` are nearly identical (e.g. `.workspace` on macOS). Added a hairline border and bumped the shadow from `theme.shadows.sm` to `theme.shadows.md` so elevation reads correctly regardless of how close a theme's surface/background tones are.
- **`DFFilledBadgeStyle`:** the `.dot` variant and its capsule background hardcoded `theme.colors.destructive`, so every dot badge rendered red regardless of theme or intended severity. Both now read `theme.colors.primary`.
- **`DFSidebar`:** added `.navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 340)` — previously a sidebar placed in a `NavigationSplitView` column fell back to the system's narrow default width instead of enough room for real nav labels, while still remaining user-resizable.
- **`DFSidebarStyle`** (`.standard`, `.plain`, `.glass`): added `.lineLimit(1)` to item labels — long labels previously wrapped and threw off row height instead of truncating.
- **`DFDataTable`:** `macOSStaticColumnTable` (≤6 columns) drew its own sortable header row, but a native `Table` also draws its own column-title header, so every static-column table on macOS showed two stacked headers — the second reading as a phantom data row. Hidden via `.tableColumnHeaders(.hidden)`.

### Docs
- Documentation for the 21 primitives shipped across 1.3.0/1.4.0 (calendar, chip, rating, price, entity row/card, grid, carousel, quantity stepper, banner, command palette, empty state, and the article/content-row family) was written but never landed on the published site — added to `docs/index.html`, along with the missing 5th `Garnet` theme preset on `docs/theme-presets/index.html`, missing composition roots and style-protocol rows on `docs/integration/index.html`/`docs/wiki/Style-System.md`, and new Booking/Food/News verticals plus corrected block/screen/vertical counts on `docs/pro/index.html`, `docs/use-cases/index.html`, and `docs/foundation-way/index.html`. A 117-shot screenshot catalog (generated in the prior release) is now embedded across these pages instead of sitting unused in `Content/`. Stale Pro stats (block/screen/vertical counts) in `CLAUDE.md`/`AGENTS.md`/`.cursor/rules/design-foundation.mdc` corrected to match.

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
- Cleaned up stale internal planning documents. No public-facing content was removed.
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
