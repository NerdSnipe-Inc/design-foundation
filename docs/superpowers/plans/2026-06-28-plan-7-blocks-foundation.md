# DesignFoundation Blocks — Launch Set Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `DesignFoundationBlocks`, a **standalone commercial Swift Package** at `/Users/nerdsnipe/Projects/DesignFoundationBlocks/` containing 10 production-ready, fully-themed UI blocks for the most common "I need this by Friday" patterns: empty states, dashboard stats, activity feeds, contacts, profile headers, settings sections, sign-in, sign-up, forgot password, and notification cells.

**Architecture:** A new, independent Swift Package lives at `/Users/nerdsnipe/Projects/DesignFoundationBlocks/`. It declares `DesignFoundation` as a local path dependency during development (`../DesignFoundation`), which will be swapped to the public GitHub URL (`https://github.com/NerdSnipe-Inc/design-foundation`) before commercial release. This keeps the packages in separate git repositories — `design-foundation` is public/MIT, `design-foundation-blocks` is private/commercial. Each block is a self-contained `struct … : View` that accepts a `Configuration` struct and reads all visual tokens from `@Environment(\.dfTheme)`. Action closures use `@MainActor () -> Void`. No external dependencies beyond `DesignFoundation`.

> **All file paths in tasks 2–11 are relative to `/Users/nerdsnipe/Projects/DesignFoundationBlocks/`.** Task 1 creates this package and must complete before any other task runs.

**Tech Stack:** Swift 6, SwiftUI, Swift Testing, `DesignFoundation` (DFTheme, DFButton, DFTextField, DFSecureField, DFAvatar, DFBadge, DFCard, DFText, DFIcon)

---

## Global Constraints

- Swift 6 strict concurrency: `StrictConcurrency` experimental feature ON in all targets
- Platforms: iOS 18.0, macOS 15.0, visionOS 2.0 (mirror DesignFoundation's floor)
- Tests: Swift Testing only (`import Testing`, `@Suite`, `@Test`, `#expect`) — never XCTest
- All colors, typography, spacing, radius from `@Environment(\.dfTheme)` — zero hardcoded values
- Action closures in Configuration structs: `@MainActor () -> Void` (or `@MainActor (T) -> Void`) — configs do NOT declare Sendable conformance (they hold closures + SwiftUI Binding)
- Exception: `DFTrendDirection` (no closures) — declare `Sendable, Equatable`
- Exception: `DFSocialAuthProvider` (closures only, no Binding) — declare `@unchecked Sendable` with comment `// @unchecked Sendable: action is @MainActor-isolated; struct is main-actor-only.`
- Previews: one `#Preview("Light") { … }` and one `#Preview("Dark") { … .colorScheme(.dark) }` per block
- No style protocols for blocks — single opinionated look driven by DFTheme
- Package root: `/Users/nerdsnipe/Projects/DesignFoundationBlocks/` (separate git repo, private)
- Source path: `Sources/DesignFoundationBlocks/` (relative to package root)
- Test path: `Tests/DesignFoundationBlocksTests/` (relative to package root)
- During development: `DesignFoundation` referenced as `.package(path: "../DesignFoundation")` — swap to URL before release
- Commit messages: conventional commits (`feat(blocks): …`, `test(blocks): …`)
- No Co-Author line in any commit

---

## File Map

```
Package.swift                                          ← modify: add DesignFoundationBlocks targets

Sources/DesignFoundationBlocks/
  EmptyState/
    DFEmptyStateBlock.swift
    DFEmptyStateBlock+Previews.swift
  Dashboard/
    DFStatCardBlock.swift                              ← includes DFTrendDirection enum
    DFStatCardBlock+Previews.swift
  Feed/
    DFActivityFeedRow.swift
    DFActivityFeedRow+Previews.swift
  People/
    DFContactRow.swift
    DFContactRow+Previews.swift
    DFProfileHeaderBlock.swift
    DFProfileHeaderBlock+Previews.swift
  Settings/
    DFSettingsRow.swift                                ← DFSettingsRow enum (shared)
    DFSettingsSectionBlock.swift
    DFSettingsSectionBlock+Previews.swift
  Auth/
    DFSocialAuthProvider.swift                         ← shared auth type
    DFSignInBlock.swift
    DFSignInBlock+Previews.swift
    DFSignUpBlock.swift
    DFSignUpBlock+Previews.swift
    DFForgotPasswordBlock.swift
    DFForgotPasswordBlock+Previews.swift
  Notifications/
    DFNotificationCell.swift
    DFNotificationCell+Previews.swift

Tests/DesignFoundationBlocksTests/
  DFEmptyStateBlockTests.swift
  DFStatCardBlockTests.swift
  DFActivityFeedRowTests.swift
  DFContactRowTests.swift
  DFProfileHeaderBlockTests.swift
  DFSettingsSectionBlockTests.swift
  DFSignInBlockTests.swift
  DFSignUpBlockTests.swift
  DFForgotPasswordBlockTests.swift
  DFNotificationCellTests.swift
```

---

### Task 1: Create DesignFoundationBlocks Package

> **Working directory for this task only:** the parent directory `/Users/nerdsnipe/Projects/`, not the DesignFoundation repo. All subsequent tasks run from `/Users/nerdsnipe/Projects/DesignFoundationBlocks/`.

**Files (all created fresh at `/Users/nerdsnipe/Projects/DesignFoundationBlocks/`):**
- Create: `Package.swift`
- Create: `.gitignore`
- Create: `Sources/DesignFoundationBlocks/` (directory scaffold)
- Create: `Tests/DesignFoundationBlocksTests/` (directory scaffold)

**Interfaces:**
- Produces: standalone `DesignFoundationBlocks` Swift Package, importable by later tasks' test files, with `DesignFoundation` as a local path dependency

- [ ] **Step 1: Create the package directory and initialize git**

```bash
mkdir -p /Users/nerdsnipe/Projects/DesignFoundationBlocks
cd /Users/nerdsnipe/Projects/DesignFoundationBlocks
git init
```

- [ ] **Step 2: Create .gitignore**

Create `/Users/nerdsnipe/Projects/DesignFoundationBlocks/.gitignore` with content:

```
.DS_Store
/.build
/Packages
/*.xcodeproj
xcuserdata/
DerivedData/
.swiftpm/configuration/registries.json
.swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata
.netrc
```

- [ ] **Step 3: Create Package.swift**

Create `/Users/nerdsnipe/Projects/DesignFoundationBlocks/Package.swift` with content:

```swift
// swift-tools-version: 6.0
import PackageDescription

// NOTE: During development, DesignFoundation is referenced as a local path dependency.
// Before commercial release, replace the local path dependency with:
//   .package(url: "https://github.com/NerdSnipe-Inc/design-foundation", from: "1.0.0")
let package = Package(
    name: "DesignFoundationBlocks",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "DesignFoundationBlocks", targets: ["DesignFoundationBlocks"])
    ],
    dependencies: [
        .package(path: "../DesignFoundation")
    ],
    targets: [
        .target(
            name: "DesignFoundationBlocks",
            dependencies: [
                .product(name: "DesignFoundation", package: "DesignFoundation")
            ],
            path: "Sources/DesignFoundationBlocks",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "DesignFoundationBlocksTests",
            dependencies: ["DesignFoundationBlocks"],
            path: "Tests/DesignFoundationBlocksTests"
        )
    ]
)
```

- [ ] **Step 4: Create the source and test directory scaffolds**

```bash
mkdir -p /Users/nerdsnipe/Projects/DesignFoundationBlocks/Sources/DesignFoundationBlocks
mkdir -p /Users/nerdsnipe/Projects/DesignFoundationBlocks/Tests/DesignFoundationBlocksTests
```

SPM requires at least one source file to resolve. Create a minimal entry point:

Create `/Users/nerdsnipe/Projects/DesignFoundationBlocks/Sources/DesignFoundationBlocks/DesignFoundationBlocks.swift`:

```swift
// DesignFoundationBlocks — commercial UI block library built on DesignFoundation.
// This file is intentionally minimal; blocks are organized in subdirectories.
@_exported import DesignFoundation
```

- [ ] **Step 5: Verify the package resolves and builds**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationBlocks
swift package resolve
swift build
```

Expected: both exit 0. The `@_exported import DesignFoundation` re-exports the dependency so callers only need `import DesignFoundationBlocks`.

- [ ] **Step 6: Initial commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationBlocks
git add Package.swift .gitignore Sources/ Tests/
git commit -m "feat: init DesignFoundationBlocks package with local DesignFoundation dependency"
```

---

### Task 2: DFEmptyStateBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/EmptyState/DFEmptyStateBlock.swift`
- Create: `Sources/DesignFoundationBlocks/EmptyState/DFEmptyStateBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/DFEmptyStateBlockTests.swift`

**Interfaces:**
- Consumes: `DFTheme` (via `@Environment(\.dfTheme)`), `DFButton` (for optional CTA)
- Produces: `DFEmptyStateBlock` — a centered empty-state view with icon, title, optional message, optional action button

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationBlocksTests/DFEmptyStateBlockTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFEmptyStateBlock")
struct DFEmptyStateBlockTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("message and action are nil by default")
        func defaultsAreNil() {
            let config = DFEmptyStateBlock.Configuration(
                icon: "tray",
                title: "Nothing here"
            )
            #expect(config.message == nil)
            #expect(config.actionTitle == nil)
            #expect(config.onAction == nil)
        }
    }

    @Suite("Configuration custom values")
    struct CustomValueTests {
        @Test("stores all custom values")
        func storesCustomValues() {
            var called = false
            let config = DFEmptyStateBlock.Configuration(
                icon: "magnifyingglass",
                title: "No results",
                message: "Try a different search term.",
                actionTitle: "Clear search",
                onAction: { called = true }
            )
            #expect(config.icon == "magnifyingglass")
            #expect(config.title == "No results")
            #expect(config.message == "Try a different search term.")
            #expect(config.actionTitle == "Clear search")
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let block = DFEmptyStateBlock(configuration: .init(
                icon: "tray",
                title: "Empty"
            ))
            #expect(type(of: block) == DFEmptyStateBlock.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
swift test --filter DFEmptyStateBlockTests 2>&1 | tail -20
```

Expected: compile error — `DFEmptyStateBlock` not found.

- [ ] **Step 3: Implement DFEmptyStateBlock**

```swift
// Sources/DesignFoundationBlocks/EmptyState/DFEmptyStateBlock.swift
import SwiftUI
import DesignFoundation

public struct DFEmptyStateBlock: View {

    public struct Configuration {
        public var icon: String
        public var title: String
        public var message: String?
        public var actionTitle: String?
        public var onAction: (@MainActor () -> Void)?

        public init(
            icon: String,
            title: String,
            message: String? = nil,
            actionTitle: String? = nil,
            onAction: (@MainActor () -> Void)? = nil
        ) {
            self.icon = icon
            self.title = title
            self.message = message
            self.actionTitle = actionTitle
            self.onAction = onAction
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Image(systemName: configuration.icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(theme.colors.textSecondary)

            VStack(spacing: theme.spacing.xs) {
                Text(configuration.title)
                    .font(theme.typography.headline.font)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)

                if let message = configuration.message {
                    Text(message)
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            if let actionTitle = configuration.actionTitle,
               let onAction = configuration.onAction {
                DFButton(actionTitle) { await MainActor.run { onAction() } }
                    .dfButtonStyle(.outlined)
            }
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity)
    }
}
```

- [ ] **Step 4: Add previews**

```swift
// Sources/DesignFoundationBlocks/EmptyState/DFEmptyStateBlock+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    DFEmptyStateBlock(configuration: .init(
        icon: "tray",
        title: "No items yet",
        message: "Add your first item to get started.",
        actionTitle: "Add item",
        onAction: {}
    ))
}

#Preview("Dark") {
    DFEmptyStateBlock(configuration: .init(
        icon: "magnifyingglass",
        title: "No results",
        message: "Try adjusting your search or filters."
    ))
    .colorScheme(.dark)
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
swift test --filter DFEmptyStateBlockTests 2>&1 | tail -10
```

Expected: `Test run with 3 tests passed`

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationBlocks/EmptyState/ Tests/DesignFoundationBlocksTests/DFEmptyStateBlockTests.swift
git commit -m "feat(blocks): add DFEmptyStateBlock"
```

---

### Task 3: DFStatCardBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/Dashboard/DFStatCardBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Dashboard/DFStatCardBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/DFStatCardBlockTests.swift`

**Interfaces:**
- Consumes: `DFTheme`, `DFCard`
- Produces: `DFTrendDirection` (Sendable, Equatable enum); `DFStatCardBlock` — KPI card with value, title, optional trend indicator, optional icon

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationBlocksTests/DFStatCardBlockTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFStatCardBlock")
struct DFStatCardBlockTests {

    @Suite("DFTrendDirection")
    struct TrendDirectionTests {
        @Test("all cases are distinct")
        func allCasesAreDistinct() {
            #expect(DFTrendDirection.up != DFTrendDirection.down)
            #expect(DFTrendDirection.down != DFTrendDirection.neutral)
            #expect(DFTrendDirection.up != DFTrendDirection.neutral)
        }
    }

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("optional fields default to nil, trendDirection defaults to neutral")
        func defaults() {
            let config = DFStatCardBlock.Configuration(
                title: "Revenue",
                value: "$12,400"
            )
            #expect(config.trend == nil)
            #expect(config.trendDirection == .neutral)
            #expect(config.icon == nil)
            #expect(config.onTap == nil)
        }
    }

    @Suite("Configuration custom values")
    struct CustomValueTests {
        @Test("stores all custom values")
        func storesCustomValues() {
            let config = DFStatCardBlock.Configuration(
                title: "MRR",
                value: "$4,200",
                trend: "+8.3%",
                trendDirection: .up,
                icon: "chart.line.uptrend.xyaxis",
                onTap: {}
            )
            #expect(config.title == "MRR")
            #expect(config.value == "$4,200")
            #expect(config.trend == "+8.3%")
            #expect(config.trendDirection == .up)
            #expect(config.icon == "chart.line.uptrend.xyaxis")
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let block = DFStatCardBlock(configuration: .init(
                title: "Users",
                value: "1,234"
            ))
            #expect(type(of: block) == DFStatCardBlock.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
swift test --filter DFStatCardBlockTests 2>&1 | tail -20
```

Expected: compile error — `DFStatCardBlock` not found.

- [ ] **Step 3: Implement DFStatCardBlock**

```swift
// Sources/DesignFoundationBlocks/Dashboard/DFStatCardBlock.swift
import SwiftUI
import DesignFoundation

public enum DFTrendDirection: Sendable, Equatable {
    case up
    case down
    case neutral
}

public struct DFStatCardBlock: View {

    public struct Configuration {
        public var title: String
        public var value: String
        public var trend: String?
        public var trendDirection: DFTrendDirection
        public var icon: String?
        public var onTap: (@MainActor () -> Void)?

        public init(
            title: String,
            value: String,
            trend: String? = nil,
            trendDirection: DFTrendDirection = .neutral,
            icon: String? = nil,
            onTap: (@MainActor () -> Void)? = nil
        ) {
            self.title = title
            self.value = value
            self.trend = trend
            self.trendDirection = trendDirection
            self.icon = icon
            self.onTap = onTap
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack {
                    Text(configuration.title)
                        .font(theme.typography.label.font)
                        .foregroundStyle(theme.colors.textSecondary)
                    Spacer()
                    if let icon = configuration.icon {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundStyle(theme.colors.primary)
                    }
                }

                Text(configuration.value)
                    .font(theme.typography.title.font)
                    .foregroundStyle(theme.colors.textPrimary)

                if let trend = configuration.trend {
                    HStack(spacing: 4) {
                        Image(systemName: trendIcon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(trendColor)
                        Text(trend)
                            .font(theme.typography.caption.font)
                            .foregroundStyle(trendColor)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Trend: \(trend)")
                }
            }
            .padding(theme.spacing.md)
        }
        .onTapGesture {
            if let onTap = configuration.onTap {
                Task { @MainActor in onTap() }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var trendIcon: String {
        switch configuration.trendDirection {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }

    private var trendColor: Color {
        switch configuration.trendDirection {
        case .up: return theme.colors.success
        case .down: return theme.colors.error
        case .neutral: return theme.colors.textSecondary
        }
    }
}
```

- [ ] **Step 4: Add previews**

```swift
// Sources/DesignFoundationBlocks/Dashboard/DFStatCardBlock+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    HStack(spacing: 12) {
        DFStatCardBlock(configuration: .init(
            title: "Monthly Revenue",
            value: "$12,400",
            trend: "+8.3%",
            trendDirection: .up,
            icon: "chart.line.uptrend.xyaxis"
        ))
        DFStatCardBlock(configuration: .init(
            title: "Churn",
            value: "2.1%",
            trend: "-0.4%",
            trendDirection: .down,
            icon: "arrow.down.right.circle"
        ))
    }
    .padding()
}

#Preview("Dark") {
    DFStatCardBlock(configuration: .init(
        title: "Active Users",
        value: "8,241",
        trend: "+12%",
        trendDirection: .up,
        icon: "person.2"
    ))
    .padding()
    .colorScheme(.dark)
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
swift test --filter DFStatCardBlockTests 2>&1 | tail -10
```

Expected: `Test run with 4 tests passed`

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationBlocks/Dashboard/ Tests/DesignFoundationBlocksTests/DFStatCardBlockTests.swift
git commit -m "feat(blocks): add DFStatCardBlock with DFTrendDirection"
```

---

### Task 4: DFActivityFeedRow

**Files:**
- Create: `Sources/DesignFoundationBlocks/Feed/DFActivityFeedRow.swift`
- Create: `Sources/DesignFoundationBlocks/Feed/DFActivityFeedRow+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/DFActivityFeedRowTests.swift`

**Interfaces:**
- Consumes: `DFTheme`, `DFAvatar`
- Produces: `DFActivityFeedRow` — HStack row with avatar, title+subtitle+timestamp, optional unread indicator

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationBlocksTests/DFActivityFeedRowTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFActivityFeedRow")
struct DFActivityFeedRowTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("optional fields are nil/false by default")
        func defaults() {
            let config = DFActivityFeedRow.Configuration(
                initials: "AB",
                title: "Alice posted a comment",
                timestamp: "2m ago"
            )
            #expect(config.avatarImage == nil)
            #expect(config.subtitle == nil)
            #expect(config.isUnread == false)
            #expect(config.onTap == nil)
        }
    }

    @Suite("Configuration custom values")
    struct CustomValueTests {
        @Test("stores all custom values")
        func storesCustomValues() {
            let config = DFActivityFeedRow.Configuration(
                initials: "CD",
                title: "Charlie mentioned you",
                subtitle: "In project Alpha",
                timestamp: "5m ago",
                isUnread: true,
                onTap: {}
            )
            #expect(config.initials == "CD")
            #expect(config.title == "Charlie mentioned you")
            #expect(config.subtitle == "In project Alpha")
            #expect(config.timestamp == "5m ago")
            #expect(config.isUnread == true)
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let row = DFActivityFeedRow(configuration: .init(
                initials: "EF",
                title: "Event occurred",
                timestamp: "now"
            ))
            #expect(type(of: row) == DFActivityFeedRow.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
swift test --filter DFActivityFeedRowTests 2>&1 | tail -20
```

Expected: compile error.

- [ ] **Step 3: Implement DFActivityFeedRow**

```swift
// Sources/DesignFoundationBlocks/Feed/DFActivityFeedRow.swift
import SwiftUI
import DesignFoundation

public struct DFActivityFeedRow: View {

    public struct Configuration {
        public var initials: String
        public var avatarImage: Image?
        public var title: String
        public var subtitle: String?
        public var timestamp: String
        public var isUnread: Bool
        public var onTap: (@MainActor () -> Void)?

        public init(
            initials: String,
            avatarImage: Image? = nil,
            title: String,
            subtitle: String? = nil,
            timestamp: String,
            isUnread: Bool = false,
            onTap: (@MainActor () -> Void)? = nil
        ) {
            self.initials = initials
            self.avatarImage = avatarImage
            self.title = title
            self.subtitle = subtitle
            self.timestamp = timestamp
            self.isUnread = isUnread
            self.onTap = onTap
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            DFAvatar(initials: configuration.initials, image: configuration.avatarImage)
                .dfAvatarStyle(.circle)

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(configuration.title)
                        .font(
                            configuration.isUnread
                                ? theme.typography.body.font.bold()
                                : theme.typography.body.font
                        )
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(2)
                    Spacer()
                    Text(configuration.timestamp)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                if let subtitle = configuration.subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                }
            }

            if configuration.isUnread {
                Circle()
                    .fill(theme.colors.primary)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
                    .accessibilityLabel("Unread")
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            if let onTap = configuration.onTap {
                Task { @MainActor in onTap() }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(configuration.onTap != nil ? .isButton : [])
    }
}
```

- [ ] **Step 4: Add previews**

```swift
// Sources/DesignFoundationBlocks/Feed/DFActivityFeedRow+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    VStack(spacing: 0) {
        DFActivityFeedRow(configuration: .init(
            initials: "AB",
            title: "Alice commented on your post",
            subtitle: "Looks great, ship it!",
            timestamp: "2m ago",
            isUnread: true
        ))
        Divider()
        DFActivityFeedRow(configuration: .init(
            initials: "CD",
            title: "Charlie invited you to Design Review",
            timestamp: "1h ago"
        ))
    }
    .padding(.horizontal)
}

#Preview("Dark") {
    DFActivityFeedRow(configuration: .init(
        initials: "EF",
        title: "Eve mentioned you in a thread",
        subtitle: "In #engineering",
        timestamp: "3h ago",
        isUnread: true
    ))
    .padding(.horizontal)
    .colorScheme(.dark)
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
swift test --filter DFActivityFeedRowTests 2>&1 | tail -10
```

Expected: `Test run with 3 tests passed`

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationBlocks/Feed/ Tests/DesignFoundationBlocksTests/DFActivityFeedRowTests.swift
git commit -m "feat(blocks): add DFActivityFeedRow"
```

---

### Task 5: DFContactRow

**Files:**
- Create: `Sources/DesignFoundationBlocks/People/DFContactRow.swift`
- Create: `Sources/DesignFoundationBlocks/People/DFContactRow+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/DFContactRowTests.swift`

**Interfaces:**
- Consumes: `DFTheme`, `DFAvatar`, `DFBadge`
- Produces: `DFContactRow` — HStack row with avatar, name+subtitle, optional badge count, tap interaction

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationBlocksTests/DFContactRowTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFContactRow")
struct DFContactRowTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("optional fields are nil by default")
        func defaults() {
            let config = DFContactRow.Configuration(
                name: "Alice Smith",
                initials: "AS"
            )
            #expect(config.subtitle == nil)
            #expect(config.avatarImage == nil)
            #expect(config.badge == nil)
            #expect(config.onTap == nil)
        }
    }

    @Suite("Configuration custom values")
    struct CustomValueTests {
        @Test("stores all custom values")
        func storesCustomValues() {
            let config = DFContactRow.Configuration(
                name: "Bob Jones",
                initials: "BJ",
                subtitle: "Engineering",
                badge: "5",
                onTap: {}
            )
            #expect(config.name == "Bob Jones")
            #expect(config.initials == "BJ")
            #expect(config.subtitle == "Engineering")
            #expect(config.badge == "5")
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let row = DFContactRow(configuration: .init(
                name: "Carol White",
                initials: "CW"
            ))
            #expect(type(of: row) == DFContactRow.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
swift test --filter DFContactRowTests 2>&1 | tail -20
```

Expected: compile error.

- [ ] **Step 3: Implement DFContactRow**

```swift
// Sources/DesignFoundationBlocks/People/DFContactRow.swift
import SwiftUI
import DesignFoundation

public struct DFContactRow: View {

    public struct Configuration {
        public var name: String
        public var initials: String
        public var subtitle: String?
        public var avatarImage: Image?
        public var badge: String?
        public var onTap: (@MainActor () -> Void)?

        public init(
            name: String,
            initials: String,
            subtitle: String? = nil,
            avatarImage: Image? = nil,
            badge: String? = nil,
            onTap: (@MainActor () -> Void)? = nil
        ) {
            self.name = name
            self.initials = initials
            self.subtitle = subtitle
            self.avatarImage = avatarImage
            self.badge = badge
            self.onTap = onTap
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            DFAvatar(initials: configuration.initials, image: configuration.avatarImage)
                .dfAvatarStyle(.circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(configuration.name)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)

                if let subtitle = configuration.subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            Spacer()

            if let badge = configuration.badge {
                DFBadge(badge)
            }

            if configuration.onTap != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(theme.colors.textSecondary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            if let onTap = configuration.onTap {
                Task { @MainActor in onTap() }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(configuration.onTap != nil ? .isButton : [])
    }
}
```

- [ ] **Step 4: Add previews**

```swift
// Sources/DesignFoundationBlocks/People/DFContactRow+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    VStack(spacing: 0) {
        DFContactRow(configuration: .init(
            name: "Alice Smith",
            initials: "AS",
            subtitle: "Product Design",
            badge: "3",
            onTap: {}
        ))
        Divider()
        DFContactRow(configuration: .init(
            name: "Bob Jones",
            initials: "BJ",
            subtitle: "Engineering",
            onTap: {}
        ))
    }
    .padding(.horizontal)
}

#Preview("Dark") {
    DFContactRow(configuration: .init(
        name: "Carol White",
        initials: "CW",
        subtitle: "Marketing",
        badge: "12",
        onTap: {}
    ))
    .padding(.horizontal)
    .colorScheme(.dark)
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
swift test --filter DFContactRowTests 2>&1 | tail -10
```

Expected: `Test run with 3 tests passed`

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationBlocks/People/DFContactRow.swift Sources/DesignFoundationBlocks/People/DFContactRow+Previews.swift Tests/DesignFoundationBlocksTests/DFContactRowTests.swift
git commit -m "feat(blocks): add DFContactRow"
```

---

### Task 6: DFProfileHeaderBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/People/DFProfileHeaderBlock.swift`
- Create: `Sources/DesignFoundationBlocks/People/DFProfileHeaderBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/DFProfileHeaderBlockTests.swift`

**Interfaces:**
- Consumes: `DFTheme`, `DFAvatar`, `DFButton`
- Produces: `DFProfileHeaderBlock` — centered hero with large avatar, name, subtitle, primary + optional secondary CTA

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationBlocksTests/DFProfileHeaderBlockTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFProfileHeaderBlock")
struct DFProfileHeaderBlockTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("optional fields are nil by default")
        func defaults() {
            let config = DFProfileHeaderBlock.Configuration(
                name: "Alice Smith",
                initials: "AS"
            )
            #expect(config.subtitle == nil)
            #expect(config.avatarImage == nil)
            #expect(config.primaryActionTitle == nil)
            #expect(config.secondaryActionTitle == nil)
            #expect(config.onPrimaryAction == nil)
            #expect(config.onSecondaryAction == nil)
        }
    }

    @Suite("Configuration custom values")
    struct CustomValueTests {
        @Test("stores all custom values")
        func storesCustomValues() {
            let config = DFProfileHeaderBlock.Configuration(
                name: "Bob Jones",
                initials: "BJ",
                subtitle: "Senior Engineer",
                primaryActionTitle: "Edit profile",
                secondaryActionTitle: "Share",
                onPrimaryAction: {},
                onSecondaryAction: {}
            )
            #expect(config.name == "Bob Jones")
            #expect(config.subtitle == "Senior Engineer")
            #expect(config.primaryActionTitle == "Edit profile")
            #expect(config.secondaryActionTitle == "Share")
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let block = DFProfileHeaderBlock(configuration: .init(
                name: "Carol White",
                initials: "CW"
            ))
            #expect(type(of: block) == DFProfileHeaderBlock.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
swift test --filter DFProfileHeaderBlockTests 2>&1 | tail -20
```

Expected: compile error.

- [ ] **Step 3: Implement DFProfileHeaderBlock**

```swift
// Sources/DesignFoundationBlocks/People/DFProfileHeaderBlock.swift
import SwiftUI
import DesignFoundation

public struct DFProfileHeaderBlock: View {

    public struct Configuration {
        public var name: String
        public var initials: String
        public var subtitle: String?
        public var avatarImage: Image?
        public var primaryActionTitle: String?
        public var secondaryActionTitle: String?
        public var onPrimaryAction: (@MainActor () -> Void)?
        public var onSecondaryAction: (@MainActor () -> Void)?

        public init(
            name: String,
            initials: String,
            subtitle: String? = nil,
            avatarImage: Image? = nil,
            primaryActionTitle: String? = nil,
            secondaryActionTitle: String? = nil,
            onPrimaryAction: (@MainActor () -> Void)? = nil,
            onSecondaryAction: (@MainActor () -> Void)? = nil
        ) {
            self.name = name
            self.initials = initials
            self.subtitle = subtitle
            self.avatarImage = avatarImage
            self.primaryActionTitle = primaryActionTitle
            self.secondaryActionTitle = secondaryActionTitle
            self.onPrimaryAction = onPrimaryAction
            self.onSecondaryAction = onSecondaryAction
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            DFAvatar(initials: configuration.initials, image: configuration.avatarImage)
                .dfAvatarStyle(.circle)
                .frame(width: 80, height: 80)

            VStack(spacing: theme.spacing.xs) {
                Text(configuration.name)
                    .font(theme.typography.title.font)
                    .foregroundStyle(theme.colors.textPrimary)

                if let subtitle = configuration.subtitle {
                    Text(subtitle)
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            if configuration.primaryActionTitle != nil || configuration.secondaryActionTitle != nil {
                HStack(spacing: theme.spacing.sm) {
                    if let title = configuration.primaryActionTitle,
                       let action = configuration.onPrimaryAction {
                        DFButton(title) { await MainActor.run { action() } }
                    }
                    if let title = configuration.secondaryActionTitle,
                       let action = configuration.onSecondaryAction {
                        DFButton(title) { await MainActor.run { action() } }
                            .dfButtonStyle(.outlined)
                    }
                }
            }
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity)
    }
}
```

- [ ] **Step 4: Add previews**

```swift
// Sources/DesignFoundationBlocks/People/DFProfileHeaderBlock+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    DFProfileHeaderBlock(configuration: .init(
        name: "Alice Smith",
        initials: "AS",
        subtitle: "Product Designer · San Francisco",
        primaryActionTitle: "Edit profile",
        secondaryActionTitle: "Share",
        onPrimaryAction: {},
        onSecondaryAction: {}
    ))
}

#Preview("Dark") {
    DFProfileHeaderBlock(configuration: .init(
        name: "Bob Jones",
        initials: "BJ",
        subtitle: "Senior Engineer"
    ))
    .colorScheme(.dark)
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
swift test --filter DFProfileHeaderBlockTests 2>&1 | tail -10
```

Expected: `Test run with 3 tests passed`

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationBlocks/People/DFProfileHeaderBlock.swift Sources/DesignFoundationBlocks/People/DFProfileHeaderBlock+Previews.swift Tests/DesignFoundationBlocksTests/DFProfileHeaderBlockTests.swift
git commit -m "feat(blocks): add DFProfileHeaderBlock"
```

---

### Task 7: DFSettingsSectionBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/Settings/DFSettingsRow.swift`
- Create: `Sources/DesignFoundationBlocks/Settings/DFSettingsSectionBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Settings/DFSettingsSectionBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/DFSettingsSectionBlockTests.swift`

**Interfaces:**
- Consumes: `DFTheme`
- Produces: `DFSettingsRow` enum (not Sendable — holds closures and Binding); `DFSettingsSectionBlock` — grouped settings section with header, footer, typed rows

Note on `DFSettingsRow`: This enum holds `Binding<Bool>` and `@MainActor () -> Void` closures. It cannot conform to `Sendable`. This is intentional and correct — settings blocks are always used on the main actor.

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationBlocksTests/DFSettingsSectionBlockTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFSettingsSectionBlock")
struct DFSettingsSectionBlockTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("header and footer are nil by default")
        func defaults() {
            let config = DFSettingsSectionBlock.Configuration(rows: [])
            #expect(config.header == nil)
            #expect(config.footer == nil)
            #expect(config.rows.isEmpty)
        }
    }

    @Suite("Configuration row types")
    struct RowTypeTests {
        @Test("navigation row stores title and icon")
        func navigationRow() {
            var tapped = false
            let row = DFSettingsRow.navigation(
                icon: "bell",
                title: "Notifications",
                action: { tapped = true }
            )
            if case .navigation(let icon, let title, _, _) = row {
                #expect(icon == "bell")
                #expect(title == "Notifications")
            } else {
                Issue.record("Expected .navigation case")
            }
        }

        @Test("info row stores value")
        func infoRow() {
            let row = DFSettingsRow.info(icon: "info.circle", title: "Version", value: "1.0.0")
            if case .info(_, _, let value) = row {
                #expect(value == "1.0.0")
            } else {
                Issue.record("Expected .info case")
            }
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let block = DFSettingsSectionBlock(configuration: .init(
                header: "Account",
                rows: [
                    .info(icon: "person", title: "Name", value: "Alice")
                ]
            ))
            #expect(type(of: block) == DFSettingsSectionBlock.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
swift test --filter DFSettingsSectionBlockTests 2>&1 | tail -20
```

Expected: compile error.

- [ ] **Step 3: Implement DFSettingsRow and DFSettingsSectionBlock**

```swift
// Sources/DesignFoundationBlocks/Settings/DFSettingsRow.swift
import SwiftUI

public enum DFSettingsRow {
    case navigation(icon: String, title: String, value: String? = nil, action: @MainActor () -> Void)
    case toggle(icon: String, title: String, isOn: Binding<Bool>)
    case destructive(icon: String, title: String, action: @MainActor () -> Void)
    case info(icon: String, title: String, value: String)
}
```

```swift
// Sources/DesignFoundationBlocks/Settings/DFSettingsSectionBlock.swift
import SwiftUI
import DesignFoundation

public struct DFSettingsSectionBlock: View {

    public struct Configuration {
        public var header: String?
        public var footer: String?
        public var rows: [DFSettingsRow]

        public init(header: String? = nil, footer: String? = nil, rows: [DFSettingsRow]) {
            self.header = header
            self.footer = footer
            self.rows = rows
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header = configuration.header {
                Text(header.uppercased())
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.bottom, theme.spacing.xs)
            }

            VStack(spacing: 0) {
                ForEach(Array(configuration.rows.enumerated()), id: \.offset) { index, row in
                    rowView(row)
                    if index < configuration.rows.count - 1 {
                        Divider()
                            .padding(.leading, theme.spacing.md + 28)
                    }
                }
            }
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))

            if let footer = configuration.footer {
                Text(footer)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.top, theme.spacing.xs)
            }
        }
    }

    @ViewBuilder
    private func rowView(_ row: DFSettingsRow) -> some View {
        switch row {
        case .navigation(let icon, let title, let value, let action):
            Button {
                Task { @MainActor in action() }
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    iconView(icon, color: theme.colors.primary)
                    Text(title)
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.textPrimary)
                    Spacer()
                    if let value {
                        Text(value)
                            .font(theme.typography.body.font)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.colors.textSecondary)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
            }
            .buttonStyle(.plain)

        case .toggle(let icon, let title, let isOn):
            HStack(spacing: theme.spacing.sm) {
                iconView(icon, color: theme.colors.primary)
                Text(title)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer()
                Toggle("", isOn: isOn)
                    .labelsHidden()
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)

        case .destructive(let icon, let title, let action):
            Button {
                Task { @MainActor in action() }
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    iconView(icon, color: theme.colors.error)
                    Text(title)
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.error)
                    Spacer()
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
            }
            .buttonStyle(.plain)

        case .info(let icon, let title, let value):
            HStack(spacing: theme.spacing.sm) {
                iconView(icon, color: theme.colors.primary)
                Text(title)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer()
                Text(value)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
        }
    }

    private func iconView(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(color)
            .frame(width: 20)
    }
}
```

- [ ] **Step 4: Add previews**

```swift
// Sources/DesignFoundationBlocks/Settings/DFSettingsSectionBlock+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    @Previewable @State var notificationsOn = true
    ScrollView {
        VStack(spacing: 20) {
            DFSettingsSectionBlock(configuration: .init(
                header: "Account",
                rows: [
                    .navigation(icon: "person.circle", title: "Edit profile", action: {}),
                    .navigation(icon: "lock", title: "Change password", action: {}),
                    .info(icon: "envelope", title: "Email", value: "alice@example.com")
                ]
            ))
            DFSettingsSectionBlock(configuration: .init(
                header: "Preferences",
                footer: "You'll only receive notifications you've enabled.",
                rows: [
                    .toggle(icon: "bell", title: "Push notifications", isOn: $notificationsOn),
                    .navigation(icon: "globe", title: "Language", value: "English", action: {})
                ]
            ))
            DFSettingsSectionBlock(configuration: .init(
                rows: [
                    .destructive(icon: "trash", title: "Delete account", action: {})
                ]
            ))
        }
        .padding()
    }
}

#Preview("Dark") {
    @Previewable @State var enabled = false
    DFSettingsSectionBlock(configuration: .init(
        header: "Notifications",
        rows: [
            .toggle(icon: "bell.badge", title: "Email alerts", isOn: $enabled),
            .navigation(icon: "speaker.wave.2", title: "Sound", value: "Default", action: {})
        ]
    ))
    .padding()
    .colorScheme(.dark)
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
swift test --filter DFSettingsSectionBlockTests 2>&1 | tail -10
```

Expected: `Test run with 3 tests passed`

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationBlocks/Settings/ Tests/DesignFoundationBlocksTests/DFSettingsSectionBlockTests.swift
git commit -m "feat(blocks): add DFSettingsSectionBlock with DFSettingsRow"
```

---

### Task 8: DFSignInBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/Auth/DFSocialAuthProvider.swift`
- Create: `Sources/DesignFoundationBlocks/Auth/DFSignInBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Auth/DFSignInBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/DFSignInBlockTests.swift`

**Interfaces:**
- Consumes: `DFTheme`, `DFTextField`, `DFSecureField`, `DFButton`
- Produces: `DFSocialAuthProvider` (@unchecked Sendable — shared by DFSignInBlock and DFSignUpBlock); `DFSignInBlock` — full sign-in screen with email/password fields, forgot password, optional social auth, optional sign-up link

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationBlocksTests/DFSignInBlockTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFSignInBlock")
struct DFSignInBlockTests {

    @Suite("DFSocialAuthProvider")
    struct SocialAuthProviderTests {
        @Test("stores label and icon")
        func storesValues() {
            let provider = DFSocialAuthProvider(
                label: "Continue with Apple",
                icon: "apple.logo",
                action: {}
            )
            #expect(provider.label == "Continue with Apple")
            #expect(provider.icon == "apple.logo")
        }

        @Test("convenience apple factory sets expected values")
        func appleFactory() {
            let provider = DFSocialAuthProvider.apple(action: {})
            #expect(provider.icon == "apple.logo")
        }

        @Test("convenience google factory sets expected values")
        func googleFactory() {
            let provider = DFSocialAuthProvider.google(action: {})
            #expect(provider.label.lowercased().contains("google"))
        }
    }

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("default text values and empty optional collections")
        func defaults() {
            let config = DFSignInBlock.Configuration(onSubmit: { _, _ in })
            #expect(config.title == "Sign in")
            #expect(config.submitTitle == "Sign in")
            #expect(config.forgotPasswordTitle == "Forgot password?")
            #expect(config.socialProviders.isEmpty)
            #expect(config.onForgotPassword == nil)
            #expect(config.onSignUp == nil)
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let block = DFSignInBlock(configuration: .init(onSubmit: { _, _ in }))
            #expect(type(of: block) == DFSignInBlock.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
swift test --filter DFSignInBlockTests 2>&1 | tail -20
```

Expected: compile error.

- [ ] **Step 3: Implement DFSocialAuthProvider**

```swift
// Sources/DesignFoundationBlocks/Auth/DFSocialAuthProvider.swift
import Foundation

// @unchecked Sendable: action is @MainActor-isolated; struct is main-actor-only.
public struct DFSocialAuthProvider: @unchecked Sendable {
    public let label: String
    public let icon: String
    public let action: @MainActor () -> Void

    public init(label: String, icon: String, action: @escaping @MainActor () -> Void) {
        self.label = label
        self.icon = icon
        self.action = action
    }
}

public extension DFSocialAuthProvider {
    static func apple(action: @escaping @MainActor () -> Void) -> DFSocialAuthProvider {
        DFSocialAuthProvider(label: "Continue with Apple", icon: "apple.logo", action: action)
    }

    static func google(action: @escaping @MainActor () -> Void) -> DFSocialAuthProvider {
        DFSocialAuthProvider(label: "Continue with Google", icon: "g.circle", action: action)
    }
}
```

- [ ] **Step 4: Implement DFSignInBlock**

```swift
// Sources/DesignFoundationBlocks/Auth/DFSignInBlock.swift
import SwiftUI
import DesignFoundation

public struct DFSignInBlock: View {

    public struct Configuration {
        public var title: String
        public var subtitle: String?
        public var submitTitle: String
        public var forgotPasswordTitle: String
        public var signUpPrompt: String?
        public var signUpTitle: String?
        public var socialProviders: [DFSocialAuthProvider]
        public var onSubmit: @MainActor (String, String) -> Void
        public var onForgotPassword: (@MainActor () -> Void)?
        public var onSignUp: (@MainActor () -> Void)?

        public init(
            title: String = "Sign in",
            subtitle: String? = nil,
            submitTitle: String = "Sign in",
            forgotPasswordTitle: String = "Forgot password?",
            signUpPrompt: String? = "Don't have an account?",
            signUpTitle: String? = "Sign up",
            socialProviders: [DFSocialAuthProvider] = [],
            onSubmit: @escaping @MainActor (String, String) -> Void,
            onForgotPassword: (@MainActor () -> Void)? = nil,
            onSignUp: (@MainActor () -> Void)? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.submitTitle = submitTitle
            self.forgotPasswordTitle = forgotPasswordTitle
            self.signUpPrompt = signUpPrompt
            self.signUpTitle = signUpTitle
            self.socialProviders = socialProviders
            self.onSubmit = onSubmit
            self.onForgotPassword = onForgotPassword
            self.onSignUp = onSignUp
        }
    }

    private let configuration: Configuration
    @State private var email: String = ""
    @State private var password: String = ""
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                VStack(spacing: theme.spacing.xs) {
                    Text(configuration.title)
                        .font(theme.typography.title.font)
                        .foregroundStyle(theme.colors.textPrimary)

                    if let subtitle = configuration.subtitle {
                        Text(subtitle)
                            .font(theme.typography.body.font)
                            .foregroundStyle(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }

                VStack(spacing: theme.spacing.sm) {
                    DFTextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif

                    DFSecureField("Password", text: $password)
                        .textContentType(.password)

                    HStack {
                        Spacer()
                        Button(configuration.forgotPasswordTitle) {
                            if let action = configuration.onForgotPassword {
                                Task { @MainActor in action() }
                            }
                        }
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.primary)
                    }
                }

                DFButton(configuration.submitTitle) {
                    let e = email
                    let p = password
                    await MainActor.run { configuration.onSubmit(e, p) }
                }

                if !configuration.socialProviders.isEmpty {
                    HStack {
                        Rectangle().fill(theme.colors.border).frame(height: 1)
                        Text("or")
                            .font(theme.typography.caption.font)
                            .foregroundStyle(theme.colors.textSecondary)
                            .padding(.horizontal, theme.spacing.sm)
                        Rectangle().fill(theme.colors.border).frame(height: 1)
                    }

                    VStack(spacing: theme.spacing.sm) {
                        ForEach(Array(configuration.socialProviders.enumerated()), id: \.offset) { _, provider in
                            Button {
                                Task { @MainActor in provider.action() }
                            } label: {
                                HStack(spacing: theme.spacing.sm) {
                                    Image(systemName: provider.icon)
                                    Text(provider.label)
                                }
                                .font(theme.typography.body.font)
                                .foregroundStyle(theme.colors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, theme.spacing.sm)
                                .background(theme.colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: theme.radius.md)
                                        .stroke(theme.colors.border, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if let prompt = configuration.signUpPrompt,
                   let signUpTitle = configuration.signUpTitle,
                   let onSignUp = configuration.onSignUp {
                    HStack(spacing: 4) {
                        Text(prompt)
                            .font(theme.typography.body.font)
                            .foregroundStyle(theme.colors.textSecondary)
                        Button(signUpTitle) {
                            Task { @MainActor in onSignUp() }
                        }
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.primary)
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
    }
}
```

- [ ] **Step 5: Add previews**

```swift
// Sources/DesignFoundationBlocks/Auth/DFSignInBlock+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    DFSignInBlock(configuration: .init(
        title: "Welcome back",
        subtitle: "Sign in to your account",
        socialProviders: [
            .apple(action: {}),
            .google(action: {})
        ],
        onSubmit: { _, _ in },
        onForgotPassword: {},
        onSignUp: {}
    ))
}

#Preview("Dark") {
    DFSignInBlock(configuration: .init(
        onSubmit: { _, _ in },
        onForgotPassword: {}
    ))
    .colorScheme(.dark)
}
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
swift test --filter DFSignInBlockTests 2>&1 | tail -10
```

Expected: `Test run with 5 tests passed`

- [ ] **Step 7: Commit**

```bash
git add Sources/DesignFoundationBlocks/Auth/DFSocialAuthProvider.swift Sources/DesignFoundationBlocks/Auth/DFSignInBlock.swift Sources/DesignFoundationBlocks/Auth/DFSignInBlock+Previews.swift Tests/DesignFoundationBlocksTests/DFSignInBlockTests.swift
git commit -m "feat(blocks): add DFSignInBlock and DFSocialAuthProvider"
```

---

### Task 9: DFSignUpBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/Auth/DFSignUpBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Auth/DFSignUpBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/DFSignUpBlockTests.swift`

**Interfaces:**
- Consumes: `DFTheme`, `DFTextField`, `DFSecureField`, `DFButton`, `DFSocialAuthProvider` (from Task 8)
- Produces: `DFSignUpBlock` — sign-up screen with name, email, password fields; mirrors DFSignInBlock structure

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationBlocksTests/DFSignUpBlockTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFSignUpBlock")
struct DFSignUpBlockTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("default text values and empty optional collections")
        func defaults() {
            let config = DFSignUpBlock.Configuration(onSubmit: { _, _, _ in })
            #expect(config.title == "Create account")
            #expect(config.submitTitle == "Create account")
            #expect(config.socialProviders.isEmpty)
            #expect(config.onSignIn == nil)
        }
    }

    @Suite("Configuration custom values")
    struct CustomValueTests {
        @Test("stores custom title and subtitle")
        func storesCustomValues() {
            let config = DFSignUpBlock.Configuration(
                title: "Get started",
                subtitle: "Create your free account",
                onSubmit: { _, _, _ in }
            )
            #expect(config.title == "Get started")
            #expect(config.subtitle == "Create your free account")
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let block = DFSignUpBlock(configuration: .init(onSubmit: { _, _, _ in }))
            #expect(type(of: block) == DFSignUpBlock.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
swift test --filter DFSignUpBlockTests 2>&1 | tail -20
```

Expected: compile error.

- [ ] **Step 3: Implement DFSignUpBlock**

```swift
// Sources/DesignFoundationBlocks/Auth/DFSignUpBlock.swift
import SwiftUI
import DesignFoundation

public struct DFSignUpBlock: View {

    public struct Configuration {
        public var title: String
        public var subtitle: String?
        public var submitTitle: String
        public var signInPrompt: String?
        public var signInTitle: String?
        public var socialProviders: [DFSocialAuthProvider]
        public var onSubmit: @MainActor (String, String, String) -> Void  // name, email, password
        public var onSignIn: (@MainActor () -> Void)?

        public init(
            title: String = "Create account",
            subtitle: String? = nil,
            submitTitle: String = "Create account",
            signInPrompt: String? = "Already have an account?",
            signInTitle: String? = "Sign in",
            socialProviders: [DFSocialAuthProvider] = [],
            onSubmit: @escaping @MainActor (String, String, String) -> Void,
            onSignIn: (@MainActor () -> Void)? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.submitTitle = submitTitle
            self.signInPrompt = signInPrompt
            self.signInTitle = signInTitle
            self.socialProviders = socialProviders
            self.onSubmit = onSubmit
            self.onSignIn = onSignIn
        }
    }

    private let configuration: Configuration
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                VStack(spacing: theme.spacing.xs) {
                    Text(configuration.title)
                        .font(theme.typography.title.font)
                        .foregroundStyle(theme.colors.textPrimary)

                    if let subtitle = configuration.subtitle {
                        Text(subtitle)
                            .font(theme.typography.body.font)
                            .foregroundStyle(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }

                VStack(spacing: theme.spacing.sm) {
                    DFTextField("Full name", text: $name)
                        .textContentType(.name)

                    DFTextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif

                    DFSecureField("Password", text: $password)
                        .textContentType(.newPassword)
                }

                DFButton(configuration.submitTitle) {
                    let n = name; let e = email; let p = password
                    await MainActor.run { configuration.onSubmit(n, e, p) }
                }

                if !configuration.socialProviders.isEmpty {
                    HStack {
                        Rectangle().fill(theme.colors.border).frame(height: 1)
                        Text("or")
                            .font(theme.typography.caption.font)
                            .foregroundStyle(theme.colors.textSecondary)
                            .padding(.horizontal, theme.spacing.sm)
                        Rectangle().fill(theme.colors.border).frame(height: 1)
                    }

                    VStack(spacing: theme.spacing.sm) {
                        ForEach(Array(configuration.socialProviders.enumerated()), id: \.offset) { _, provider in
                            Button {
                                Task { @MainActor in provider.action() }
                            } label: {
                                HStack(spacing: theme.spacing.sm) {
                                    Image(systemName: provider.icon)
                                    Text(provider.label)
                                }
                                .font(theme.typography.body.font)
                                .foregroundStyle(theme.colors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, theme.spacing.sm)
                                .background(theme.colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: theme.radius.md)
                                        .stroke(theme.colors.border, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if let prompt = configuration.signInPrompt,
                   let signInTitle = configuration.signInTitle,
                   let onSignIn = configuration.onSignIn {
                    HStack(spacing: 4) {
                        Text(prompt)
                            .font(theme.typography.body.font)
                            .foregroundStyle(theme.colors.textSecondary)
                        Button(signInTitle) {
                            Task { @MainActor in onSignIn() }
                        }
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.primary)
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
    }
}
```

- [ ] **Step 4: Add previews**

```swift
// Sources/DesignFoundationBlocks/Auth/DFSignUpBlock+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    DFSignUpBlock(configuration: .init(
        subtitle: "It's free to get started.",
        socialProviders: [.apple(action: {})],
        onSubmit: { _, _, _ in },
        onSignIn: {}
    ))
}

#Preview("Dark") {
    DFSignUpBlock(configuration: .init(
        onSubmit: { _, _, _ in }
    ))
    .colorScheme(.dark)
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
swift test --filter DFSignUpBlockTests 2>&1 | tail -10
```

Expected: `Test run with 3 tests passed`

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationBlocks/Auth/DFSignUpBlock.swift Sources/DesignFoundationBlocks/Auth/DFSignUpBlock+Previews.swift Tests/DesignFoundationBlocksTests/DFSignUpBlockTests.swift
git commit -m "feat(blocks): add DFSignUpBlock"
```

---

### Task 10: DFForgotPasswordBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/Auth/DFForgotPasswordBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Auth/DFForgotPasswordBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/DFForgotPasswordBlockTests.swift`

**Interfaces:**
- Consumes: `DFTheme`, `DFTextField`, `DFButton`
- Produces: `DFForgotPasswordBlock` — single email field with submit and optional back link

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationBlocksTests/DFForgotPasswordBlockTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFForgotPasswordBlock")
struct DFForgotPasswordBlockTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("default text values match expected strings")
        func defaults() {
            let config = DFForgotPasswordBlock.Configuration(onSubmit: { _ in })
            #expect(config.title == "Reset password")
            #expect(config.submitTitle == "Send reset link")
            #expect(config.backTitle == "Back to sign in")
            #expect(config.onBack == nil)
        }

        @Test("default subtitle is non-nil and non-empty")
        func defaultSubtitleExists() {
            let config = DFForgotPasswordBlock.Configuration(onSubmit: { _ in })
            #expect(config.subtitle != nil)
            #expect(config.subtitle?.isEmpty == false)
        }
    }

    @Suite("Configuration custom values")
    struct CustomValueTests {
        @Test("stores custom title")
        func storesCustomTitle() {
            let config = DFForgotPasswordBlock.Configuration(
                title: "Forgot your password?",
                onSubmit: { _ in }
            )
            #expect(config.title == "Forgot your password?")
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let block = DFForgotPasswordBlock(configuration: .init(onSubmit: { _ in }))
            #expect(type(of: block) == DFForgotPasswordBlock.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
swift test --filter DFForgotPasswordBlockTests 2>&1 | tail -20
```

Expected: compile error.

- [ ] **Step 3: Implement DFForgotPasswordBlock**

```swift
// Sources/DesignFoundationBlocks/Auth/DFForgotPasswordBlock.swift
import SwiftUI
import DesignFoundation

public struct DFForgotPasswordBlock: View {

    public struct Configuration {
        public var title: String
        public var subtitle: String?
        public var submitTitle: String
        public var backTitle: String?
        public var onSubmit: @MainActor (String) -> Void   // email
        public var onBack: (@MainActor () -> Void)?

        public init(
            title: String = "Reset password",
            subtitle: String? = "Enter your email and we'll send you a link to reset your password.",
            submitTitle: String = "Send reset link",
            backTitle: String? = "Back to sign in",
            onSubmit: @escaping @MainActor (String) -> Void,
            onBack: (@MainActor () -> Void)? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.submitTitle = submitTitle
            self.backTitle = backTitle
            self.onSubmit = onSubmit
            self.onBack = onBack
        }
    }

    private let configuration: Configuration
    @State private var email: String = ""
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: theme.spacing.lg) {
            VStack(spacing: theme.spacing.xs) {
                Text(configuration.title)
                    .font(theme.typography.title.font)
                    .foregroundStyle(theme.colors.textPrimary)

                if let subtitle = configuration.subtitle {
                    Text(subtitle)
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            DFTextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif

            DFButton(configuration.submitTitle) {
                let e = email
                await MainActor.run { configuration.onSubmit(e) }
            }

            if let backTitle = configuration.backTitle,
               let onBack = configuration.onBack {
                Button(backTitle) {
                    Task { @MainActor in onBack() }
                }
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.primary)
            }

            Spacer()
        }
        .padding(theme.spacing.lg)
    }
}
```

- [ ] **Step 4: Add previews**

```swift
// Sources/DesignFoundationBlocks/Auth/DFForgotPasswordBlock+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    DFForgotPasswordBlock(configuration: .init(
        onSubmit: { _ in },
        onBack: {}
    ))
}

#Preview("Dark") {
    DFForgotPasswordBlock(configuration: .init(
        onSubmit: { _ in }
    ))
    .colorScheme(.dark)
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
swift test --filter DFForgotPasswordBlockTests 2>&1 | tail -10
```

Expected: `Test run with 4 tests passed`

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationBlocks/Auth/DFForgotPasswordBlock.swift Sources/DesignFoundationBlocks/Auth/DFForgotPasswordBlock+Previews.swift Tests/DesignFoundationBlocksTests/DFForgotPasswordBlockTests.swift
git commit -m "feat(blocks): add DFForgotPasswordBlock"
```

---

### Task 11: DFNotificationCell

**Files:**
- Create: `Sources/DesignFoundationBlocks/Notifications/DFNotificationCell.swift`
- Create: `Sources/DesignFoundationBlocks/Notifications/DFNotificationCell+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/DFNotificationCellTests.swift`

**Interfaces:**
- Consumes: `DFTheme`
- Produces: `DFNotificationCell` — notification row with icon circle, title+body+timestamp, unread indicator, optional dismiss button

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationBlocksTests/DFNotificationCellTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFNotificationCell")
struct DFNotificationCellTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("optional fields are nil/false by default")
        func defaults() {
            let config = DFNotificationCell.Configuration(
                icon: "bell",
                title: "New message",
                body: "You have a new message",
                timestamp: "now"
            )
            #expect(config.isRead == false)
            #expect(config.onTap == nil)
            #expect(config.onDismiss == nil)
        }
    }

    @Suite("Configuration custom values")
    struct CustomValueTests {
        @Test("stores all custom values")
        func storesCustomValues() {
            let config = DFNotificationCell.Configuration(
                icon: "star",
                title: "Review request",
                body: "Alice wants your feedback",
                timestamp: "5m ago",
                isRead: true,
                onTap: {},
                onDismiss: {}
            )
            #expect(config.icon == "star")
            #expect(config.title == "Review request")
            #expect(config.body == "Alice wants your feedback")
            #expect(config.timestamp == "5m ago")
            #expect(config.isRead == true)
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let cell = DFNotificationCell(configuration: .init(
                icon: "bell",
                title: "Alert",
                body: "Something happened",
                timestamp: "now"
            ))
            #expect(type(of: cell) == DFNotificationCell.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
swift test --filter DFNotificationCellTests 2>&1 | tail -20
```

Expected: compile error.

- [ ] **Step 3: Implement DFNotificationCell**

```swift
// Sources/DesignFoundationBlocks/Notifications/DFNotificationCell.swift
import SwiftUI
import DesignFoundation

public struct DFNotificationCell: View {

    public struct Configuration {
        public var icon: String
        public var title: String
        public var body: String
        public var timestamp: String
        public var isRead: Bool
        public var onTap: (@MainActor () -> Void)?
        public var onDismiss: (@MainActor () -> Void)?

        public init(
            icon: String,
            title: String,
            body: String,
            timestamp: String,
            isRead: Bool = false,
            onTap: (@MainActor () -> Void)? = nil,
            onDismiss: (@MainActor () -> Void)? = nil
        ) {
            self.icon = icon
            self.title = title
            self.body = body
            self.timestamp = timestamp
            self.isRead = isRead
            self.onTap = onTap
            self.onDismiss = onDismiss
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            ZStack {
                Circle()
                    .fill(theme.colors.primary.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: configuration.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(theme.colors.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(configuration.title)
                        .font(
                            configuration.isRead
                                ? theme.typography.body.font
                                : theme.typography.body.font.bold()
                        )
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text(configuration.timestamp)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Text(configuration.body)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
            }

            if !configuration.isRead {
                Circle()
                    .fill(theme.colors.primary)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
                    .accessibilityLabel("Unread")
            }

            if let onDismiss = configuration.onDismiss {
                Button {
                    Task { @MainActor in onDismiss() }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss")
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            if let onTap = configuration.onTap {
                Task { @MainActor in onTap() }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(configuration.onTap != nil ? .isButton : [])
    }
}
```

- [ ] **Step 4: Add previews**

```swift
// Sources/DesignFoundationBlocks/Notifications/DFNotificationCell+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    VStack(spacing: 0) {
        DFNotificationCell(configuration: .init(
            icon: "star.fill",
            title: "You received a review",
            body: "Alice left a 5-star review on your project.",
            timestamp: "2m ago",
            isRead: false,
            onTap: {},
            onDismiss: {}
        ))
        Divider()
        DFNotificationCell(configuration: .init(
            icon: "bell",
            title: "Reminder: Team standup",
            body: "Your daily standup starts in 10 minutes.",
            timestamp: "1h ago",
            isRead: true,
            onTap: {}
        ))
    }
    .padding(.horizontal)
}

#Preview("Dark") {
    DFNotificationCell(configuration: .init(
        icon: "person.crop.circle.badge.plus",
        title: "Bob sent you a connection request",
        body: "Senior Engineer at Acme Corp",
        timestamp: "3h ago",
        isRead: false,
        onTap: {},
        onDismiss: {}
    ))
    .padding(.horizontal)
    .colorScheme(.dark)
}
```

- [ ] **Step 5: Run the full block test suite**

```bash
swift test --filter DesignFoundationBlocksTests 2>&1 | tail -15
```

Expected: all tests pass. Count should be ≥ 33 tests across 11 suites.

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationBlocks/Notifications/ Tests/DesignFoundationBlocksTests/DFNotificationCellTests.swift
git commit -m "feat(blocks): add DFNotificationCell"
```

---

## Self-Review

**Spec coverage check:**

| Requirement | Task |
|---|---|
| New DesignFoundationBlocks SPM target with DesignFoundation dependency | Task 1 |
| DFEmptyStateBlock: icon, title, optional message, optional CTA | Task 2 |
| DFStatCardBlock: KPI value, title, trend, icon, tap | Task 3 |
| DFTrendDirection enum (Sendable, Equatable) | Task 3 |
| DFActivityFeedRow: avatar, title, subtitle, timestamp, unread | Task 4 |
| DFContactRow: avatar, name, subtitle, badge, tap | Task 5 |
| DFProfileHeaderBlock: avatar, name, subtitle, primary + secondary CTA | Task 6 |
| DFSettingsSectionBlock with navigation/toggle/destructive/info row types | Task 7 |
| DFSocialAuthProvider (@unchecked Sendable, apple/google convenience) | Task 8 |
| DFSignInBlock: email, password, forgot password, social, sign-up link | Task 8 |
| DFSignUpBlock: name, email, password, social, sign-in link | Task 9 |
| DFForgotPasswordBlock: email field, submit, back link | Task 10 |
| DFNotificationCell: icon circle, title, body, timestamp, unread dot, dismiss | Task 11 |
| All closures: @MainActor () -> Void pattern | All tasks |
| Zero hardcoded colors/spacing/radius | All tasks |
| Light + Dark previews per block | All tasks |
| Swift Testing only | All tasks |
| StrictConcurrency on both targets | Task 1 |
| Accessibility (.accessibilityElement, .accessibilityAddTraits, .accessibilityLabel) | Tasks 4,5,7,11 |

**No placeholders detected.**

**Type consistency check:** `DFSocialAuthProvider` is defined in Task 8 and consumed in Task 9 — both reference the same type name and file path. ✓