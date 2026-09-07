# Wave 2: Screenshot Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a browsable, framed-screenshot catalog (`Content/index.md`) for every DFPlayground screen, gallery, Pro block, Pro screen, shell layout, and composition example, backed by a real capture pipeline and a dedicated subagent that regenerates it safely.

**Architecture — deviates from the original spec, discovered during implementation:** The spec (section 5.2) proposed adding `swift-snapshot-testing` as a dependency and new XCTest snapshot targets inside `DesignFoundation`/`DesignFoundationPro`. That's architecturally impossible as written — those packages can't depend on `DFPlayground` (the render surface), since `DFPlayground` depends on *them*, not the reverse, so a test target living in either package has no way to see DFPlayground's screens.

Instead: `DFPlayground` already ships headless-automation hooks (`Sources/DFPlayground/AutomationHooks.swift`) that open a specific Pro screen/block/shell/composition-example as its own window when launched with an environment variable (`DFP_SCREEN_ID`, `DFP_BLOCK_ID`, `DFP_SHELL_NAME`, `DFP_APP_ID`), with `DFP_HIDE_MAIN=1` to close the main sidebar window for a clean isolated shot. This plan extends that same mechanism with a `DFP_TAB_ID` variable covering every top-level sidebar destination (all free-tier tabs plus the Pro index galleries and Themes), then drives it directly: launch `swift run` with the right env var, bring the window frontmost via AppleScript (`System Events`), read its on-screen position/size, capture exactly that rect with `screencapture -R`, kill the process, repeat. A single Python script (`scripts/generate_screenshot_catalog.py`) does the driving, the Pillow-based card framing, the per-category strip composites, and the `index.md` generation — one script instead of the spec's three (bash wrapper + capture script + Python post-processor), since there's no longer a separate XCTest step to shell out to.

**Tech Stack:** Python 3 + Pillow (already available, no new dependency), `osascript`/AppleScript, macOS `screencapture`, Swift/SwiftUI (the `DFP_TAB_ID` hook).

**Spec:** `docs/superpowers/specs/2026-09-07-catalog-expansion-and-screenshot-pipeline-design.md` (section 5) — sections 5.2/5.3's exact tooling (swift-snapshot-testing, XCTest targets, bash wrapper) is superseded by this plan; section 5.1 (render surface), 5.4 (subagent), and section 6 (sequencing) still apply as written.

## Global Constraints

- No new Swift package dependencies (avoided by reusing `ImageRenderer`-free, native `screencapture`/AppleScript automation instead of `swift-snapshot-testing`).
- The capture pass drives the real, live desktop for ~15-20 minutes (114 launch/capture/kill cycles) — it must never run unattended/unsupervised. The `df-screenshot-cataloger` subagent enforces this; anyone invoking the underlying script directly must do the same.
- `Content/RawCaptures/` is gitignored (large, ephemeral); `Content/Frames/`, `Content/Groups/`, and `Content/index.md` are committed as the actual deliverable.
- The manifest in `scripts/generate_screenshot_catalog.py` must be kept in sync with `DFPlayground`'s actual `PlaygroundTab` cases and Pro focus-view switch cases — a drift check is part of the subagent's job (see its definition), not a one-time task.

---

## Task 1: `DFP_TAB_ID` headless automation hook

**Files:**
- Modify: `/Users/nerdsnipe/Projects/DFPlayground/Sources/DFPlayground/ContentView.swift`

**Interfaces:**
- Produces: `NavItem.fromID(_ id: String?) -> NavItem?`, and `ContentView.init()` reading `ProcessInfo.processInfo.environment["DFP_TAB_ID"]` to preselect that `NavItem` at launch.

**Status: DONE.** `NavItem.fromID` maps a `PlaygroundTab.rawValue` or one of `"Forms & Validation"`/`"Data Tables"`/`"Pro Blocks"`/`"Pro Screens"`/`"Shell Layouts"`/`"Themes"`/`"Composition Examples"`/`"Welcome"` to the corresponding `NavItem`, falling back to `.welcome` for an unset or unrecognized value. Verified live: `DFP_TAB_ID="Content & Media" swift run` opens directly to the new Wave 1 gallery tab (confirmed via a real screen capture during implementation, not just a build check).

- [x] Add `NavItem.fromID(_:)`
- [x] Add `ContentView.init()` reading `DFP_TAB_ID`
- [x] `swift build` passes
- [x] Live-verified: launching with `DFP_TAB_ID="Content & Media"` actually opens that tab (confirmed by screen capture, not just code inspection)
- [x] Commit: `feat: add DFP_TAB_ID headless automation hook for top-level nav selection`

## Task 2: Capture + framing + index script

**Files:**
- Create: `scripts/generate_screenshot_catalog.py`
- Create: `Content/README.md`
- Create: `../DesignFoundationPro/Content/README.md`
- Modify: `.gitignore` (add `Content/RawCaptures/`)

**Interfaces:**
- Produces: `build_manifest() -> list[CaptureTarget]` (114 entries: 19 top-level nav destinations + 39 Pro screens + 29 Pro blocks + 18 shells + 9 composition-example apps), `run_capture_pass(manifest)` (drives the live desktop), `generate_frames_and_index(manifest)` (pure Pillow + file I/O, no GUI interaction — safe to run standalone via `--skip-capture` against already-captured raw PNGs).

**Status: DONE and validated.** The manifest was cross-checked against the actual `switch` cases in `ScreenFocusView.swift`/`BlockFocusView.swift`/`ShellFocusView.swift`/`AppFocusView.swift` and `PlaygroundTab`'s cases (39/29/18/9/19 respectively — 114 total). The framing/strip/index logic (`generate_frames_and_index`) was validated end-to-end against synthetic placeholder images (not live captures — see Task 3 for why the live capture pass itself was deliberately not run this session): card framing with drop shadow renders correctly, strip composites group by category, and both `Content/index.md` and a cross-linked Pro index generate with correct relative image paths and source-file links. Test artifacts were removed after validation; the script itself is the deliverable.

- [x] `build_manifest()` — 114 entries, cross-checked against DFPlayground's actual source
- [x] `run_capture_pass()` — launches via `swift run`'s built binary directly (not `swift run` itself, to avoid re-triggering an incremental build per entry), activates via AppleScript, captures via `screencapture -R`, tears down via `terminate()`/`pkill`
- [x] `generate_frames_and_index()` — Pillow card framing (rounded rect, drop shadow, corner-clipped screenshot), per-category strip composites, `index.md` with a preview/name/source table per category, cross-linked Pro index
- [x] Syntax-checked (`python3 -m py_compile`) and logic-validated against synthetic images
- [x] `Content/README.md` / Pro's `Content/README.md` explain the folder and how to re-run
- [x] `.gitignore` excludes `Content/RawCaptures/`
- [x] Commit: `feat: add screenshot catalog capture/framing/index pipeline`

## Task 3: Live capture pass — DONE (run with the user present and watching)

**Status: DONE**, after one fix discovered during the run. Initially deferred in this session pending explicit user authorization to take over the screen — see the superseded note below, kept for the record. Once authorized, the run confirmed the earlier concern was real: the first attempt captured a DFPlayground window with a terminal window's text bleeding into the left edge, even though `frontmost` correctly reported DFPlayground. `activate`/`frontmost` guarantee an app is *focused*, not that its window is unobstructed at every pixel of the rect a plain `screencapture -R` samples — another app's floating window can still occlude part of it.

Fix: `hide_other_apps()`/`restore_apps()` (AppleScript `set visible of process ... to false/true`) now hide every other visible app for the duration of the capture pass and restore them afterward (wrapped in `try/finally` so a crash mid-run still restores). The window is also pinned to a fixed position (`{60, 60}`) before each capture so geometry is predictable regardless of where SwiftUI cascades it. Re-ran clean: all 117 targets captured, zero `SKIP`s, all 12 previously-visible apps confirmed restored afterward by comparing the visible-process list before and after.

*Superseded note, kept for the record:* "DEFERRED, by deliberate judgment call... 114 sequential launch/activate/kill cycles (~15-20 minutes of continuous window churn) is not something to run against someone's unattended desktop overnight." — this stood until the user explicitly said to proceed in a later turn, at which point it was run with them present, per that original recommendation.

- [x] Ran `python3 scripts/generate_screenshot_catalog.py` with the user present, after fixing the overlap bug
- [x] Spot-checked several `Content/Frames/*.framed.png` (Foundation, Pro Screens, Pro Blocks, and specifically the three new Wave 3 verticals) — all show real, correct, uncontaminated content
- [x] Committed: `feat: run first full screenshot catalog capture (117 entries)` (DesignFoundation, includes the hide/restore fix), `feat: add generated screenshot catalog index` (DesignFoundationPro)

## Task 4: `df-screenshot-cataloger` subagent

**Files:**
- Create: `.claude/agents/df-screenshot-cataloger.md`

**Status: DONE.** Defines the subagent per spec section 5.4, with an explicit hard rule (matching Task 3's finding) that it must confirm the user is present and has authorized taking over the screen before running a live capture, and otherwise does the read-only build-check + manifest-drift-check + index-diff work only.

- [x] Frontmatter (`name`, `description` with usage examples, `tools`)
- [x] Body: read-only checks always; live capture only when explicitly authorized; manifest-drift detection against DFPlayground's actual source; summary-not-wall-of-output reporting
- [x] Commit: `feat: add df-screenshot-cataloger subagent`

## Addendum: Wave 3 additions

Wave 3 added three new composition-example apps (`DFBookingRootView`, `DFFoodRootView`,
`DFNewsRootView`). The manifest in `scripts/generate_screenshot_catalog.py` (`_apps()`)
was updated accordingly — the catalog now covers 117 entries (was 114), matching
`CompositionExamplesGalleryView.swift`'s updated "12 Rooted Showcases" count. No other
plan text in this file was rewritten; treat the "114"/"9 composition-example apps"
figures above as accurate as of end-of-Wave-2, superseded by this note.
