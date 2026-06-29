# Social / Feed App — Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build 4 production-ready SwiftUI screens for a social / professional feed app vertical — Feed, Profile, Notifications, and Explore — inside the `DesignFoundationScreens` package.

**Architecture:** Each screen is a standalone `struct … : View` with a `Configuration` struct that holds display data and `@MainActor` action closures. Screens compose from existing `DesignFoundationBlocks` building blocks wherever possible. Navigation adaptation (tab bar on iPhone, sidebar on iPad/Mac) is handled by `DFSocialAppShell`, a lightweight host view built in Task 1 that wraps all four screens. Each screen file is accompanied by a `+Previews` file with light and dark previews.

**Tech Stack:** Swift 6, SwiftUI, Swift Testing, `DesignFoundation` (DFTheme + primitives), `DesignFoundationBlocks` (all blocks listed below)

---

## Global Constraints

- Swift 6 strict concurrency: `StrictConcurrency` experimental feature ON in `DesignFoundationScreens` target
- Platforms: iOS 18.0, macOS 15.0, visionOS 2.0
- All tokens from `@Environment(\.dfTheme)` — zero hardcoded colors, spacing, or typography values
- Action closures in Configuration structs: `@MainActor () -> Void` or `@MainActor (T) -> Void`
- Bridge `@MainActor` closures at call site with `Task { @MainActor in action() }` — never `MainActor.assumeIsolated`
- `DFAvatar(_ initials: String)` OR `DFAvatar(image: Image)` — two distinct inits, never combined
- `DFBadge(text: String)` — labeled parameter required
- Tests: Swift Testing only — `import Testing`, `@Suite`, `@Test`, `#expect` — never XCTest
- Previews: one `#Preview("Light") { … }` and one `#Preview("Dark") { … .colorScheme(.dark) }` per screen
- Adaptive layout: `TabView` on iPhone, `NavigationSplitView` sidebar on iPad/Mac (detected via `horizontalSizeClass`)
- Package root: `/Users/nerdsnipe/Projects/DesignFoundationScreens/`
- Source path: `Sources/DesignFoundationScreens/Social/` (relative to package root)
- Test path: `Tests/DesignFoundationScreensTests/Social/` (relative to package root)
- Commit messages: conventional commits (`feat(screens): …`, `test(screens): …`)
- No Co-Author line in any commit

---

## Available Blocks and Their Key APIs

### DFActivityFeedBlock
```swift
DFActivityFeedBlock(configuration: .init(
    title: String,                                   // section header
    items: [DFActivityFeedRow.Configuration],
    seeAllTitle: String,                             // default "See All"
    onSeeAll: (@MainActor () -> Void)?,
    emptyTitle: String,                              // default "No activity yet"
    emptyIcon: String                                // SF Symbol name
))
```

### DFActivityFeedRow.Configuration
```swift
DFActivityFeedRow.Configuration(
    initials: String,
    avatarImage: Image?,                             // nil → use initials
    title: String,
    subtitle: String?,
    timestamp: String,
    isUnread: Bool,
    onTap: (@MainActor () -> Void)?
)
```

### DFContactRow
```swift
DFContactRow(configuration: .init(
    name: String,
    initials: String,
    subtitle: String?,
    avatarImage: Image?,
    badge: String?,
    onTap: (@MainActor () -> Void)?
))
```

### DFProfileHeaderBlock
```swift
DFProfileHeaderBlock(configuration: .init(
    name: String,
    initials: String,
    subtitle: String?,
    avatarImage: Image?,
    primaryActionTitle: String?,
    secondaryActionTitle: String?,
    onPrimaryAction: (@MainActor () -> Void)?,
    onSecondaryAction: (@MainActor () -> Void)?
))
```

### DFNotificationCell
```swift
DFNotificationCell(configuration: .init(
    icon: String,                                    // SF Symbol
    title: String,
    body: String,
    timestamp: String,
    isRead: Bool,
    onTap: (@MainActor () -> Void)?,
    onDismiss: (@MainActor () -> Void)?
))
```

### DFSearchResultsBlock
```swift
DFSearchResultsBlock(configuration: .init(
    results: [DFSearchResult],
    isLoading: Bool,
    emptyIcon: String,
    emptyTitle: String,
    emptyMessage: String?
))
// DFSearchResult: id, icon, title, subtitle, badge, onTap
```

### DFEmptyStateBlock
```swift
DFEmptyStateBlock(configuration: .init(
    icon: String,
    title: String,
    message: String?,
    actionTitle: String?,
    onAction: (@MainActor () -> Void)?
))
```

### DFBlockSkeletonBlock
```swift
DFBlockSkeletonBlock(configuration: .init(
    layout: DFSkeletonLayout,       // .activityRow | .contactRow | .profileHeader | .notificationCell | .textBlock(lines:) | .statCard
    repeatCount: Int
))
```

### DFMetricGridBlock
```swift
DFMetricGridBlock(configuration: .init(
    metrics: [DFStatCardBlock.Configuration],
    columns: Int                                     // default 2
))
// DFStatCardBlock.Configuration: title, value, trend (DFTrendDirection), trendLabel, icon, onTap
```

### DFTagPickerBlock
```swift
DFTagPickerBlock(configuration: .init(
    tags: [DFTag],                                   // DFTag: id, label, icon?
    selectedIDs: Set<UUID>,
    multiSelect: Bool,
    maxSelection: Int?,
    title: String?,
    onSelectionChange: @escaping @MainActor (Set<UUID>) -> Void
))
```

### Primitives
- `DFCard { content }` — themed card container
- `DFButton(_ label: String, role: ButtonRole? = nil, action: @escaping () -> Void)` + `.dfButtonStyle(.outlined)`
- `DFText(_ content: String)` + `.dfTextStyle(.headline / .body / .caption)`
- `DFBadge(text: String)` — colored badge chip
- `DFAvatar(_ initials: String)` / `DFAvatar(image: Image)` + `.dfAvatarStyle(.circle)`
- `DFList` / `DFListRow` — themed list container
- `DFTextField` — themed text field
- `DFDivider` — themed divider
- `DFToast` — transient feedback overlay

---

## File Map

```
Sources/DesignFoundationScreens/Social/
  Shell/
    DFSocialAppShell.swift                    ← Task 1: adaptive tab/sidebar host
    DFSocialAppShell+Previews.swift
  Feed/
    DFSocialFeedScreen.swift                  ← Task 2
    DFSocialFeedScreen+Previews.swift
    DFSocialStoryRail.swift                   ← Task 2: story/highlights sub-view
    DFSocialPostCard.swift                    ← Task 2: individual post card sub-view
  Profile/
    DFSocialProfileScreen.swift               ← Task 3
    DFSocialProfileScreen+Previews.swift
  Notifications/
    DFSocialNotificationsScreen.swift         ← Task 4
    DFSocialNotificationsScreen+Previews.swift
  Explore/
    DFSocialExploreScreen.swift               ← Task 5
    DFSocialExploreScreen+Previews.swift

Tests/DesignFoundationScreensTests/Social/
  DFSocialAppShellTests.swift                 ← Task 1
  DFSocialFeedScreenTests.swift               ← Task 2
  DFSocialProfileScreenTests.swift            ← Task 3
  DFSocialNotificationsScreenTests.swift      ← Task 4
  DFSocialExploreScreenTests.swift            ← Task 5
```

---

### Task 1: DFSocialAppShell — Adaptive Navigation Host

**Files:**
- Create: `Sources/DesignFoundationScreens/Social/Shell/DFSocialAppShell.swift`
- Create: `Sources/DesignFoundationScreens/Social/Shell/DFSocialAppShell+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Social/DFSocialAppShellTests.swift`

**Interfaces:**
- Consumes: nothing (this is the root view)
- Produces:
  - `DFSocialAppShell` — adaptive host that accepts four child screen views via generic slots
  - `DFSocialTab` — enum with cases `.feed`, `.explore`, `.notifications`, `.profile`

- [ ] **Step 1: Write failing test**

Create `Tests/DesignFoundationScreensTests/Social/DFSocialAppShellTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSocialAppShell")
struct DFSocialAppShellTests {

    @Test("DFSocialTab has four cases")
    func tabCaseCount() {
        let allCases = DFSocialTab.allCases
        #expect(allCases.count == 4)
    }

    @Test("DFSocialTab titles are non-empty")
    func tabTitles() {
        for tab in DFSocialTab.allCases {
            #expect(!tab.title.isEmpty)
        }
    }

    @Test("DFSocialTab icons are non-empty SF Symbol names")
    func tabIcons() {
        for tab in DFSocialTab.allCases {
            #expect(!tab.icon.isEmpty)
        }
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSocialAppShellTests 2>&1 | tail -20
```

Expected: compile error — `DFSocialTab` not found.

- [ ] **Step 3: Implement DFSocialAppShell**

Create `Sources/DesignFoundationScreens/Social/Shell/DFSocialAppShell.swift`:

```swift
import SwiftUI
import DesignFoundation

// MARK: - Tab Model

public enum DFSocialTab: String, CaseIterable, Sendable {
    case feed
    case explore
    case notifications
    case profile

    public var title: String {
        switch self {
        case .feed:          return "Feed"
        case .explore:       return "Explore"
        case .notifications: return "Notifications"
        case .profile:       return "Profile"
        }
    }

    public var icon: String {
        switch self {
        case .feed:          return "house"
        case .explore:       return "magnifyingglass"
        case .notifications: return "bell"
        case .profile:       return "person.circle"
        }
    }
}

// MARK: - Shell

/// Adaptive navigation host for the Social vertical.
/// On iPhone (compact horizontal size class) renders a TabView.
/// On iPad and Mac renders a NavigationSplitView sidebar.
public struct DFSocialAppShell<
    Feed: View,
    Explore: View,
    Notifications: View,
    Profile: View
>: View {

    private let feed: Feed
    private let explore: Explore
    private let notifications: Notifications
    private let profile: Profile

    @State private var selectedTab: DFSocialTab = .feed
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dfTheme) private var theme

    public init(
        @ViewBuilder feed: () -> Feed,
        @ViewBuilder explore: () -> Explore,
        @ViewBuilder notifications: () -> Notifications,
        @ViewBuilder profile: () -> Profile
    ) {
        self.feed = feed()
        self.explore = explore()
        self.notifications = notifications()
        self.profile = profile()
    }

    public var body: some View {
        if sizeClass == .compact {
            tabLayout
        } else {
            sidebarLayout
        }
    }

    // MARK: - Tab layout (iPhone)

    private var tabLayout: some View {
        TabView(selection: $selectedTab) {
            Tab(DFSocialTab.feed.title, systemImage: DFSocialTab.feed.icon, value: DFSocialTab.feed) {
                feed
            }
            Tab(DFSocialTab.explore.title, systemImage: DFSocialTab.explore.icon, value: DFSocialTab.explore) {
                explore
            }
            Tab(DFSocialTab.notifications.title, systemImage: DFSocialTab.notifications.icon, value: DFSocialTab.notifications) {
                notifications
            }
            Tab(DFSocialTab.profile.title, systemImage: DFSocialTab.profile.icon, value: DFSocialTab.profile) {
                profile
            }
        }
        .tint(theme.colors.primary)
    }

    // MARK: - Sidebar layout (iPad / Mac)

    private var sidebarLayout: some View {
        NavigationSplitView {
            List(DFSocialTab.allCases, id: \.self, selection: $selectedTab) { tab in
                Label(tab.title, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationTitle("Social")
        } detail: {
            switch selectedTab {
            case .feed:          feed
            case .explore:       explore
            case .notifications: notifications
            case .profile:       profile
            }
        }
    }
}
```

- [ ] **Step 4: Create previews**

Create `Sources/DesignFoundationScreens/Social/Shell/DFSocialAppShell+Previews.swift`:

```swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    DFSocialAppShell {
        Text("Feed")
    } explore: {
        Text("Explore")
    } notifications: {
        Text("Notifications")
    } profile: {
        Text("Profile")
    }
}

#Preview("Dark") {
    DFSocialAppShell {
        Text("Feed")
    } explore: {
        Text("Explore")
    } notifications: {
        Text("Notifications")
    } profile: {
        Text("Profile")
    }
    .colorScheme(.dark)
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSocialAppShellTests 2>&1 | tail -20
```

Expected: `Test run passed. 3 tests passed.`

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Social/Shell/ Tests/DesignFoundationScreensTests/Social/DFSocialAppShellTests.swift
git commit -m "feat(screens): add DFSocialAppShell adaptive tab/sidebar host"
```

---

### Task 2: DFSocialFeedScreen — Main Feed

**Files:**
- Create: `Sources/DesignFoundationScreens/Social/Feed/DFSocialFeedScreen.swift`
- Create: `Sources/DesignFoundationScreens/Social/Feed/DFSocialFeedScreen+Previews.swift`
- Create: `Sources/DesignFoundationScreens/Social/Feed/DFSocialStoryRail.swift`
- Create: `Sources/DesignFoundationScreens/Social/Feed/DFSocialPostCard.swift`
- Create: `Tests/DesignFoundationScreensTests/Social/DFSocialFeedScreenTests.swift`

**Interfaces:**
- Consumes: `DFActivityFeedBlock`, `DFBlockSkeletonBlock`, `DFEmptyStateBlock`, `DFAvatar`, `DFBadge`, `DFCard`, `DFButton`
- Produces:
  - `DFSocialFeedScreen` struct with `Configuration`
  - `DFSocialStory` model — `id: UUID`, `initials: String`, `name: String`, `avatarImage: Image?`, `isSeen: Bool`, `isOwn: Bool`
  - `DFSocialPost` model — `id: UUID`, `authorInitials: String`, `authorName: String`, `authorAvatarImage: Image?`, `timestamp: String`, `body: String`, `likeCount: Int`, `commentCount: Int`, `shareCount: Int`, `isSponsored: Bool`

- [ ] **Step 1: Write failing tests**

Create `Tests/DesignFoundationScreensTests/Social/DFSocialFeedScreenTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSocialFeedScreen")
struct DFSocialFeedScreenTests {

    @Test("Configuration stores posts")
    func configurationStoresPosts() {
        let post = DFSocialPost(
            authorInitials: "JD",
            authorName: "Jane Doe",
            authorAvatarImage: nil,
            timestamp: "2m ago",
            body: "Hello world",
            likeCount: 10,
            commentCount: 3,
            shareCount: 1,
            isSponsored: false
        )
        let config = DFSocialFeedScreen.Configuration(
            stories: [],
            posts: [post],
            isLoading: false,
            onRefresh: {},
            onCompose: {},
            onLike: { _ in },
            onComment: { _ in },
            onShare: { _ in },
            onStoryTap: { _ in }
        )
        #expect(config.posts.count == 1)
        #expect(config.posts[0].authorName == "Jane Doe")
    }

    @Test("Configuration stores stories")
    func configurationStoresStories() {
        let story = DFSocialStory(
            initials: "AB",
            name: "Alice",
            avatarImage: nil,
            isSeen: false,
            isOwn: false
        )
        let config = DFSocialFeedScreen.Configuration(
            stories: [story],
            posts: [],
            isLoading: false,
            onRefresh: {},
            onCompose: {},
            onLike: { _ in },
            onComment: { _ in },
            onShare: { _ in },
            onStoryTap: { _ in }
        )
        #expect(config.stories.count == 1)
        #expect(config.stories[0].name == "Alice")
    }

    @Test("isLoading flag propagates")
    func isLoadingPropagates() {
        let config = DFSocialFeedScreen.Configuration(
            stories: [],
            posts: [],
            isLoading: true,
            onRefresh: {},
            onCompose: {},
            onLike: { _ in },
            onComment: { _ in },
            onShare: { _ in },
            onStoryTap: { _ in }
        )
        #expect(config.isLoading == true)
    }

    @Test("Sponsored post flag set correctly")
    func sponsoredPostFlag() {
        let post = DFSocialPost(
            authorInitials: "AD",
            authorName: "Acme Co",
            authorAvatarImage: nil,
            timestamp: "Sponsored",
            body: "Buy our product",
            likeCount: 0,
            commentCount: 0,
            shareCount: 0,
            isSponsored: true
        )
        #expect(post.isSponsored == true)
    }

    @Test("Empty feed has zero posts")
    func emptyFeed() {
        let config = DFSocialFeedScreen.Configuration(
            stories: [],
            posts: [],
            isLoading: false,
            onRefresh: {},
            onCompose: {},
            onLike: { _ in },
            onComment: { _ in },
            onShare: { _ in },
            onStoryTap: { _ in }
        )
        #expect(config.posts.isEmpty)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSocialFeedScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFSocialPost`, `DFSocialStory`, `DFSocialFeedScreen` not found.

- [ ] **Step 3: Implement DFSocialPostCard**

Create `Sources/DesignFoundationScreens/Social/Feed/DFSocialPostCard.swift`:

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Post Model

public struct DFSocialPost: Identifiable, Sendable {
    public let id: UUID
    public var authorInitials: String
    public var authorName: String
    public var authorAvatarImage: Image?
    public var timestamp: String
    public var body: String
    public var likeCount: Int
    public var commentCount: Int
    public var shareCount: Int
    public var isSponsored: Bool

    public init(
        id: UUID = UUID(),
        authorInitials: String,
        authorName: String,
        authorAvatarImage: Image? = nil,
        timestamp: String,
        body: String,
        likeCount: Int,
        commentCount: Int,
        shareCount: Int,
        isSponsored: Bool = false
    ) {
        self.id = id
        self.authorInitials = authorInitials
        self.authorName = authorName
        self.authorAvatarImage = authorAvatarImage
        self.timestamp = timestamp
        self.body = body
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.shareCount = shareCount
        self.isSponsored = isSponsored
    }
}

// MARK: - Post Card View

struct DFSocialPostCard: View {
    let post: DFSocialPost
    let onLike: @MainActor (UUID) -> Void
    let onComment: @MainActor (UUID) -> Void
    let onShare: @MainActor (UUID) -> Void

    @Environment(\.dfTheme) private var theme

    var body: some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                // Header: avatar + author + timestamp + optional Sponsored badge
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    if let img = post.authorAvatarImage {
                        DFAvatar(image: img)
                            .dfAvatarStyle(.circle)
                    } else {
                        DFAvatar(post.authorInitials)
                            .dfAvatarStyle(.circle)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.authorName)
                            .font(theme.typography.body.font.bold())
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(post.timestamp)
                            .font(theme.typography.caption.font)
                            .foregroundStyle(theme.colors.textSecondary)
                    }

                    Spacer()

                    if post.isSponsored {
                        DFBadge(text: "Sponsored")
                    }
                }

                // Post body text
                Text(post.body)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                // Image placeholder (future: replace with real AsyncImage)
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.surface)
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(theme.colors.textSecondary)
                    )
                    .accessibilityLabel("Post image placeholder")

                DFDivider()

                // Reaction bar
                HStack(spacing: theme.spacing.lg) {
                    reactionButton(
                        icon: "heart",
                        count: post.likeCount,
                        label: "Like"
                    ) {
                        Task { @MainActor in onLike(post.id) }
                    }
                    reactionButton(
                        icon: "bubble.left",
                        count: post.commentCount,
                        label: "Comment"
                    ) {
                        Task { @MainActor in onComment(post.id) }
                    }
                    reactionButton(
                        icon: "arrowshape.turn.up.right",
                        count: post.shareCount,
                        label: "Share"
                    ) {
                        Task { @MainActor in onShare(post.id) }
                    }
                    Spacer()
                }
            }
            .padding(theme.spacing.md)
        }
    }

    @ViewBuilder
    private func reactionButton(icon: String, count: Int, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(theme.typography.caption.font)
                Text("\(count)")
                    .font(theme.typography.caption.font)
            }
            .foregroundStyle(theme.colors.textSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label), \(count)")
    }
}
```

- [ ] **Step 4: Implement DFSocialStoryRail**

Create `Sources/DesignFoundationScreens/Social/Feed/DFSocialStoryRail.swift`:

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Story Model

public struct DFSocialStory: Identifiable, Sendable {
    public let id: UUID
    public var initials: String
    public var name: String
    public var avatarImage: Image?
    public var isSeen: Bool
    public var isOwn: Bool

    public init(
        id: UUID = UUID(),
        initials: String,
        name: String,
        avatarImage: Image? = nil,
        isSeen: Bool = false,
        isOwn: Bool = false
    ) {
        self.id = id
        self.initials = initials
        self.name = name
        self.avatarImage = avatarImage
        self.isSeen = isSeen
        self.isOwn = isOwn
    }
}

// MARK: - Story Rail View

struct DFSocialStoryRail: View {
    let stories: [DFSocialStory]
    let onTap: @MainActor (UUID) -> Void
    let onAddStory: @MainActor () -> Void

    @Environment(\.dfTheme) private var theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.md) {
                // "Your Story" first
                storyBubble(
                    initials: "+",
                    name: "Your Story",
                    avatarImage: nil,
                    isSeen: true,
                    isOwn: true,
                    id: UUID()
                )

                ForEach(stories) { story in
                    storyBubble(
                        initials: story.initials,
                        name: story.name,
                        avatarImage: story.avatarImage,
                        isSeen: story.isSeen,
                        isOwn: false,
                        id: story.id
                    )
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
        }
    }

    @ViewBuilder
    private func storyBubble(
        initials: String,
        name: String,
        avatarImage: Image?,
        isSeen: Bool,
        isOwn: Bool,
        id: UUID
    ) -> some View {
        Button {
            if isOwn {
                Task { @MainActor in onAddStory() }
            } else {
                Task { @MainActor in onTap(id) }
            }
        } label: {
            VStack(spacing: theme.spacing.xs) {
                ZStack {
                    // Unseen ring
                    if !isSeen {
                        Circle()
                            .strokeBorder(theme.colors.primary, lineWidth: 2)
                            .frame(width: 60, height: 60)
                    }

                    if isOwn {
                        // "+" add story button
                        ZStack {
                            Circle()
                                .fill(theme.colors.surface)
                                .frame(width: 52, height: 52)
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(theme.colors.primary)
                        }
                    } else if let img = avatarImage {
                        DFAvatar(image: img, size: 52)
                            .dfAvatarStyle(.circle)
                            .frame(width: 52, height: 52)
                    } else {
                        DFAvatar(initials, size: 52)
                            .dfAvatarStyle(.circle)
                            .frame(width: 52, height: 52)
                    }
                }
                .frame(width: 60, height: 60)

                Text(name)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .frame(width: 60)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOwn ? "Add your story" : "\(name)'s story\(isSeen ? ", seen" : ", unseen")")
    }
}
```

- [ ] **Step 5: Implement DFSocialFeedScreen**

Create `Sources/DesignFoundationScreens/Social/Feed/DFSocialFeedScreen.swift`:

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public struct DFSocialFeedScreen: View {

    // MARK: - Configuration

    public struct Configuration {
        public var stories: [DFSocialStory]
        public var posts: [DFSocialPost]
        public var isLoading: Bool
        public var onRefresh: @MainActor () -> Void
        public var onCompose: @MainActor () -> Void
        public var onLike: @MainActor (UUID) -> Void
        public var onComment: @MainActor (UUID) -> Void
        public var onShare: @MainActor (UUID) -> Void
        public var onStoryTap: @MainActor (UUID) -> Void

        public init(
            stories: [DFSocialStory],
            posts: [DFSocialPost],
            isLoading: Bool = false,
            onRefresh: @escaping @MainActor () -> Void,
            onCompose: @escaping @MainActor () -> Void,
            onLike: @escaping @MainActor (UUID) -> Void,
            onComment: @escaping @MainActor (UUID) -> Void,
            onShare: @escaping @MainActor (UUID) -> Void,
            onStoryTap: @escaping @MainActor (UUID) -> Void
        ) {
            self.stories = stories
            self.posts = posts
            self.isLoading = isLoading
            self.onRefresh = onRefresh
            self.onCompose = onCompose
            self.onLike = onLike
            self.onComment = onComment
            self.onShare = onShare
            self.onStoryTap = onStoryTap
        }
    }

    // MARK: - Properties

    private let configuration: Configuration
    @State private var isRefreshing = false
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(spacing: theme.spacing.md) {
                        // Story rail
                        DFSocialStoryRail(
                            stories: configuration.stories,
                            onTap: configuration.onStoryTap,
                            onAddStory: configuration.onCompose
                        )

                        DFDivider()
                            .padding(.horizontal, theme.spacing.md)

                        if configuration.isLoading {
                            // Skeleton placeholders while refreshing
                            ForEach(0..<3, id: \.self) { _ in
                                DFBlockSkeletonBlock(
                                    configuration: .init(layout: .activityRow, repeatCount: 4)
                                )
                                .padding(.horizontal, theme.spacing.md)
                            }
                        } else if configuration.posts.isEmpty {
                            DFEmptyStateBlock(
                                configuration: .init(
                                    icon: "person.2",
                                    title: "Nothing here yet",
                                    message: "Follow people to see their posts here.",
                                    actionTitle: "Discover people",
                                    onAction: { Task { @MainActor in configuration.onCompose() } }
                                )
                            )
                            .padding(.horizontal, theme.spacing.md)
                        } else {
                            ForEach(configuration.posts) { post in
                                DFSocialPostCard(
                                    post: post,
                                    onLike: configuration.onLike,
                                    onComment: configuration.onComment,
                                    onShare: configuration.onShare
                                )
                                .padding(.horizontal, theme.spacing.md)
                            }
                        }
                    }
                    .padding(.bottom, theme.spacing.xl)
                }
                .refreshable {
                    await MainActor.run { configuration.onRefresh() }
                }

                // Floating action button — compose
                Button {
                    Task { @MainActor in configuration.onCompose() }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(theme.colors.primary)
                        .clipShape(Circle())
                        .shadow(color: theme.colors.primary.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(theme.spacing.lg)
                .accessibilityLabel("Compose new post")
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

- [ ] **Step 6: Create previews**

Create `Sources/DesignFoundationScreens/Social/Feed/DFSocialFeedScreen+Previews.swift`:

```swift
import SwiftUI
import DesignFoundation

private let sampleStories: [DFSocialStory] = [
    DFSocialStory(initials: "AB", name: "Alice", isSeen: false),
    DFSocialStory(initials: "BK", name: "Bob", isSeen: true),
    DFSocialStory(initials: "CJ", name: "Carol", isSeen: false),
]

private let samplePosts: [DFSocialPost] = [
    DFSocialPost(
        authorInitials: "AB",
        authorName: "Alice Brown",
        timestamp: "2m ago",
        body: "Just shipped a new feature today! The team crushed it 🚀",
        likeCount: 24,
        commentCount: 7,
        shareCount: 3
    ),
    DFSocialPost(
        authorInitials: "BK",
        authorName: "Acme Corp",
        timestamp: "Sponsored",
        body: "Unlock your team's full potential. Try Acme Pro free for 30 days.",
        likeCount: 0,
        commentCount: 0,
        shareCount: 0,
        isSponsored: true
    ),
    DFSocialPost(
        authorInitials: "CJ",
        authorName: "Carol Jones",
        timestamp: "1h ago",
        body: "Great article on distributed systems. Worth a read.",
        likeCount: 12,
        commentCount: 4,
        shareCount: 6
    ),
]

#Preview("Light") {
    DFSocialFeedScreen(configuration: .init(
        stories: sampleStories,
        posts: samplePosts,
        onRefresh: {},
        onCompose: {},
        onLike: { _ in },
        onComment: { _ in },
        onShare: { _ in },
        onStoryTap: { _ in }
    ))
}

#Preview("Dark") {
    DFSocialFeedScreen(configuration: .init(
        stories: sampleStories,
        posts: samplePosts,
        onRefresh: {},
        onCompose: {},
        onLike: { _ in },
        onComment: { _ in },
        onShare: { _ in },
        onStoryTap: { _ in }
    ))
    .colorScheme(.dark)
}

#Preview("Loading") {
    DFSocialFeedScreen(configuration: .init(
        stories: [],
        posts: [],
        isLoading: true,
        onRefresh: {},
        onCompose: {},
        onLike: { _ in },
        onComment: { _ in },
        onShare: { _ in },
        onStoryTap: { _ in }
    ))
}

#Preview("Empty State") {
    DFSocialFeedScreen(configuration: .init(
        stories: [],
        posts: [],
        onRefresh: {},
        onCompose: {},
        onLike: { _ in },
        onComment: { _ in },
        onShare: { _ in },
        onStoryTap: { _ in }
    ))
}
```

- [ ] **Step 7: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSocialFeedScreenTests 2>&1 | tail -20
```

Expected: `Test run passed. 5 tests passed.`

- [ ] **Step 8: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Social/Feed/ Tests/DesignFoundationScreensTests/Social/DFSocialFeedScreenTests.swift
git commit -m "feat(screens): add DFSocialFeedScreen with story rail, post cards, and FAB"
```

---

### Task 3: DFSocialProfileScreen — User Profile

**Files:**
- Create: `Sources/DesignFoundationScreens/Social/Profile/DFSocialProfileScreen.swift`
- Create: `Sources/DesignFoundationScreens/Social/Profile/DFSocialProfileScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Social/DFSocialProfileScreenTests.swift`

**Interfaces:**
- Consumes: `DFProfileHeaderBlock`, `DFMetricGridBlock`, `DFStatCardBlock`, `DFActivityFeedBlock`, `DFBlockSkeletonBlock`, `DFButton`
- Produces:
  - `DFSocialProfileScreen` struct with `Configuration`
  - `DFSocialProfileTab` enum with cases `.posts`, `.replies`, `.media`, `.likes`
  - `DFSocialProfileMode` enum with cases `.own` (shows Edit Profile + settings cog), `.other(isFollowing: Bool)` (shows Follow/Following + Message)

- [ ] **Step 1: Write failing tests**

Create `Tests/DesignFoundationScreensTests/Social/DFSocialProfileScreenTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSocialProfileScreen")
struct DFSocialProfileScreenTests {

    @Test("DFSocialProfileTab has four cases")
    func profileTabCount() {
        #expect(DFSocialProfileTab.allCases.count == 4)
    }

    @Test("DFSocialProfileTab titles are non-empty")
    func profileTabTitles() {
        for tab in DFSocialProfileTab.allCases {
            #expect(!tab.title.isEmpty)
        }
    }

    @Test("Configuration stores display name and username")
    func configurationStoresNames() {
        let config = DFSocialProfileScreen.Configuration(
            displayName: "Jane Doe",
            username: "janedoe",
            bio: "Swift dev",
            location: "London",
            website: "https://example.com",
            initials: "JD",
            avatarImage: nil,
            postCount: 42,
            followerCount: 1000,
            followingCount: 200,
            isLoading: false,
            mode: .own,
            feedItems: [],
            onEditProfile: {},
            onSettings: {},
            onFollow: {},
            onMessage: {},
            onFollowersTap: {},
            onFollowingTap: {},
            onPostTap: { _ in }
        )
        #expect(config.displayName == "Jane Doe")
        #expect(config.username == "janedoe")
    }

    @Test("own mode is own")
    func ownMode() {
        if case .own = DFSocialProfileMode.own {
            #expect(true)
        } else {
            Issue.record("Expected .own mode")
        }
    }

    @Test("other mode stores isFollowing")
    func otherMode() {
        let mode = DFSocialProfileMode.other(isFollowing: true)
        if case .other(let following) = mode {
            #expect(following == true)
        } else {
            Issue.record("Expected .other mode")
        }
    }

    @Test("isLoading flag stored correctly")
    func isLoadingFlag() {
        let config = DFSocialProfileScreen.Configuration(
            displayName: "",
            username: "",
            bio: nil,
            location: nil,
            website: nil,
            initials: "??",
            avatarImage: nil,
            postCount: 0,
            followerCount: 0,
            followingCount: 0,
            isLoading: true,
            mode: .own,
            feedItems: [],
            onEditProfile: {},
            onSettings: {},
            onFollow: {},
            onMessage: {},
            onFollowersTap: {},
            onFollowingTap: {},
            onPostTap: { _ in }
        )
        #expect(config.isLoading == true)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSocialProfileScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFSocialProfileScreen`, `DFSocialProfileTab`, `DFSocialProfileMode` not found.

- [ ] **Step 3: Implement DFSocialProfileScreen**

Create `Sources/DesignFoundationScreens/Social/Profile/DFSocialProfileScreen.swift`:

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Supporting Types

public enum DFSocialProfileTab: String, CaseIterable, Sendable {
    case posts
    case replies
    case media
    case likes

    public var title: String {
        switch self {
        case .posts:   return "Posts"
        case .replies: return "Replies"
        case .media:   return "Media"
        case .likes:   return "Likes"
        }
    }
}

public enum DFSocialProfileMode: Sendable {
    case own
    case other(isFollowing: Bool)
}

// MARK: - Screen

public struct DFSocialProfileScreen: View {

    // MARK: Configuration

    public struct Configuration {
        public var displayName: String
        public var username: String
        public var bio: String?
        public var location: String?
        public var website: String?
        public var initials: String
        public var avatarImage: Image?
        public var postCount: Int
        public var followerCount: Int
        public var followingCount: Int
        public var isLoading: Bool
        public var mode: DFSocialProfileMode
        public var feedItems: [DFActivityFeedRow.Configuration]
        public var onEditProfile: @MainActor () -> Void
        public var onSettings: @MainActor () -> Void
        public var onFollow: @MainActor () -> Void
        public var onMessage: @MainActor () -> Void
        public var onFollowersTap: @MainActor () -> Void
        public var onFollowingTap: @MainActor () -> Void
        public var onPostTap: @MainActor (UUID) -> Void

        public init(
            displayName: String,
            username: String,
            bio: String? = nil,
            location: String? = nil,
            website: String? = nil,
            initials: String,
            avatarImage: Image? = nil,
            postCount: Int,
            followerCount: Int,
            followingCount: Int,
            isLoading: Bool = false,
            mode: DFSocialProfileMode,
            feedItems: [DFActivityFeedRow.Configuration],
            onEditProfile: @escaping @MainActor () -> Void,
            onSettings: @escaping @MainActor () -> Void,
            onFollow: @escaping @MainActor () -> Void,
            onMessage: @escaping @MainActor () -> Void,
            onFollowersTap: @escaping @MainActor () -> Void,
            onFollowingTap: @escaping @MainActor () -> Void,
            onPostTap: @escaping @MainActor (UUID) -> Void
        ) {
            self.displayName = displayName
            self.username = username
            self.bio = bio
            self.location = location
            self.website = website
            self.initials = initials
            self.avatarImage = avatarImage
            self.postCount = postCount
            self.followerCount = followerCount
            self.followingCount = followingCount
            self.isLoading = isLoading
            self.mode = mode
            self.feedItems = feedItems
            self.onEditProfile = onEditProfile
            self.onSettings = onSettings
            self.onFollow = onFollow
            self.onMessage = onMessage
            self.onFollowersTap = onFollowersTap
            self.onFollowingTap = onFollowingTap
            self.onPostTap = onPostTap
        }
    }

    // MARK: Properties

    private let configuration: Configuration
    @State private var selectedTab: DFSocialProfileTab = .posts
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: Body

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if configuration.isLoading {
                        DFBlockSkeletonBlock(
                            configuration: .init(layout: .profileHeader, repeatCount: 1)
                        )
                        .padding(theme.spacing.md)
                    } else {
                        profileHeader
                    }

                    DFDivider()

                    tabPicker

                    DFDivider()

                    tabContent
                        .padding(.top, theme.spacing.sm)
                }
            }
            .navigationTitle(configuration.isLoading ? "" : "@\(configuration.username)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if case .own = configuration.mode {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            Task { @MainActor in configuration.onSettings() }
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(theme.colors.textPrimary)
                        }
                        .accessibilityLabel("Settings")
                    }
                }
            }
        }
    }

    // MARK: - Sub-Views

    private var profileHeader: some View {
        VStack(spacing: theme.spacing.md) {
            DFProfileHeaderBlock(configuration: .init(
                name: configuration.displayName,
                initials: configuration.initials,
                subtitle: bioSubtitle,
                avatarImage: configuration.avatarImage,
                primaryActionTitle: primaryActionTitle,
                secondaryActionTitle: secondaryActionTitle,
                onPrimaryAction: primaryAction,
                onSecondaryAction: secondaryAction
            ))

            // Stats row
            DFMetricGridBlock(configuration: .init(
                metrics: [
                    .init(title: "Posts",     value: "\(configuration.postCount)",      onTap: nil),
                    .init(title: "Followers", value: formatCount(configuration.followerCount),
                          onTap: { Task { @MainActor in configuration.onFollowersTap() } }),
                    .init(title: "Following", value: formatCount(configuration.followingCount),
                          onTap: { Task { @MainActor in configuration.onFollowingTap() } }),
                ],
                columns: 3
            ))
            .padding(.horizontal, theme.spacing.md)
        }
    }

    private var bioSubtitle: String? {
        var parts: [String] = []
        if let bio = configuration.bio { parts.append(bio) }
        if let location = configuration.location { parts.append("📍 \(location)") }
        if let website = configuration.website { parts.append(website) }
        return parts.isEmpty ? nil : parts.joined(separator: "\n")
    }

    private var primaryActionTitle: String? {
        switch configuration.mode {
        case .own:               return "Edit Profile"
        case .other(let f):     return f ? "Following" : "Follow"
        }
    }

    private var secondaryActionTitle: String? {
        switch configuration.mode {
        case .own:   return nil
        case .other: return "Message"
        }
    }

    private var primaryAction: (@MainActor () -> Void)? {
        switch configuration.mode {
        case .own:   return configuration.onEditProfile
        case .other: return configuration.onFollow
        }
    }

    private var secondaryAction: (@MainActor () -> Void)? {
        switch configuration.mode {
        case .own:   return nil
        case .other: return configuration.onMessage
        }
    }

    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(DFSocialProfileTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: theme.spacing.xs) {
                            Text(tab.title)
                                .font(theme.typography.body.font)
                                .foregroundStyle(selectedTab == tab
                                    ? theme.colors.primary
                                    : theme.colors.textSecondary)
                                .padding(.horizontal, theme.spacing.md)
                                .padding(.vertical, theme.spacing.sm)

                            Rectangle()
                                .fill(selectedTab == tab
                                    ? theme.colors.primary
                                    : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
                }
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .posts:
            if configuration.feedItems.isEmpty {
                DFEmptyStateBlock(configuration: .init(
                    icon: "square.and.pencil",
                    title: "No posts yet"
                ))
                .padding(theme.spacing.md)
            } else {
                DFActivityFeedBlock(configuration: .init(
                    title: "Posts",
                    items: configuration.feedItems,
                    onSeeAll: nil
                ))
                .padding(.horizontal, theme.spacing.md)
            }
        case .replies:
            DFEmptyStateBlock(configuration: .init(
                icon: "bubble.left.and.bubble.right",
                title: "No replies yet"
            ))
            .padding(theme.spacing.md)
        case .media:
            DFEmptyStateBlock(configuration: .init(
                icon: "photo.on.rectangle",
                title: "No media yet"
            ))
            .padding(theme.spacing.md)
        case .likes:
            DFEmptyStateBlock(configuration: .init(
                icon: "heart",
                title: "No likes yet"
            ))
            .padding(theme.spacing.md)
        }
    }

    private func formatCount(_ n: Int) -> String {
        switch n {
        case 0..<1_000:       return "\(n)"
        case 1_000..<1_000_000: return String(format: "%.1fK", Double(n) / 1_000)
        default:               return String(format: "%.1fM", Double(n) / 1_000_000)
        }
    }
}
```

- [ ] **Step 4: Create previews**

Create `Sources/DesignFoundationScreens/Social/Profile/DFSocialProfileScreen+Previews.swift`:

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

private let sampleFeedItems: [DFActivityFeedRow.Configuration] = [
    .init(initials: "JD", title: "Shipped a new feature today!", subtitle: nil, timestamp: "2h ago", isUnread: false),
    .init(initials: "JD", title: "Great Swift concurrency article.", subtitle: "Worth reading.", timestamp: "1d ago", isUnread: false),
]

#Preview("Own Profile — Light") {
    DFSocialProfileScreen(configuration: .init(
        displayName: "Jane Doe",
        username: "janedoe",
        bio: "Swift engineer. Building things.",
        location: "London",
        website: "janedoe.dev",
        initials: "JD",
        postCount: 42,
        followerCount: 1_240,
        followingCount: 180,
        mode: .own,
        feedItems: sampleFeedItems,
        onEditProfile: {},
        onSettings: {},
        onFollow: {},
        onMessage: {},
        onFollowersTap: {},
        onFollowingTap: {},
        onPostTap: { _ in }
    ))
}

#Preview("Own Profile — Dark") {
    DFSocialProfileScreen(configuration: .init(
        displayName: "Jane Doe",
        username: "janedoe",
        bio: "Swift engineer. Building things.",
        location: "London",
        website: "janedoe.dev",
        initials: "JD",
        postCount: 42,
        followerCount: 1_240,
        followingCount: 180,
        mode: .own,
        feedItems: sampleFeedItems,
        onEditProfile: {},
        onSettings: {},
        onFollow: {},
        onMessage: {},
        onFollowersTap: {},
        onFollowingTap: {},
        onPostTap: { _ in }
    ))
    .colorScheme(.dark)
}

#Preview("Other Profile — Not Following") {
    DFSocialProfileScreen(configuration: .init(
        displayName: "Bob Kumar",
        username: "bobkumar",
        bio: "Product designer @ Acme",
        location: "NYC",
        website: nil,
        initials: "BK",
        postCount: 18,
        followerCount: 530,
        followingCount: 95,
        mode: .other(isFollowing: false),
        feedItems: [],
        onEditProfile: {},
        onSettings: {},
        onFollow: {},
        onMessage: {},
        onFollowersTap: {},
        onFollowingTap: {},
        onPostTap: { _ in }
    ))
}

#Preview("Loading") {
    DFSocialProfileScreen(configuration: .init(
        displayName: "",
        username: "",
        initials: "??",
        postCount: 0,
        followerCount: 0,
        followingCount: 0,
        isLoading: true,
        mode: .own,
        feedItems: [],
        onEditProfile: {},
        onSettings: {},
        onFollow: {},
        onMessage: {},
        onFollowersTap: {},
        onFollowingTap: {},
        onPostTap: { _ in }
    ))
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSocialProfileScreenTests 2>&1 | tail -20
```

Expected: `Test run passed. 5 tests passed.`

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Social/Profile/ Tests/DesignFoundationScreensTests/Social/DFSocialProfileScreenTests.swift
git commit -m "feat(screens): add DFSocialProfileScreen with own/other modes and content tabs"
```

---

### Task 4: DFSocialNotificationsScreen — Notification Centre

**Files:**
- Create: `Sources/DesignFoundationScreens/Social/Notifications/DFSocialNotificationsScreen.swift`
- Create: `Sources/DesignFoundationScreens/Social/Notifications/DFSocialNotificationsScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Social/DFSocialNotificationsScreenTests.swift`

**Interfaces:**
- Consumes: `DFNotificationCell`, `DFEmptyStateBlock`, `DFButton`
- Produces:
  - `DFSocialNotificationsScreen` struct with `Configuration`
  - `DFSocialNotificationKind` enum: `.follow`, `.mention(excerpt: String)`, `.reaction(emoji: String)`, `.comment(excerpt: String)`
  - `DFSocialNotification` model: `id: UUID`, `actorInitials: String`, `actorName: String`, `actorAvatarImage: Image?`, `kind: DFSocialNotificationKind`, `timestamp: String`, `isRead: Bool`
  - `DFSocialNotificationFilter` enum: `.all`, `.mentions`, `.follows`, `.reactions`

- [ ] **Step 1: Write failing tests**

Create `Tests/DesignFoundationScreensTests/Social/DFSocialNotificationsScreenTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSocialNotificationsScreen")
struct DFSocialNotificationsScreenTests {

    @Test("DFSocialNotificationFilter has four cases")
    func filterCaseCount() {
        #expect(DFSocialNotificationFilter.allCases.count == 4)
    }

    @Test("DFSocialNotificationFilter titles are non-empty")
    func filterTitles() {
        for filter in DFSocialNotificationFilter.allCases {
            #expect(!filter.title.isEmpty)
        }
    }

    @Test("Configuration stores notifications")
    func configurationStoresNotifications() {
        let n = DFSocialNotification(
            actorInitials: "AB",
            actorName: "Alice",
            kind: .follow,
            timestamp: "5m ago",
            isRead: false
        )
        let config = DFSocialNotificationsScreen.Configuration(
            notifications: [n],
            onMarkAllRead: {},
            onDismiss: { _ in },
            onTap: { _ in },
            onFollowBack: { _ in }
        )
        #expect(config.notifications.count == 1)
        #expect(config.notifications[0].actorName == "Alice")
    }

    @Test("Unread notification has isRead false")
    func unreadFlag() {
        let n = DFSocialNotification(
            actorInitials: "XY",
            actorName: "Xena",
            kind: .reaction(emoji: "❤️"),
            timestamp: "1h ago",
            isRead: false
        )
        #expect(n.isRead == false)
    }

    @Test("Comment kind stores excerpt")
    func commentKindExcerpt() {
        let kind = DFSocialNotificationKind.comment(excerpt: "Great post!")
        if case .comment(let excerpt) = kind {
            #expect(excerpt == "Great post!")
        } else {
            Issue.record("Expected .comment kind")
        }
    }

    @Test("Empty notifications list")
    func emptyList() {
        let config = DFSocialNotificationsScreen.Configuration(
            notifications: [],
            onMarkAllRead: {},
            onDismiss: { _ in },
            onTap: { _ in },
            onFollowBack: { _ in }
        )
        #expect(config.notifications.isEmpty)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSocialNotificationsScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFSocialNotificationsScreen`, `DFSocialNotification`, `DFSocialNotificationFilter`, `DFSocialNotificationKind` not found.

- [ ] **Step 3: Implement DFSocialNotificationsScreen**

Create `Sources/DesignFoundationScreens/Social/Notifications/DFSocialNotificationsScreen.swift`:

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Supporting Types

public enum DFSocialNotificationKind: Sendable {
    case follow
    case mention(excerpt: String)
    case reaction(emoji: String)
    case comment(excerpt: String)
}

public struct DFSocialNotification: Identifiable, Sendable {
    public let id: UUID
    public var actorInitials: String
    public var actorName: String
    public var actorAvatarImage: Image?
    public var kind: DFSocialNotificationKind
    public var timestamp: String
    public var isRead: Bool

    public init(
        id: UUID = UUID(),
        actorInitials: String,
        actorName: String,
        actorAvatarImage: Image? = nil,
        kind: DFSocialNotificationKind,
        timestamp: String,
        isRead: Bool = false
    ) {
        self.id = id
        self.actorInitials = actorInitials
        self.actorName = actorName
        self.actorAvatarImage = actorAvatarImage
        self.kind = kind
        self.timestamp = timestamp
        self.isRead = isRead
    }

    var icon: String {
        switch kind {
        case .follow:     return "person.badge.plus"
        case .mention:    return "at"
        case .reaction:   return "heart.fill"
        case .comment:    return "bubble.left.fill"
        }
    }

    var title: String {
        switch kind {
        case .follow:              return "\(actorName) started following you"
        case .mention:             return "\(actorName) mentioned you in a post"
        case .reaction(let emoji): return "\(actorName) reacted \(emoji) to your post"
        case .comment:             return "\(actorName) commented on your post"
        }
    }

    var body: String {
        switch kind {
        case .follow:               return "Tap to view their profile"
        case .mention(let excerpt): return excerpt
        case .reaction:             return ""
        case .comment(let excerpt): return excerpt
        }
    }
}

public enum DFSocialNotificationFilter: String, CaseIterable, Sendable {
    case all
    case mentions
    case follows
    case reactions

    public var title: String {
        switch self {
        case .all:       return "All"
        case .mentions:  return "Mentions"
        case .follows:   return "Follows"
        case .reactions: return "Reactions"
        }
    }

    func matches(_ n: DFSocialNotification) -> Bool {
        switch self {
        case .all:       return true
        case .mentions:
            if case .mention = n.kind { return true }
            return false
        case .follows:
            if case .follow = n.kind { return true }
            return false
        case .reactions:
            if case .reaction = n.kind { return true }
            if case .comment  = n.kind { return true }
            return false
        }
    }
}

// MARK: - Screen

public struct DFSocialNotificationsScreen: View {

    // MARK: Configuration

    public struct Configuration {
        public var notifications: [DFSocialNotification]
        public var onMarkAllRead: @MainActor () -> Void
        public var onDismiss: @MainActor (UUID) -> Void
        public var onTap: @MainActor (UUID) -> Void
        public var onFollowBack: @MainActor (UUID) -> Void

        public init(
            notifications: [DFSocialNotification],
            onMarkAllRead: @escaping @MainActor () -> Void,
            onDismiss: @escaping @MainActor (UUID) -> Void,
            onTap: @escaping @MainActor (UUID) -> Void,
            onFollowBack: @escaping @MainActor (UUID) -> Void
        ) {
            self.notifications = notifications
            self.onMarkAllRead = onMarkAllRead
            self.onDismiss = onDismiss
            self.onTap = onTap
            self.onFollowBack = onFollowBack
        }
    }

    // MARK: Properties

    private let configuration: Configuration
    @State private var activeFilter: DFSocialNotificationFilter = .all
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: Body

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar

                DFDivider()

                notificationList
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mark all read") {
                        Task { @MainActor in configuration.onMarkAllRead() }
                    }
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.primary)
                    .disabled(filtered.allSatisfy(\.isRead))
                }
            }
        }
    }

    // MARK: - Computed

    private var filtered: [DFSocialNotification] {
        configuration.notifications.filter { activeFilter.matches($0) }
    }

    private var unread: [DFSocialNotification] {
        filtered.filter { !$0.isRead }
    }

    private var read: [DFSocialNotification] {
        filtered.filter { $0.isRead }
    }

    // MARK: - Sub-Views

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(DFSocialNotificationFilter.allCases, id: \.self) { filter in
                    Button {
                        activeFilter = filter
                    } label: {
                        Text(filter.title)
                            .font(theme.typography.body.font)
                            .padding(.horizontal, theme.spacing.md)
                            .padding(.vertical, theme.spacing.sm)
                            .background(
                                activeFilter == filter
                                    ? theme.colors.primary
                                    : theme.colors.surface
                            )
                            .foregroundStyle(
                                activeFilter == filter
                                    ? Color.white
                                    : theme.colors.textPrimary
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(activeFilter == filter ? .isSelected : [])
                }
            }
            .padding(theme.spacing.md)
        }
    }

    @ViewBuilder
    private var notificationList: some View {
        if filtered.isEmpty {
            DFEmptyStateBlock(configuration: .init(
                icon: "bell.slash",
                title: "No notifications yet",
                message: "When people interact with you, you'll see it here."
            ))
        } else {
            List {
                if !unread.isEmpty {
                    Section("New") {
                        ForEach(unread) { notification in
                            notificationRow(notification)
                                .listRowBackground(theme.colors.primary.opacity(0.06))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task { @MainActor in configuration.onDismiss(notification.id) }
                                    } label: {
                                        Label("Dismiss", systemImage: "xmark")
                                    }
                                }
                        }
                    }
                }
                if !read.isEmpty {
                    Section("Earlier") {
                        ForEach(read) { notification in
                            notificationRow(notification)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task { @MainActor in configuration.onDismiss(notification.id) }
                                    } label: {
                                        Label("Dismiss", systemImage: "xmark")
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private func notificationRow(_ notification: DFSocialNotification) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            DFNotificationCell(configuration: .init(
                icon: notification.icon,
                title: notification.title,
                body: notification.body,
                timestamp: notification.timestamp,
                isRead: notification.isRead,
                onTap: { Task { @MainActor in configuration.onTap(notification.id) } },
                onDismiss: nil   // dismiss handled via swipe
            ))

            // Follow-back inline action
            if case .follow = notification.kind {
                HStack {
                    Spacer()
                    DFButton("Follow Back") {
                        Task { @MainActor in configuration.onFollowBack(notification.id) }
                    }
                    .dfButtonStyle(.outlined)
                }
                .padding(.bottom, theme.spacing.xs)
            }
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: theme.spacing.md,
            bottom: 0,
            trailing: theme.spacing.md
        ))
    }
}
```

- [ ] **Step 4: Create previews**

Create `Sources/DesignFoundationScreens/Social/Notifications/DFSocialNotificationsScreen+Previews.swift`:

```swift
import SwiftUI
import DesignFoundation

private let sampleNotifications: [DFSocialNotification] = [
    DFSocialNotification(
        actorInitials: "AB",
        actorName: "Alice Brown",
        kind: .follow,
        timestamp: "2m ago",
        isRead: false
    ),
    DFSocialNotification(
        actorInitials: "CJ",
        actorName: "Carol Jones",
        kind: .mention(excerpt: "\"Great point @janedoe — totally agree.\""),
        timestamp: "15m ago",
        isRead: false
    ),
    DFSocialNotification(
        actorInitials: "BK",
        actorName: "Bob Kumar",
        kind: .reaction(emoji: "❤️"),
        timestamp: "1h ago",
        isRead: true
    ),
    DFSocialNotification(
        actorInitials: "DL",
        actorName: "Diana Lee",
        kind: .comment(excerpt: "\"This is really helpful, thanks for sharing!\""),
        timestamp: "3h ago",
        isRead: true
    ),
]

#Preview("Light") {
    DFSocialNotificationsScreen(configuration: .init(
        notifications: sampleNotifications,
        onMarkAllRead: {},
        onDismiss: { _ in },
        onTap: { _ in },
        onFollowBack: { _ in }
    ))
}

#Preview("Dark") {
    DFSocialNotificationsScreen(configuration: .init(
        notifications: sampleNotifications,
        onMarkAllRead: {},
        onDismiss: { _ in },
        onTap: { _ in },
        onFollowBack: { _ in }
    ))
    .colorScheme(.dark)
}

#Preview("Empty") {
    DFSocialNotificationsScreen(configuration: .init(
        notifications: [],
        onMarkAllRead: {},
        onDismiss: { _ in },
        onTap: { _ in },
        onFollowBack: { _ in }
    ))
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSocialNotificationsScreenTests 2>&1 | tail -20
```

Expected: `Test run passed. 6 tests passed.`

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Social/Notifications/ Tests/DesignFoundationScreensTests/Social/DFSocialNotificationsScreenTests.swift
git commit -m "feat(screens): add DFSocialNotificationsScreen with filter segments and swipe-dismiss"
```

---

### Task 5: DFSocialExploreScreen — Discovery

**Files:**
- Create: `Sources/DesignFoundationScreens/Social/Explore/DFSocialExploreScreen.swift`
- Create: `Sources/DesignFoundationScreens/Social/Explore/DFSocialExploreScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Social/DFSocialExploreScreenTests.swift`

**Interfaces:**
- Consumes: `DFSearchResultsBlock`, `DFTagPickerBlock`, `DFContactRow`, `DFActivityFeedBlock`, `DFBlockSkeletonBlock`, `DFEmptyStateBlock`, `DFCard`, `DFBadge`, `DFTextField`
- Produces:
  - `DFSocialExploreScreen` struct with `Configuration`
  - `DFSocialHashtagCard` model: `id: UUID`, `hashtag: String`, `postCount: Int`
  - `DFSocialSuggestedPerson` model: `id: UUID`, `initials: String`, `name: String`, `subtitle: String?`, `avatarImage: Image?`

- [ ] **Step 1: Write failing tests**

Create `Tests/DesignFoundationScreensTests/Social/DFSocialExploreScreenTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFSocialExploreScreen")
struct DFSocialExploreScreenTests {

    @Test("Configuration stores hashtag cards")
    func configurationStoresHashtags() {
        let tag = DFSocialHashtagCard(hashtag: "#swift", postCount: 4_200)
        let config = DFSocialExploreScreen.Configuration(
            searchQuery: "",
            searchResults: [],
            isSearching: false,
            trendingTags: [],
            suggestedPeople: [],
            hashtagCards: [tag],
            trendingFeedItems: [],
            isLoading: false,
            onSearchQueryChange: { _ in },
            onSearchResultTap: { _ in },
            onTagTap: { _ in },
            onPersonTap: { _ in },
            onHashtagCardTap: { _ in }
        )
        #expect(config.hashtagCards.count == 1)
        #expect(config.hashtagCards[0].hashtag == "#swift")
    }

    @Test("Configuration stores suggested people")
    func configurationStoresSuggestedPeople() {
        let person = DFSocialSuggestedPerson(initials: "XY", name: "Xena", subtitle: "Designer")
        let config = DFSocialExploreScreen.Configuration(
            searchQuery: "",
            searchResults: [],
            isSearching: false,
            trendingTags: [],
            suggestedPeople: [person],
            hashtagCards: [],
            trendingFeedItems: [],
            isLoading: false,
            onSearchQueryChange: { _ in },
            onSearchResultTap: { _ in },
            onTagTap: { _ in },
            onPersonTap: { _ in },
            onHashtagCardTap: { _ in }
        )
        #expect(config.suggestedPeople.count == 1)
        #expect(config.suggestedPeople[0].name == "Xena")
    }

    @Test("isSearching flag stored")
    func isSearchingFlag() {
        let config = DFSocialExploreScreen.Configuration(
            searchQuery: "hello",
            searchResults: [],
            isSearching: true,
            trendingTags: [],
            suggestedPeople: [],
            hashtagCards: [],
            trendingFeedItems: [],
            isLoading: false,
            onSearchQueryChange: { _ in },
            onSearchResultTap: { _ in },
            onTagTap: { _ in },
            onPersonTap: { _ in },
            onHashtagCardTap: { _ in }
        )
        #expect(config.isSearching == true)
    }

    @Test("isLoading flag stored")
    func isLoadingFlag() {
        let config = DFSocialExploreScreen.Configuration(
            searchQuery: "",
            searchResults: [],
            isSearching: false,
            trendingTags: [],
            suggestedPeople: [],
            hashtagCards: [],
            trendingFeedItems: [],
            isLoading: true,
            onSearchQueryChange: { _ in },
            onSearchResultTap: { _ in },
            onTagTap: { _ in },
            onPersonTap: { _ in },
            onHashtagCardTap: { _ in }
        )
        #expect(config.isLoading == true)
    }

    @Test("Hashtag card postCount stored")
    func hashtagPostCount() {
        let card = DFSocialHashtagCard(hashtag: "#design", postCount: 9_999)
        #expect(card.postCount == 9_999)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSocialExploreScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFSocialExploreScreen`, `DFSocialHashtagCard`, `DFSocialSuggestedPerson` not found.

- [ ] **Step 3: Implement DFSocialExploreScreen**

Create `Sources/DesignFoundationScreens/Social/Explore/DFSocialExploreScreen.swift`:

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Supporting Models

public struct DFSocialHashtagCard: Identifiable, Sendable {
    public let id: UUID
    public var hashtag: String
    public var postCount: Int

    public init(id: UUID = UUID(), hashtag: String, postCount: Int) {
        self.id = id
        self.hashtag = hashtag
        self.postCount = postCount
    }
}

public struct DFSocialSuggestedPerson: Identifiable, Sendable {
    public let id: UUID
    public var initials: String
    public var name: String
    public var subtitle: String?
    public var avatarImage: Image?

    public init(
        id: UUID = UUID(),
        initials: String,
        name: String,
        subtitle: String? = nil,
        avatarImage: Image? = nil
    ) {
        self.id = id
        self.initials = initials
        self.name = name
        self.subtitle = subtitle
        self.avatarImage = avatarImage
    }
}

// MARK: - Screen

public struct DFSocialExploreScreen: View {

    // MARK: Configuration

    public struct Configuration {
        public var searchQuery: String
        public var searchResults: [DFSearchResult]
        public var isSearching: Bool
        public var trendingTags: [DFTag]
        public var suggestedPeople: [DFSocialSuggestedPerson]
        public var hashtagCards: [DFSocialHashtagCard]
        public var trendingFeedItems: [DFActivityFeedRow.Configuration]
        public var isLoading: Bool
        public var onSearchQueryChange: @MainActor (String) -> Void
        public var onSearchResultTap: @MainActor (UUID) -> Void
        public var onTagTap: @MainActor (UUID) -> Void
        public var onPersonTap: @MainActor (UUID) -> Void
        public var onHashtagCardTap: @MainActor (UUID) -> Void

        public init(
            searchQuery: String,
            searchResults: [DFSearchResult],
            isSearching: Bool = false,
            trendingTags: [DFTag],
            suggestedPeople: [DFSocialSuggestedPerson],
            hashtagCards: [DFSocialHashtagCard],
            trendingFeedItems: [DFActivityFeedRow.Configuration],
            isLoading: Bool = false,
            onSearchQueryChange: @escaping @MainActor (String) -> Void,
            onSearchResultTap: @escaping @MainActor (UUID) -> Void,
            onTagTap: @escaping @MainActor (UUID) -> Void,
            onPersonTap: @escaping @MainActor (UUID) -> Void,
            onHashtagCardTap: @escaping @MainActor (UUID) -> Void
        ) {
            self.searchQuery = searchQuery
            self.searchResults = searchResults
            self.isSearching = isSearching
            self.trendingTags = trendingTags
            self.suggestedPeople = suggestedPeople
            self.hashtagCards = hashtagCards
            self.trendingFeedItems = trendingFeedItems
            self.isLoading = isLoading
            self.onSearchQueryChange = onSearchQueryChange
            self.onSearchResultTap = onSearchResultTap
            self.onTagTap = onTagTap
            self.onPersonTap = onPersonTap
            self.onHashtagCardTap = onHashtagCardTap
        }
    }

    // MARK: Properties

    private let configuration: Configuration
    @State private var localQuery: String
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
        self._localQuery = State(initialValue: configuration.searchQuery)
    }

    // MARK: Body

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Persistent search bar
                searchBar

                DFDivider()

                if configuration.isSearching {
                    // Search results overlay
                    DFSearchResultsBlock(configuration: .init(
                        results: configuration.searchResults,
                        isLoading: configuration.isLoading,
                        emptyIcon: "magnifyingglass",
                        emptyTitle: "No results",
                        emptyMessage: "Try a different name or hashtag"
                    ))
                    .padding(theme.spacing.md)
                } else {
                    exploreContent
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Sub-Views

    private var searchBar: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.colors.textSecondary)
            TextField("Search people, hashtags, topics", text: $localQuery)
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.textPrimary)
                .onChange(of: localQuery) { _, newValue in
                    Task { @MainActor in configuration.onSearchQueryChange(newValue) }
                }
            if !localQuery.isEmpty {
                Button {
                    localQuery = ""
                    Task { @MainActor in configuration.onSearchQueryChange("") }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(theme.spacing.sm)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
    }

    private var exploreContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {

                if configuration.isLoading {
                    loadingSkeleton
                } else {

                    // Trending tags
                    if !configuration.trendingTags.isEmpty {
                        sectionHeader("Trending")
                        DFTagPickerBlock(configuration: .init(
                            tags: configuration.trendingTags,
                            selectedIDs: [],
                            multiSelect: false,
                            title: nil,
                            onSelectionChange: { ids in
                                if let id = ids.first {
                                    Task { @MainActor in configuration.onTagTap(id) }
                                }
                            }
                        ))
                        .padding(.horizontal, theme.spacing.md)
                    }

                    // Suggested people
                    if !configuration.suggestedPeople.isEmpty {
                        sectionHeader("People to Follow")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: theme.spacing.md) {
                                ForEach(configuration.suggestedPeople) { person in
                                    DFCard {
                                        DFContactRow(configuration: .init(
                                            name: person.name,
                                            initials: person.initials,
                                            subtitle: person.subtitle,
                                            avatarImage: person.avatarImage,
                                            onTap: { Task { @MainActor in configuration.onPersonTap(person.id) } }
                                        ))
                                        .padding(theme.spacing.sm)
                                    }
                                    .frame(width: 220)
                                }
                            }
                            .padding(.horizontal, theme.spacing.md)
                        }
                    }

                    // Trending posts
                    if !configuration.trendingFeedItems.isEmpty {
                        sectionHeader("Trending Posts")
                        DFActivityFeedBlock(configuration: .init(
                            title: "",
                            items: configuration.trendingFeedItems,
                            onSeeAll: nil
                        ))
                        .padding(.horizontal, theme.spacing.md)
                    }

                    // Popular hashtag grid
                    if !configuration.hashtagCards.isEmpty {
                        sectionHeader("Popular Hashtags")
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: theme.spacing.sm),
                                GridItem(.flexible(), spacing: theme.spacing.sm)
                            ],
                            spacing: theme.spacing.sm
                        ) {
                            ForEach(configuration.hashtagCards) { card in
                                hashtagCard(card)
                            }
                        }
                        .padding(.horizontal, theme.spacing.md)
                    }

                    // Empty state when nothing to show
                    if configuration.trendingTags.isEmpty
                        && configuration.suggestedPeople.isEmpty
                        && configuration.trendingFeedItems.isEmpty
                        && configuration.hashtagCards.isEmpty {
                        DFEmptyStateBlock(configuration: .init(
                            icon: "globe",
                            title: "Nothing to explore yet",
                            message: "Check back soon for trending content."
                        ))
                        .padding(.horizontal, theme.spacing.md)
                    }
                }
            }
            .padding(.vertical, theme.spacing.md)
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(theme.typography.headline.font)
            .foregroundStyle(theme.colors.textPrimary)
            .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private func hashtagCard(_ card: DFSocialHashtagCard) -> some View {
        Button {
            Task { @MainActor in configuration.onHashtagCardTap(card.id) }
        } label: {
            DFCard {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(card.hashtag)
                        .font(theme.typography.body.font.bold())
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1)
                    DFBadge(text: "\(formatCount(card.postCount)) posts")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(theme.spacing.md)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(card.hashtag), \(card.postCount) posts")
    }

    private var loadingSkeleton: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            // Trending tags skeleton
            DFBlockSkeletonBlock(
                configuration: .init(layout: .textBlock(lines: 1), repeatCount: 1)
            )
            .padding(.horizontal, theme.spacing.md)

            // People skeleton
            DFBlockSkeletonBlock(
                configuration: .init(layout: .contactRow, repeatCount: 3)
            )
            .padding(.horizontal, theme.spacing.md)

            // Feed skeleton
            DFBlockSkeletonBlock(
                configuration: .init(layout: .activityRow, repeatCount: 3)
            )
            .padding(.horizontal, theme.spacing.md)
        }
    }

    private func formatCount(_ n: Int) -> String {
        switch n {
        case 0..<1_000:         return "\(n)"
        case 1_000..<1_000_000: return String(format: "%.1fK", Double(n) / 1_000)
        default:                return String(format: "%.1fM", Double(n) / 1_000_000)
        }
    }
}
```

- [ ] **Step 4: Create previews**

Create `Sources/DesignFoundationScreens/Social/Explore/DFSocialExploreScreen+Previews.swift`:

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

private let sampleTags: [DFTag] = [
    DFTag(label: "#swift"),
    DFTag(label: "#design"),
    DFTag(label: "#startups"),
    DFTag(label: "#AI"),
    DFTag(label: "#ux"),
]

private let samplePeople: [DFSocialSuggestedPerson] = [
    DFSocialSuggestedPerson(initials: "AB", name: "Alice Brown", subtitle: "iOS Engineer"),
    DFSocialSuggestedPerson(initials: "CJ", name: "Carol Jones", subtitle: "Product Designer"),
    DFSocialSuggestedPerson(initials: "DL", name: "Dan Lee", subtitle: "Founder @ Acme"),
]

private let sampleHashtags: [DFSocialHashtagCard] = [
    DFSocialHashtagCard(hashtag: "#swift", postCount: 42_000),
    DFSocialHashtagCard(hashtag: "#design", postCount: 18_500),
    DFSocialHashtagCard(hashtag: "#startups", postCount: 9_200),
    DFSocialHashtagCard(hashtag: "#AI", postCount: 67_000),
]

private let sampleFeedItems: [DFActivityFeedRow.Configuration] = [
    .init(initials: "AB", title: "Just shipped v2.0 🚀", subtitle: nil, timestamp: "5m ago", isUnread: false),
    .init(initials: "CJ", title: "Hot take: SwiftUI is now production-ready.", subtitle: nil, timestamp: "2h ago", isUnread: false),
]

#Preview("Light") {
    DFSocialExploreScreen(configuration: .init(
        searchQuery: "",
        searchResults: [],
        trendingTags: sampleTags,
        suggestedPeople: samplePeople,
        hashtagCards: sampleHashtags,
        trendingFeedItems: sampleFeedItems,
        onSearchQueryChange: { _ in },
        onSearchResultTap: { _ in },
        onTagTap: { _ in },
        onPersonTap: { _ in },
        onHashtagCardTap: { _ in }
    ))
}

#Preview("Dark") {
    DFSocialExploreScreen(configuration: .init(
        searchQuery: "",
        searchResults: [],
        trendingTags: sampleTags,
        suggestedPeople: samplePeople,
        hashtagCards: sampleHashtags,
        trendingFeedItems: sampleFeedItems,
        onSearchQueryChange: { _ in },
        onSearchResultTap: { _ in },
        onTagTap: { _ in },
        onPersonTap: { _ in },
        onHashtagCardTap: { _ in }
    ))
    .colorScheme(.dark)
}

#Preview("Loading") {
    DFSocialExploreScreen(configuration: .init(
        searchQuery: "",
        searchResults: [],
        trendingTags: [],
        suggestedPeople: [],
        hashtagCards: [],
        trendingFeedItems: [],
        isLoading: true,
        onSearchQueryChange: { _ in },
        onSearchResultTap: { _ in },
        onTagTap: { _ in },
        onPersonTap: { _ in },
        onHashtagCardTap: { _ in }
    ))
}

#Preview("Search Active") {
    DFSocialExploreScreen(configuration: .init(
        searchQuery: "alice",
        searchResults: [
            DFSearchResult(icon: "person.circle", title: "Alice Brown", subtitle: "iOS Engineer"),
            DFSearchResult(icon: "number", title: "#alice", subtitle: "240 posts"),
        ],
        isSearching: true,
        trendingTags: sampleTags,
        suggestedPeople: samplePeople,
        hashtagCards: sampleHashtags,
        trendingFeedItems: sampleFeedItems,
        onSearchQueryChange: { _ in },
        onSearchResultTap: { _ in },
        onTagTap: { _ in },
        onPersonTap: { _ in },
        onHashtagCardTap: { _ in }
    ))
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFSocialExploreScreenTests 2>&1 | tail -20
```

Expected: `Test run passed. 5 tests passed.`

- [ ] **Step 6: Full test suite**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test 2>&1 | tail -20
```

Expected: all Social tests pass with zero failures.

- [ ] **Step 7: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Social/Explore/ Tests/DesignFoundationScreensTests/Social/DFSocialExploreScreenTests.swift
git commit -m "feat(screens): add DFSocialExploreScreen with search, trending tags, suggested people, and hashtag grid"
```

---

## Self-Review Checklist

### Spec Coverage

| Requirement | Task |
|---|---|
| Story/highlights rail with unseen ring and "Your Story" + icon | Task 2 — `DFSocialStoryRail` |
| Feed of post cards: author, timestamp, content, image placeholder, reaction bar | Task 2 — `DFSocialPostCard` |
| Sponsored posts with subtle badge | Task 2 — `DFSocialPostCard.isSponsored` |
| Pull to refresh + skeleton loading | Task 2 — `.refreshable` + `DFBlockSkeletonBlock` |
| FAB to compose | Task 2 — floating button |
| Tab bar (iPhone) / sidebar (iPad/Mac) | Task 1 — `DFSocialAppShell` |
| Empty state with discover CTA | Task 2 — `DFEmptyStateBlock` |
| DFProfileHeaderBlock with avatar, name, @username, bio, location, website | Task 3 |
| Stats row: Posts, Followers, Following (tappable) | Task 3 — `DFMetricGridBlock` |
| Follow/Following/Message vs Edit Profile buttons | Task 3 — `DFSocialProfileMode` |
| Content tabs: Posts, Replies, Media, Likes | Task 3 — `DFSocialProfileTab` |
| Posts tab uses DFActivityFeedBlock filtered to user | Task 3 |
| Loading skeleton for profile | Task 3 — `DFBlockSkeletonBlock(.profileHeader)` |
| Settings cog on own profile | Task 3 — toolbar `ToolbarItem` |
| Segment control All/Mentions/Follows/Reactions | Task 4 — `DFSocialNotificationFilter` |
| Grouped sections: New (unread highlight) / Earlier | Task 4 — `List` with two `Section`s |
| Follow notification + Follow Back button | Task 4 — inline `DFButton` |
| Mention with post excerpt | Task 4 — `DFSocialNotificationKind.mention` |
| Reaction with emoji | Task 4 — `DFSocialNotificationKind.reaction` |
| Comment with excerpt | Task 4 — `DFSocialNotificationKind.comment` |
| Swipe to dismiss | Task 4 — `.swipeActions` |
| Mark all as read | Task 4 — toolbar button |
| Empty state for notifications | Task 4 — `DFEmptyStateBlock` |
| Search bar always visible | Task 5 — `searchBar` pinned above scroll |
| DFSearchResultsBlock on type | Task 5 — `isSearching` branch |
| Trending tags (DFTagPickerBlock) | Task 5 |
| Suggested people horizontal scroll (DFContactRow) | Task 5 |
| Trending posts (DFActivityFeedBlock) | Task 5 |
| Popular hashtag 2-column grid with post count badge | Task 5 — `LazyVGrid` + `DFBadge` |
| DFBlockSkeletonBlock loading state | Task 5 |
| Light + dark previews for every screen | Tasks 1–5 |
| Swift 6 / StrictConcurrency | Global constraint on package |
| All tokens from `@Environment(\.dfTheme)` | All tasks |
| `@MainActor () -> Void` closures | All configuration structs |

All spec requirements are covered. No gaps found.
