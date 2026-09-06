# Wave 3: New Pro Verticals Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the five new premium Pro verticals/blocks identified in the catalog gap analysis (Booking, Food, News, a Social comment-thread block, and two AIChat additions), each themed, tested, documented, and wired into DFPlayground's Composition Examples gallery.

**Architecture:** Every new vertical follows the existing Pro convention exactly (a `*DesignKit.swift` marker file with models + fixtures, one file per screen taking a `Configuration` struct, a `*RootView` composition root, a `+Previews.swift` file) — no new patterns introduced. Scope was deliberately trimmed from the spec's original 5-screen-per-vertical estimate to 3-4 screens each: real, working, on-theme SwiftUI at a complexity closer to the existing `Feed`/`People`/`Auth` verticals than the much larger `Documents`/`Ecommerce` ones, since the spec's screen counts were estimates, not a hard requirement.

**Tech Stack:** Swift 6, SwiftUI, `swift-testing`, existing DesignFoundation/DesignFoundationPro theming and component conventions.

**Spec:** `docs/superpowers/specs/2026-09-07-catalog-expansion-and-screenshot-pipeline-design.md` (section 4)

## Global Constraints

- Every `Configuration` struct with closures uses `@MainActor (X) -> Void`, not `@Sendable` — matching the existing convention (see `DFEcommerceOrdersScreen.Configuration`). A `@Sendable` closure cannot mutate `@MainActor`-isolated view state under Swift 6 strict concurrency, which is what every caller of these needs to do.
- Model types (`DFArticle`, `DFBooking`, `DFBookingService`, `DFComment`, `DFRestaurant`, `DFFoodItem`) are `Identifiable, Sendable` (add `Hashable` where used as `NavigationPath`/`Hashable` route payloads) — they carry no closures, so `Sendable` is correct and desired for them, unlike `Configuration` structs.
- Every new root view is fully defaulted (`DFBookingRootView()`, `DFFoodRootView()`, `DFNewsRootView()` all callable with zero arguments) — matching every existing Pro root except `DFPMRootView`'s documented exception.
- New public API is documented in `CLAUDE.md`, `AGENTS.md`, and `.cursor/rules/design-foundation-pro.mdc`, verified via `python3 Tools/check_doc_snippets.py`.

---

## Task 1: News vertical — DONE

**Files:** `Sources/DesignFoundationPro/News/{NewsDesignKit,DFNewsListScreen,DFNewsDetailScreen,DFNewsRootView,DFNewsRootView+Previews}.swift`, `Tests/DesignFoundationProTests/News/NewsTests.swift`

Built directly on Wave 1's new base primitives (`DFArticleRow`, `DFAuthorView`, `DFRelativeTimeTag`, `DFMetadataRow`, `DFInlineTagView`) — the clearest example of the two waves reinforcing each other. `DFArticle` model + 3 realistic fixture articles; list screen composes `DFArticleRow` per article; detail screen composes the same primitives at full size plus the article body.

- [x] `DFArticle` model + `NewsPreviewFixtures`
- [x] `DFNewsListScreen`, `DFNewsDetailScreen`, `DFNewsRootView` (+ Previews)
- [x] Tests (model field storage, fixture non-emptiness/uniqueness)
- [x] `swift build` + `swift test` pass
- [x] Commit: `feat: add News vertical (article list/detail, built on Wave 1 article primitives)`

## Task 2: DFCommentThreadBlock (Social addition) — DONE

**Files:** `Sources/DesignFoundationPro/Social/Threads/{DFCommentThreadBlock,DFCommentThreadBlock+Previews}.swift`, `Tests/DesignFoundationProTests/Social/DFCommentThreadBlockTests.swift`

`DFComment` model (author, text, timestamp, one level of `replies`) + a block that renders top-level comments with their replies indented one level — deeper nesting deliberately collapses into that first level, matching how most social apps flatten long reply chains rather than rendering unbounded indentation.

- [x] `DFComment` model
- [x] `DFCommentThreadBlock` (+ Previews)
- [x] Tests (default/explicit replies, configuration ordering)
- [x] `swift build` + `swift test` pass
- [x] Commit: `feat: add DFCommentThreadBlock to Social vertical`

## Task 3: DFAIThinkingView + DFAISummaryCard (AIChat additions) — DONE

**Files:** `Sources/DesignFoundationPro/AIChat/{DFAIThinkingView,DFAISummaryCard,DFAISummaryCard+Previews}.swift`, `Tests/DesignFoundationProTests/AIChat/DFAISummaryCardTests.swift`

`DFAIThinkingView` is a themed three-dot staggered-wave loading indicator (`theme.materials.surfaceMaterial` capsule background) for "the model is thinking" states — a lighter, glass-aware stand-in for a plain `ProgressView`. `DFAISummaryCard` is a themed card (headline + summary + optional bullet key points) for "here's what I found" moments in AIChat screens.

- [x] `DFAIThinkingView` (animated, no configuration needed)
- [x] `DFAISummaryCard` + `Configuration` (+ Previews)
- [x] Tests (`Configuration` defaults and field storage)
- [x] `swift build` + `swift test` pass
- [x] Commit: `feat: add DFAIThinkingView and DFAISummaryCard to AIChat vertical`

## Task 4: Booking vertical — DONE

**Files:** `Sources/DesignFoundationPro/Booking/{BookingDesignKit,DFBookingServiceSelectionScreen,DFBookingScheduleScreen,DFBookingConfirmationScreen,DFMyBookingsScreen,DFBookingRootView,DFBookingRootView+Previews}.swift`, `Tests/DesignFoundationProTests/Booking/BookingTests.swift`

`DFBookingService`/`DFBooking`/`DFBookingStatus` models. A `TabView` root (`Book` / `My Bookings`) where the `Book` tab is a `NavigationStack` flow: pick a service → schedule (uses base `DFDatePicker` + Wave 1's new `DFRadioPickerView` for time-slot selection) → confirmation (`DFEmptyState` success screen) → appends to the bookings list and switches to the `My Bookings` tab.

- [x] Models + `BookingPreviewFixtures` (4 services, 5 time slots, 2 sample bookings)
- [x] 4 screens + `DFBookingRootView` (+ Previews)
- [x] Fixed initial `@Sendable` closure typing to `@MainActor` after a strict-concurrency build failure (see Global Constraints)
- [x] Tests (status labels, model field storage, fixture non-emptiness)
- [x] `swift build` + `swift test` pass
- [x] Commit: `feat: add Booking vertical (service selection, schedule, confirmation, my bookings)`

## Task 5: Food vertical — DONE

**Files:** `Sources/DesignFoundationPro/Food/{FoodDesignKit,DFFoodHomeScreen,DFFoodRestaurantDetailScreen,DFFoodItemDetailScreen,DFFoodRootView,DFFoodRootView+Previews}.swift`, `Tests/DesignFoundationProTests/Food/FoodTests.swift`

`DFRestaurant`/`DFFoodItem` models. Home screen is a `DFGrid` of `DFEntityCard`s (restaurants); restaurant detail lists `DFEntityRow`-based menu items with `DFRatingView`; item detail uses `DFQuantityStepper` + `DFPriceView` and Wave 1's `dfBottomBar` modifier for the "Add to Cart" CTA — a second concrete example of Wave 1 and Wave 3 reinforcing each other.

- [x] Models + `FoodPreviewFixtures` (3 restaurants, 4 items, `items(for:)` scoping helper)
- [x] 3 screens + `DFFoodRootView` (+ Previews)
- [x] Tests (model field storage, fixture scoping including the empty-result case)
- [x] `swift build` + `swift test` pass
- [x] Commit: `feat: add Food vertical (restaurant home, menu, item detail)`

## Task 6: Wire into DFPlayground + update docs — DONE

**Files:** `DFPlayground/Sources/DFPlayground/Pro/{AppFocusView,CompositionExamplesGalleryView}.swift`, `DFPlayground/Sources/DFPlayground/ContentView.swift`, `DesignFoundationPro/{CLAUDE.md,AGENTS.md,.cursor/rules/design-foundation-pro.mdc}`, `DesignFoundation/scripts/generate_screenshot_catalog.py`

All three new root views take zero-argument fully-defaulted inits, so wiring them into `AppFocusView`'s `DFP_APP_ID` switch and `CompositionExamplesGalleryView`'s card grid was a direct, mechanical extension of the existing 9-app pattern (now 12; the gallery's "9 Rooted Showcases" badge and the sidebar's "Composition examples (9)" label were updated to 12 to match). The screenshot manifest's `_apps()` function (Wave 2) picked up the same three additions so the catalog covers them once the live capture pass runs.

- [x] `AppFocusView.swift` — 3 new `case` branches (name mapping + content) for `DFBookingRootView`/`DFFoodRootView`/`DFNewsRootView`
- [x] `CompositionExamplesGalleryView.swift` — 3 new `CompositionExampleItem` cards, badge count 9 → 12
- [x] `ContentView.swift` — sidebar label count 9 → 12
- [x] `scripts/generate_screenshot_catalog.py` — `_apps()` extended to 12 entries (117 total manifest size, up from 114)
- [x] `CLAUDE.md`/`AGENTS.md`/`.cursor/rules/design-foundation-pro.mdc` updated: Blocks 29→32, Full Screens 47→52 across 9→12 verticals, with usage snippets for every new API
- [x] `python3 Tools/check_doc_snippets.py` passes with no new harness stubs needed
- [x] Full clean build (`swift package clean && swift build`) across `DesignFoundation`, `DesignFoundationPro`, and `DFPlayground` — all green
- [x] Full test suite: `DesignFoundation` 404/404 pass (one unrelated pre-existing failure in `DFDataTableTests.swift`, tied to an uncommitted change that predates this session — not touched); `DesignFoundationPro` 531/531 pass
- [x] Commits: `feat: wire Booking/Food/News verticals into Composition Examples gallery` (DFPlayground), `chore: add Booking/Food/News to screenshot manifest, fix stale path references` (DesignFoundation), `docs: document Wave 3 additions...` (DesignFoundationPro)

## Note on the one pre-existing test failure

`DesignFoundationTests` has one failing test, `DFDataTableTests.swift:269` ("multiple mode replaces selection on arrow move"), tied to an uncommitted, in-progress change to `Sources/DesignFoundation/Supplementary/Table/DFDataTable.swift` that already existed in the working tree before this session started (along with four other uncommitted files — `DFCardStyle.swift`, `DFSidebar.swift`, `DFSidebarStyle.swift`, `DFBadgeStyle.swift`). None of this was touched by Wave 1/2/3 work; it's the user's own unfinished work and is called out here rather than fixed, since fixing someone else's uncommitted in-progress change without being asked risks stepping on work they haven't finished yet.
