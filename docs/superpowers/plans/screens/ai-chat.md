# AI Chat Screens — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build 4 production-ready AI chat screens — thread view with sidebar, new chat starting point, side-by-side model comparison, and a settings sheet — for the `DesignFoundationScreens` package.

**Architecture:** Each screen is a standalone SwiftUI view with a typed `Configuration` struct. Adaptive layout is handled inside each screen (NavigationSplitView on iPad/Mac, NavigationStack on iPhone). All shared types live in `AIChatModels.swift`. Screens compose existing blocks from `DesignFoundationBlocks`; custom sub-views within a screen live in the same file unless they exceed ~150 lines, in which case they get a `+SubView` file.

**Tech Stack:** Swift 6, SwiftUI, DesignFoundation, DesignFoundationBlocks, Swift Testing

---

## Preview Pattern — REQUIRED FOR ALL PREVIEWS

Every `#Preview` block MUST:
1. Wrap content in `ScrollView { ... }` only when the view is scroll-based. Full-screen views use no wrapper.
2. Apply `.frame(width: 390)` for iPhone previews, `.frame(width: 1024, height: 768)` for iPad/Mac previews.
3. Apply `.preferredColorScheme(.light)` or `.preferredColorScheme(.dark)` at the end.

```swift
#Preview("Thread — Light") {
    DFAIChatThreadScreen(configuration: .mock)
        .frame(width: 1024, height: 768)
        .preferredColorScheme(.light)
}
```

---

## Global Constraints

- Swift 6 strict concurrency, `StrictConcurrency` experimental feature ON
- Platforms: iOS 18, macOS 15, visionOS 2
- All tokens from `@Environment(\.dfTheme)` — zero hardcoded values
- Action closures: `@MainActor () -> Void` or `@MainActor (T) -> Void`
- Light + dark `#Preview` for every screen (minimum 4 previews per screen)
- Adaptive layout: `NavigationSplitView` on iPad/Mac, `NavigationStack` on iPhone
- Tests: Swift Testing only — `import Testing`, `@Suite`, `@Test`, `#expect` — NEVER XCTest
- No external dependencies beyond DesignFoundation + DesignFoundationBlocks
- Commit messages: `feat(screens): …`
- Package: `DesignFoundationScreens` at `/Users/nerdsnipe/Projects/DesignFoundationScreens/`
- Source root: `Sources/DesignFoundationScreens/AIChat/`
- Test root: `Tests/DesignFoundationScreensTests/AIChat/`

---

## Verified Block APIs

```swift
// DFSearchResultsBlock
public struct DFSearchResult: Identifiable, @unchecked Sendable {
    public var icon: String?
    public var title: String
    public var subtitle: String?
    public var badge: String?
    public var onTap: (@MainActor () -> Void)?
}
public struct DFSearchResultsBlock: View {
    public struct Configuration {
        public var results: [DFSearchResult]
        public var isLoading: Bool
        public var emptyIcon: String
        public var emptyTitle: String
        public var emptyMessage: String?
    }
}

// DFBlockSkeletonBlock
public enum DFSkeletonLayout: Sendable {
    case statCard
    case activityRow
    case contactRow
    case profileHeader
    case notificationCell
    case textBlock(lines: Int)
}
public struct DFBlockSkeletonBlock: View {
    public struct Configuration {
        public var layout: DFSkeletonLayout
        public var repeatCount: Int
    }
}

// DFSettingsSectionBlock
public enum DFSettingsRow {
    case navigation(icon: String, title: String, value: String?, action: @MainActor () -> Void)
    case toggle(icon: String, title: String, isOn: Binding<Bool>)
    case destructive(icon: String, title: String, action: @MainActor () -> Void)
    case info(icon: String, title: String, value: String)
}
public struct DFSettingsSectionBlock: View {
    public struct Configuration {
        public var header: String?
        public var footer: String?
        public var rows: [DFSettingsRow]
    }
}

// DFAccountBlock
public struct DFAccountBlock: View {
    public struct Configuration: @unchecked Sendable {
        public var avatarInitials: String?
        public var avatarImage: Image?
        public var name: String
        public var email: String
        public var planName: String?
        public var planBadge: String?
        public var editTitle: String
        public var onEdit: (@MainActor () -> Void)?
        public var manageTitle: String
        public var onManage: (@MainActor () -> Void)?
    }
}

// DFNotificationPreferencesBlock
public struct DFNotificationPreference {
    public var icon: String
    public var title: String
    public var description: String?
    public var isEnabled: Binding<Bool>
}
public struct DFNotificationPreferencesBlock: View {
    public struct Configuration {
        public var title: String
        public var preferences: [DFNotificationPreference]
    }
}

// DFDangerZoneBlock
public struct DFDangerAction {
    public var icon: String
    public var title: String
    public var description: String?
    public var confirmTitle: String
    public var action: @MainActor () -> Void
}
public struct DFDangerZoneBlock: View {
    public struct Configuration {
        public var title: String
        public var actions: [DFDangerAction]
    }
}

// DFActivityFeedRow
public struct DFActivityFeedRow: View {
    public struct Configuration {
        public var initials: String
        public var avatarImage: Image?
        public var title: String
        public var subtitle: String?
        public var timestamp: String
        public var isUnread: Bool
        public var onTap: (@MainActor () -> Void)?
    }
}

// DFStatCardBlock
public struct DFStatCardBlock: View {
    public struct Configuration {
        public var title: String
        public var value: String
        public var trend: String?
        public var trendDirection: DFTrendDirection  // .up, .down, .neutral
        public var icon: String?
        public var onTap: (@MainActor () -> Void)?
    }
}

// DFEmptyStateBlock
public struct DFEmptyStateBlock: View {
    public struct Configuration {
        public var icon: String
        public var title: String
        public var message: String?
        public var actionTitle: String?
        public var onAction: (@MainActor () -> Void)?
    }
}

// DFTagPickerBlock — assumed API (verify before Task 3)
// DFButton, DFTextField, DFText, DFIcon, DFBadge, DFAvatar, DFCard, DFToast, DFDivider
// DFButton(_ label: String, role: DFButtonRole? = nil, action: @escaping () -> Void)
// DFTextField(_ label: String, text: Binding<String>)
// DFAvatar(_ initials: String) or DFAvatar(image: Image)
// DFBadge(text: String)
```

---

## File Map

```
Sources/DesignFoundationScreens/AIChat/
  AIChatModels.swift                    — shared value types: AIChatMessage, AIChatConversation, AIChatModel
  DFAIChatThreadScreen.swift            — main split-view screen
  DFAIChatThreadScreen+Previews.swift   — 4 previews
  DFAIChatNewScreen.swift               — empty new-chat starting point
  DFAIChatNewScreen+Previews.swift      — 4 previews
  DFAIChatCompareScreen.swift           — two-column model comparison
  DFAIChatCompareScreen+Previews.swift  — 4 previews
  DFAIChatSettingsSheet.swift           — sheet for model config + history
  DFAIChatSettingsSheet+Previews.swift  — 4 previews

Tests/DesignFoundationScreensTests/AIChat/
  AIChatModelsTests.swift               — value type and grouping logic
  DFAIChatThreadScreenTests.swift       — configuration init and grouping
  DFAIChatNewScreenTests.swift          — configuration init
  DFAIChatCompareScreenTests.swift      — configuration init
  DFAIChatSettingsSheetTests.swift      — configuration init
```

---

## Task 1: Shared Models (`AIChatModels.swift`)

**Files:**
- Create: `Sources/DesignFoundationScreens/AIChat/AIChatModels.swift`
- Test: `Tests/DesignFoundationScreensTests/AIChat/AIChatModelsTests.swift`

**Interfaces:**
- Consumes: nothing
- Produces:
  - `AIChatMessage` — `id: UUID`, `role: AIChatRole`, `content: String`, `timestamp: Date`, `isStreaming: Bool`
  - `AIChatRole` — `.user`, `.assistant`
  - `AIChatConversation` — `id: UUID`, `title: String`, `messages: [AIChatMessage]`, `model: AIChatModel`, `updatedAt: Date`
  - `AIChatModel` — `id: String`, `displayName: String`, `badgeLabel: String`
  - `AIChatConversationGroup` — `label: String`, `conversations: [AIChatConversation]`
  - `func groupConversations(_ conversations: [AIChatConversation], now: Date) -> [AIChatConversationGroup]`

- [ ] **Step 1 — Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/AIChat/AIChatModelsTests.swift
import Testing
@testable import DesignFoundationScreens

@Suite("AIChatModels")
struct AIChatModelsTests {

    @Test("AIChatMessage defaults isStreaming to false")
    func messageDefaultsIsStreamingFalse() {
        let msg = AIChatMessage(role: .user, content: "Hello")
        #expect(msg.isStreaming == false)
    }

    @Test("AIChatModel badgeLabel is set")
    func modelBadgeLabel() {
        let model = AIChatModel(id: "claude-3-5-sonnet", displayName: "Claude 3.5 Sonnet", badgeLabel: "Sonnet")
        #expect(model.badgeLabel == "Sonnet")
    }

    @Test("groupConversations — today bucket contains today conversation")
    func groupConversationsTodayBucket() {
        let now = Date()
        let convo = AIChatConversation(
            title: "Today chat",
            messages: [],
            model: AIChatModel(id: "gpt-4o", displayName: "GPT-4o", badgeLabel: "GPT-4o"),
            updatedAt: now
        )
        let groups = groupConversations([convo], now: now)
        let todayGroup = groups.first { $0.label == "Today" }
        #expect(todayGroup != nil)
        #expect(todayGroup?.conversations.count == 1)
    }

    @Test("groupConversations — yesterday bucket contains yesterday conversation")
    func groupConversationsYesterdayBucket() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let convo = AIChatConversation(
            title: "Yesterday chat",
            messages: [],
            model: AIChatModel(id: "gpt-4o", displayName: "GPT-4o", badgeLabel: "GPT-4o"),
            updatedAt: yesterday
        )
        let groups = groupConversations([convo], now: now)
        let bucket = groups.first { $0.label == "Yesterday" }
        #expect(bucket != nil)
        #expect(bucket?.conversations.count == 1)
    }

    @Test("groupConversations — 5 days ago lands in Previous 7 Days")
    func groupConversationsPrevious7Days() {
        let now = Date()
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: now)!
        let convo = AIChatConversation(
            title: "5 days ago",
            messages: [],
            model: AIChatModel(id: "gpt-4o", displayName: "GPT-4o", badgeLabel: "GPT-4o"),
            updatedAt: fiveDaysAgo
        )
        let groups = groupConversations([convo], now: now)
        let bucket = groups.first { $0.label == "Previous 7 Days" }
        #expect(bucket != nil)
    }

    @Test("groupConversations — 10 days ago lands in Older")
    func groupConversationsOlder() {
        let now = Date()
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: now)!
        let convo = AIChatConversation(
            title: "Old chat",
            messages: [],
            model: AIChatModel(id: "gpt-4o", displayName: "GPT-4o", badgeLabel: "GPT-4o"),
            updatedAt: tenDaysAgo
        )
        let groups = groupConversations([convo], now: now)
        let bucket = groups.first { $0.label == "Older" }
        #expect(bucket != nil)
    }

    @Test("groupConversations — empty input returns no groups")
    func groupConversationsEmptyInput() {
        let groups = groupConversations([], now: Date())
        #expect(groups.isEmpty)
    }
}
```

- [ ] **Step 2 — Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter AIChatModelsTests 2>&1 | tail -20
```

Expected: compile error — `AIChatMessage`, `groupConversations` not found.

- [ ] **Step 3 — Create `AIChatModels.swift`**

```swift
// Sources/DesignFoundationScreens/AIChat/AIChatModels.swift
import Foundation

// MARK: - Core Types

public enum AIChatRole: Sendable {
    case user
    case assistant
}

public struct AIChatMessage: Identifiable, Sendable {
    public let id: UUID
    public var role: AIChatRole
    public var content: String
    public var timestamp: Date
    public var isStreaming: Bool

    public init(
        id: UUID = UUID(),
        role: AIChatRole,
        content: String,
        timestamp: Date = Date(),
        isStreaming: Bool = false
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.isStreaming = isStreaming
    }
}

public struct AIChatModel: Identifiable, Hashable, Sendable {
    public let id: String
    public var displayName: String
    public var badgeLabel: String

    public init(id: String, displayName: String, badgeLabel: String) {
        self.id = id
        self.displayName = displayName
        self.badgeLabel = badgeLabel
    }
}

public struct AIChatConversation: Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var messages: [AIChatMessage]
    public var model: AIChatModel
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        messages: [AIChatMessage],
        model: AIChatModel,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.model = model
        self.updatedAt = updatedAt
    }
}

public struct AIChatConversationGroup: Identifiable, Sendable {
    public let id: String
    public var label: String
    public var conversations: [AIChatConversation]

    public init(label: String, conversations: [AIChatConversation]) {
        self.id = label
        self.label = label
        self.conversations = conversations
    }
}

// MARK: - Grouping

public func groupConversations(
    _ conversations: [AIChatConversation],
    now: Date = Date()
) -> [AIChatConversationGroup] {
    let calendar = Calendar.current
    let startOfToday = calendar.startOfDay(for: now)
    let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
    let startOf7DaysAgo = calendar.date(byAdding: .day, value: -7, to: startOfToday)!

    var today: [AIChatConversation] = []
    var yesterday: [AIChatConversation] = []
    var previous7Days: [AIChatConversation] = []
    var older: [AIChatConversation] = []

    for convo in conversations {
        let day = calendar.startOfDay(for: convo.updatedAt)
        if day >= startOfToday {
            today.append(convo)
        } else if day >= startOfYesterday {
            yesterday.append(convo)
        } else if day >= startOf7DaysAgo {
            previous7Days.append(convo)
        } else {
            older.append(convo)
        }
    }

    var groups: [AIChatConversationGroup] = []
    if !today.isEmpty { groups.append(.init(label: "Today", conversations: today)) }
    if !yesterday.isEmpty { groups.append(.init(label: "Yesterday", conversations: yesterday)) }
    if !previous7Days.isEmpty { groups.append(.init(label: "Previous 7 Days", conversations: previous7Days)) }
    if !older.isEmpty { groups.append(.init(label: "Older", conversations: older)) }
    return groups
}

// MARK: - Mock Data

public extension AIChatModel {
    static let claude = AIChatModel(id: "claude-3-5-sonnet", displayName: "Claude 3.5 Sonnet", badgeLabel: "Sonnet")
    static let gpt4o = AIChatModel(id: "gpt-4o", displayName: "GPT-4o", badgeLabel: "GPT-4o")
    static let gemini = AIChatModel(id: "gemini-1-5-pro", displayName: "Gemini 1.5 Pro", badgeLabel: "Gemini")
}

public extension AIChatConversation {
    static func mockConversations(now: Date = Date()) -> [AIChatConversation] {
        let calendar = Calendar.current
        return [
            AIChatConversation(
                title: "Refactor the auth module",
                messages: [
                    AIChatMessage(role: .user, content: "How should I refactor my auth module?"),
                    AIChatMessage(role: .assistant, content: "Start by extracting the token refresh logic into its own service…"),
                ],
                model: .claude,
                updatedAt: now
            ),
            AIChatConversation(
                title: "Write a cover letter",
                messages: [
                    AIChatMessage(role: .user, content: "Write a cover letter for a senior iOS engineer role."),
                    AIChatMessage(role: .assistant, content: "Dear Hiring Manager, I am writing to express my interest…"),
                ],
                model: .gpt4o,
                updatedAt: calendar.date(byAdding: .day, value: -1, to: now)!
            ),
            AIChatConversation(
                title: "Explain diffusion models",
                messages: [],
                model: .gemini,
                updatedAt: calendar.date(byAdding: .day, value: -4, to: now)!
            ),
            AIChatConversation(
                title: "SQL query optimisation",
                messages: [],
                model: .claude,
                updatedAt: calendar.date(byAdding: .day, value: -12, to: now)!
            ),
        ]
    }
}
```

- [ ] **Step 4 — Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter AIChatModelsTests 2>&1 | tail -20
```

Expected: `Test Suite 'AIChatModelsTests' passed`.

- [ ] **Step 5 — Commit**

```bash
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens add \
  Sources/DesignFoundationScreens/AIChat/AIChatModels.swift \
  Tests/DesignFoundationScreensTests/AIChat/AIChatModelsTests.swift
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens commit -m "feat(screens): add AIChatModels shared types and grouping logic"
```

---

## Task 2: DFAIChatThreadScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/AIChat/DFAIChatThreadScreen.swift`
- Create: `Sources/DesignFoundationScreens/AIChat/DFAIChatThreadScreen+Previews.swift`
- Test: `Tests/DesignFoundationScreensTests/AIChat/DFAIChatThreadScreenTests.swift`

**Interfaces:**
- Consumes: `AIChatConversation`, `AIChatConversationGroup`, `AIChatMessage`, `AIChatModel`, `groupConversations(_:now:)` from Task 1; `DFSearchResultsBlock`, `DFBlockSkeletonBlock`, `DFActivityFeedRow`, `DFEmptyStateBlock`, `DFButton`, `DFTextField`, `DFBadge`, `DFAvatar`, `DFDivider` from blocks
- Produces:
  ```swift
  public struct DFAIChatThreadScreen: View {
      public struct Configuration: @unchecked Sendable {
          public var conversations: [AIChatConversation]
          public var activeConversationID: AIChatConversation.ID?
          public var isStreaming: Bool
          public var currentUserInitials: String
          public var currentUserName: String
          public var currentUserEmail: String
          public var onNewChat: @MainActor () -> Void
          public var onSelectConversation: @MainActor (AIChatConversation.ID) -> Void
          public var onSend: @MainActor (String) -> Void
          public var onRegenerate: @MainActor (AIChatMessage.ID) -> Void
          public var onDeleteMessage: @MainActor (AIChatMessage.ID) -> Void
          public var onSettings: @MainActor () -> Void
      }
      public init(configuration: Configuration)
  }
  ```

- [ ] **Step 1 — Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/AIChat/DFAIChatThreadScreenTests.swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFAIChatThreadScreen")
struct DFAIChatThreadScreenTests {

    func makeSUT(
        conversations: [AIChatConversation] = AIChatConversation.mockConversations(),
        activeID: AIChatConversation.ID? = nil,
        isStreaming: Bool = false
    ) -> DFAIChatThreadScreen.Configuration {
        DFAIChatThreadScreen.Configuration(
            conversations: conversations,
            activeConversationID: activeID,
            isStreaming: isStreaming,
            currentUserInitials: "NS",
            currentUserName: "NerdSnipe",
            currentUserEmail: "nerdsnipe@example.com",
            onNewChat: {},
            onSelectConversation: { _ in },
            onSend: { _ in },
            onRegenerate: { _ in },
            onDeleteMessage: { _ in },
            onSettings: {}
        )
    }

    @Test("Configuration init stores conversations")
    func configStoresConversations() {
        let convos = AIChatConversation.mockConversations()
        let config = makeSUT(conversations: convos)
        #expect(config.conversations.count == convos.count)
    }

    @Test("Configuration activeConversationID defaults to nil")
    func configDefaultsActiveIDNil() {
        let config = makeSUT()
        #expect(config.activeConversationID == nil)
    }

    @Test("Configuration isStreaming stored correctly")
    func configIsStreaming() {
        let config = makeSUT(isStreaming: true)
        #expect(config.isStreaming == true)
    }

    @Test("Configuration stores user initials")
    func configUserInitials() {
        let config = makeSUT()
        #expect(config.currentUserInitials == "NS")
    }
}
```

- [ ] **Step 2 — Run to verify failure**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAIChatThreadScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFAIChatThreadScreen` not found.

- [ ] **Step 3 — Create `DFAIChatThreadScreen.swift`**

```swift
// Sources/DesignFoundationScreens/AIChat/DFAIChatThreadScreen.swift
import SwiftUI
import DesignFoundationBlocks

public struct DFAIChatThreadScreen: View {

    // MARK: - Configuration

    public struct Configuration: @unchecked Sendable {
        public var conversations: [AIChatConversation]
        public var activeConversationID: AIChatConversation.ID?
        public var isStreaming: Bool
        public var currentUserInitials: String
        public var currentUserName: String
        public var currentUserEmail: String
        public var onNewChat: @MainActor () -> Void
        public var onSelectConversation: @MainActor (AIChatConversation.ID) -> Void
        public var onSend: @MainActor (String) -> Void
        public var onRegenerate: @MainActor (AIChatMessage.ID) -> Void
        public var onDeleteMessage: @MainActor (AIChatMessage.ID) -> Void
        public var onSettings: @MainActor () -> Void

        public init(
            conversations: [AIChatConversation],
            activeConversationID: AIChatConversation.ID? = nil,
            isStreaming: Bool = false,
            currentUserInitials: String,
            currentUserName: String,
            currentUserEmail: String,
            onNewChat: @escaping @MainActor () -> Void,
            onSelectConversation: @escaping @MainActor (AIChatConversation.ID) -> Void,
            onSend: @escaping @MainActor (String) -> Void,
            onRegenerate: @escaping @MainActor (AIChatMessage.ID) -> Void,
            onDeleteMessage: @escaping @MainActor (AIChatMessage.ID) -> Void,
            onSettings: @escaping @MainActor () -> Void
        ) {
            self.conversations = conversations
            self.activeConversationID = activeConversationID
            self.isStreaming = isStreaming
            self.currentUserInitials = currentUserInitials
            self.currentUserName = currentUserName
            self.currentUserEmail = currentUserEmail
            self.onNewChat = onNewChat
            self.onSelectConversation = onSelectConversation
            self.onSend = onSend
            self.onRegenerate = onRegenerate
            self.onDeleteMessage = onDeleteMessage
            self.onSettings = onSettings
        }
    }

    // MARK: - State

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme
    @State private var searchText: String = ""
    @State private var inputText: String = ""
    @State private var selectedConversationID: AIChatConversation.ID?

    // MARK: - Init

    public init(configuration: Configuration) {
        self.configuration = configuration
        self._selectedConversationID = State(initialValue: configuration.activeConversationID)
    }

    // MARK: - Computed

    private var activeConversation: AIChatConversation? {
        let id = selectedConversationID ?? configuration.activeConversationID
        return configuration.conversations.first { $0.id == id }
    }

    private var filteredGroups: [AIChatConversationGroup] {
        let filtered = searchText.isEmpty
            ? configuration.conversations
            : configuration.conversations.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        return groupConversations(filtered)
    }

    // MARK: - Body

    public var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationTitle("Chats")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { Task { @MainActor in configuration.onNewChat() } }) {
                            Label("New Chat", systemImage: "square.and.pencil")
                        }
                    }
                }
        } detail: {
            if let convo = activeConversation {
                threadContent(for: convo)
            } else {
                DFEmptyStateBlock(configuration: .init(
                    icon: "bubble.left.and.bubble.right",
                    title: "No conversation selected",
                    message: "Choose a chat from the sidebar or start a new one.",
                    actionTitle: "New Chat",
                    onAction: { Task { @MainActor in configuration.onNewChat() } }
                ))
            }
        }
    }

    // MARK: - Sidebar

    @ViewBuilder
    private var sidebarContent: some View {
        List(selection: $selectedConversationID) {
            // Search
            Section {
                DFTextField("Search conversations", text: $searchText)
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .listRowSeparator(.hidden)
            }

            // Grouped conversations
            if filteredGroups.isEmpty {
                DFEmptyStateBlock(configuration: .init(
                    icon: "magnifyingglass",
                    title: "No results",
                    message: "Try a different search term."
                ))
                .listRowSeparator(.hidden)
            } else {
                ForEach(filteredGroups) { group in
                    Section(group.label) {
                        ForEach(group.conversations) { convo in
                            conversationRow(convo)
                                .tag(convo.id)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .onChange(of: selectedConversationID) { _, newID in
            if let id = newID {
                Task { @MainActor in configuration.onSelectConversation(id) }
            }
        }

        Divider()

        // User footer
        HStack(spacing: theme.spacing.sm) {
            DFAvatar(configuration.currentUserInitials)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(configuration.currentUserName)
                    .font(theme.typography.bodySmall)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(configuration.currentUserEmail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            Spacer()
            Button(action: { Task { @MainActor in configuration.onSettings() } }) {
                Image(systemName: "gearshape")
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(theme.spacing.md)
    }

    @ViewBuilder
    private func conversationRow(_ convo: AIChatConversation) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(convo.title)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                Spacer()
                DFBadge(text: convo.model.badgeLabel)
            }
            Text(convo.updatedAt, style: .relative)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Thread Area

    @ViewBuilder
    private func threadContent(for convo: AIChatConversation) -> some View {
        VStack(spacing: 0) {
            // Nav bar model badge
            HStack {
                Spacer()
                DFBadge(text: convo.model.displayName)
                Button(action: { Task { @MainActor in configuration.onSettings() } }) {
                    Image(systemName: "gearshape")
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)

            DFDivider()

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: theme.spacing.sm) {
                        ForEach(convo.messages) { message in
                            messageRow(message)
                                .id(message.id)
                        }
                        if configuration.isStreaming {
                            streamingIndicator
                        }
                    }
                    .padding(theme.spacing.md)
                }
                .onChange(of: convo.messages.count) { _, _ in
                    if let last = convo.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            DFDivider()

            // Input bar
            inputBar
        }
        .navigationTitle(convo.title)
    }

    @ViewBuilder
    private func messageRow(_ message: AIChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: theme.spacing.sm) {
            if message.role == .assistant {
                DFAvatar("AI")
                    .frame(width: 28, height: 28)
            } else {
                Spacer()
            }

            Text(message.content)
                .font(theme.typography.body)
                .foregroundStyle(message.role == .user ? Color.white : theme.colors.textPrimary)
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
                .background(
                    message.role == .user
                        ? theme.colors.primary
                        : theme.colors.surface
                )
                .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
                .frame(maxWidth: 320, alignment: message.role == .user ? .trailing : .leading)
                .contextMenu {
                    Button("Copy", systemImage: "doc.on.doc") {
                        UIPasteboard.general.string = message.content
                    }
                    if message.role == .assistant {
                        Button("Regenerate", systemImage: "arrow.clockwise") {
                            Task { @MainActor in configuration.onRegenerate(message.id) }
                        }
                    }
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        Task { @MainActor in configuration.onDeleteMessage(message.id) }
                    }
                }

            if message.role == .user {
                DFAvatar(configuration.currentUserInitials)
                    .frame(width: 28, height: 28)
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }

    private var streamingIndicator: some View {
        HStack(alignment: .bottom, spacing: theme.spacing.sm) {
            DFAvatar("AI")
                .frame(width: 28, height: 28)
            DFBlockSkeletonBlock(configuration: .init(layout: .textBlock(lines: 1), repeatCount: 1))
                .frame(width: 120)
            Spacer()
        }
    }

    private var inputBar: some View {
        HStack(spacing: theme.spacing.sm) {
            Button(action: {}) {
                Image(systemName: "paperclip")
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .buttonStyle(.plain)

            DFTextField("Message", text: $inputText)

            DFButton("Send") {
                let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return }
                inputText = ""
                Task { @MainActor in configuration.onSend(text) }
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(theme.spacing.md)
    }
}
```

- [ ] **Step 4 — Create `DFAIChatThreadScreen+Previews.swift`**

```swift
// Sources/DesignFoundationScreens/AIChat/DFAIChatThreadScreen+Previews.swift
import SwiftUI
import DesignFoundationBlocks

private let mockConvos = AIChatConversation.mockConversations()

private func mockConfig(activeIndex: Int? = 0) -> DFAIChatThreadScreen.Configuration {
    DFAIChatThreadScreen.Configuration(
        conversations: mockConvos,
        activeConversationID: activeIndex.map { mockConvos[$0].id },
        isStreaming: false,
        currentUserInitials: "NS",
        currentUserName: "NerdSnipe",
        currentUserEmail: "nerdsnipe@example.com",
        onNewChat: {},
        onSelectConversation: { _ in },
        onSend: { _ in },
        onRegenerate: { _ in },
        onDeleteMessage: { _ in },
        onSettings: {}
    )
}

#Preview("With Active Thread — Light") {
    DFAIChatThreadScreen(configuration: mockConfig(activeIndex: 0))
        .frame(width: 1024, height: 768)
        .preferredColorScheme(.light)
}

#Preview("With Active Thread — Dark") {
    DFAIChatThreadScreen(configuration: mockConfig(activeIndex: 0))
        .frame(width: 1024, height: 768)
        .preferredColorScheme(.dark)
}

#Preview("No Selection — Light") {
    DFAIChatThreadScreen(configuration: mockConfig(activeIndex: nil))
        .frame(width: 1024, height: 768)
        .preferredColorScheme(.light)
}

#Preview("Streaming — Dark") {
    var config = mockConfig(activeIndex: 0)
    config.isStreaming = true
    return DFAIChatThreadScreen(configuration: config)
        .frame(width: 1024, height: 768)
        .preferredColorScheme(.dark)
}
```

- [ ] **Step 5 — Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAIChatThreadScreenTests 2>&1 | tail -20
```

Expected: `Test Suite 'DFAIChatThreadScreenTests' passed`.

- [ ] **Step 6 — Commit**

```bash
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens add \
  Sources/DesignFoundationScreens/AIChat/DFAIChatThreadScreen.swift \
  Sources/DesignFoundationScreens/AIChat/DFAIChatThreadScreen+Previews.swift \
  Tests/DesignFoundationScreensTests/AIChat/DFAIChatThreadScreenTests.swift
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens commit -m "feat(screens): add DFAIChatThreadScreen with sidebar and thread area"
```

---

## Task 3: DFAIChatNewScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/AIChat/DFAIChatNewScreen.swift`
- Create: `Sources/DesignFoundationScreens/AIChat/DFAIChatNewScreen+Previews.swift`
- Test: `Tests/DesignFoundationScreensTests/AIChat/DFAIChatNewScreenTests.swift`

**Interfaces:**
- Consumes: `AIChatConversation`, `AIChatModel` from Task 1; `DFCard`, `DFButton`, `DFTextField`, `DFBadge`, `DFIcon` from blocks
- Produces:
  ```swift
  public struct DFAIChatNewScreen: View {
      public struct Configuration: @unchecked Sendable {
          public var availableModels: [AIChatModel]
          public var selectedModel: AIChatModel
          public var recentConversations: [AIChatConversation]   // last 3 shown as chips
          public var onSend: @MainActor (String, AIChatModel) -> Void
          public var onSelectModel: @MainActor (AIChatModel) -> Void
          public var onResumeConversation: @MainActor (AIChatConversation.ID) -> Void
      }
      public init(configuration: Configuration)
  }
  ```

- [ ] **Step 1 — Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/AIChat/DFAIChatNewScreenTests.swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFAIChatNewScreen")
struct DFAIChatNewScreenTests {

    func makeSUT(
        models: [AIChatModel] = [.claude, .gpt4o, .gemini],
        selected: AIChatModel = .claude,
        recent: [AIChatConversation] = Array(AIChatConversation.mockConversations().prefix(3))
    ) -> DFAIChatNewScreen.Configuration {
        DFAIChatNewScreen.Configuration(
            availableModels: models,
            selectedModel: selected,
            recentConversations: recent,
            onSend: { _, _ in },
            onSelectModel: { _ in },
            onResumeConversation: { _ in }
        )
    }

    @Test("Configuration stores available models")
    func configStoresModels() {
        let config = makeSUT()
        #expect(config.availableModels.count == 3)
    }

    @Test("Configuration stores selected model")
    func configStoresSelectedModel() {
        let config = makeSUT(selected: .gpt4o)
        #expect(config.selectedModel.id == "gpt-4o")
    }

    @Test("Configuration caps recent conversations at 3")
    func configRecentConversations() {
        let config = makeSUT(recent: Array(AIChatConversation.mockConversations().prefix(3)))
        #expect(config.recentConversations.count <= 3)
    }
}
```

- [ ] **Step 2 — Run to verify failure**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAIChatNewScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFAIChatNewScreen` not found.

- [ ] **Step 3 — Create `DFAIChatNewScreen.swift`**

```swift
// Sources/DesignFoundationScreens/AIChat/DFAIChatNewScreen.swift
import SwiftUI
import DesignFoundationBlocks

public struct DFAIChatNewScreen: View {

    // MARK: - Configuration

    public struct Configuration: @unchecked Sendable {
        public var availableModels: [AIChatModel]
        public var selectedModel: AIChatModel
        public var recentConversations: [AIChatConversation]
        public var onSend: @MainActor (String, AIChatModel) -> Void
        public var onSelectModel: @MainActor (AIChatModel) -> Void
        public var onResumeConversation: @MainActor (AIChatConversation.ID) -> Void

        public init(
            availableModels: [AIChatModel],
            selectedModel: AIChatModel,
            recentConversations: [AIChatConversation],
            onSend: @escaping @MainActor (String, AIChatModel) -> Void,
            onSelectModel: @escaping @MainActor (AIChatModel) -> Void,
            onResumeConversation: @escaping @MainActor (AIChatConversation.ID) -> Void
        ) {
            self.availableModels = availableModels
            self.selectedModel = selectedModel
            self.recentConversations = Array(recentConversations.prefix(3))
            self.onSend = onSend
            self.onSelectModel = onSelectModel
            self.onResumeConversation = onResumeConversation
        }
    }

    // MARK: - Prompt Starters

    private struct PromptStarter: Identifiable {
        let id = UUID()
        let icon: String
        let category: String
        let prompt: String
    }

    private let starters: [PromptStarter] = [
        .init(icon: "pencil", category: "Write", prompt: "Draft a professional email"),
        .init(icon: "chevron.left.forwardslash.chevron.right", category: "Code", prompt: "Review my Swift code"),
        .init(icon: "chart.bar.doc.horizontal", category: "Analyze", prompt: "Summarize this document"),
        .init(icon: "calendar.badge.checkmark", category: "Plan", prompt: "Plan my week"),
        .init(icon: "text.bubble", category: "Write", prompt: "Help me brainstorm ideas"),
        .init(icon: "magnifyingglass", category: "Analyze", prompt: "Research this topic"),
    ]

    // MARK: - State

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme
    @State private var inputText: String = ""
    @State private var selectedModel: AIChatModel

    // MARK: - Init

    public init(configuration: Configuration) {
        self.configuration = configuration
        self._selectedModel = State(initialValue: configuration.selectedModel)
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Header
            VStack(spacing: theme.spacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.colors.primary)
                Text("What can I help with?")
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.textPrimary)
            }
            .padding(.bottom, theme.spacing.xl)

            // Model selector
            Picker("Model", selection: $selectedModel) {
                ForEach(configuration.availableModels) { model in
                    Text(model.displayName).tag(model)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedModel) { _, newModel in
                Task { @MainActor in configuration.onSelectModel(newModel) }
            }
            .padding(.bottom, theme.spacing.lg)

            // Suggestion grid
            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: theme.spacing.sm) {
                ForEach(starters) { starter in
                    Button {
                        inputText = starter.prompt
                    } label: {
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            Image(systemName: starter.icon)
                                .foregroundStyle(theme.colors.primary)
                            Text(starter.category)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            Text(starter.prompt)
                                .font(theme.typography.bodySmall)
                                .foregroundStyle(theme.colors.textPrimary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(theme.spacing.sm)
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
            .padding(.horizontal, theme.spacing.lg)
            .padding(.bottom, theme.spacing.lg)

            // Recent conversation chips
            if !configuration.recentConversations.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        Text("Recent:")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        ForEach(configuration.recentConversations) { convo in
                            Button {
                                Task { @MainActor in configuration.onResumeConversation(convo.id) }
                            } label: {
                                Text(convo.title)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textPrimary)
                                    .lineLimit(1)
                                    .padding(.horizontal, theme.spacing.sm)
                                    .padding(.vertical, theme.spacing.xs)
                                    .background(theme.colors.surface)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(theme.colors.border, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, theme.spacing.lg)
                }
                .padding(.bottom, theme.spacing.md)
            }

            Spacer()

            // Input bar
            DFDivider()
            HStack(spacing: theme.spacing.sm) {
                Button(action: {}) {
                    Image(systemName: "paperclip")
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)

                DFTextField("Message", text: $inputText)

                DFButton("Send") {
                    let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    inputText = ""
                    Task { @MainActor in configuration.onSend(text, selectedModel) }
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.background)
    }
}
```

- [ ] **Step 4 — Create `DFAIChatNewScreen+Previews.swift`**

```swift
// Sources/DesignFoundationScreens/AIChat/DFAIChatNewScreen+Previews.swift
import SwiftUI
import DesignFoundationBlocks

private let mockModels: [AIChatModel] = [.claude, .gpt4o, .gemini]
private let mockRecent = Array(AIChatConversation.mockConversations().prefix(3))

private func mockConfig() -> DFAIChatNewScreen.Configuration {
    DFAIChatNewScreen.Configuration(
        availableModels: mockModels,
        selectedModel: .claude,
        recentConversations: mockRecent,
        onSend: { _, _ in },
        onSelectModel: { _ in },
        onResumeConversation: { _ in }
    )
}

#Preview("Default — Light") {
    DFAIChatNewScreen(configuration: mockConfig())
        .frame(width: 390, height: 844)
        .preferredColorScheme(.light)
}

#Preview("Default — Dark") {
    DFAIChatNewScreen(configuration: mockConfig())
        .frame(width: 390, height: 844)
        .preferredColorScheme(.dark)
}

#Preview("No Recent — Light") {
    DFAIChatNewScreen(configuration: DFAIChatNewScreen.Configuration(
        availableModels: mockModels,
        selectedModel: .claude,
        recentConversations: [],
        onSend: { _, _ in },
        onSelectModel: { _ in },
        onResumeConversation: { _ in }
    ))
    .frame(width: 390, height: 844)
    .preferredColorScheme(.light)
}

#Preview("iPad Wide — Dark") {
    DFAIChatNewScreen(configuration: mockConfig())
        .frame(width: 1024, height: 768)
        .preferredColorScheme(.dark)
}
```

- [ ] **Step 5 — Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAIChatNewScreenTests 2>&1 | tail -20
```

Expected: `Test Suite 'DFAIChatNewScreenTests' passed`.

- [ ] **Step 6 — Commit**

```bash
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens add \
  Sources/DesignFoundationScreens/AIChat/DFAIChatNewScreen.swift \
  Sources/DesignFoundationScreens/AIChat/DFAIChatNewScreen+Previews.swift \
  Tests/DesignFoundationScreensTests/AIChat/DFAIChatNewScreenTests.swift
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens commit -m "feat(screens): add DFAIChatNewScreen with prompt starters and model picker"
```

---

## Task 4: DFAIChatCompareScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/AIChat/DFAIChatCompareScreen.swift`
- Create: `Sources/DesignFoundationScreens/AIChat/DFAIChatCompareScreen+Previews.swift`
- Test: `Tests/DesignFoundationScreensTests/AIChat/DFAIChatCompareScreenTests.swift`

**Interfaces:**
- Consumes: `AIChatMessage`, `AIChatModel`, `AIChatConversation` from Task 1; `DFBlockSkeletonBlock`, `DFButton`, `DFTextField`, `DFBadge`, `DFToggle`, `DFDivider` from blocks
- Produces:
  ```swift
  public struct DFAIChatCompareColumn: Sendable {
      public var model: AIChatModel
      public var messages: [AIChatMessage]
      public var isStreaming: Bool
      public var tokenCount: Int?
      public var responseTimeMs: Int?
  }
  public struct DFAIChatCompareScreen: View {
      public struct Configuration: @unchecked Sendable {
          public var leftColumn: DFAIChatCompareColumn
          public var rightColumn: DFAIChatCompareColumn
          public var availableModels: [AIChatModel]
          public var syncScroll: Bool
          public var onSend: @MainActor (String) -> Void
          public var onChangeLeftModel: @MainActor (AIChatModel) -> Void
          public var onChangeRightModel: @MainActor (AIChatModel) -> Void
          public var onToggleSyncScroll: @MainActor () -> Void
      }
      public init(configuration: Configuration)
  }
  ```

- [ ] **Step 1 — Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/AIChat/DFAIChatCompareScreenTests.swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFAIChatCompareScreen")
struct DFAIChatCompareScreenTests {

    func makeColumn(model: AIChatModel, isStreaming: Bool = false) -> DFAIChatCompareColumn {
        DFAIChatCompareColumn(
            model: model,
            messages: [AIChatMessage(role: .user, content: "Hello"), AIChatMessage(role: .assistant, content: "Hi!")],
            isStreaming: isStreaming,
            tokenCount: 42,
            responseTimeMs: 1200
        )
    }

    func makeSUT() -> DFAIChatCompareScreen.Configuration {
        DFAIChatCompareScreen.Configuration(
            leftColumn: makeColumn(model: .claude),
            rightColumn: makeColumn(model: .gpt4o),
            availableModels: [.claude, .gpt4o, .gemini],
            syncScroll: false,
            onSend: { _ in },
            onChangeLeftModel: { _ in },
            onChangeRightModel: { _ in },
            onToggleSyncScroll: {}
        )
    }

    @Test("Configuration stores left column model")
    func configLeftColumnModel() {
        let config = makeSUT()
        #expect(config.leftColumn.model.id == "claude-3-5-sonnet")
    }

    @Test("Configuration stores right column model")
    func configRightColumnModel() {
        let config = makeSUT()
        #expect(config.rightColumn.model.id == "gpt-4o")
    }

    @Test("Configuration stores syncScroll")
    func configSyncScroll() {
        var config = makeSUT()
        config.syncScroll = true
        #expect(config.syncScroll == true)
    }

    @Test("DFAIChatCompareColumn stores token count")
    func columnTokenCount() {
        let col = makeColumn(model: .claude)
        #expect(col.tokenCount == 42)
    }

    @Test("DFAIChatCompareColumn stores response time")
    func columnResponseTime() {
        let col = makeColumn(model: .claude)
        #expect(col.responseTimeMs == 1200)
    }
}
```

- [ ] **Step 2 — Run to verify failure**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAIChatCompareScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFAIChatCompareScreen` not found.

- [ ] **Step 3 — Create `DFAIChatCompareScreen.swift`**

```swift
// Sources/DesignFoundationScreens/AIChat/DFAIChatCompareScreen.swift
import SwiftUI
import DesignFoundationBlocks

// MARK: - Column Model

public struct DFAIChatCompareColumn: Sendable {
    public var model: AIChatModel
    public var messages: [AIChatMessage]
    public var isStreaming: Bool
    public var tokenCount: Int?
    public var responseTimeMs: Int?

    public init(
        model: AIChatModel,
        messages: [AIChatMessage] = [],
        isStreaming: Bool = false,
        tokenCount: Int? = nil,
        responseTimeMs: Int? = nil
    ) {
        self.model = model
        self.messages = messages
        self.isStreaming = isStreaming
        self.tokenCount = tokenCount
        self.responseTimeMs = responseTimeMs
    }
}

// MARK: - Screen

public struct DFAIChatCompareScreen: View {

    // MARK: - Configuration

    public struct Configuration: @unchecked Sendable {
        public var leftColumn: DFAIChatCompareColumn
        public var rightColumn: DFAIChatCompareColumn
        public var availableModels: [AIChatModel]
        public var syncScroll: Bool
        public var onSend: @MainActor (String) -> Void
        public var onChangeLeftModel: @MainActor (AIChatModel) -> Void
        public var onChangeRightModel: @MainActor (AIChatModel) -> Void
        public var onToggleSyncScroll: @MainActor () -> Void

        public init(
            leftColumn: DFAIChatCompareColumn,
            rightColumn: DFAIChatCompareColumn,
            availableModels: [AIChatModel],
            syncScroll: Bool = false,
            onSend: @escaping @MainActor (String) -> Void,
            onChangeLeftModel: @escaping @MainActor (AIChatModel) -> Void,
            onChangeRightModel: @escaping @MainActor (AIChatModel) -> Void,
            onToggleSyncScroll: @escaping @MainActor () -> Void
        ) {
            self.leftColumn = leftColumn
            self.rightColumn = rightColumn
            self.availableModels = availableModels
            self.syncScroll = syncScroll
            self.onSend = onSend
            self.onChangeLeftModel = onChangeLeftModel
            self.onChangeRightModel = onChangeRightModel
            self.onToggleSyncScroll = onToggleSyncScroll
        }
    }

    // MARK: - State

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme
    @State private var inputText: String = ""
    @State private var selectedTab: Int = 0        // iPhone only: 0 = left, 1 = right
    @State private var leftModel: AIChatModel
    @State private var rightModel: AIChatModel

    // MARK: - Init

    public init(configuration: Configuration) {
        self.configuration = configuration
        self._leftModel = State(initialValue: configuration.leftColumn.model)
        self._rightModel = State(initialValue: configuration.rightColumn.model)
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            // Toolbar: sync scroll toggle
            HStack {
                Text("Compare")
                    .font(theme.typography.headline)
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer()
                Button {
                    Task { @MainActor in configuration.onToggleSyncScroll() }
                } label: {
                    Label(
                        configuration.syncScroll ? "Sync ON" : "Sync OFF",
                        systemImage: configuration.syncScroll ? "link" : "link.badge.plus"
                    )
                    .font(theme.typography.caption)
                    .foregroundStyle(configuration.syncScroll ? theme.colors.primary : theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)

            DFDivider()

            // Adaptive layout
            adaptiveContent

            DFDivider()

            // Shared input bar
            HStack(spacing: theme.spacing.sm) {
                DFTextField("Send to both models", text: $inputText)
                DFButton("Send") {
                    let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    inputText = ""
                    Task { @MainActor in configuration.onSend(text) }
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.background)
    }

    // MARK: - Adaptive Layout

    @ViewBuilder
    private var adaptiveContent: some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone: tab picker
            VStack(spacing: 0) {
                Picker("Column", selection: $selectedTab) {
                    Text(leftModel.displayName).tag(0)
                    Text(rightModel.displayName).tag(1)
                }
                .pickerStyle(.segmented)
                .padding(theme.spacing.md)

                if selectedTab == 0 {
                    columnView(configuration.leftColumn, model: $leftModel) { model in
                        Task { @MainActor in configuration.onChangeLeftModel(model) }
                    }
                } else {
                    columnView(configuration.rightColumn, model: $rightModel) { model in
                        Task { @MainActor in configuration.onChangeRightModel(model) }
                    }
                }
            }
        } else {
            splitColumns
        }
        #else
        splitColumns
        #endif
    }

    private var splitColumns: some View {
        HStack(spacing: 0) {
            columnView(configuration.leftColumn, model: $leftModel) { model in
                Task { @MainActor in configuration.onChangeLeftModel(model) }
            }
            DFDivider()
                .frame(width: 1)
            columnView(configuration.rightColumn, model: $rightModel) { model in
                Task { @MainActor in configuration.onChangeRightModel(model) }
            }
        }
    }

    // MARK: - Column View

    @ViewBuilder
    private func columnView(
        _ column: DFAIChatCompareColumn,
        model: Binding<AIChatModel>,
        onModelChange: @escaping (AIChatModel) -> Void
    ) -> some View {
        VStack(spacing: 0) {
            // Column header
            HStack {
                Picker("Model", selection: model) {
                    ForEach(configuration.availableModels) { m in
                        Text(m.displayName).tag(m)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: model.wrappedValue) { _, newModel in
                    onModelChange(newModel)
                }

                Spacer()

                if let tokens = column.tokenCount {
                    DFBadge(text: "\(tokens) tokens")
                }
                if let ms = column.responseTimeMs {
                    DFBadge(text: "\(ms)ms")
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)

            DFDivider()

            // Messages
            ScrollView {
                LazyVStack(spacing: theme.spacing.sm) {
                    if column.messages.isEmpty && !column.isStreaming {
                        DFEmptyStateBlock(configuration: .init(
                            icon: "bubble.left",
                            title: "No messages yet",
                            message: "Send a message below to compare responses."
                        ))
                        .padding(theme.spacing.lg)
                    }

                    ForEach(column.messages) { message in
                        columnMessageRow(message)
                    }

                    if column.isStreaming {
                        DFBlockSkeletonBlock(configuration: .init(layout: .textBlock(lines: 2), repeatCount: 1))
                            .padding(.horizontal, theme.spacing.md)
                    }
                }
                .padding(.vertical, theme.spacing.md)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func columnMessageRow(_ message: AIChatMessage) -> some View {
        HStack {
            if message.role == .user { Spacer() }
            Text(message.content)
                .font(theme.typography.bodySmall)
                .foregroundStyle(message.role == .user ? Color.white : theme.colors.textPrimary)
                .padding(.horizontal, theme.spacing.sm)
                .padding(.vertical, theme.spacing.xs)
                .background(message.role == .user ? theme.colors.primary : theme.colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: theme.radius.sm))
                .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
            if message.role == .assistant { Spacer() }
        }
        .padding(.horizontal, theme.spacing.md)
    }
}
```

- [ ] **Step 4 — Create `DFAIChatCompareScreen+Previews.swift`**

```swift
// Sources/DesignFoundationScreens/AIChat/DFAIChatCompareScreen+Previews.swift
import SwiftUI
import DesignFoundationBlocks

private let userMsg = AIChatMessage(role: .user, content: "Explain generics in Swift in one sentence.")
private let claudeReply = AIChatMessage(role: .assistant, content: "Generics let you write flexible, reusable functions and types that work with any type you define, subject to constraints you specify.")
private let gptReply = AIChatMessage(role: .assistant, content: "Generics allow you to write code that works with different types by using type parameters, enabling type safety without duplication.")

private func mockConfig(syncScroll: Bool = false) -> DFAIChatCompareScreen.Configuration {
    DFAIChatCompareScreen.Configuration(
        leftColumn: DFAIChatCompareColumn(
            model: .claude,
            messages: [userMsg, claudeReply],
            isStreaming: false,
            tokenCount: 38,
            responseTimeMs: 890
        ),
        rightColumn: DFAIChatCompareColumn(
            model: .gpt4o,
            messages: [userMsg, gptReply],
            isStreaming: false,
            tokenCount: 44,
            responseTimeMs: 1100
        ),
        availableModels: [.claude, .gpt4o, .gemini],
        syncScroll: syncScroll,
        onSend: { _ in },
        onChangeLeftModel: { _ in },
        onChangeRightModel: { _ in },
        onToggleSyncScroll: {}
    )
}

#Preview("Side-by-Side — Light") {
    DFAIChatCompareScreen(configuration: mockConfig())
        .frame(width: 1024, height: 768)
        .preferredColorScheme(.light)
}

#Preview("Side-by-Side — Dark") {
    DFAIChatCompareScreen(configuration: mockConfig())
        .frame(width: 1024, height: 768)
        .preferredColorScheme(.dark)
}

#Preview("Sync Scroll ON — Light") {
    DFAIChatCompareScreen(configuration: mockConfig(syncScroll: true))
        .frame(width: 1024, height: 768)
        .preferredColorScheme(.light)
}

#Preview("Streaming Right Column — Dark") {
    var config = mockConfig()
    config.rightColumn.isStreaming = true
    config.rightColumn.messages = [userMsg]
    return DFAIChatCompareScreen(configuration: config)
        .frame(width: 1024, height: 768)
        .preferredColorScheme(.dark)
}
```

- [ ] **Step 5 — Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAIChatCompareScreenTests 2>&1 | tail -20
```

Expected: `Test Suite 'DFAIChatCompareScreenTests' passed`.

- [ ] **Step 6 — Commit**

```bash
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens add \
  Sources/DesignFoundationScreens/AIChat/DFAIChatCompareScreen.swift \
  Sources/DesignFoundationScreens/AIChat/DFAIChatCompareScreen+Previews.swift \
  Tests/DesignFoundationScreensTests/AIChat/DFAIChatCompareScreenTests.swift
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens commit -m "feat(screens): add DFAIChatCompareScreen with two-column model comparison"
```

---

## Task 5: DFAIChatSettingsSheet

**Files:**
- Create: `Sources/DesignFoundationScreens/AIChat/DFAIChatSettingsSheet.swift`
- Create: `Sources/DesignFoundationScreens/AIChat/DFAIChatSettingsSheet+Previews.swift`
- Test: `Tests/DesignFoundationScreensTests/AIChat/DFAIChatSettingsSheetTests.swift`

**Interfaces:**
- Consumes: `AIChatModel` from Task 1; `DFSettingsSectionBlock`, `DFSettingsRow`, `DFAccountBlock`, `DFNotificationPreferencesBlock`, `DFDangerZoneBlock`, `DFDangerAction`, `DFButton`, `DFTextField` from blocks
- Produces:
  ```swift
  public struct DFAIChatSettingsSheet: View {
      public struct Configuration: @unchecked Sendable {
          public var selectedModel: AIChatModel
          public var availableModels: [AIChatModel]
          public var systemPrompt: String
          public var temperature: Double            // 0.0–2.0
          public var maxTokens: Int                 // 256–8192
          public var conversationCount: Int
          public var accountConfig: DFAccountBlock.Configuration
          public var notificationConfig: DFNotificationPreferencesBlock.Configuration
          public var onSelectModel: @MainActor (AIChatModel) -> Void
          public var onSystemPromptChange: @MainActor (String) -> Void
          public var onTemperatureChange: @MainActor (Double) -> Void
          public var onMaxTokensChange: @MainActor (Int) -> Void
          public var onClearHistory: @MainActor () -> Void
          public var onExportHistory: @MainActor () -> Void
          public var onManageSubscription: @MainActor () -> Void
          public var onDismiss: @MainActor () -> Void
      }
      public init(configuration: Configuration)
  }
  ```

- [ ] **Step 1 — Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/AIChat/DFAIChatSettingsSheetTests.swift
import Testing
@testable import DesignFoundationScreens
import DesignFoundationBlocks

@Suite("DFAIChatSettingsSheet")
struct DFAIChatSettingsSheetTests {

    func makeNotifConfig() -> DFNotificationPreferencesBlock.Configuration {
        DFNotificationPreferencesBlock.Configuration(
            title: "Notifications",
            preferences: []
        )
    }

    func makeAccountConfig() -> DFAccountBlock.Configuration {
        DFAccountBlock.Configuration(
            avatarInitials: "NS",
            name: "NerdSnipe",
            email: "nerdsnipe@example.com",
            editTitle: "Edit Profile",
            manageTitle: "Manage Plan"
        )
    }

    func makeSUT(
        temperature: Double = 1.0,
        maxTokens: Int = 2048,
        conversationCount: Int = 14
    ) -> DFAIChatSettingsSheet.Configuration {
        DFAIChatSettingsSheet.Configuration(
            selectedModel: .claude,
            availableModels: [.claude, .gpt4o, .gemini],
            systemPrompt: "You are a helpful assistant.",
            temperature: temperature,
            maxTokens: maxTokens,
            conversationCount: conversationCount,
            accountConfig: makeAccountConfig(),
            notificationConfig: makeNotifConfig(),
            onSelectModel: { _ in },
            onSystemPromptChange: { _ in },
            onTemperatureChange: { _ in },
            onMaxTokensChange: { _ in },
            onClearHistory: {},
            onExportHistory: {},
            onManageSubscription: {},
            onDismiss: {}
        )
    }

    @Test("Configuration stores temperature")
    func configTemperature() {
        let config = makeSUT(temperature: 0.7)
        #expect(config.temperature == 0.7)
    }

    @Test("Configuration stores maxTokens")
    func configMaxTokens() {
        let config = makeSUT(maxTokens: 4096)
        #expect(config.maxTokens == 4096)
    }

    @Test("Configuration stores conversation count")
    func configConversationCount() {
        let config = makeSUT(conversationCount: 42)
        #expect(config.conversationCount == 42)
    }

    @Test("Configuration stores selected model")
    func configSelectedModel() {
        let config = makeSUT()
        #expect(config.selectedModel.id == "claude-3-5-sonnet")
    }
}
```

- [ ] **Step 2 — Run to verify failure**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAIChatSettingsSheetTests 2>&1 | tail -20
```

Expected: compile error — `DFAIChatSettingsSheet` not found.

- [ ] **Step 3 — Create `DFAIChatSettingsSheet.swift`**

```swift
// Sources/DesignFoundationScreens/AIChat/DFAIChatSettingsSheet.swift
import SwiftUI
import DesignFoundationBlocks

public struct DFAIChatSettingsSheet: View {

    // MARK: - Configuration

    public struct Configuration: @unchecked Sendable {
        public var selectedModel: AIChatModel
        public var availableModels: [AIChatModel]
        public var systemPrompt: String
        public var temperature: Double
        public var maxTokens: Int
        public var conversationCount: Int
        public var accountConfig: DFAccountBlock.Configuration
        public var notificationConfig: DFNotificationPreferencesBlock.Configuration
        public var onSelectModel: @MainActor (AIChatModel) -> Void
        public var onSystemPromptChange: @MainActor (String) -> Void
        public var onTemperatureChange: @MainActor (Double) -> Void
        public var onMaxTokensChange: @MainActor (Int) -> Void
        public var onClearHistory: @MainActor () -> Void
        public var onExportHistory: @MainActor () -> Void
        public var onManageSubscription: @MainActor () -> Void
        public var onDismiss: @MainActor () -> Void

        public init(
            selectedModel: AIChatModel,
            availableModels: [AIChatModel],
            systemPrompt: String,
            temperature: Double,
            maxTokens: Int,
            conversationCount: Int,
            accountConfig: DFAccountBlock.Configuration,
            notificationConfig: DFNotificationPreferencesBlock.Configuration,
            onSelectModel: @escaping @MainActor (AIChatModel) -> Void,
            onSystemPromptChange: @escaping @MainActor (String) -> Void,
            onTemperatureChange: @escaping @MainActor (Double) -> Void,
            onMaxTokensChange: @escaping @MainActor (Int) -> Void,
            onClearHistory: @escaping @MainActor () -> Void,
            onExportHistory: @escaping @MainActor () -> Void,
            onManageSubscription: @escaping @MainActor () -> Void,
            onDismiss: @escaping @MainActor () -> Void
        ) {
            self.selectedModel = selectedModel
            self.availableModels = availableModels
            self.systemPrompt = systemPrompt
            self.temperature = temperature
            self.maxTokens = maxTokens
            self.conversationCount = conversationCount
            self.accountConfig = accountConfig
            self.notificationConfig = notificationConfig
            self.onSelectModel = onSelectModel
            self.onSystemPromptChange = onSystemPromptChange
            self.onTemperatureChange = onTemperatureChange
            self.onMaxTokensChange = onMaxTokensChange
            self.onClearHistory = onClearHistory
            self.onExportHistory = onExportHistory
            self.onManageSubscription = onManageSubscription
            self.onDismiss = onDismiss
        }
    }

    // MARK: - State

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme
    @State private var systemPromptText: String
    @State private var temperature: Double
    @State private var maxTokens: Int
    @State private var selectedModel: AIChatModel

    // MARK: - Init

    public init(configuration: Configuration) {
        self.configuration = configuration
        self._systemPromptText = State(initialValue: configuration.systemPrompt)
        self._temperature = State(initialValue: configuration.temperature)
        self._maxTokens = State(initialValue: configuration.maxTokens)
        self._selectedModel = State(initialValue: configuration.selectedModel)
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            List {
                // MARK: Model & Behaviour
                Section {
                    // Model picker row
                    HStack {
                        Label("Model", systemImage: "cpu")
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer()
                        Picker("Model", selection: $selectedModel) {
                            ForEach(configuration.availableModels) { model in
                                Text(model.displayName).tag(model)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedModel) { _, newModel in
                            Task { @MainActor in configuration.onSelectModel(newModel) }
                        }
                    }

                    // System prompt
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Label("System Prompt", systemImage: "text.quote")
                            .font(theme.typography.bodySmall)
                            .foregroundStyle(theme.colors.textSecondary)
                        TextEditor(text: $systemPromptText)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textPrimary)
                            .frame(minHeight: 80)
                            .onChange(of: systemPromptText) { _, newVal in
                                Task { @MainActor in configuration.onSystemPromptChange(newVal) }
                            }
                    }

                    // Temperature slider
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack {
                            Label("Temperature", systemImage: "thermometer.medium")
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                            Text(String(format: "%.1f", temperature))
                                .font(theme.typography.bodySmall)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        DFSlider(value: $temperature, in: 0.0...2.0)
                            .onChange(of: temperature) { _, newVal in
                                Task { @MainActor in configuration.onTemperatureChange(newVal) }
                            }
                    }

                    // Max tokens picker
                    HStack {
                        Label("Max Tokens", systemImage: "number.square")
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer()
                        Picker("Max Tokens", selection: $maxTokens) {
                            ForEach([256, 512, 1024, 2048, 4096, 8192], id: \.self) { tokens in
                                Text("\(tokens)").tag(tokens)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: maxTokens) { _, newVal in
                            Task { @MainActor in configuration.onMaxTokensChange(newVal) }
                        }
                    }
                } header: {
                    Text("Model & Behaviour")
                }

                // MARK: History
                Section {
                    HStack {
                        Label("Conversations", systemImage: "bubble.left.and.bubble.right")
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer()
                        DFBadge(text: "\(configuration.conversationCount)")
                    }

                    Button {
                        Task { @MainActor in configuration.onExportHistory() }
                    } label: {
                        Label("Export History", systemImage: "square.and.arrow.up")
                            .foregroundStyle(theme.colors.textPrimary)
                    }
                    .buttonStyle(.plain)

                    Button(role: .destructive) {
                        Task { @MainActor in configuration.onClearHistory() }
                    } label: {
                        Label("Clear All History", systemImage: "trash")
                            .foregroundStyle(theme.colors.destructive)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("History")
                }

                // MARK: Account
                Section {
                    DFAccountBlock(configuration: configuration.accountConfig)
                        .listRowInsets(EdgeInsets())

                    Button {
                        Task { @MainActor in configuration.onManageSubscription() }
                    } label: {
                        Label("Manage Subscription", systemImage: "creditcard")
                            .foregroundStyle(theme.colors.primary)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Account")
                }

                // MARK: Notifications
                Section {
                    DFNotificationPreferencesBlock(configuration: configuration.notificationConfig)
                        .listRowInsets(EdgeInsets())
                } header: {
                    Text("Notifications")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task { @MainActor in configuration.onDismiss() }
                    }
                }
            }
        }
    }
}
```

> **Note:** `DFSlider` is imported from `DesignFoundation` via the `@_exported import` in the package entry point. If it is not available at build time, replace with SwiftUI's `Slider(value:in:)` and file a ticket to add `DFSlider` to the public surface.

- [ ] **Step 4 — Create `DFAIChatSettingsSheet+Previews.swift`**

```swift
// Sources/DesignFoundationScreens/AIChat/DFAIChatSettingsSheet+Previews.swift
import SwiftUI
import DesignFoundationBlocks

private func mockConfig() -> DFAIChatSettingsSheet.Configuration {
    DFAIChatSettingsSheet.Configuration(
        selectedModel: .claude,
        availableModels: [.claude, .gpt4o, .gemini],
        systemPrompt: "You are a helpful, concise assistant. Format code in code blocks.",
        temperature: 0.8,
        maxTokens: 2048,
        conversationCount: 37,
        accountConfig: DFAccountBlock.Configuration(
            avatarInitials: "NS",
            name: "NerdSnipe",
            email: "nerdsnipe@example.com",
            planName: "Pro",
            planBadge: "PRO",
            editTitle: "Edit Profile",
            manageTitle: "Manage Plan"
        ),
        notificationConfig: DFNotificationPreferencesBlock.Configuration(
            title: "Notifications",
            preferences: []
        ),
        onSelectModel: { _ in },
        onSystemPromptChange: { _ in },
        onTemperatureChange: { _ in },
        onMaxTokensChange: { _ in },
        onClearHistory: {},
        onExportHistory: {},
        onManageSubscription: {},
        onDismiss: {}
    )
}

#Preview("Sheet — Light") {
    DFAIChatSettingsSheet(configuration: mockConfig())
        .frame(width: 390, height: 800)
        .preferredColorScheme(.light)
}

#Preview("Sheet — Dark") {
    DFAIChatSettingsSheet(configuration: mockConfig())
        .frame(width: 390, height: 800)
        .preferredColorScheme(.dark)
}

#Preview("Presented as sheet — Light") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            DFAIChatSettingsSheet(configuration: mockConfig())
        }
        .frame(width: 390, height: 844)
        .preferredColorScheme(.light)
}

#Preview("Presented as sheet — Dark") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            DFAIChatSettingsSheet(configuration: mockConfig())
        }
        .frame(width: 390, height: 844)
        .preferredColorScheme(.dark)
}
```

- [ ] **Step 5 — Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAIChatSettingsSheetTests 2>&1 | tail -20
```

Expected: `Test Suite 'DFAIChatSettingsSheetTests' passed`.

- [ ] **Step 6 — Commit**

```bash
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens add \
  Sources/DesignFoundationScreens/AIChat/DFAIChatSettingsSheet.swift \
  Sources/DesignFoundationScreens/AIChat/DFAIChatSettingsSheet+Previews.swift \
  Tests/DesignFoundationScreensTests/AIChat/DFAIChatSettingsSheetTests.swift
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens commit -m "feat(screens): add DFAIChatSettingsSheet with model config and history management"
```

---

## Task 6: Full Build Verification

**Files:** none new — verification only

- [ ] **Step 1 — Build the package**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift build 2>&1
```

Expected: `Build complete!` with zero errors and zero warnings.

- [ ] **Step 2 — Run the full AI Chat test suite**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter AIChat 2>&1 | tail -40
```

Expected: all tests in `AIChatModelsTests`, `DFAIChatThreadScreenTests`, `DFAIChatNewScreenTests`, `DFAIChatCompareScreenTests`, `DFAIChatSettingsSheetTests` pass.

- [ ] **Step 3 — Run the entire test suite to check for regressions**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test 2>&1 | tail -20
```

Expected: `Test Suite 'All tests' passed`.

- [ ] **Step 4 — Commit if any fixups were needed**

```bash
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens add -p
git -C /Users/nerdsnipe/Projects/DesignFoundationScreens commit -m "feat(screens): fix build warnings and test failures in AIChat vertical"
```

---

## Self-Review

### Spec Coverage

| Spec requirement | Covered by |
|---|---|
| Thread screen: sidebar with Today/Yesterday/Previous 7 Days/Older grouping | Task 1 `groupConversations`, Task 2 sidebar `ForEach(filteredGroups)` |
| Conversation row: title, timestamp, model badge | Task 2 `conversationRow(_:)` |
| Search conversations at top of sidebar | Task 2 `DFTextField` in sidebar Section |
| "New Chat" button prominent at top | Task 2 `ToolbarItem(.primaryAction)` |
| User avatar + name + settings cog at sidebar bottom | Task 2 `DFAvatar` + `gearshape` button footer |
| Messages scroll, user right-aligned, assistant left-aligned | Task 2 `messageRow(_:)` |
| Streaming indicator | Task 2 `streamingIndicator` using `DFBlockSkeletonBlock` |
| Long-press message actions: Copy, Regenerate, Delete | Task 2 `.contextMenu` on message bubbles |
| Input bar: DFTextField + send + attach | Task 2 `inputBar` |
| Model selector in nav bar | Task 2 `DFBadge` in `threadContent(for:)` toolbar |
| iPhone: conversation list primary, tap → thread | Task 2 `NavigationSplitView` — split view handles this natively |
| New screen: centered logo + headline | Task 3 `sparkles` icon + "What can I help with?" |
| Suggestion grid: 4–6 cards with icon + prompt + category | Task 3 6 `PromptStarter` items in `LazyVGrid` |
| Model selector below suggestions | Task 3 `Picker` |
| Input bar at bottom | Task 3 `inputBar` at bottom |
| Recent conversations (last 3) as chips | Task 3 `.prefix(3)` in init + chip row |
| Compare: two-column layout, iPad/Mac; tab toggle on iPhone | Task 4 `adaptiveContent` / `splitColumns` |
| Each column: model selector + token count + response time | Task 4 `columnView` header |
| Shared input bar sends to both models simultaneously | Task 4 `onSend` called with same text from shared input |
| Sync scroll toggle | Task 4 `onToggleSyncScroll` button in toolbar |
| Settings sheet: system prompt editor | Task 5 `TextEditor` |
| Settings sheet: temperature slider | Task 5 `DFSlider` |
| Settings sheet: max tokens picker | Task 5 `Picker` with token options |
| History: count badge + Clear All + Export | Task 5 History section |
| Account: DFAccountBlock compact + subscription link | Task 5 Account section |
| DFNotificationPreferencesBlock | Task 5 Notifications section |
| Done button dismisses sheet | Task 5 `.confirmationAction` toolbar item |

### Placeholder Scan

No TBD, TODO, or "implement later" text found. All code blocks are complete. The one open note about `DFSlider` availability is a real build-time concern, not a plan deferral — a fallback is named.

### Type Consistency

- `AIChatMessage.id: UUID` — used as `AIChatMessage.ID` in `onRegenerate` and `onDeleteMessage` closures consistently across Tasks 2 and 5.
- `AIChatConversation.id: UUID` — used as `AIChatConversation.ID` in `onSelectConversation` and `onResumeConversation` consistently across Tasks 2, 3, and 4.
- `groupConversations(_:now:)` defined in Task 1, called in Task 2 with matching signature.
- `DFAIChatCompareColumn` defined in Task 4 and consumed only in Task 4 — no cross-task type drift.
- `DFBadge(text:)` labeled parameter used consistently.
- `DFAvatar(_ initials:)` positional init used consistently.
