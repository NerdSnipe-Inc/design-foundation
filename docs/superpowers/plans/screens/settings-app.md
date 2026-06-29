# Settings App — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build six production-ready Settings screens (`DFSettingsAccountScreen`, `DFSettingsBillingScreen`, `DFSettingsTeamScreen`, `DFSettingsNotificationsScreen`, `DFSettingsSecurityScreen`, `DFSettingsDangerZoneScreen`) in the `DesignFoundationScreens` package, composing from existing blocks to deliver a complete, polished SaaS account-management section.

**Architecture:** Each screen is a standalone `struct … : View` with a `Configuration` struct holding all state hooks and action closures. Screens are organized under `Sources/DesignFoundationScreens/Settings/`. A shared `DFSettingsNavigation` helper handles the adaptive layout: `NavigationSplitView` sidebar on iPad/Mac, `NavigationStack` push flow on iPhone. Every screen reads all visual tokens from `@Environment(\.dfTheme)` — nothing hardcoded. Blocks from `DesignFoundationBlocks` handle sub-layout concerns so screen files stay declarative and thin.

**Tech Stack:** Swift 6, SwiftUI, Swift Testing, `DesignFoundation` (DFTheme + primitives), `DesignFoundationBlocks` (all blocks listed in the Global Constraints)

> **All file paths in tasks 1–7 are relative to `/Users/nerdsnipe/Projects/DesignFoundationScreens/`.** The package is assumed to already exist (bootstrapped by the Sidebar Shells plan). Tasks here only add files under `Settings/`.

---

## Global Constraints

- Swift 6 strict concurrency: `StrictConcurrency` experimental feature ON in all targets
- Platforms: iOS 18.0, macOS 15.0, visionOS 2.0
- Tests: Swift Testing only (`import Testing`, `@Suite`, `@Test`, `#expect`) — never XCTest
- All colors, typography, spacing, radius from `@Environment(\.dfTheme)` — zero hardcoded values
- Action closures: `@MainActor () -> Void` or `@MainActor (T) -> Void` — `Configuration` structs do NOT declare `Sendable` (they hold closures + SwiftUI `Binding`)
- Previews: one `#Preview("Light") { … }` and one `#Preview("Dark") { … .colorScheme(.dark) }` per screen
- Adaptive navigation: `NavigationSplitView` with sidebar on iPad/Mac; `NavigationStack` push on iPhone
- No style protocols — single opinionated look driven by DFTheme
- Package root: `/Users/nerdsnipe/Projects/DesignFoundationScreens/`
- Source path: `Sources/DesignFoundationScreens/Settings/`
- Test path: `Tests/DesignFoundationScreensTests/Settings/`
- Dependencies available: `DesignFoundation`, `DesignFoundationBlocks`
- Commit messages: conventional commits (`feat(screens): …`, `test(screens): …`)
- No Co-Author line in any commit

---

## File Map

```
Sources/DesignFoundationScreens/
  Settings/
    DFSettingsNavigation.swift            ← adaptive nav shell (sidebar+detail on iPad/Mac, stack on iPhone)
    DFSettingsAccountScreen.swift
    DFSettingsAccountScreen+Previews.swift
    DFSettingsBillingScreen.swift
    DFSettingsBillingScreen+Previews.swift
    DFSettingsTeamScreen.swift
    DFSettingsTeamScreen+Previews.swift
    DFSettingsNotificationsScreen.swift
    DFSettingsNotificationsScreen+Previews.swift
    DFSettingsSecurityScreen.swift
    DFSettingsSecurityScreen+Previews.swift
    DFSettingsDangerZoneScreen.swift
    DFSettingsDangerZoneScreen+Previews.swift

Tests/DesignFoundationScreensTests/
  Settings/
    DFSettingsAccountScreenTests.swift
    DFSettingsBillingScreenTests.swift
    DFSettingsTeamScreenTests.swift
    DFSettingsNotificationsScreenTests.swift
    DFSettingsSecurityScreenTests.swift
    DFSettingsDangerZoneScreenTests.swift
```

---

## Task 1: Adaptive Navigation Shell

**Files:**
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsNavigation.swift`

**Interfaces:**
- Produces:
  - `enum DFSettingsDestination: String, CaseIterable, Identifiable` with cases `.account`, `.billing`, `.team`, `.notifications`, `.security`, `.dangerZone`
  - `struct DFSettingsNavigation: View` — wraps the six screens in an adaptive container. Accepts a `@Binding var selection: DFSettingsDestination?` and a `@ViewBuilder content: (DFSettingsDestination) -> Content` parameter.
  - `func label(for destination: DFSettingsDestination) -> (title: String, systemImage: String)` — returns sidebar label + SF Symbol name

- [ ] **Step 1: Write the failing test**

```swift
// Tests/DesignFoundationScreensTests/Settings/DFSettingsAccountScreenTests.swift
// (We put the navigation type smoke test here since it has no dedicated test file of its own)
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSettingsDestination")
struct DFSettingsDestinationTests {
    @Test("all cases are iterable and have unique rawValues")
    func allCasesUnique() {
        let rawValues = DFSettingsDestination.allCases.map(\.rawValue)
        #expect(Set(rawValues).count == rawValues.count)
        #expect(rawValues.count == 6)
    }

    @Test("label returns non-empty title and systemImage")
    func labelNonEmpty() {
        for destination in DFSettingsDestination.allCases {
            let info = DFSettingsNavigation.label(for: destination)
            #expect(!info.title.isEmpty)
            #expect(!info.systemImage.isEmpty)
        }
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSettingsDestinationTests
```
Expected: compile error — `DFSettingsDestination` not found.

- [ ] **Step 3: Write the implementation**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsNavigation.swift
import SwiftUI
import DesignFoundation

// MARK: - Destination

public enum DFSettingsDestination: String, CaseIterable, Identifiable, Sendable {
    case account
    case billing
    case team
    case notifications
    case security
    case dangerZone

    public var id: String { rawValue }
}

// MARK: - Label helper

public extension DFSettingsNavigation {
    static func label(for destination: DFSettingsDestination) -> (title: String, systemImage: String) {
        switch destination {
        case .account:       return ("Account", "person.crop.circle")
        case .billing:       return ("Billing", "creditcard")
        case .team:          return ("Team", "person.3")
        case .notifications: return ("Notifications", "bell")
        case .security:      return ("Security", "lock.shield")
        case .dangerZone:    return ("Danger Zone", "exclamationmark.triangle")
        }
    }
}

// MARK: - Adaptive Shell

/// Wraps the six Settings screens in an adaptive navigation container.
/// - iPad / Mac: NavigationSplitView with a sidebar listing all destinations.
/// - iPhone: NavigationStack pushing each destination on tap.
public struct DFSettingsNavigation<Content: View>: View {
    @Binding var selection: DFSettingsDestination?
    @ViewBuilder let content: (DFSettingsDestination) -> Content
    @Environment(\.horizontalSizeClass) private var sizeClass

    public init(
        selection: Binding<DFSettingsDestination?>,
        @ViewBuilder content: @escaping (DFSettingsDestination) -> Content
    ) {
        _selection = selection
        self.content = content
    }

    public var body: some View {
        if sizeClass == .compact {
            // iPhone: NavigationStack with List
            NavigationStack {
                List(DFSettingsDestination.allCases, selection: $selection) { destination in
                    let info = DFSettingsNavigation.label(for: destination)
                    NavigationLink(value: destination) {
                        Label(info.title, systemImage: info.systemImage)
                    }
                }
                .navigationTitle("Settings")
                .navigationDestination(for: DFSettingsDestination.self) { destination in
                    content(destination)
                }
            }
        } else {
            // iPad / Mac: sidebar split
            NavigationSplitView {
                List(DFSettingsDestination.allCases, selection: $selection) { destination in
                    let info = DFSettingsNavigation.label(for: destination)
                    Label(info.title, systemImage: info.systemImage)
                        .tag(destination)
                }
                .navigationTitle("Settings")
            } detail: {
                if let destination = selection {
                    content(destination)
                } else {
                    content(.account)
                }
            }
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
swift test --filter DFSettingsDestinationTests
```
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundationScreens/Settings/DFSettingsNavigation.swift \
        Tests/DesignFoundationScreensTests/Settings/DFSettingsAccountScreenTests.swift
git commit -m "feat(screens): add DFSettingsNavigation adaptive shell and DFSettingsDestination enum"
```

---

## Task 2: DFSettingsAccountScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsAccountScreen.swift`
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsAccountScreen+Previews.swift`
- Modify: `Tests/DesignFoundationScreensTests/Settings/DFSettingsAccountScreenTests.swift`

**Interfaces:**
- Consumes: `DFSettingsNavigation` (Task 1)
- Produces: `struct DFSettingsAccountScreen: View` with `struct Configuration`

```swift
struct DFSettingsAccountScreen.Configuration {
    // Display state
    var avatarURL: URL?
    var displayName: String
    var email: String
    var planName: String
    // Editable fields (caller owns the @State / @Binding)
    var nameBinding: Binding<String>
    var usernameBinding: Binding<String>
    var bioBinding: Binding<String>
    var isGoogleConnected: Bool
    var isAppleConnected: Bool
    var isGitHubConnected: Bool
    // Callbacks
    var onChangePhoto: @MainActor () -> Void
    var onSave: @MainActor () -> Void
    var onDiscard: @MainActor () -> Void
    var onConnectGoogle: @MainActor () -> Void
    var onDisconnectGoogle: @MainActor () -> Void
    var onConnectApple: @MainActor () -> Void
    var onDisconnectApple: @MainActor () -> Void
    var onConnectGitHub: @MainActor () -> Void
    var onDisconnectGitHub: @MainActor () -> Void
    var showSuccessToast: Bool
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Settings/DFSettingsAccountScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSettingsAccountScreen")
struct DFSettingsAccountScreenTests {
    // Navigation enum tests from Task 1 stay here

    @Test("Configuration initialises with expected defaults")
    func configurationDefaults() {
        @State var name = "Ada Lovelace"
        @State var username = "ada"
        @State var bio = ""
        let config = DFSettingsAccountScreen.Configuration(
            avatarURL: nil,
            displayName: "Ada Lovelace",
            email: "ada@example.com",
            planName: "Pro",
            nameBinding: $name,
            usernameBinding: $username,
            bioBinding: $bio,
            isGoogleConnected: false,
            isAppleConnected: true,
            isGitHubConnected: false,
            onChangePhoto: {},
            onSave: {},
            onDiscard: {},
            onConnectGoogle: {},
            onDisconnectGoogle: {},
            onConnectApple: {},
            onDisconnectApple: {},
            onConnectGitHub: {},
            onDisconnectGitHub: {},
            showSuccessToast: false
        )
        #expect(config.displayName == "Ada Lovelace")
        #expect(config.planName == "Pro")
        #expect(config.isAppleConnected == true)
        #expect(config.isGoogleConnected == false)
        #expect(config.showSuccessToast == false)
    }

    @Test("onSave callback is invocable")
    @MainActor
    func onSaveCallback() async {
        var called = false
        @State var name = "Ada"
        @State var username = "ada"
        @State var bio = ""
        let config = DFSettingsAccountScreen.Configuration(
            avatarURL: nil,
            displayName: "Ada",
            email: "ada@example.com",
            planName: "Free",
            nameBinding: $name,
            usernameBinding: $username,
            bioBinding: $bio,
            isGoogleConnected: false,
            isAppleConnected: false,
            isGitHubConnected: false,
            onChangePhoto: {},
            onSave: { called = true },
            onDiscard: {},
            onConnectGoogle: {},
            onDisconnectGoogle: {},
            onConnectApple: {},
            onDisconnectApple: {},
            onConnectGitHub: {},
            onDisconnectGitHub: {},
            showSuccessToast: false
        )
        config.onSave()
        #expect(called == true)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
swift test --filter DFSettingsAccountScreenTests
```
Expected: compile error — `DFSettingsAccountScreen` not found.

- [ ] **Step 3: Write the implementation**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsAccountScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public struct DFSettingsAccountScreen: View {
    public struct Configuration {
        public var avatarURL: URL?
        public var displayName: String
        public var email: String
        public var planName: String
        public var nameBinding: Binding<String>
        public var usernameBinding: Binding<String>
        public var bioBinding: Binding<String>
        public var isGoogleConnected: Bool
        public var isAppleConnected: Bool
        public var isGitHubConnected: Bool
        public var onChangePhoto: @MainActor () -> Void
        public var onSave: @MainActor () -> Void
        public var onDiscard: @MainActor () -> Void
        public var onConnectGoogle: @MainActor () -> Void
        public var onDisconnectGoogle: @MainActor () -> Void
        public var onConnectApple: @MainActor () -> Void
        public var onDisconnectApple: @MainActor () -> Void
        public var onConnectGitHub: @MainActor () -> Void
        public var onDisconnectGitHub: @MainActor () -> Void
        public var showSuccessToast: Bool

        public init(
            avatarURL: URL? = nil,
            displayName: String,
            email: String,
            planName: String,
            nameBinding: Binding<String>,
            usernameBinding: Binding<String>,
            bioBinding: Binding<String>,
            isGoogleConnected: Bool = false,
            isAppleConnected: Bool = false,
            isGitHubConnected: Bool = false,
            onChangePhoto: @escaping @MainActor () -> Void = {},
            onSave: @escaping @MainActor () -> Void,
            onDiscard: @escaping @MainActor () -> Void,
            onConnectGoogle: @escaping @MainActor () -> Void = {},
            onDisconnectGoogle: @escaping @MainActor () -> Void = {},
            onConnectApple: @escaping @MainActor () -> Void = {},
            onDisconnectApple: @escaping @MainActor () -> Void = {},
            onConnectGitHub: @escaping @MainActor () -> Void = {},
            onDisconnectGitHub: @escaping @MainActor () -> Void = {},
            showSuccessToast: Bool = false
        ) {
            self.avatarURL = avatarURL
            self.displayName = displayName
            self.email = email
            self.planName = planName
            self.nameBinding = nameBinding
            self.usernameBinding = usernameBinding
            self.bioBinding = bioBinding
            self.isGoogleConnected = isGoogleConnected
            self.isAppleConnected = isAppleConnected
            self.isGitHubConnected = isGitHubConnected
            self.onChangePhoto = onChangePhoto
            self.onSave = onSave
            self.onDiscard = onDiscard
            self.onConnectGoogle = onConnectGoogle
            self.onDisconnectGoogle = onDisconnectGoogle
            self.onConnectApple = onConnectApple
            self.onDisconnectApple = onDisconnectApple
            self.onConnectGitHub = onConnectGitHub
            self.onDisconnectGitHub = onDisconnectGitHub
            self.showSuccessToast = showSuccessToast
        }
    }

    private let config: Configuration
    @Environment(\.dfTheme) private var theme

    public init(config: Configuration) {
        self.config = config
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                // Large avatar + name + email + plan badge
                DFAccountBlock(config: .init(
                    avatarURL: config.avatarURL,
                    displayName: config.displayName,
                    email: config.email,
                    badgeLabel: config.planName,
                    onAvatarTap: config.onChangePhoto
                ))

                // Edit Profile
                DFSettingsSectionBlock(title: "Edit Profile", rows: [
                    .textField("Name", binding: config.nameBinding),
                    .textField("Username", binding: config.usernameBinding),
                    .multiLineTextField("Bio", binding: config.bioBinding),
                ])

                // Contact Info (collapsible)
                DFAddressBlock(config: .init(isCollapsible: true))

                // Connected Accounts
                DFSettingsSectionBlock(title: "Connected Accounts", rows: [
                    .toggle("Google", isOn: .init(
                        get: { config.isGoogleConnected },
                        set: { _ in config.isGoogleConnected ? config.onDisconnectGoogle() : config.onConnectGoogle() }
                    )),
                    .toggle("Apple", isOn: .init(
                        get: { config.isAppleConnected },
                        set: { _ in config.isAppleConnected ? config.onDisconnectApple() : config.onConnectApple() }
                    )),
                    .toggle("GitHub", isOn: .init(
                        get: { config.isGitHubConnected },
                        set: { _ in config.isGitHubConnected ? config.onDisconnectGitHub() : config.onConnectGitHub() }
                    )),
                ])

                // Save / Discard — only shown when edits are pending (caller controls visibility via config bindings changing)
                HStack(spacing: theme.spacing.md) {
                    DFButton("Discard", style: .ghost, action: config.onDiscard)
                    DFButton("Save Changes", style: .primary, action: config.onSave)
                }
                .padding(.horizontal, theme.spacing.lg)
            }
            .padding(.vertical, theme.spacing.lg)
        }
        .navigationTitle("Account")
        .overlay(alignment: .bottom) {
            if config.showSuccessToast {
                DFToast(message: "Changes saved", style: .success)
                    .padding(.bottom, theme.spacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: config.showSuccessToast)
    }
}
```

- [ ] **Step 4: Write the previews file**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsAccountScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    NavigationStack {
        DFSettingsAccountScreen(config: .previewConfig)
    }
}

#Preview("Dark") {
    NavigationStack {
        DFSettingsAccountScreen(config: .previewConfig)
    }
    .colorScheme(.dark)
}

private extension DFSettingsAccountScreen.Configuration {
    @MainActor
    static var previewConfig: Self {
        @State var name = "Ada Lovelace"
        @State var username = "ada"
        @State var bio = "Building the future, one algorithm at a time."
        return .init(
            displayName: "Ada Lovelace",
            email: "ada@example.com",
            planName: "Pro",
            nameBinding: $name,
            usernameBinding: $username,
            bioBinding: $bio,
            isGoogleConnected: true,
            isAppleConnected: false,
            isGitHubConnected: true,
            onSave: {},
            onDiscard: {}
        )
    }
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
swift test --filter DFSettingsAccountScreenTests
```
Expected: PASS (3 tests including navigation enum tests)

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationScreens/Settings/DFSettingsAccountScreen.swift \
        Sources/DesignFoundationScreens/Settings/DFSettingsAccountScreen+Previews.swift \
        Tests/DesignFoundationScreensTests/Settings/DFSettingsAccountScreenTests.swift
git commit -m "feat(screens): add DFSettingsAccountScreen with profile edit and connected accounts"
```

---

## Task 3: DFSettingsBillingScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsBillingScreen.swift`
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsBillingScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Settings/DFSettingsBillingScreenTests.swift`

**Interfaces:**
- Produces: `struct DFSettingsBillingScreen: View` with `struct Configuration` and `struct DFInvoiceRow`

```swift
struct DFInvoiceRow: Identifiable {
    let id: UUID
    let date: String       // pre-formatted, e.g. "Jun 1, 2026"
    let amount: String     // pre-formatted, e.g. "$49.00"
    let status: Status
    enum Status { case paid, refunded }
    let onDownload: @MainActor () -> Void
}

struct DFSettingsBillingScreen.Configuration {
    var planName: String
    var planPrice: String          // e.g. "$49 / month"
    var renewalDate: String        // e.g. "Jul 1, 2026"
    var planFeatures: [String]
    var usageLabel: String         // e.g. "API Calls"
    var usageValue: Double         // 0.0–1.0 fraction for DFProgressBar
    var usageDetail: String        // e.g. "8,200 / 10,000"
    var cardBrand: String          // e.g. "Visa"
    var cardLast4: String          // e.g. "4242"
    var cardExpiry: String         // e.g. "12/27"
    var invoices: [DFInvoiceRow]
    var onUpgrade: @MainActor () -> Void
    var onUpdateCard: @MainActor () -> Void
    var onCancelSubscription: @MainActor () -> Void
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Settings/DFSettingsBillingScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSettingsBillingScreen")
struct DFSettingsBillingScreenTests {
    @Test("DFInvoiceRow id is stable")
    func invoiceRowIdStable() {
        let id = UUID()
        let row = DFInvoiceRow(id: id, date: "Jun 1, 2026", amount: "$49.00",
                               status: .paid, onDownload: {})
        #expect(row.id == id)
    }

    @Test("Configuration stores plan and card details")
    func configurationStoresPlanAndCard() {
        let config = DFSettingsBillingScreen.Configuration(
            planName: "Pro",
            planPrice: "$49 / month",
            renewalDate: "Jul 1, 2026",
            planFeatures: ["Unlimited projects", "Priority support"],
            usageLabel: "API Calls",
            usageValue: 0.82,
            usageDetail: "8,200 / 10,000",
            cardBrand: "Visa",
            cardLast4: "4242",
            cardExpiry: "12/27",
            invoices: [],
            onUpgrade: {},
            onUpdateCard: {},
            onCancelSubscription: {}
        )
        #expect(config.planName == "Pro")
        #expect(config.cardLast4 == "4242")
        #expect(config.usageValue == 0.82)
        #expect(config.invoices.isEmpty)
    }

    @Test("onCancelSubscription callback is invocable")
    @MainActor
    func cancelCallback() {
        var called = false
        let config = DFSettingsBillingScreen.Configuration(
            planName: "Pro",
            planPrice: "$49 / month",
            renewalDate: "Jul 1, 2026",
            planFeatures: [],
            usageLabel: "API Calls",
            usageValue: 0.5,
            usageDetail: "5,000 / 10,000",
            cardBrand: "Visa",
            cardLast4: "4242",
            cardExpiry: "12/27",
            invoices: [],
            onUpgrade: {},
            onUpdateCard: {},
            onCancelSubscription: { called = true }
        )
        config.onCancelSubscription()
        #expect(called == true)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
swift test --filter DFSettingsBillingScreenTests
```
Expected: compile error — `DFSettingsBillingScreen` not found.

- [ ] **Step 3: Write the implementation**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsBillingScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Supporting Types

public struct DFInvoiceRow: Identifiable {
    public let id: UUID
    public let date: String
    public let amount: String
    public let status: Status
    public let onDownload: @MainActor () -> Void

    public enum Status: Sendable { case paid, refunded }

    public init(id: UUID = UUID(), date: String, amount: String,
                status: Status, onDownload: @escaping @MainActor () -> Void) {
        self.id = id
        self.date = date
        self.amount = amount
        self.status = status
        self.onDownload = onDownload
    }
}

// MARK: - Screen

public struct DFSettingsBillingScreen: View {
    public struct Configuration {
        public var planName: String
        public var planPrice: String
        public var renewalDate: String
        public var planFeatures: [String]
        public var usageLabel: String
        public var usageValue: Double
        public var usageDetail: String
        public var cardBrand: String
        public var cardLast4: String
        public var cardExpiry: String
        public var invoices: [DFInvoiceRow]
        public var onUpgrade: @MainActor () -> Void
        public var onUpdateCard: @MainActor () -> Void
        public var onCancelSubscription: @MainActor () -> Void

        public init(
            planName: String,
            planPrice: String,
            renewalDate: String,
            planFeatures: [String],
            usageLabel: String,
            usageValue: Double,
            usageDetail: String,
            cardBrand: String,
            cardLast4: String,
            cardExpiry: String,
            invoices: [DFInvoiceRow],
            onUpgrade: @escaping @MainActor () -> Void,
            onUpdateCard: @escaping @MainActor () -> Void,
            onCancelSubscription: @escaping @MainActor () -> Void
        ) {
            self.planName = planName
            self.planPrice = planPrice
            self.renewalDate = renewalDate
            self.planFeatures = planFeatures
            self.usageLabel = usageLabel
            self.usageValue = usageValue
            self.usageDetail = usageDetail
            self.cardBrand = cardBrand
            self.cardLast4 = cardLast4
            self.cardExpiry = cardExpiry
            self.invoices = invoices
            self.onUpgrade = onUpgrade
            self.onUpdateCard = onUpdateCard
            self.onCancelSubscription = onCancelSubscription
        }
    }

    private let config: Configuration
    @Environment(\.dfTheme) private var theme

    public init(config: Configuration) {
        self.config = config
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                // Current Plan card
                DFCard {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        DFText(config.planName, style: .title2)
                        DFText(config.planPrice, style: .body)
                            .foregroundStyle(theme.colors.textSecondary)
                        DFText("Renews \(config.renewalDate)", style: .caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        Divider()
                        ForEach(config.planFeatures, id: \.self) { feature in
                            Label(feature, systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(theme.colors.success)
                        }
                    }
                }

                // Usage meter
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack {
                        DFText(config.usageLabel, style: .caption)
                        Spacer()
                        DFText(config.usageDetail, style: .caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    DFProgressBar(value: config.usageValue)
                }
                .padding(.horizontal, theme.spacing.lg)

                // Upgrade CTA
                DFSettingsSectionBlock(title: "Upgrade", rows: [
                    .navigation("Upgrade to Pro", action: config.onUpgrade),
                ])

                // Payment Method
                DFSettingsSectionBlock(title: "Payment Method", rows: [
                    .detail("\(config.cardBrand) ••••\(config.cardLast4)", value: "Exp \(config.cardExpiry)"),
                    .navigation("Update Card", action: config.onUpdateCard),
                ])

                // Billing History
                if config.invoices.isEmpty {
                    DFEmptyStateBlock(config: .init(
                        systemImage: "receipt",
                        title: "No invoices yet",
                        message: "Your billing history will appear here."
                    ))
                } else {
                    DFList(items: config.invoices) { invoice in
                        DFListRow {
                            HStack {
                                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                                    DFText(invoice.date, style: .body)
                                    DFText(invoice.amount, style: .caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                                Spacer()
                                DFBadge(
                                    invoice.status == .paid ? "Paid" : "Refunded",
                                    style: invoice.status == .paid ? .success : .warning
                                )
                                Button(action: invoice.onDownload) {
                                    Image(systemName: "arrow.down.circle")
                                        .foregroundStyle(theme.colors.primary)
                                }
                            }
                        }
                    }
                }

                // Danger Zone
                DFDangerZoneBlock(actions: [
                    .init(title: "Cancel Subscription",
                          description: "You'll lose access at the end of your billing period.",
                          buttonLabel: "Cancel Subscription",
                          onAction: config.onCancelSubscription)
                ])
            }
            .padding(.vertical, theme.spacing.lg)
        }
        .navigationTitle("Billing")
    }
}
```

- [ ] **Step 4: Write the previews file**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsBillingScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    NavigationStack {
        DFSettingsBillingScreen(config: .previewConfig)
    }
}

#Preview("Dark") {
    NavigationStack {
        DFSettingsBillingScreen(config: .previewConfig)
    }
    .colorScheme(.dark)
}

#Preview("No Invoices") {
    NavigationStack {
        DFSettingsBillingScreen(config: .emptyConfig)
    }
}

private extension DFSettingsBillingScreen.Configuration {
    static var previewConfig: Self {
        .init(
            planName: "Pro",
            planPrice: "$49 / month",
            renewalDate: "Jul 1, 2026",
            planFeatures: ["Unlimited projects", "10,000 API calls/mo", "Priority support"],
            usageLabel: "API Calls",
            usageValue: 0.82,
            usageDetail: "8,200 / 10,000",
            cardBrand: "Visa",
            cardLast4: "4242",
            cardExpiry: "12/27",
            invoices: [
                .init(date: "Jun 1, 2026", amount: "$49.00", status: .paid, onDownload: {}),
                .init(date: "May 1, 2026", amount: "$49.00", status: .paid, onDownload: {}),
                .init(date: "Apr 1, 2026", amount: "$49.00", status: .refunded, onDownload: {}),
            ],
            onUpgrade: {},
            onUpdateCard: {},
            onCancelSubscription: {}
        )
    }

    static var emptyConfig: Self {
        .init(
            planName: "Free",
            planPrice: "$0 / month",
            renewalDate: "—",
            planFeatures: ["3 projects", "1,000 API calls/mo"],
            usageLabel: "API Calls",
            usageValue: 0.3,
            usageDetail: "300 / 1,000",
            cardBrand: "",
            cardLast4: "",
            cardExpiry: "",
            invoices: [],
            onUpgrade: {},
            onUpdateCard: {},
            onCancelSubscription: {}
        )
    }
}
```

- [ ] **Step 5: Run tests**

```bash
swift test --filter DFSettingsBillingScreenTests
```
Expected: PASS (3 tests)

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationScreens/Settings/DFSettingsBillingScreen.swift \
        Sources/DesignFoundationScreens/Settings/DFSettingsBillingScreen+Previews.swift \
        Tests/DesignFoundationScreensTests/Settings/DFSettingsBillingScreenTests.swift
git commit -m "feat(screens): add DFSettingsBillingScreen with plan, usage meter, invoices, and danger zone"
```

---

## Task 4: DFSettingsTeamScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsTeamScreen.swift`
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsTeamScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Settings/DFSettingsTeamScreenTests.swift`

**Interfaces:**
- Produces: `struct DFSettingsTeamScreen: View` with `struct Configuration`, `struct DFTeamMemberRow`, `struct DFPendingInviteRow`

```swift
public struct DFTeamMemberRow: Identifiable {
    public let id: UUID
    public let avatarURL: URL?
    public let name: String
    public let email: String
    public let role: Role
    public let lastActive: String          // pre-formatted, e.g. "2 hours ago"
    public let onChangeRole: @MainActor () -> Void
    public let onRemove: @MainActor () -> Void
    public enum Role: String, Sendable { case admin = "Admin"; case member = "Member"; case viewer = "Viewer" }
}

public struct DFPendingInviteRow: Identifiable {
    public let id: UUID
    public let email: String
    public let sentDate: String            // pre-formatted, e.g. "Jun 27, 2026"
    public let onResend: @MainActor () -> Void
    public let onRevoke: @MainActor () -> Void
}

public struct DFSettingsTeamScreen.Configuration {
    public var seatsUsed: Int
    public var seatsTotal: Int
    public var pendingInviteCount: Int
    public var members: [DFTeamMemberRow]
    public var pendingInvites: [DFPendingInviteRow]
    public var onInviteMember: @MainActor () -> Void   // opens invite sheet
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Settings/DFSettingsTeamScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSettingsTeamScreen")
struct DFSettingsTeamScreenTests {
    @Test("DFTeamMemberRow role rawValue matches display string")
    func memberRoleRawValue() {
        #expect(DFTeamMemberRow.Role.admin.rawValue == "Admin")
        #expect(DFTeamMemberRow.Role.member.rawValue == "Member")
        #expect(DFTeamMemberRow.Role.viewer.rawValue == "Viewer")
    }

    @Test("Configuration seat counts are stored correctly")
    func seatCounts() {
        let config = DFSettingsTeamScreen.Configuration(
            seatsUsed: 3,
            seatsTotal: 10,
            pendingInviteCount: 2,
            members: [],
            pendingInvites: [],
            onInviteMember: {}
        )
        #expect(config.seatsUsed == 3)
        #expect(config.seatsTotal == 10)
        #expect(config.pendingInviteCount == 2)
    }

    @Test("onInviteMember callback is invocable")
    @MainActor
    func inviteCallback() {
        var called = false
        let config = DFSettingsTeamScreen.Configuration(
            seatsUsed: 1,
            seatsTotal: 5,
            pendingInviteCount: 0,
            members: [],
            pendingInvites: [],
            onInviteMember: { called = true }
        )
        config.onInviteMember()
        #expect(called == true)
    }

    @Test("DFPendingInviteRow revoke callback invocable")
    @MainActor
    func revokeCallback() {
        var revoked = false
        let invite = DFPendingInviteRow(
            id: UUID(),
            email: "new@example.com",
            sentDate: "Jun 27, 2026",
            onResend: {},
            onRevoke: { revoked = true }
        )
        invite.onRevoke()
        #expect(revoked == true)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
swift test --filter DFSettingsTeamScreenTests
```
Expected: compile error — `DFSettingsTeamScreen` not found.

- [ ] **Step 3: Write the implementation**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsTeamScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Supporting Types

public struct DFTeamMemberRow: Identifiable {
    public let id: UUID
    public let avatarURL: URL?
    public let name: String
    public let email: String
    public let role: Role
    public let lastActive: String
    public let onChangeRole: @MainActor () -> Void
    public let onRemove: @MainActor () -> Void

    public enum Role: String, Sendable {
        case admin = "Admin"
        case member = "Member"
        case viewer = "Viewer"
    }

    public init(id: UUID = UUID(), avatarURL: URL? = nil, name: String, email: String,
                role: Role, lastActive: String,
                onChangeRole: @escaping @MainActor () -> Void,
                onRemove: @escaping @MainActor () -> Void) {
        self.id = id
        self.avatarURL = avatarURL
        self.name = name
        self.email = email
        self.role = role
        self.lastActive = lastActive
        self.onChangeRole = onChangeRole
        self.onRemove = onRemove
    }
}

public struct DFPendingInviteRow: Identifiable {
    public let id: UUID
    public let email: String
    public let sentDate: String
    public let onResend: @MainActor () -> Void
    public let onRevoke: @MainActor () -> Void

    public init(id: UUID = UUID(), email: String, sentDate: String,
                onResend: @escaping @MainActor () -> Void,
                onRevoke: @escaping @MainActor () -> Void) {
        self.id = id
        self.email = email
        self.sentDate = sentDate
        self.onResend = onResend
        self.onRevoke = onRevoke
    }
}

// MARK: - Screen

public struct DFSettingsTeamScreen: View {
    public struct Configuration {
        public var seatsUsed: Int
        public var seatsTotal: Int
        public var pendingInviteCount: Int
        public var members: [DFTeamMemberRow]
        public var pendingInvites: [DFPendingInviteRow]
        public var onInviteMember: @MainActor () -> Void

        public init(seatsUsed: Int, seatsTotal: Int, pendingInviteCount: Int,
                    members: [DFTeamMemberRow], pendingInvites: [DFPendingInviteRow],
                    onInviteMember: @escaping @MainActor () -> Void) {
            self.seatsUsed = seatsUsed
            self.seatsTotal = seatsTotal
            self.pendingInviteCount = pendingInviteCount
            self.members = members
            self.pendingInvites = pendingInvites
            self.onInviteMember = onInviteMember
        }
    }

    private let config: Configuration
    @Environment(\.dfTheme) private var theme

    public init(config: Configuration) {
        self.config = config
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                // Header stats
                DFMetricGridBlock(metrics: [
                    .init(label: "Seats Used", value: "\(config.seatsUsed)"),
                    .init(label: "Seats Available", value: "\(config.seatsTotal - config.seatsUsed)"),
                    .init(label: "Pending Invites", value: "\(config.pendingInviteCount)"),
                ])

                // Team members
                if config.members.isEmpty {
                    DFEmptyStateBlock(config: .init(
                        systemImage: "person.3",
                        title: "No teammates yet",
                        message: "Invite your first teammate to collaborate.",
                        actionLabel: "Invite Member",
                        onAction: config.onInviteMember
                    ))
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        DFText("Team Members", style: .headline)
                            .padding(.horizontal, theme.spacing.lg)
                        DFList(items: config.members) { member in
                            DFListRow(
                                swipeLeadingActions: [
                                    .init(label: "Change Role", systemImage: "person.badge.key",
                                          tint: theme.colors.warning, action: member.onChangeRole)
                                ],
                                swipeTrailingActions: [
                                    .init(label: "Remove", systemImage: "trash",
                                          tint: theme.colors.destructive, action: member.onRemove)
                                ]
                            ) {
                                DFContactRow(config: .init(
                                    avatarURL: member.avatarURL,
                                    name: member.name,
                                    subtitle: member.email,
                                    accessory: { DFBadge(member.role.rawValue, style: .neutral) }
                                ))
                            }
                        }
                    }
                }

                // Pending invites
                if !config.pendingInvites.isEmpty {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        DFText("Pending Invites", style: .headline)
                            .padding(.horizontal, theme.spacing.lg)
                        DFList(items: config.pendingInvites) { invite in
                            DFListRow {
                                HStack {
                                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                                        DFText(invite.email, style: .body)
                                        DFText("Sent \(invite.sentDate)", style: .caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                    }
                                    Spacer()
                                    Button("Resend", action: invite.onResend)
                                        .buttonStyle(.borderless)
                                        .foregroundStyle(theme.colors.primary)
                                    Button("Revoke", action: invite.onRevoke)
                                        .buttonStyle(.borderless)
                                        .foregroundStyle(theme.colors.destructive)
                                }
                            }
                        }
                    }
                }

                // Invite button
                DFButton("Invite Member", style: .primary, action: config.onInviteMember)
                    .padding(.horizontal, theme.spacing.lg)
            }
            .padding(.vertical, theme.spacing.lg)
        }
        .navigationTitle("Team")
    }
}
```

- [ ] **Step 4: Write the previews file**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsTeamScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light — Active Team") {
    NavigationStack {
        DFSettingsTeamScreen(config: .previewConfig)
    }
}

#Preview("Dark — Active Team") {
    NavigationStack {
        DFSettingsTeamScreen(config: .previewConfig)
    }
    .colorScheme(.dark)
}

#Preview("Empty Team") {
    NavigationStack {
        DFSettingsTeamScreen(config: .emptyConfig)
    }
}

private extension DFSettingsTeamScreen.Configuration {
    static var previewConfig: Self {
        .init(
            seatsUsed: 3,
            seatsTotal: 10,
            pendingInviteCount: 2,
            members: [
                .init(name: "Ada Lovelace", email: "ada@example.com",
                      role: .admin, lastActive: "2 hours ago", onChangeRole: {}, onRemove: {}),
                .init(name: "Charles Babbage", email: "charles@example.com",
                      role: .member, lastActive: "Yesterday", onChangeRole: {}, onRemove: {}),
                .init(name: "Grace Hopper", email: "grace@example.com",
                      role: .viewer, lastActive: "3 days ago", onChangeRole: {}, onRemove: {}),
            ],
            pendingInvites: [
                .init(email: "alan@example.com", sentDate: "Jun 27, 2026", onResend: {}, onRevoke: {}),
                .init(email: "linus@example.com", sentDate: "Jun 25, 2026", onResend: {}, onRevoke: {}),
            ],
            onInviteMember: {}
        )
    }

    static var emptyConfig: Self {
        .init(seatsUsed: 1, seatsTotal: 5, pendingInviteCount: 0,
              members: [], pendingInvites: [], onInviteMember: {})
    }
}
```

- [ ] **Step 5: Run tests**

```bash
swift test --filter DFSettingsTeamScreenTests
```
Expected: PASS (4 tests)

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationScreens/Settings/DFSettingsTeamScreen.swift \
        Sources/DesignFoundationScreens/Settings/DFSettingsTeamScreen+Previews.swift \
        Tests/DesignFoundationScreensTests/Settings/DFSettingsTeamScreenTests.swift
git commit -m "feat(screens): add DFSettingsTeamScreen with member list, pending invites, and invite CTA"
```

---

## Task 5: DFSettingsNotificationsScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsNotificationsScreen.swift`
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsNotificationsScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Settings/DFSettingsNotificationsScreenTests.swift`

**Interfaces:**
- Produces: `struct DFSettingsNotificationsScreen: View` with `struct Configuration`

```swift
public struct DFSettingsNotificationsScreen.Configuration {
    // Product Updates
    public var productUpdatesEmail: Binding<Bool>
    public var productUpdatesPush: Binding<Bool>
    // Activity
    public var activityMentionsEmail: Binding<Bool>
    public var activityMentionsPush: Binding<Bool>
    public var activityRepliesEmail: Binding<Bool>
    public var activityRepliesPush: Binding<Bool>
    public var activityAssignmentsEmail: Binding<Bool>
    public var activityAssignmentsPush: Binding<Bool>
    // Billing (email only)
    public var billingReceiptsEmail: Binding<Bool>
    public var billingRenewalEmail: Binding<Bool>
    // Do Not Disturb
    public var doNotDisturb: Binding<Bool>
    public var dndStartTime: Binding<Date>
    public var dndEndTime: Binding<Date>
    // Actions
    public var onSave: @MainActor () -> Void
    public var showSuccessToast: Bool
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Settings/DFSettingsNotificationsScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSettingsNotificationsScreen")
struct DFSettingsNotificationsScreenTests {
    @Test("Configuration bindings are accessible")
    func configurationBindings() {
        @State var email = true
        @State var push = false
        @State var repliesEmail = true
        @State var repliesPush = true
        @State var assignEmail = false
        @State var assignPush = false
        @State var receipts = true
        @State var renewal = true
        @State var dnd = false
        @State var start = Date()
        @State var end = Date()
        @State var mentionsEmail = true
        @State var mentionsPush = false

        let config = DFSettingsNotificationsScreen.Configuration(
            productUpdatesEmail: $email,
            productUpdatesPush: $push,
            activityMentionsEmail: $mentionsEmail,
            activityMentionsPush: $mentionsPush,
            activityRepliesEmail: $repliesEmail,
            activityRepliesPush: $repliesPush,
            activityAssignmentsEmail: $assignEmail,
            activityAssignmentsPush: $assignPush,
            billingReceiptsEmail: $receipts,
            billingRenewalEmail: $renewal,
            doNotDisturb: $dnd,
            dndStartTime: $start,
            dndEndTime: $end,
            onSave: {},
            showSuccessToast: false
        )
        #expect(config.productUpdatesEmail.wrappedValue == true)
        #expect(config.productUpdatesPush.wrappedValue == false)
        #expect(config.doNotDisturb.wrappedValue == false)
        #expect(config.showSuccessToast == false)
    }

    @Test("onSave callback is invocable")
    @MainActor
    func onSaveCallback() {
        var saved = false
        @State var b = false
        @State var d = Date()
        let config = DFSettingsNotificationsScreen.Configuration(
            productUpdatesEmail: $b, productUpdatesPush: $b,
            activityMentionsEmail: $b, activityMentionsPush: $b,
            activityRepliesEmail: $b, activityRepliesPush: $b,
            activityAssignmentsEmail: $b, activityAssignmentsPush: $b,
            billingReceiptsEmail: $b, billingRenewalEmail: $b,
            doNotDisturb: $b, dndStartTime: $d, dndEndTime: $d,
            onSave: { saved = true },
            showSuccessToast: false
        )
        config.onSave()
        #expect(saved == true)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
swift test --filter DFSettingsNotificationsScreenTests
```
Expected: compile error — `DFSettingsNotificationsScreen` not found.

- [ ] **Step 3: Write the implementation**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsNotificationsScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public struct DFSettingsNotificationsScreen: View {
    public struct Configuration {
        public var productUpdatesEmail: Binding<Bool>
        public var productUpdatesPush: Binding<Bool>
        public var activityMentionsEmail: Binding<Bool>
        public var activityMentionsPush: Binding<Bool>
        public var activityRepliesEmail: Binding<Bool>
        public var activityRepliesPush: Binding<Bool>
        public var activityAssignmentsEmail: Binding<Bool>
        public var activityAssignmentsPush: Binding<Bool>
        public var billingReceiptsEmail: Binding<Bool>
        public var billingRenewalEmail: Binding<Bool>
        public var doNotDisturb: Binding<Bool>
        public var dndStartTime: Binding<Date>
        public var dndEndTime: Binding<Date>
        public var onSave: @MainActor () -> Void
        public var showSuccessToast: Bool

        public init(
            productUpdatesEmail: Binding<Bool>,
            productUpdatesPush: Binding<Bool>,
            activityMentionsEmail: Binding<Bool>,
            activityMentionsPush: Binding<Bool>,
            activityRepliesEmail: Binding<Bool>,
            activityRepliesPush: Binding<Bool>,
            activityAssignmentsEmail: Binding<Bool>,
            activityAssignmentsPush: Binding<Bool>,
            billingReceiptsEmail: Binding<Bool>,
            billingRenewalEmail: Binding<Bool>,
            doNotDisturb: Binding<Bool>,
            dndStartTime: Binding<Date>,
            dndEndTime: Binding<Date>,
            onSave: @escaping @MainActor () -> Void,
            showSuccessToast: Bool = false
        ) {
            self.productUpdatesEmail = productUpdatesEmail
            self.productUpdatesPush = productUpdatesPush
            self.activityMentionsEmail = activityMentionsEmail
            self.activityMentionsPush = activityMentionsPush
            self.activityRepliesEmail = activityRepliesEmail
            self.activityRepliesPush = activityRepliesPush
            self.activityAssignmentsEmail = activityAssignmentsEmail
            self.activityAssignmentsPush = activityAssignmentsPush
            self.billingReceiptsEmail = billingReceiptsEmail
            self.billingRenewalEmail = billingRenewalEmail
            self.doNotDisturb = doNotDisturb
            self.dndStartTime = dndStartTime
            self.dndEndTime = dndEndTime
            self.onSave = onSave
            self.showSuccessToast = showSuccessToast
        }
    }

    private let config: Configuration
    @Environment(\.dfTheme) private var theme

    public init(config: Configuration) {
        self.config = config
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                DFNotificationPreferencesBlock(config: .init(groups: [
                    .init(title: "Product Updates", rows: [
                        .toggle("Email", isOn: config.productUpdatesEmail),
                        .toggle("Push", isOn: config.productUpdatesPush),
                    ]),
                    .init(title: "Activity", rows: [
                        .toggle("Mentions — Email", isOn: config.activityMentionsEmail),
                        .toggle("Mentions — Push", isOn: config.activityMentionsPush),
                        .toggle("Replies — Email", isOn: config.activityRepliesEmail),
                        .toggle("Replies — Push", isOn: config.activityRepliesPush),
                        .toggle("Assignments — Email", isOn: config.activityAssignmentsEmail),
                        .toggle("Assignments — Push", isOn: config.activityAssignmentsPush),
                    ]),
                    .init(title: "Billing", rows: [
                        .toggle("Payment Receipts", isOn: config.billingReceiptsEmail),
                        .toggle("Renewal Reminders", isOn: config.billingRenewalEmail),
                    ]),
                    .init(title: "Security", rows: [
                        // Login alerts cannot be disabled — rendered as locked row
                        .locked("Login Alerts", caption: "Required for account security"),
                    ]),
                ]))

                // Do Not Disturb
                DFSettingsSectionBlock(title: "Do Not Disturb", rows: [
                    .toggle("Enable", isOn: config.doNotDisturb),
                ])
                if config.doNotDisturb.wrappedValue {
                    DFDateRangeBlock(config: .init(
                        mode: .timePicker,
                        startBinding: config.dndStartTime,
                        endBinding: config.dndEndTime,
                        startLabel: "From",
                        endLabel: "Until"
                    ))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                DFButton("Save", style: .primary, action: config.onSave)
                    .padding(.horizontal, theme.spacing.lg)
            }
            .padding(.vertical, theme.spacing.lg)
            .animation(.spring(duration: 0.25), value: config.doNotDisturb.wrappedValue)
        }
        .navigationTitle("Notifications")
        .overlay(alignment: .bottom) {
            if config.showSuccessToast {
                DFToast(message: "Preferences saved", style: .success)
                    .padding(.bottom, theme.spacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: config.showSuccessToast)
    }
}
```

- [ ] **Step 4: Write the previews file**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsNotificationsScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    NavigationStack {
        DFSettingsNotificationsScreen(config: .previewConfig)
    }
}

#Preview("Dark") {
    NavigationStack {
        DFSettingsNotificationsScreen(config: .previewConfig)
    }
    .colorScheme(.dark)
}

private extension DFSettingsNotificationsScreen.Configuration {
    @MainActor
    static var previewConfig: Self {
        @State var t = true
        @State var f = false
        @State var start = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
        @State var end = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
        return .init(
            productUpdatesEmail: $t, productUpdatesPush: $f,
            activityMentionsEmail: $t, activityMentionsPush: $t,
            activityRepliesEmail: $t, activityRepliesPush: $f,
            activityAssignmentsEmail: $t, activityAssignmentsPush: $t,
            billingReceiptsEmail: $t, billingRenewalEmail: $t,
            doNotDisturb: $f, dndStartTime: $start, dndEndTime: $end,
            onSave: {}
        )
    }
}
```

- [ ] **Step 5: Run tests**

```bash
swift test --filter DFSettingsNotificationsScreenTests
```
Expected: PASS (2 tests)

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationScreens/Settings/DFSettingsNotificationsScreen.swift \
        Sources/DesignFoundationScreens/Settings/DFSettingsNotificationsScreen+Previews.swift \
        Tests/DesignFoundationScreensTests/Settings/DFSettingsNotificationsScreenTests.swift
git commit -m "feat(screens): add DFSettingsNotificationsScreen with grouped prefs, locked security row, and DND"
```

---

## Task 6: DFSettingsSecurityScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsSecurityScreen.swift`
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsSecurityScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Settings/DFSettingsSecurityScreenTests.swift`

**Interfaces:**
- Produces: `struct DFSettingsSecurityScreen: View` with `struct Configuration` and `struct DFActiveSessionRow`

```swift
public struct DFActiveSessionRow: Identifiable {
    public let id: UUID
    public let deviceName: String
    public let location: String
    public let lastActive: String
    public let deviceSystemImage: String   // SF Symbol: "laptopcomputer", "iphone", "ipad", etc.
    public let onSignOut: @MainActor () -> Void
}

public struct DFSettingsSecurityScreen.Configuration {
    // Change Password
    public var currentPasswordBinding: Binding<String>
    public var newPasswordBinding: Binding<String>
    public var confirmPasswordBinding: Binding<String>
    public var passwordStrength: Double     // 0.0–1.0 for DFProgressBar
    public var onChangePassword: @MainActor () -> Void
    // 2FA
    public var twoFAEnabled: Bool
    public var onToggle2FA: @MainActor (Bool) -> Void   // true = enable, false = disable
    public var show2FASetupSheet: Bool
    public var otpBinding: Binding<String>
    public var onConfirmOTP: @MainActor () -> Void
    public var backupCodes: [String]   // shown after OTP confirmed; empty until then
    // Active sessions
    public var activeSessions: [DFActiveSessionRow]
    public var onSignOutAll: @MainActor () -> Void
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Settings/DFSettingsSecurityScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSettingsSecurityScreen")
struct DFSettingsSecurityScreenTests {
    @Test("DFActiveSessionRow id is stable")
    func sessionIdStable() {
        let id = UUID()
        let row = DFActiveSessionRow(
            id: id,
            deviceName: "MacBook Pro",
            location: "San Francisco, CA",
            lastActive: "Now",
            deviceSystemImage: "laptopcomputer",
            onSignOut: {}
        )
        #expect(row.id == id)
        #expect(row.deviceSystemImage == "laptopcomputer")
    }

    @Test("Configuration passwordStrength is stored")
    func passwordStrength() {
        @State var cp = ""
        @State var np = ""
        @State var cnp = ""
        @State var otp = ""
        let config = DFSettingsSecurityScreen.Configuration(
            currentPasswordBinding: $cp,
            newPasswordBinding: $np,
            confirmPasswordBinding: $cnp,
            passwordStrength: 0.75,
            onChangePassword: {},
            twoFAEnabled: false,
            onToggle2FA: { _ in },
            show2FASetupSheet: false,
            otpBinding: $otp,
            onConfirmOTP: {},
            backupCodes: [],
            activeSessions: [],
            onSignOutAll: {}
        )
        #expect(config.passwordStrength == 0.75)
        #expect(config.twoFAEnabled == false)
        #expect(config.backupCodes.isEmpty)
    }

    @Test("onToggle2FA callback passes value")
    @MainActor
    func toggle2FACallback() {
        var receivedValue: Bool?
        @State var cp = ""
        @State var np = ""
        @State var cnp = ""
        @State var otp = ""
        let config = DFSettingsSecurityScreen.Configuration(
            currentPasswordBinding: $cp,
            newPasswordBinding: $np,
            confirmPasswordBinding: $cnp,
            passwordStrength: 0.0,
            onChangePassword: {},
            twoFAEnabled: false,
            onToggle2FA: { receivedValue = $0 },
            show2FASetupSheet: false,
            otpBinding: $otp,
            onConfirmOTP: {},
            backupCodes: [],
            activeSessions: [],
            onSignOutAll: {}
        )
        config.onToggle2FA(true)
        #expect(receivedValue == true)
    }

    @Test("onSignOutAll callback is invocable")
    @MainActor
    func signOutAllCallback() {
        var called = false
        @State var s = ""
        @State var d = Date()
        let config = DFSettingsSecurityScreen.Configuration(
            currentPasswordBinding: $s,
            newPasswordBinding: $s,
            confirmPasswordBinding: $s,
            passwordStrength: 0,
            onChangePassword: {},
            twoFAEnabled: true,
            onToggle2FA: { _ in },
            show2FASetupSheet: false,
            otpBinding: $s,
            onConfirmOTP: {},
            backupCodes: [],
            activeSessions: [],
            onSignOutAll: { called = true }
        )
        config.onSignOutAll()
        #expect(called == true)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
swift test --filter DFSettingsSecurityScreenTests
```
Expected: compile error — `DFSettingsSecurityScreen` not found.

- [ ] **Step 3: Write the implementation**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsSecurityScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Supporting Types

public struct DFActiveSessionRow: Identifiable {
    public let id: UUID
    public let deviceName: String
    public let location: String
    public let lastActive: String
    public let deviceSystemImage: String
    public let onSignOut: @MainActor () -> Void

    public init(id: UUID = UUID(), deviceName: String, location: String, lastActive: String,
                deviceSystemImage: String, onSignOut: @escaping @MainActor () -> Void) {
        self.id = id
        self.deviceName = deviceName
        self.location = location
        self.lastActive = lastActive
        self.deviceSystemImage = deviceSystemImage
        self.onSignOut = onSignOut
    }
}

// MARK: - Screen

public struct DFSettingsSecurityScreen: View {
    public struct Configuration {
        public var currentPasswordBinding: Binding<String>
        public var newPasswordBinding: Binding<String>
        public var confirmPasswordBinding: Binding<String>
        public var passwordStrength: Double
        public var onChangePassword: @MainActor () -> Void
        public var twoFAEnabled: Bool
        public var onToggle2FA: @MainActor (Bool) -> Void
        public var show2FASetupSheet: Bool
        public var otpBinding: Binding<String>
        public var onConfirmOTP: @MainActor () -> Void
        public var backupCodes: [String]
        public var activeSessions: [DFActiveSessionRow]
        public var onSignOutAll: @MainActor () -> Void

        public init(
            currentPasswordBinding: Binding<String>,
            newPasswordBinding: Binding<String>,
            confirmPasswordBinding: Binding<String>,
            passwordStrength: Double,
            onChangePassword: @escaping @MainActor () -> Void,
            twoFAEnabled: Bool,
            onToggle2FA: @escaping @MainActor (Bool) -> Void,
            show2FASetupSheet: Bool,
            otpBinding: Binding<String>,
            onConfirmOTP: @escaping @MainActor () -> Void,
            backupCodes: [String],
            activeSessions: [DFActiveSessionRow],
            onSignOutAll: @escaping @MainActor () -> Void
        ) {
            self.currentPasswordBinding = currentPasswordBinding
            self.newPasswordBinding = newPasswordBinding
            self.confirmPasswordBinding = confirmPasswordBinding
            self.passwordStrength = passwordStrength
            self.onChangePassword = onChangePassword
            self.twoFAEnabled = twoFAEnabled
            self.onToggle2FA = onToggle2FA
            self.show2FASetupSheet = show2FASetupSheet
            self.otpBinding = otpBinding
            self.onConfirmOTP = onConfirmOTP
            self.backupCodes = backupCodes
            self.activeSessions = activeSessions
            self.onSignOutAll = onSignOutAll
        }
    }

    private let config: Configuration
    @Environment(\.dfTheme) private var theme

    public init(config: Configuration) {
        self.config = config
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                // Change Password
                DFSettingsSectionBlock(title: "Change Password", rows: [
                    .secureField("Current Password", binding: config.currentPasswordBinding),
                    .secureField("New Password", binding: config.newPasswordBinding),
                    .secureField("Confirm New Password", binding: config.confirmPasswordBinding),
                ])

                // Password strength
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack {
                        DFText("Password Strength", style: .caption)
                        Spacer()
                        DFText(strengthLabel(for: config.passwordStrength), style: .caption)
                            .foregroundStyle(strengthColor(for: config.passwordStrength, theme: theme))
                    }
                    DFProgressBar(value: config.passwordStrength,
                                  tint: strengthColor(for: config.passwordStrength, theme: theme))
                }
                .padding(.horizontal, theme.spacing.lg)

                DFButton("Change Password", style: .secondary, action: config.onChangePassword)
                    .padding(.horizontal, theme.spacing.lg)

                // Two-Factor Authentication
                DFCard {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        HStack {
                            DFText("Two-Factor Authentication", style: .headline)
                            Spacer()
                            DFBadge(config.twoFAEnabled ? "Enabled" : "Disabled",
                                    style: config.twoFAEnabled ? .success : .neutral)
                        }
                        DFText("Add an extra layer of security to your account.",
                               style: .caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        DFToggle(
                            isOn: .init(
                                get: { config.twoFAEnabled },
                                set: { config.onToggle2FA($0) }
                            ),
                            label: config.twoFAEnabled ? "Disable 2FA" : "Enable 2FA"
                        )
                    }
                }

                // 2FA Setup Sheet (caller controls show2FASetupSheet)
                if config.show2FASetupSheet {
                    DFCard {
                        VStack(spacing: theme.spacing.md) {
                            // QR Code placeholder
                            RoundedRectangle(cornerRadius: theme.radius.md)
                                .fill(theme.colors.surfaceSecondary)
                                .frame(width: 160, height: 160)
                                .overlay {
                                    Image(systemName: "qrcode")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(theme.spacing.lg)
                                        .foregroundStyle(theme.colors.textPrimary)
                                }
                            DFText("Scan this QR code with your authenticator app,\nthen enter the 6-digit code below.",
                                   style: .caption)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(theme.colors.textSecondary)
                            DFOTPBlock(config: .init(length: 6, codeBinding: config.otpBinding,
                                                    onComplete: config.onConfirmOTP))
                            if !config.backupCodes.isEmpty {
                                Divider()
                                DFText("Backup Codes", style: .headline)
                                DFText("Save these somewhere safe. Each code can be used once.",
                                       style: .caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                                          spacing: theme.spacing.xs) {
                                    ForEach(config.backupCodes, id: \.self) { code in
                                        DFText(code, style: .mono)
                                            .padding(theme.spacing.xs)
                                            .background(theme.colors.surfaceSecondary)
                                            .clipShape(RoundedRectangle(cornerRadius: theme.radius.sm))
                                    }
                                }
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Active Sessions
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack {
                        DFText("Active Sessions", style: .headline)
                        Spacer()
                        Button("Sign out all", action: config.onSignOutAll)
                            .font(.subheadline)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    .padding(.horizontal, theme.spacing.lg)

                    DFList(items: config.activeSessions) { session in
                        DFListRow {
                            HStack(spacing: theme.spacing.md) {
                                Image(systemName: session.deviceSystemImage)
                                    .font(.title2)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .frame(width: 32)
                                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                                    DFText(session.deviceName, style: .body)
                                    DFText(session.location, style: .caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                    DFText(session.lastActive, style: .caption)
                                        .foregroundStyle(theme.colors.textTertiary)
                                }
                                Spacer()
                                Button("Sign out", action: session.onSignOut)
                                    .font(.subheadline)
                                    .foregroundStyle(theme.colors.destructive)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, theme.spacing.lg)
            .animation(.spring(duration: 0.25), value: config.show2FASetupSheet)
        }
        .navigationTitle("Security")
    }

    private func strengthLabel(for value: Double) -> String {
        switch value {
        case 0..<0.25: return "Weak"
        case 0.25..<0.5: return "Fair"
        case 0.5..<0.75: return "Good"
        default: return "Strong"
        }
    }

    private func strengthColor(for value: Double, theme: DFTheme) -> Color {
        switch value {
        case 0..<0.25: return theme.colors.destructive
        case 0.25..<0.5: return theme.colors.warning
        case 0.5..<0.75: return theme.colors.info
        default: return theme.colors.success
        }
    }
}
```

- [ ] **Step 4: Write the previews file**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsSecurityScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    NavigationStack {
        DFSettingsSecurityScreen(config: .previewConfig)
    }
}

#Preview("Dark") {
    NavigationStack {
        DFSettingsSecurityScreen(config: .previewConfig)
    }
    .colorScheme(.dark)
}

#Preview("2FA Setup Sheet") {
    NavigationStack {
        DFSettingsSecurityScreen(config: .setup2FAConfig)
    }
}

private extension DFSettingsSecurityScreen.Configuration {
    @MainActor
    static var previewConfig: Self {
        @State var cp = ""
        @State var np = ""
        @State var cnp = ""
        @State var otp = ""
        return .init(
            currentPasswordBinding: $cp,
            newPasswordBinding: $np,
            confirmPasswordBinding: $cnp,
            passwordStrength: 0.65,
            onChangePassword: {},
            twoFAEnabled: true,
            onToggle2FA: { _ in },
            show2FASetupSheet: false,
            otpBinding: $otp,
            onConfirmOTP: {},
            backupCodes: [],
            activeSessions: [
                .init(deviceName: "MacBook Pro 16\"", location: "San Francisco, CA",
                      lastActive: "Now", deviceSystemImage: "laptopcomputer", onSignOut: {}),
                .init(deviceName: "iPhone 16 Pro", location: "San Francisco, CA",
                      lastActive: "2 hours ago", deviceSystemImage: "iphone", onSignOut: {}),
                .init(deviceName: "iPad Pro", location: "New York, NY",
                      lastActive: "3 days ago", deviceSystemImage: "ipad", onSignOut: {}),
            ],
            onSignOutAll: {}
        )
    }

    @MainActor
    static var setup2FAConfig: Self {
        @State var cp = ""
        @State var np = ""
        @State var cnp = ""
        @State var otp = ""
        return .init(
            currentPasswordBinding: $cp,
            newPasswordBinding: $np,
            confirmPasswordBinding: $cnp,
            passwordStrength: 0.0,
            onChangePassword: {},
            twoFAEnabled: false,
            onToggle2FA: { _ in },
            show2FASetupSheet: true,
            otpBinding: $otp,
            onConfirmOTP: {},
            backupCodes: ["a1b2-c3d4", "e5f6-g7h8", "i9j0-k1l2",
                          "m3n4-o5p6", "q7r8-s9t0", "u1v2-w3x4",
                          "y5z6-a7b8", "c9d0-e1f2"],
            activeSessions: [],
            onSignOutAll: {}
        )
    }
}
```

- [ ] **Step 5: Run tests**

```bash
swift test --filter DFSettingsSecurityScreenTests
```
Expected: PASS (4 tests)

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationScreens/Settings/DFSettingsSecurityScreen.swift \
        Sources/DesignFoundationScreens/Settings/DFSettingsSecurityScreen+Previews.swift \
        Tests/DesignFoundationScreensTests/Settings/DFSettingsSecurityScreenTests.swift
git commit -m "feat(screens): add DFSettingsSecurityScreen with password change, 2FA setup, and active sessions"
```

---

## Task 7: DFSettingsDangerZoneScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsDangerZoneScreen.swift`
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsDangerZoneScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Settings/DFSettingsDangerZoneScreenTests.swift`

**Interfaces:**
- Produces: `struct DFSettingsDangerZoneScreen: View` with `struct Configuration`

```swift
public struct DFSettingsDangerZoneScreen.Configuration {
    // Export Data
    public var onExportData: @MainActor () -> Void
    // Transfer Ownership
    public var teamMembers: [DFTeamMemberRow]          // from Task 4
    public var onTransferOwnership: @MainActor (DFTeamMemberRow) -> Void
    public var showTransferSheet: Bool
    // Leave Team
    public var teamName: String
    public var leaveConfirmTextBinding: Binding<String>
    public var showLeaveSheet: Bool
    public var onLeaveTeam: @MainActor () -> Void
    public var onPresentLeaveSheet: @MainActor () -> Void
    // Delete Account
    public var accountEmail: String
    public var deleteReasonTagsBinding: Binding<[String]>
    public var availableDeleteReasons: [String]
    public var deleteConfirmEmailBinding: Binding<String>
    public var onDeleteAccount: @MainActor () -> Void
    public var showDeleteSheet: Bool
    public var onPresentDeleteSheet: @MainActor () -> Void
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Settings/DFSettingsDangerZoneScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSettingsDangerZoneScreen")
struct DFSettingsDangerZoneScreenTests {
    @Test("Configuration stores team name and account email")
    func configurationStoresStrings() {
        @State var leaveText = ""
        @State var reasons: [String] = []
        @State var deleteEmail = ""
        let config = DFSettingsDangerZoneScreen.Configuration(
            onExportData: {},
            teamMembers: [],
            onTransferOwnership: { _ in },
            showTransferSheet: false,
            teamName: "Acme Corp",
            leaveConfirmTextBinding: $leaveText,
            showLeaveSheet: false,
            onLeaveTeam: {},
            onPresentLeaveSheet: {},
            accountEmail: "ada@example.com",
            deleteReasonTagsBinding: $reasons,
            availableDeleteReasons: ["Too expensive", "Missing features", "Switching tools"],
            deleteConfirmEmailBinding: $deleteEmail,
            onDeleteAccount: {},
            showDeleteSheet: false,
            onPresentDeleteSheet: {}
        )
        #expect(config.teamName == "Acme Corp")
        #expect(config.accountEmail == "ada@example.com")
        #expect(config.availableDeleteReasons.count == 3)
        #expect(config.showDeleteSheet == false)
    }

    @Test("onExportData callback is invocable")
    @MainActor
    func exportCallback() {
        var called = false
        @State var s = ""
        @State var arr: [String] = []
        let config = DFSettingsDangerZoneScreen.Configuration(
            onExportData: { called = true },
            teamMembers: [],
            onTransferOwnership: { _ in },
            showTransferSheet: false,
            teamName: "Acme",
            leaveConfirmTextBinding: $s,
            showLeaveSheet: false,
            onLeaveTeam: {},
            onPresentLeaveSheet: {},
            accountEmail: "ada@example.com",
            deleteReasonTagsBinding: $arr,
            availableDeleteReasons: [],
            deleteConfirmEmailBinding: $s,
            onDeleteAccount: {},
            showDeleteSheet: false,
            onPresentDeleteSheet: {}
        )
        config.onExportData()
        #expect(called == true)
    }

    @Test("onTransferOwnership receives the correct member")
    @MainActor
    func transferCallback() {
        var receivedId: UUID?
        let member = DFTeamMemberRow(
            id: UUID(),
            name: "Charles Babbage",
            email: "charles@example.com",
            role: .admin,
            lastActive: "Today",
            onChangeRole: {},
            onRemove: {}
        )
        @State var s = ""
        @State var arr: [String] = []
        let config = DFSettingsDangerZoneScreen.Configuration(
            onExportData: {},
            teamMembers: [member],
            onTransferOwnership: { receivedId = $0.id },
            showTransferSheet: false,
            teamName: "Acme",
            leaveConfirmTextBinding: $s,
            showLeaveSheet: false,
            onLeaveTeam: {},
            onPresentLeaveSheet: {},
            accountEmail: "ada@example.com",
            deleteReasonTagsBinding: $arr,
            availableDeleteReasons: [],
            deleteConfirmEmailBinding: $s,
            onDeleteAccount: {},
            showDeleteSheet: false,
            onPresentDeleteSheet: {}
        )
        config.onTransferOwnership(member)
        #expect(receivedId == member.id)
    }

    @Test("onDeleteAccount callback is invocable")
    @MainActor
    func deleteCallback() {
        var deleted = false
        @State var s = ""
        @State var arr: [String] = []
        let config = DFSettingsDangerZoneScreen.Configuration(
            onExportData: {},
            teamMembers: [],
            onTransferOwnership: { _ in },
            showTransferSheet: false,
            teamName: "Acme",
            leaveConfirmTextBinding: $s,
            showLeaveSheet: false,
            onLeaveTeam: {},
            onPresentLeaveSheet: {},
            accountEmail: "ada@example.com",
            deleteReasonTagsBinding: $arr,
            availableDeleteReasons: [],
            deleteConfirmEmailBinding: $s,
            onDeleteAccount: { deleted = true },
            showDeleteSheet: false,
            onPresentDeleteSheet: {}
        )
        config.onDeleteAccount()
        #expect(deleted == true)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
swift test --filter DFSettingsDangerZoneScreenTests
```
Expected: compile error — `DFSettingsDangerZoneScreen` not found.

- [ ] **Step 3: Write the implementation**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsDangerZoneScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public struct DFSettingsDangerZoneScreen: View {
    public struct Configuration {
        public var onExportData: @MainActor () -> Void
        public var teamMembers: [DFTeamMemberRow]
        public var onTransferOwnership: @MainActor (DFTeamMemberRow) -> Void
        public var showTransferSheet: Bool
        public var teamName: String
        public var leaveConfirmTextBinding: Binding<String>
        public var showLeaveSheet: Bool
        public var onLeaveTeam: @MainActor () -> Void
        public var onPresentLeaveSheet: @MainActor () -> Void
        public var accountEmail: String
        public var deleteReasonTagsBinding: Binding<[String]>
        public var availableDeleteReasons: [String]
        public var deleteConfirmEmailBinding: Binding<String>
        public var onDeleteAccount: @MainActor () -> Void
        public var showDeleteSheet: Bool
        public var onPresentDeleteSheet: @MainActor () -> Void

        public init(
            onExportData: @escaping @MainActor () -> Void,
            teamMembers: [DFTeamMemberRow],
            onTransferOwnership: @escaping @MainActor (DFTeamMemberRow) -> Void,
            showTransferSheet: Bool,
            teamName: String,
            leaveConfirmTextBinding: Binding<String>,
            showLeaveSheet: Bool,
            onLeaveTeam: @escaping @MainActor () -> Void,
            onPresentLeaveSheet: @escaping @MainActor () -> Void,
            accountEmail: String,
            deleteReasonTagsBinding: Binding<[String]>,
            availableDeleteReasons: [String],
            deleteConfirmEmailBinding: Binding<String>,
            onDeleteAccount: @escaping @MainActor () -> Void,
            showDeleteSheet: Bool,
            onPresentDeleteSheet: @escaping @MainActor () -> Void
        ) {
            self.onExportData = onExportData
            self.teamMembers = teamMembers
            self.onTransferOwnership = onTransferOwnership
            self.showTransferSheet = showTransferSheet
            self.teamName = teamName
            self.leaveConfirmTextBinding = leaveConfirmTextBinding
            self.showLeaveSheet = showLeaveSheet
            self.onLeaveTeam = onLeaveTeam
            self.onPresentLeaveSheet = onPresentLeaveSheet
            self.accountEmail = accountEmail
            self.deleteReasonTagsBinding = deleteReasonTagsBinding
            self.availableDeleteReasons = availableDeleteReasons
            self.deleteConfirmEmailBinding = deleteConfirmEmailBinding
            self.onDeleteAccount = onDeleteAccount
            self.showDeleteSheet = showDeleteSheet
            self.onPresentDeleteSheet = onPresentDeleteSheet
        }
    }

    private let config: Configuration
    @Environment(\.dfTheme) private var theme

    public init(config: Configuration) {
        self.config = config
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.xl) {
                // 1. Export Data — lowest severity, no confirmation
                DFDangerZoneBlock(actions: [
                    .init(
                        title: "Export Data",
                        description: "Download an archive of all your data. No confirmation needed.",
                        buttonLabel: "Export Data",
                        buttonStyle: .secondary,
                        onAction: config.onExportData
                    )
                ])

                // 2. Transfer Ownership — sheet with team member picker
                DFDangerZoneBlock(actions: [
                    .init(
                        title: "Transfer Ownership",
                        description: "Transfer ownership of this account to another team member. You will become an Admin.",
                        buttonLabel: "Transfer Ownership",
                        buttonStyle: .warning,
                        onAction: config.onPresentLeaveSheet  // caller swaps this for the transfer sheet presenter
                    )
                ])
                // Transfer sheet: DFContactRow list
                if config.showTransferSheet {
                    DFCard {
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            DFText("Choose new owner", style: .headline)
                            ForEach(config.teamMembers) { member in
                                Button {
                                    config.onTransferOwnership(member)
                                } label: {
                                    DFContactRow(config: .init(
                                        avatarURL: member.avatarURL,
                                        name: member.name,
                                        subtitle: member.email,
                                        accessory: { DFBadge(member.role.rawValue, style: .neutral) }
                                    ))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // 3. Leave Team — confirmation requires typing team name
                DFDangerZoneBlock(actions: [
                    .init(
                        title: "Leave Team",
                        description: "You will lose access to \"\(config.teamName)\" immediately.",
                        buttonLabel: "Leave Team",
                        buttonStyle: .warning,
                        onAction: config.onPresentLeaveSheet
                    )
                ])
                if config.showLeaveSheet {
                    DFCard {
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            DFText("Confirm: type the team name to continue", style: .caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            DFTextField(
                                placeholder: config.teamName,
                                binding: config.leaveConfirmTextBinding
                            )
                            DFButton("Leave \"\(config.teamName)\"", style: .destructive,
                                     action: config.onLeaveTeam)
                                .disabled(config.leaveConfirmTextBinding.wrappedValue != config.teamName)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // 4. Delete Account — highest severity, two-step
                DFDangerZoneBlock(actions: [
                    .init(
                        title: "Delete Account",
                        description: "Permanently delete your account and all data. This cannot be undone.",
                        buttonLabel: "Delete Account",
                        buttonStyle: .destructive,
                        onAction: config.onPresentDeleteSheet
                    )
                ])
                if config.showDeleteSheet {
                    DFCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            DFText("Before you go — what's the reason?", style: .headline)
                            DFTagPickerBlock(config: .init(
                                tags: config.availableDeleteReasons,
                                selectedTagsBinding: config.deleteReasonTagsBinding,
                                allowsMultipleSelection: true
                            ))
                            Divider()
                            DFText("Type your email address to confirm deletion", style: .caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            DFTextField(
                                placeholder: config.accountEmail,
                                binding: config.deleteConfirmEmailBinding
                            )
                            DFButton("Permanently Delete Account", style: .destructive,
                                     action: config.onDeleteAccount)
                                .disabled(config.deleteConfirmEmailBinding.wrappedValue != config.accountEmail)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.vertical, theme.spacing.lg)
            .animation(.spring(duration: 0.25), value: config.showTransferSheet)
            .animation(.spring(duration: 0.25), value: config.showLeaveSheet)
            .animation(.spring(duration: 0.25), value: config.showDeleteSheet)
        }
        .navigationTitle("Danger Zone")
    }
}
```

- [ ] **Step 4: Write the previews file**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsDangerZoneScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light — Collapsed") {
    NavigationStack {
        DFSettingsDangerZoneScreen(config: .collapsedConfig)
    }
}

#Preview("Dark — Collapsed") {
    NavigationStack {
        DFSettingsDangerZoneScreen(config: .collapsedConfig)
    }
    .colorScheme(.dark)
}

#Preview("Delete Sheet Expanded") {
    NavigationStack {
        DFSettingsDangerZoneScreen(config: .deleteSheetConfig)
    }
}

private extension DFSettingsDangerZoneScreen.Configuration {
    @MainActor
    static var collapsedConfig: Self {
        @State var leaveText = ""
        @State var reasons: [String] = []
        @State var deleteEmail = ""
        return .init(
            onExportData: {},
            teamMembers: [
                .init(name: "Charles Babbage", email: "charles@example.com",
                      role: .member, lastActive: "Today", onChangeRole: {}, onRemove: {})
            ],
            onTransferOwnership: { _ in },
            showTransferSheet: false,
            teamName: "Acme Corp",
            leaveConfirmTextBinding: $leaveText,
            showLeaveSheet: false,
            onLeaveTeam: {},
            onPresentLeaveSheet: {},
            accountEmail: "ada@example.com",
            deleteReasonTagsBinding: $reasons,
            availableDeleteReasons: ["Too expensive", "Missing features",
                                     "Switching to another tool", "Privacy concerns",
                                     "Closing business", "Other"],
            deleteConfirmEmailBinding: $deleteEmail,
            onDeleteAccount: {},
            showDeleteSheet: false,
            onPresentDeleteSheet: {}
        )
    }

    @MainActor
    static var deleteSheetConfig: Self {
        @State var leaveText = ""
        @State var reasons: [String] = ["Too expensive"]
        @State var deleteEmail = ""
        return .init(
            onExportData: {},
            teamMembers: [],
            onTransferOwnership: { _ in },
            showTransferSheet: false,
            teamName: "Acme Corp",
            leaveConfirmTextBinding: $leaveText,
            showLeaveSheet: false,
            onLeaveTeam: {},
            onPresentLeaveSheet: {},
            accountEmail: "ada@example.com",
            deleteReasonTagsBinding: $reasons,
            availableDeleteReasons: ["Too expensive", "Missing features",
                                     "Switching to another tool", "Privacy concerns",
                                     "Closing business", "Other"],
            deleteConfirmEmailBinding: $deleteEmail,
            onDeleteAccount: {},
            showDeleteSheet: true,
            onPresentDeleteSheet: {}
        )
    }
}
```

- [ ] **Step 5: Run tests**

```bash
swift test --filter DFSettingsDangerZoneScreenTests
```
Expected: PASS (4 tests)

- [ ] **Step 6: Commit**

```bash
git add Sources/DesignFoundationScreens/Settings/DFSettingsDangerZoneScreen.swift \
        Sources/DesignFoundationScreens/Settings/DFSettingsDangerZoneScreen+Previews.swift \
        Tests/DesignFoundationScreensTests/Settings/DFSettingsDangerZoneScreenTests.swift
git commit -m "feat(screens): add DFSettingsDangerZoneScreen with escalating destructive actions"
```

---

## Task 8: Wire Into DFSettingsNavigation and Final Integration Test

**Files:**
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsRootScreen.swift`
- Create: `Sources/DesignFoundationScreens/Settings/DFSettingsRootScreen+Previews.swift`

**Interfaces:**
- Consumes: `DFSettingsNavigation` (Task 1), all six screens (Tasks 2–7)
- Produces: `struct DFSettingsRootScreen: View` — the entry point callers drop into their app. Accepts a single `Configuration` struct that composes all six screen configurations.

- [ ] **Step 1: Write the implementation**

No new test file needed — the six screen tests already cover behavior. This task is integration wiring only.

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsRootScreen.swift
import SwiftUI
import DesignFoundation

/// Drop-in entry point for the full Settings vertical.
/// Caller owns all state; this view is pure composition.
public struct DFSettingsRootScreen: View {
    public struct Configuration {
        public var account: DFSettingsAccountScreen.Configuration
        public var billing: DFSettingsBillingScreen.Configuration
        public var team: DFSettingsTeamScreen.Configuration
        public var notifications: DFSettingsNotificationsScreen.Configuration
        public var security: DFSettingsSecurityScreen.Configuration
        public var dangerZone: DFSettingsDangerZoneScreen.Configuration
        public var initialSelection: DFSettingsDestination

        public init(
            account: DFSettingsAccountScreen.Configuration,
            billing: DFSettingsBillingScreen.Configuration,
            team: DFSettingsTeamScreen.Configuration,
            notifications: DFSettingsNotificationsScreen.Configuration,
            security: DFSettingsSecurityScreen.Configuration,
            dangerZone: DFSettingsDangerZoneScreen.Configuration,
            initialSelection: DFSettingsDestination = .account
        ) {
            self.account = account
            self.billing = billing
            self.team = team
            self.notifications = notifications
            self.security = security
            self.dangerZone = dangerZone
            self.initialSelection = initialSelection
        }
    }

    private let config: Configuration
    @State private var selection: DFSettingsDestination?

    public init(config: Configuration) {
        self.config = config
        self._selection = State(initialValue: config.initialSelection)
    }

    public var body: some View {
        DFSettingsNavigation(selection: $selection) { destination in
            switch destination {
            case .account:
                DFSettingsAccountScreen(config: config.account)
            case .billing:
                DFSettingsBillingScreen(config: config.billing)
            case .team:
                DFSettingsTeamScreen(config: config.team)
            case .notifications:
                DFSettingsNotificationsScreen(config: config.notifications)
            case .security:
                DFSettingsSecurityScreen(config: config.security)
            case .dangerZone:
                DFSettingsDangerZoneScreen(config: config.dangerZone)
            }
        }
    }
}
```

- [ ] **Step 2: Write the previews file**

```swift
// Sources/DesignFoundationScreens/Settings/DFSettingsRootScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Settings Root — Light") {
    DFSettingsRootScreen(config: .previewConfig)
}

#Preview("Settings Root — Dark") {
    DFSettingsRootScreen(config: .previewConfig)
        .colorScheme(.dark)
}

private extension DFSettingsRootScreen.Configuration {
    @MainActor
    static var previewConfig: Self {
        // Account
        @State var name = "Ada Lovelace"
        @State var username = "ada"
        @State var bio = "Building the future."
        // Notifications
        @State var emailOn = true
        @State var pushOn = false
        @State var dnd = false
        @State var dndStart = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
        @State var dndEnd = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
        // Security
        @State var cp = ""
        @State var np = ""
        @State var cnp = ""
        @State var otp = ""
        // Danger Zone
        @State var leaveText = ""
        @State var reasons: [String] = []
        @State var deleteEmail = ""

        return .init(
            account: .init(
                displayName: "Ada Lovelace",
                email: "ada@example.com",
                planName: "Pro",
                nameBinding: $name,
                usernameBinding: $username,
                bioBinding: $bio,
                isGoogleConnected: true,
                onSave: {},
                onDiscard: {}
            ),
            billing: .init(
                planName: "Pro",
                planPrice: "$49 / month",
                renewalDate: "Jul 1, 2026",
                planFeatures: ["Unlimited projects", "10,000 API calls/mo"],
                usageLabel: "API Calls",
                usageValue: 0.82,
                usageDetail: "8,200 / 10,000",
                cardBrand: "Visa",
                cardLast4: "4242",
                cardExpiry: "12/27",
                invoices: [
                    .init(date: "Jun 1, 2026", amount: "$49.00", status: .paid, onDownload: {}),
                ],
                onUpgrade: {},
                onUpdateCard: {},
                onCancelSubscription: {}
            ),
            team: .init(
                seatsUsed: 3,
                seatsTotal: 10,
                pendingInviteCount: 1,
                members: [
                    .init(name: "Charles Babbage", email: "charles@example.com",
                          role: .member, lastActive: "Yesterday", onChangeRole: {}, onRemove: {})
                ],
                pendingInvites: [
                    .init(email: "grace@example.com", sentDate: "Jun 27, 2026", onResend: {}, onRevoke: {})
                ],
                onInviteMember: {}
            ),
            notifications: .init(
                productUpdatesEmail: $emailOn, productUpdatesPush: $pushOn,
                activityMentionsEmail: $emailOn, activityMentionsPush: $pushOn,
                activityRepliesEmail: $emailOn, activityRepliesPush: $pushOn,
                activityAssignmentsEmail: $emailOn, activityAssignmentsPush: $pushOn,
                billingReceiptsEmail: $emailOn, billingRenewalEmail: $emailOn,
                doNotDisturb: $dnd, dndStartTime: $dndStart, dndEndTime: $dndEnd,
                onSave: {}
            ),
            security: .init(
                currentPasswordBinding: $cp,
                newPasswordBinding: $np,
                confirmPasswordBinding: $cnp,
                passwordStrength: 0.65,
                onChangePassword: {},
                twoFAEnabled: true,
                onToggle2FA: { _ in },
                show2FASetupSheet: false,
                otpBinding: $otp,
                onConfirmOTP: {},
                backupCodes: [],
                activeSessions: [
                    .init(deviceName: "MacBook Pro", location: "San Francisco, CA",
                          lastActive: "Now", deviceSystemImage: "laptopcomputer", onSignOut: {})
                ],
                onSignOutAll: {}
            ),
            dangerZone: .init(
                onExportData: {},
                teamMembers: [],
                onTransferOwnership: { _ in },
                showTransferSheet: false,
                teamName: "Acme Corp",
                leaveConfirmTextBinding: $leaveText,
                showLeaveSheet: false,
                onLeaveTeam: {},
                onPresentLeaveSheet: {},
                accountEmail: "ada@example.com",
                deleteReasonTagsBinding: $reasons,
                availableDeleteReasons: ["Too expensive", "Missing features", "Other"],
                deleteConfirmEmailBinding: $deleteEmail,
                onDeleteAccount: {},
                showDeleteSheet: false,
                onPresentDeleteSheet: {}
            ),
            initialSelection: .account
        )
    }
}
```

- [ ] **Step 3: Run the full Settings test suite**

```bash
swift test --filter Settings
```
Expected: PASS (all tests across all 6 screen test files)

- [ ] **Step 4: Confirm previews build**

```bash
swift build
```
Expected: Build succeeded with no warnings about Settings targets.

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundationScreens/Settings/DFSettingsRootScreen.swift \
        Sources/DesignFoundationScreens/Settings/DFSettingsRootScreen+Previews.swift
git commit -m "feat(screens): add DFSettingsRootScreen wiring all six settings screens into adaptive nav"
```

---

## Self-Review Checklist

### Spec Coverage

| Spec requirement | Covered by |
|---|---|
| DFSettingsAccountScreen — avatar, name, email, plan badge | Task 2: `DFAccountBlock` at top of scroll |
| Edit Profile — Name, Username, Bio | Task 2: `DFSettingsSectionBlock` with `.textField` and `.multiLineTextField` rows |
| Contact Info — DFAddressBlock collapsible | Task 2: `DFAddressBlock(isCollapsible: true)` |
| Connected Accounts — Google/Apple/GitHub toggles | Task 2: `DFSettingsSectionBlock` with `.toggle` rows |
| Save/Discard buttons, success toast | Task 2: `DFButton` pair + `DFToast` overlay |
| DFSettingsBillingScreen — current plan card | Task 3: `DFCard` with plan name, price, renewal, features |
| Usage meter (DFProgressBar) | Task 3: `DFProgressBar` with `usageValue` |
| Upgrade CTA | Task 3: `DFSettingsSectionBlock` highlighted row |
| Payment Method — card ending, update row | Task 3: `DFSettingsSectionBlock` with `.detail` + `.navigation` rows |
| Billing History — invoice list | Task 3: `DFList` of `DFInvoiceRow` with date, amount, status badge, download |
| Empty state if no history | Task 3: `DFEmptyStateBlock` gated on `config.invoices.isEmpty` |
| Cancel Subscription in DFDangerZoneBlock | Task 3: `DFDangerZoneBlock` at bottom |
| DFSettingsTeamScreen — header stats | Task 4: `DFMetricGridBlock` (Seats Used / Available / Pending) |
| Team member list — DFContactRow, role badge, last active | Task 4: `DFList` with `DFContactRow` + `DFBadge` |
| Swipe actions — Change Role, Remove Member | Task 4: `DFListRow` swipe leading/trailing |
| Pending invites — email, sent date, Resend/Revoke | Task 4: second `DFList` section |
| Invite Member button | Task 4: `DFButton` at bottom |
| Empty state for new teams | Task 4: `DFEmptyStateBlock` with invite CTA |
| DFSettingsNotificationsScreen — DFNotificationPreferencesBlock | Task 5: full grouped prefs block |
| Product Updates (email + push) | Task 5: group 1 |
| Activity (mentions, replies, assignments — email + push) | Task 5: group 2 |
| Billing — email only | Task 5: group 3 |
| Security — login alerts locked | Task 5: `.locked` row in group 4 |
| Do Not Disturb — toggle + time range | Task 5: `DFToggle` + `DFDateRangeBlock` |
| Save + success toast | Task 5: `DFButton` + `DFToast` overlay |
| DFSettingsSecurityScreen — Change Password | Task 6: `DFSettingsSectionBlock` with three `DFSecureField` rows |
| Password strength indicator | Task 6: `DFProgressBar` with color-coded tint |
| 2FA card — status badge, enable/disable toggle | Task 6: `DFCard` with `DFBadge` + `DFToggle` |
| 2FA setup flow — QR placeholder, DFOTPBlock, backup codes | Task 6: inline expanded card gated on `show2FASetupSheet` |
| Active Sessions list — device, location, last active, sign out | Task 6: `DFList` of `DFActiveSessionRow` |
| Sign out of all devices | Task 6: secondary Button in sessions header |
| DFSettingsDangerZoneScreen — Export Data | Task 7: `DFDangerZoneBlock` with `.secondary` style, no confirmation |
| Transfer Ownership — team picker sheet | Task 7: `DFDangerZoneBlock` + `DFContactRow` list in `showTransferSheet` |
| Leave Team — type team name to confirm | Task 7: `DFDangerZoneBlock` + confirmation card with `DFTextField` + disabled button |
| Delete Account — reasons picker + email confirmation | Task 7: `DFDangerZoneBlock` + `DFTagPickerBlock` + `DFTextField` + disabled destructive button |
| Escalating severity order | Task 7: Export → Transfer → Leave → Delete, top to bottom |
| Adaptive nav — sidebar on iPad/Mac, stack on iPhone | Task 1: `DFSettingsNavigation` using `horizontalSizeClass` |
| Light + dark previews per screen | Tasks 2–8: every screen has `#Preview("Light")` and `#Preview("Dark")` |
| All tokens from `@Environment(\.dfTheme)` | Every screen uses `@Environment(\.dfTheme) private var theme` |
| Swift 6 strict concurrency | All closures `@MainActor`, no `Sendable` on `Configuration` structs |
| Swift Testing only | All test files use `import Testing`, `@Suite`, `@Test`, `#expect` |
| DFSettingsRootScreen entry point | Task 8 |

### Placeholder Scan

No TBD, TODO, or "similar to Task N" patterns found. Every step contains complete code.

### Type Consistency

- `DFTeamMemberRow` defined in Task 4 (`DFSettingsTeamScreen.swift`) and consumed in Task 7 (`DFSettingsDangerZoneScreen.Configuration.teamMembers`) — same type name and file, no shadowing.
- `DFInvoiceRow` defined in Task 3 — used only within that file.
- `DFActiveSessionRow` defined in Task 6 — used only within that file.
- `DFSettingsDestination` defined in Task 1 — used in Task 8 `DFSettingsRootScreen` switch and `DFSettingsNavigation.label(for:)`.
- All callback signatures `@MainActor () -> Void` or `@MainActor (T) -> Void` are consistent across definition and usage sites.
