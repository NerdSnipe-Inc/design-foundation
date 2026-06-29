# DesignFoundationScreens — Plan Index

> **Living document.** Each structural layer and vertical has its own plan file.
> Update status here as phases complete. Add new verticals by creating a plan file and linking below.

---

## Package

**`DesignFoundationScreens`** — private Swift Package at `/Users/nerdsnipe/Projects/DesignFoundationScreens/`
Depends on: `DesignFoundation` + `DesignFoundationBlocks`
Package setup is Task 1 of the [Sidebar Shells plan](sidebar-shells.md).

---

## Global Constraints (apply to every plan below)

- Swift 6 strict concurrency, `StrictConcurrency` experimental feature ON
- Platforms: iOS 18, macOS 15, visionOS 2
- Every screen is user-centered and launch-ready — not an "example implementation"
- All tokens from `@Environment(\.dfTheme)` — zero hardcoded values
- Compose from existing blocks wherever possible before writing new views
- Action closures: `@MainActor () -> Void` (or `@MainActor (T) -> Void`)
- Light + dark `#Preview` for every screen
- Adaptive where appropriate: sidebar/split on iPad+Mac, tab bar on iPhone
- Tests: Swift Testing only (`import Testing`, `@Suite`, `@Test`, `#expect`)
- No external dependencies beyond DesignFoundation + DesignFoundationBlocks
- Commit messages: conventional commits (`feat(screens): …`)

---

## Available Blocks (from DesignFoundationBlocks)

**Auth:** DFWelcomeBlock, DFSignInBlock, DFSignUpBlock, DFForgotPasswordBlock, DFOTPBlock
**Onboarding:** DFFeatureCarouselBlock, DFPermissionRequestBlock, DFPlanSelectionBlock, DFSuccessBlock
**Dashboard:** DFStatCardBlock, DFMetricGridBlock, DFProgressRingBlock, DFChartPlaceholderBlock
**Feed:** DFActivityFeedBlock, DFActivityFeedRow
**People:** DFContactRow, DFProfileHeaderBlock
**Forms:** DFTagPickerBlock, DFDateRangeBlock, DFAddressBlock, DFMultiStepFormBlock
**Lists:** DFSearchResultsBlock
**Notifications:** DFNotificationCell
**Settings:** DFSettingsSectionBlock, DFAccountBlock, DFNotificationPreferencesBlock, DFDangerZoneBlock
**Loading:** DFBlockSkeletonBlock
**Empty State:** DFEmptyStateBlock

---

## Phase 1 — Structural Shells

These are the navigation containers everything else lives inside. Build these first.

| Plan | Status | Screens |
|---|---|---|
| [Sidebar Shells](sidebar-shells.md) | ⬜ Not started | 18 sidebar/navigation shell variants |

---

## Phase 2 — Verticals

Each vertical is a complete, launch-ready app section. Order is priority order.

| Plan | Status | Screens |
|---|---|---|
| [CRM](crm.md) | ⬜ Not started | Home/Today, Contacts, Contact Detail, Pipeline, Deal Detail, Analytics |
| [Project Manager](project-manager.md) | ⬜ Not started | Home, Board, Task Detail, List View, Timeline, Team |
| [AI Chat](ai-chat.md) | ⬜ Not started | Thread View, New Chat, Multi-model, Settings Sheet |
| [Analytics Dashboard](analytics-dashboard.md) | ⬜ Not started | Overview, Revenue, Users, Events Feed |
| [Settings App](settings-app.md) | ⬜ Not started | Account, Billing, Team, Notifications, Security, Danger Zone |
| [Onboarding Flow](onboarding-flow.md) | ⬜ Not started | Welcome → SignUp → OTP → Permissions → Plan → Success → Home |
| [Social / Feed](social-feed.md) | ⬜ Not started | Feed, Profile, Notifications, Explore |
| [Document / Notes](document-notes.md) | ⬜ Not started | Note List + Editor, Folder Browser, Editor Full Screen |
| [E-commerce](ecommerce.md) | ⬜ Not started | Orders, Order Detail, Products, Revenue |

---

## Status Key

| Symbol | Meaning |
|---|---|
| ⬜ | Not started |
| 🔄 | In progress |
| ✅ | Complete |
| 🚧 | Blocked |
