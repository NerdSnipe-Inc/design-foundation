# Catalog expansion + screenshot pipeline

Status: approved for planning
Owner: Daniel S
Related repos: `DesignFoundation` (this repo), `DesignFoundationPro` (`../DesignFoundationPro`), `DFPlayground` (`../DFPlayground`, catalog/demo app)

## 1. Problem

`DesignFoundation`/`DesignFoundationPro` have no browsable visual catalog — there is no equivalent of a pre-rendered, framed screenshot gallery with a generated index that lets someone evaluate the library without opening Xcode. Separately, a gap analysis identified a handful of genuinely useful primitives missing from the base package, and a few full verticals that would keep the Pro upgrade compelling.

This spec covers: (1) a small set of new base primitives, (2) five new premium verticals/blocks for Pro, (3) a screenshot-generation pipeline (test target + Pillow post-processing) producing framed PNGs and an `index.md`, driven by a dedicated subagent.

## 2. Non-goals

- Adding low-value internals: scroll-offset helpers, micro-wrappers with a trivial native equivalent (chevron/SF-symbol wrappers, card-accessory decorations), an app-icon hero view, a terms-and-conditions text block, or internal dev-tooling screens for design tokens/dynamic type — DFPlayground's `ThemePickerView` already serves that purpose.
- Full 1:1 rebuilding of Cart/Order/Payment/Shipping/Login/SignUp/Profile flows — Pro's existing Ecommerce, Auth, Social, and People verticals already cover this ground. Only incidental polish, not a rewrite, is in scope if a specific gap surfaces during implementation.
- Renaming or restructuring any existing DF/Pro public API. This is additive only.
- Changing the deployment/publishing process for either package (no version bump, no release cut is part of this spec).

## 3. New base primitives (`DesignFoundation`)

Added under `Sources/DesignFoundation/`, following existing folder conventions (a component gets its own subfolder with a `DF*.swift` + `DF*Style.swift` pair where styling varies, matching e.g. `Primitives/Badge/DFBadgeStyle.swift`):

| New component | Location | Purpose |
|---|---|---|
| `DFArticleRow` | `Supplementary/Article/` | Title + author + relative time + tags row, for feeds/news/docs lists |
| `DFAuthorView` | `Supplementary/Article/` | Avatar + name (+ optional subtitle) inline unit, reusable standalone |
| `DFRelativeTimeTag` | `Supplementary/Article/` | Small "3h ago" style tag; takes a `Date`, formats via `RelativeDateTimeFormatter` |
| `DFInlineTagView` | `Supplementary/Article/` | Small pill-style category tag, distinct from `DFChip` (no selection/dismiss state, purely decorative label) |
| `DFMetadataRow` | `Supplementary/Article/` | Horizontal row of small icon+label metadata items (e.g. read time, view count) |
| `DFBottomContainer` | `Layouts/BottomContainer/` | Sticky bottom bar container (view modifier `.dfBottomBar { content }`), for checkout/continue CTAs |
| `DFRadioPickerView` | `Inputs/RadioPicker/` | Single-select list of labeled radio rows, distinct from `DFPicker` (inline list, not a menu/wheel) |
| `DFImageGallery` | `Overlays/ImageGallery/` | Full-screen swipeable image viewer with page indicator, presented via `.dfImageGallery(isPresented:images:)` modifier (overlay, matching the existing overlay-modifier pattern) |

All eight read theme tokens the same way every existing component does (`@Environment(\.dfTheme)`), take `DFComponentTokens`-style overrides only where sizing varies (`DFArticleRowTokens`, `DFBottomContainerTokens` — the others are simple enough to inherit spacing/typography directly), and ship with a doc-snippet-checked usage example added to this file, `AGENTS.md`, and `.cursor/rules/design-foundation.mdc` per the existing CI contract.

## 4. New Pro verticals/blocks (`DesignFoundationPro`)

Added under `Sources/DesignFoundationPro/`, one new top-level folder per vertical (matching e.g. `Ecommerce/`, `Documents/`):

1. **`Booking/`** — new vertical. Screens: service/resource selection, date/time picker step, confirmation, my-bookings list, booking detail. Root entry point `DFBookingRootView` (mirrors `DFEcommerceRootView`'s pattern: fixtures + root view + previews file).
2. **`Food/`** — new vertical, distinct flavor from generic `Ecommerce`. Screens: restaurant home, category browse, restaurant detail, item detail, nearby-restaurants list. Root entry point `DFFoodRootView`.
3. **`News/`** — new vertical built on the new base `DFArticleRow`/`DFAuthorView`/`DFMetadataRow` primitives. Screens: article list, article detail. Root entry point `DFNewsRootView`. Pairs with existing `Social/Feed`.
4. **`Social/Threads/`** (addition to existing vertical, not a new top-level folder) — `DFCommentThreadBlock`, a nested comment/reply view, pluggable into `Social/Feed`'s existing post-detail screen.
5. **`AIChat/`** additions (existing vertical) — `DFAIThinkingView` (a particle-dissolve loading effect, adapted to `DFMaterialTokens`/glass styles) and `DFAISummaryCard` (an AI-generated summary card), both usable standalone or inside the existing AIChat screens.

Each new root-level vertical (Booking, Food, News) follows the existing Pro convention exactly: a `*DesignKit.swift` marker file, a `*PreviewFixtures.swift` with realistic sample data, a `*RootView.swift` + `*RootView+Previews.swift`, and one file per screen under a `Screens/` (or category) subfolder — matching `Ecommerce/`'s and `Documents/`'s existing shape.

## 5. Screenshot pipeline

### 5.1 Render surface

`DFPlayground` (already an executable SwiftUI app depending on both packages by local path) is extended, not replaced. New gallery screens are added under `Sources/DFPlayground/Screens/` for every new base primitive (section 3) and a new `Pro/` gallery view per new vertical (section 4), following the existing `ButtonsScreen`/`ProScreensGalleryView` pattern. Every existing DF/Pro component already has a DFPlayground screen or gallery entry — those are reused as-is.

### 5.2 Snapshot capture

New test targets (one per package, since Pillow post-processing needs raw per-component images regardless of which package they live in):
- `Tests/DesignFoundationSnapshotTests/` (new target in `DesignFoundation`'s `Package.swift`)
- `Tests/DesignFoundationProSnapshotTests/` (new target in `DesignFoundationPro`'s `Package.swift`)

Both add `swift-snapshot-testing` (pointfreeco's `swift-snapshot-testing` package) as a test-only dependency. Each test renders one DFPlayground screen/gallery item to a `UIImage`/`NSImage` snapshot (iPhone 15 Pro simulator, both light and dark theme presets where the component visibly differs) and asserts against a checked-in reference — the assertion is incidental; the checked-in `__Snapshots__/*.png` files *are* the pipeline's raw image source.

### 5.3 Post-processing

A new `scripts/generate_screenshot_catalog.py` (Python 3 + Pillow) runs after the snapshot tests:
1. Reads every PNG under both packages' `__Snapshots__/` directories.
2. Composites each into an iPhone-framed PNG (`*.framed.png`) using standard device-chrome constants (iPhone 15 Pro frame, Dynamic Island, corner radii — these are simulator/device facts, not tied to any particular source).
3. Groups framed shots by category into strip composites (`*.strip.png`, 5-per-row) for quick visual scanning.
4. Writes `Content/index.md` at the `DesignFoundation` repo root: one master index grouped by package → category → component/screen, each row showing the framed thumbnail, the component name, and a relative link to its source file. Pro's own shots also get written to `../DesignFoundationPro/Content/` with a matching per-package index, cross-linked from the master index in `DesignFoundation`.

`Scripts/documentation_generator.sh` (new) runs the test suite for both packages, then the Python script.

### 5.4 The screenshot subagent

A new subagent, `df-screenshot-cataloger`, whose sole job is: run `documentation_generator.sh`, verify no test target failed to produce a snapshot, diff `Content/index.md` for newly-missing or newly-added entries, and report a short summary (counts added/changed/removed) rather than silently regenerating and moving on. It is invoked (a) manually via `/screenshots` or similar, and (b) at the end of each implementation wave in section 6, so the catalog never drifts far from source.

## 6. Sequencing

Three waves, each independently mergeable and each ending with a screenshot-subagent run so the catalog stays current:

1. **Wave 1 — base primitives** (section 3) + DFPlayground galleries for them.
2. **Wave 2 — screenshot pipeline** (section 5): add snapshot-testing dependency, test targets, Pillow script, `Content/index.md` for everything that exists as of Wave 1 (i.e., all current DF/Pro components plus Wave 1's additions). This wave produces the first real deliverable (a browsable catalog) before any new Pro verticals exist, so it has standalone value early.
3. **Wave 3 — Pro verticals** (section 4), one vertical at a time (Booking → Food → News → Social/Threads → AIChat additions), each ending with a screenshot-subagent run.

Each wave gets its own implementation plan via the `writing-plans` skill; this spec is the shared reference for all three.

## 7. Testing

- Existing unit-test conventions for new components (`Tests/DesignFoundationTests/<Category>/`, `Tests/DesignFoundationProTests/<Vertical>/`) — behavior/state tests, not visual.
- New snapshot tests (section 5.2) are the visual regression net; a snapshot diff on PR is the signal a component's appearance changed, independent of the screenshot catalog being regenerated.
- Every new public API gets a compiling doc snippet, checked by the existing `.github/workflows/doc-snippets.yml` / `scripts/DocSnippetCheck` mechanism, in `CLAUDE.md`, `AGENTS.md`, and `.cursor/rules/design-foundation.mdc` (kept in sync per this repo's existing hard rule).

## 8. Open questions for implementation time (not blocking this spec)

- Exact `swift-snapshot-testing` version pin — pick the latest compatible with Swift 6 strict concurrency at implementation time.
- Whether Pro's new verticals need their own `docs/pro/` marketing blurb updates — likely yes, but that's a content task for whoever cuts the next Pro release, not part of this build.
