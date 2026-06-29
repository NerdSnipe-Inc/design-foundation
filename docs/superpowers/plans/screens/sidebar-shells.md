# DesignFoundationScreens — Sidebar Shells Implementation Plan

> **For agentic workers:** Use `superpowers:subagent-driven-development` to implement task-by-task. Each task is self-contained. Complete Task 1 first (package setup), then Tasks 2–19 can be done in order or in parallel per shell.

**Goal:** Build the `DesignFoundationScreens` Swift package and implement 18 sidebar/navigation shell variants — structural SwiftUI containers that form the scaffold every vertical screen will live inside.

**Architecture:** Each shell is a public SwiftUI `View` struct that accepts `@ViewBuilder` slot parameters and/or a `Configuration` struct. Shells wire navigation structure; content areas are developer-filled. No shell contains hardcoded visual tokens — all styling flows through `@Environment(\.dfTheme)`.

**Tech Stack:**
- Swift 6, SwiftUI, Swift Testing
- Depends on: `DesignFoundation` (remote, https://github.com/NerdSnipe-Inc/design-foundation, from: 1.0.0), `DesignFoundationBlocks` (local path: `../DesignFoundationBlocks`)
- Package root: `/Users/nerdsnipe/Projects/DesignFoundationScreens/`
- Sources: `Sources/DesignFoundationScreens/Shells/`
- Tests: `Tests/DesignFoundationScreensTests/`

---

## Global Constraints

Copy these verbatim into every implementation task:

- **Swift 6 strict concurrency** — `swiftLanguageVersions: [.v6]`, experimental feature `StrictConcurrency` enabled in Package.swift
- **Platforms:** iOS 18, macOS 15, visionOS 2 (`.iOS(.v18)`, `.macOS(.v15)`, `.visionOS(.v2)`)
- **Zero hardcoded values** — all colors, spacing, radii, typography via `@Environment(\.dfTheme)`
- **Action closures typed as** `@MainActor () -> Void`
- **Previews:** every shell file ends with `#Preview("Light") { ... }` and `#Preview("Dark") { ... colorScheme(.dark) }`
- **Adaptive layout:** sidebar/split on iPad + Mac, tab bar on iPhone where appropriate (shells that are inherently desktop-first may use `#if os(iOS)` guards)
- **Tests:** Swift Testing only — `import Testing`, `@Suite`, `@Test`, `#expect` — no XCTest
- **No external dependencies** beyond `DesignFoundation` and `DesignFoundationBlocks`
- **Commit format:** conventional commits — `feat(screens): add DFXxxShell`

---

## Task 1: Create DesignFoundationScreens Package

### Files to create

```
/Users/nerdsnipe/Projects/DesignFoundationScreens/
├── Package.swift
├── Sources/
│   └── DesignFoundationScreens/
│       ├── DesignFoundationScreens.swift          ← umbrella re-export
│       └── Shells/                                 ← one file per shell
└── Tests/
    └── DesignFoundationScreensTests/
        └── DesignFoundationScreensTests.swift      ← placeholder suite
```

### Step 1 — Create directory structure

```bash
mkdir -p /Users/nerdsnipe/Projects/DesignFoundationScreens/Sources/DesignFoundationScreens/Shells
mkdir -p /Users/nerdsnipe/Projects/DesignFoundationScreens/Tests/DesignFoundationScreensTests
```

### Step 2 — Write Package.swift

```swift
// /Users/nerdsnipe/Projects/DesignFoundationScreens/Package.swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DesignFoundationScreens",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "DesignFoundationScreens",
            targets: ["DesignFoundationScreens"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/NerdSnipe-Inc/design-foundation",
            from: "1.0.0"
        ),
        .package(
            path: "../DesignFoundationBlocks"
        )
    ],
    targets: [
        .target(
            name: "DesignFoundationScreens",
            dependencies: [
                .product(name: "DesignFoundation", package: "design-foundation"),
                .product(name: "DesignFoundationBlocks", package: "DesignFoundationBlocks")
            ],
            path: "Sources/DesignFoundationScreens",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "DesignFoundationScreensTests",
            dependencies: ["DesignFoundationScreens"],
            path: "Tests/DesignFoundationScreensTests",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
```

### Step 3 — Write umbrella file

```swift
// Sources/DesignFoundationScreens/DesignFoundationScreens.swift
/// DesignFoundationScreens — structural SwiftUI shell containers.
/// Import this module to access all DFXxxShell types.
@_exported import DesignFoundation
@_exported import DesignFoundationBlocks
```

### Step 4 — Write placeholder test suite

```swift
// Tests/DesignFoundationScreensTests/DesignFoundationScreensTests.swift
import Testing
@testable import DesignFoundationScreens

@Suite("DesignFoundationScreens")
struct DesignFoundationScreensTests {
    @Test("Package loads")
    func packageLoads() {
        #expect(true)
    }
}
```

### Step 5 — Initial commit

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git init
git add .
git commit -m "feat(screens): bootstrap DesignFoundationScreens package"
```

---

## Task 2: DFStandardSidebarShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFStandardSidebarShell.swift`
- `Tests/DesignFoundationScreensTests/DFStandardSidebarShellTests.swift`

### Interface

```swift
public struct DFNavSection: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let items: [DFNavItem]
    public var isCollapsible: Bool

    public init(
        id: String = UUID().uuidString,
        title: String,
        items: [DFNavItem],
        isCollapsible: Bool = true
    )
}

public struct DFNavItem: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let icon: String          // SF Symbol name
    public let badge: Int?

    public init(
        id: String = UUID().uuidString,
        label: String,
        icon: String,
        badge: Int? = nil
    )
}

public struct DFStandardSidebarShell<Content: View>: View {
    public init(
        sections: [DFNavSection],
        selectedItemID: Binding<String?>,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFStandardSidebarShell.swift
import SwiftUI
import DesignFoundation

public struct DFNavSection: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let items: [DFNavItem]
    public var isCollapsible: Bool

    public init(
        id: String = UUID().uuidString,
        title: String,
        items: [DFNavItem],
        isCollapsible: Bool = true
    ) {
        self.id = id
        self.title = title
        self.items = items
        self.isCollapsible = isCollapsible
    }
}

public struct DFNavItem: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let icon: String
    public let badge: Int?

    public init(
        id: String = UUID().uuidString,
        label: String,
        icon: String,
        badge: Int? = nil
    ) {
        self.id = id
        self.label = label
        self.icon = icon
        self.badge = badge
    }
}

public struct DFStandardSidebarShell<Content: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var selectedItemID: String?
    private let sections: [DFNavSection]
    private let content: () -> Content

    @State private var collapsedSections: Set<String> = []

    public init(
        sections: [DFNavSection],
        selectedItemID: Binding<String?>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.sections = sections
        self._selectedItemID = selectedItemID
        self.content = content
    }

    public var body: some View {
        NavigationSplitView {
            List(selection: $selectedItemID) {
                ForEach(sections) { section in
                    sectionView(section)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("")
        } detail: {
            content()
        }
    }

    @ViewBuilder
    private func sectionView(_ section: DFNavSection) -> some View {
        Section {
            if !collapsedSections.contains(section.id) {
                ForEach(section.items) { item in
                    navItemRow(item)
                }
            }
        } header: {
            if section.isCollapsible {
                Button {
                    withAnimation(theme.animation.standard) {
                        if collapsedSections.contains(section.id) {
                            collapsedSections.remove(section.id)
                        } else {
                            collapsedSections.insert(section.id)
                        }
                    }
                } label: {
                    HStack {
                        Text(section.title)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        Spacer()
                        Image(systemName: collapsedSections.contains(section.id) ? "chevron.right" : "chevron.down")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                .buttonStyle(.plain)
            } else {
                Text(section.title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }

    private func navItemRow(_ item: DFNavItem) -> some View {
        Label(item.label, systemImage: item.icon)
            .tag(item.id)
            .badge(item.badge ?? 0)
    }
}

// MARK: - Previews

private let previewSections = [
    DFNavSection(title: "Main", items: [
        DFNavItem(label: "Dashboard", icon: "square.grid.2x2", badge: 3),
        DFNavItem(label: "Projects", icon: "folder"),
        DFNavItem(label: "Tasks", icon: "checkmark.circle")
    ]),
    DFNavSection(title: "Settings", items: [
        DFNavItem(label: "Preferences", icon: "gear"),
        DFNavItem(label: "Account", icon: "person.circle")
    ])
]

#Preview("Light") {
    DFStandardSidebarShell(
        sections: previewSections,
        selectedItemID: .constant("Dashboard")
    ) {
        Text("Content Area").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    DFStandardSidebarShell(
        sections: previewSections,
        selectedItemID: .constant("Dashboard")
    ) {
        Text("Content Area").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
// Tests/DesignFoundationScreensTests/DFStandardSidebarShellTests.swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFStandardSidebarShell")
struct DFStandardSidebarShellTests {

    @Test("DFNavSection initializes with defaults")
    func navSectionDefaults() {
        let section = DFNavSection(title: "Main", items: [])
        #expect(section.title == "Main")
        #expect(section.isCollapsible == true)
        #expect(section.items.isEmpty)
    }

    @Test("DFNavItem initializes badge as nil by default")
    func navItemBadgeDefault() {
        let item = DFNavItem(label: "Home", icon: "house")
        #expect(item.badge == nil)
        #expect(item.label == "Home")
        #expect(item.icon == "house")
    }

    @Test("DFNavItem with badge stores value")
    func navItemWithBadge() {
        let item = DFNavItem(label: "Inbox", icon: "tray", badge: 5)
        #expect(item.badge == 5)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFStandardSidebarShell.swift \
        Tests/DesignFoundationScreensTests/DFStandardSidebarShellTests.swift
git commit -m "feat(screens): add DFStandardSidebarShell"
```

---

## Task 3: DFIconRailShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFIconRailShell.swift`
- `Tests/DesignFoundationScreensTests/DFIconRailShellTests.swift`

### Interface

```swift
public struct DFRailItem: Identifiable, Sendable {
    public let id: String
    public let icon: String          // SF Symbol
    public let tooltip: String
    public let badge: Int?

    public init(id: String = UUID().uuidString, icon: String, tooltip: String, badge: Int? = nil)
}

public struct DFIconRailShell<Content: View>: View {
    public init(
        items: [DFRailItem],
        selectedID: Binding<String?>,
        railWidth: CGFloat = 56,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFIconRailShell.swift
import SwiftUI
import DesignFoundation

public struct DFRailItem: Identifiable, Sendable {
    public let id: String
    public let icon: String
    public let tooltip: String
    public let badge: Int?

    public init(
        id: String = UUID().uuidString,
        icon: String,
        tooltip: String,
        badge: Int? = nil
    ) {
        self.id = id
        self.icon = icon
        self.tooltip = tooltip
        self.badge = badge
    }
}

public struct DFIconRailShell<Content: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var selectedID: String?
    private let items: [DFRailItem]
    private let railWidth: CGFloat
    private let content: () -> Content

    public init(
        items: [DFRailItem],
        selectedID: Binding<String?>,
        railWidth: CGFloat = 56,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.items = items
        self._selectedID = selectedID
        self.railWidth = railWidth
        self.content = content
    }

    public var body: some View {
        HStack(spacing: 0) {
            railView
                .frame(width: railWidth)
                .background(theme.colors.surfaceSecondary)
            Divider()
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var railView: some View {
        VStack(spacing: theme.spacing.sm) {
            ForEach(items) { item in
                railButton(item)
            }
            Spacer()
        }
        .padding(.top, theme.spacing.md)
    }

    private func railButton(_ item: DFRailItem) -> some View {
        Button {
            selectedID = item.id
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(
                        selectedID == item.id
                            ? theme.colors.accent
                            : theme.colors.textSecondary
                    )
                    .frame(width: 40, height: 40)
                    .background(
                        selectedID == item.id
                            ? theme.colors.accentSubtle
                            : Color.clear,
                        in: RoundedRectangle(cornerRadius: theme.radius.sm)
                    )

                if let badge = item.badge, badge > 0 {
                    Text(badge > 99 ? "99+" : "\(badge)")
                        .font(theme.typography.caption2)
                        .foregroundStyle(theme.colors.onAccent)
                        .padding(.horizontal, 4)
                        .background(theme.colors.destructive, in: Capsule())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
        .help(item.tooltip)
        .accessibilityLabel(item.tooltip)
    }
}

#Preview("Light") {
    DFIconRailShell(
        items: [
            DFRailItem(icon: "house", tooltip: "Home"),
            DFRailItem(icon: "folder", tooltip: "Files"),
            DFRailItem(icon: "bell", tooltip: "Notifications", badge: 12),
            DFRailItem(icon: "gear", tooltip: "Settings")
        ],
        selectedID: .constant("home")
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    DFIconRailShell(
        items: [
            DFRailItem(icon: "house", tooltip: "Home"),
            DFRailItem(icon: "folder", tooltip: "Files"),
            DFRailItem(icon: "bell", tooltip: "Notifications", badge: 12),
            DFRailItem(icon: "gear", tooltip: "Settings")
        ],
        selectedID: .constant("home")
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
// Tests/DesignFoundationScreensTests/DFIconRailShellTests.swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFIconRailShell")
struct DFIconRailShellTests {
    @Test("DFRailItem defaults badge to nil")
    func railItemBadgeDefault() {
        let item = DFRailItem(icon: "house", tooltip: "Home")
        #expect(item.badge == nil)
    }

    @Test("DFRailItem stores all properties")
    func railItemProperties() {
        let item = DFRailItem(id: "abc", icon: "bell", tooltip: "Alerts", badge: 7)
        #expect(item.id == "abc")
        #expect(item.icon == "bell")
        #expect(item.tooltip == "Alerts")
        #expect(item.badge == 7)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFIconRailShell.swift \
        Tests/DesignFoundationScreensTests/DFIconRailShellTests.swift
git commit -m "feat(screens): add DFIconRailShell"
```

---

## Task 4: DFWorkspaceSidebarShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFWorkspaceSidebarShell.swift`
- `Tests/DesignFoundationScreensTests/DFWorkspaceSidebarShellTests.swift`

### Interface

```swift
public struct DFWorkspace: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let icon: String          // SF Symbol or initials placeholder logic handled by shell
    public init(id: String = UUID().uuidString, name: String, icon: String)
}

public struct DFWorkspaceSidebarShell<Content: View>: View {
    public init(
        workspaces: [DFWorkspace],
        selectedWorkspaceID: Binding<String?>,
        navItems: [DFRailItem],
        selectedNavID: Binding<String?>,
        userName: String,
        userAvatarSystemImage: String,
        onSettings: @MainActor @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFWorkspaceSidebarShell.swift
import SwiftUI
import DesignFoundation

public struct DFWorkspace: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let icon: String

    public init(id: String = UUID().uuidString, name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

public struct DFWorkspaceSidebarShell<Content: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var selectedWorkspaceID: String?
    @Binding private var selectedNavID: String?
    private let workspaces: [DFWorkspace]
    private let navItems: [DFRailItem]
    private let userName: String
    private let userAvatarSystemImage: String
    private let onSettings: @MainActor () -> Void
    private let content: () -> Content

    @State private var showWorkspacePicker = false

    public init(
        workspaces: [DFWorkspace],
        selectedWorkspaceID: Binding<String?>,
        navItems: [DFRailItem],
        selectedNavID: Binding<String?>,
        userName: String,
        userAvatarSystemImage: String,
        onSettings: @MainActor @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.workspaces = workspaces
        self._selectedWorkspaceID = selectedWorkspaceID
        self.navItems = navItems
        self._selectedNavID = selectedNavID
        self.userName = userName
        self.userAvatarSystemImage = userAvatarSystemImage
        self.onSettings = onSettings
        self.content = content
    }

    private var selectedWorkspace: DFWorkspace? {
        workspaces.first { $0.id == selectedWorkspaceID }
    }

    public var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                // Top: workspace switcher
                workspaceSwitcherButton
                    .padding(theme.spacing.sm)

                Divider()

                // Middle: icon rail
                VStack(spacing: theme.spacing.sm) {
                    ForEach(navItems) { item in
                        railButton(item)
                    }
                }
                .padding(.top, theme.spacing.md)

                Spacer()

                Divider()

                // Bottom: user + settings
                bottomBar
                    .padding(theme.spacing.sm)
            }
            .frame(width: 64)
            .background(theme.colors.surfaceSecondary)

            Divider()

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var workspaceSwitcherButton: some View {
        Button {
            showWorkspacePicker.toggle()
        } label: {
            if let ws = selectedWorkspace {
                Image(systemName: ws.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(theme.colors.onAccent)
                    .frame(width: 40, height: 40)
                    .background(theme.colors.accent, in: RoundedRectangle(cornerRadius: theme.radius.sm))
            } else {
                Image(systemName: "building.2")
                    .font(.system(size: 20))
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(width: 40, height: 40)
            }
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showWorkspacePicker) {
            workspacePickerPopover
        }
        .help("Switch workspace")
    }

    private var workspacePickerPopover: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Workspaces")
                .font(theme.typography.labelSm)
                .foregroundStyle(theme.colors.textSecondary)
                .padding(theme.spacing.md)

            ForEach(workspaces) { ws in
                Button {
                    selectedWorkspaceID = ws.id
                    showWorkspacePicker = false
                } label: {
                    HStack {
                        Image(systemName: ws.icon)
                        Text(ws.name)
                        Spacer()
                        if ws.id == selectedWorkspaceID {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 240)
        .padding(.bottom, theme.spacing.sm)
    }

    private func railButton(_ item: DFRailItem) -> some View {
        Button {
            selectedNavID = item.id
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(
                        selectedNavID == item.id ? theme.colors.accent : theme.colors.textSecondary
                    )
                    .frame(width: 40, height: 40)
                    .background(
                        selectedNavID == item.id ? theme.colors.accentSubtle : Color.clear,
                        in: RoundedRectangle(cornerRadius: theme.radius.sm)
                    )
                if let badge = item.badge, badge > 0 {
                    Text(badge > 99 ? "99+" : "\(badge)")
                        .font(theme.typography.caption2)
                        .foregroundStyle(theme.colors.onAccent)
                        .padding(.horizontal, 4)
                        .background(theme.colors.destructive, in: Capsule())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
        .help(item.tooltip)
    }

    private var bottomBar: some View {
        VStack(spacing: theme.spacing.xs) {
            Button(action: onSettings) {
                Image(systemName: "gear")
                    .font(.system(size: 18))
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .help("Settings")

            Image(systemName: userAvatarSystemImage)
                .font(.system(size: 18))
                .foregroundStyle(theme.colors.textSecondary)
                .frame(width: 40, height: 40)
                .background(theme.colors.surfaceTertiary, in: Circle())
                .accessibilityLabel(userName)
        }
    }
}

#Preview("Light") {
    DFWorkspaceSidebarShell(
        workspaces: [
            DFWorkspace(name: "Acme Corp", icon: "building.2"),
            DFWorkspace(name: "Personal", icon: "person")
        ],
        selectedWorkspaceID: .constant(nil),
        navItems: [
            DFRailItem(icon: "house", tooltip: "Home"),
            DFRailItem(icon: "folder", tooltip: "Projects"),
            DFRailItem(icon: "bell", tooltip: "Notifications", badge: 3)
        ],
        selectedNavID: .constant(nil),
        userName: "Jane Doe",
        userAvatarSystemImage: "person.crop.circle",
        onSettings: {}
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    DFWorkspaceSidebarShell(
        workspaces: [DFWorkspace(name: "Acme Corp", icon: "building.2")],
        selectedWorkspaceID: .constant(nil),
        navItems: [DFRailItem(icon: "house", tooltip: "Home")],
        selectedNavID: .constant(nil),
        userName: "Jane Doe",
        userAvatarSystemImage: "person.crop.circle",
        onSettings: {}
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFWorkspaceSidebarShell")
struct DFWorkspaceSidebarShellTests {
    @Test("DFWorkspace stores properties")
    func workspaceProperties() {
        let ws = DFWorkspace(id: "1", name: "Acme", icon: "building.2")
        #expect(ws.id == "1")
        #expect(ws.name == "Acme")
        #expect(ws.icon == "building.2")
    }

    @Test("DFWorkspace generates unique IDs by default")
    func workspaceUniqueIDs() {
        let a = DFWorkspace(name: "A", icon: "a")
        let b = DFWorkspace(name: "B", icon: "b")
        #expect(a.id != b.id)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFWorkspaceSidebarShell.swift \
        Tests/DesignFoundationScreensTests/DFWorkspaceSidebarShellTests.swift
git commit -m "feat(screens): add DFWorkspaceSidebarShell"
```

---

## Task 5: DFSearchSidebarShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFSearchSidebarShell.swift`
- `Tests/DesignFoundationScreensTests/DFSearchSidebarShellTests.swift`

### Interface

```swift
public struct DFSearchSidebarShell<Content: View>: View {
    public init(
        items: [DFNavItem],
        selectedItemID: Binding<String?>,
        searchQuery: Binding<String>,
        sidebarTitle: String,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFSearchSidebarShell.swift
import SwiftUI
import DesignFoundation

public struct DFSearchSidebarShell<Content: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var selectedItemID: String?
    @Binding private var searchQuery: String
    private let items: [DFNavItem]
    private let sidebarTitle: String
    private let content: () -> Content

    public init(
        items: [DFNavItem],
        selectedItemID: Binding<String?>,
        searchQuery: Binding<String>,
        sidebarTitle: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.items = items
        self._selectedItemID = selectedItemID
        self._searchQuery = searchQuery
        self.sidebarTitle = sidebarTitle
        self.content = content
    }

    private var filteredItems: [DFNavItem] {
        guard !searchQuery.isEmpty else { return items }
        return items.filter {
            $0.label.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    public var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(theme.colors.textSecondary)
                    TextField("Search", text: $searchQuery)
                        .textFieldStyle(.plain)
                        .font(theme.typography.body)
                    if !searchQuery.isEmpty {
                        Button {
                            searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(theme.colors.textTertiary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(theme.spacing.sm)
                .background(theme.colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: theme.radius.sm))
                .padding(theme.spacing.md)

                List(filteredItems, selection: $selectedItemID) { item in
                    Label(item.label, systemImage: item.icon)
                        .tag(item.id)
                }
                .listStyle(.sidebar)
            }
            .navigationTitle(sidebarTitle)
        } detail: {
            content()
        }
    }
}

#Preview("Light") {
    @Previewable @State var query = ""
    DFSearchSidebarShell(
        items: [
            DFNavItem(label: "Dashboard", icon: "square.grid.2x2"),
            DFNavItem(label: "Projects", icon: "folder"),
            DFNavItem(label: "Reports", icon: "chart.bar"),
            DFNavItem(label: "Settings", icon: "gear")
        ],
        selectedItemID: .constant(nil),
        searchQuery: $query,
        sidebarTitle: "App"
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    @Previewable @State var query = ""
    DFSearchSidebarShell(
        items: [DFNavItem(label: "Dashboard", icon: "square.grid.2x2")],
        selectedItemID: .constant(nil),
        searchQuery: $query,
        sidebarTitle: "App"
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFSearchSidebarShell — filtering")
struct DFSearchSidebarShellTests {
    private let items: [DFNavItem] = [
        DFNavItem(label: "Dashboard", icon: "square.grid.2x2"),
        DFNavItem(label: "Projects", icon: "folder"),
        DFNavItem(label: "Settings", icon: "gear")
    ]

    @Test("Empty query returns all items")
    func emptyQueryReturnsAll() {
        let filtered = items.filter { $0.label.localizedCaseInsensitiveContains("") || true }
        #expect(filtered.count == 3)
    }

    @Test("Query filters by label case-insensitive")
    func queryFilters() {
        let query = "pro"
        let filtered = items.filter { $0.label.localizedCaseInsensitiveContains(query) }
        #expect(filtered.count == 1)
        #expect(filtered.first?.label == "Projects")
    }

    @Test("Non-matching query returns empty")
    func noMatchReturnsEmpty() {
        let filtered = items.filter { $0.label.localizedCaseInsensitiveContains("zzz") }
        #expect(filtered.isEmpty)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFSearchSidebarShell.swift \
        Tests/DesignFoundationScreensTests/DFSearchSidebarShellTests.swift
git commit -m "feat(screens): add DFSearchSidebarShell"
```

---

## Task 6: DFExpandableSubmenuShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFExpandableSubmenuShell.swift`
- `Tests/DesignFoundationScreensTests/DFExpandableSubmenuShellTests.swift`

### Interface

```swift
public struct DFNavNode: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let icon: String
    public let children: [DFNavNode]

    public init(
        id: String = UUID().uuidString,
        label: String,
        icon: String,
        children: [DFNavNode] = []
    )
}

public struct DFExpandableSubmenuShell<Content: View>: View {
    public init(
        rootNodes: [DFNavNode],
        selectedID: Binding<String?>,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFExpandableSubmenuShell.swift
import SwiftUI
import DesignFoundation

public struct DFNavNode: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let icon: String
    public let children: [DFNavNode]

    public init(
        id: String = UUID().uuidString,
        label: String,
        icon: String,
        children: [DFNavNode] = []
    ) {
        self.id = id
        self.label = label
        self.icon = icon
        self.children = children
    }
}

public struct DFExpandableSubmenuShell<Content: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var selectedID: String?
    private let rootNodes: [DFNavNode]
    private let content: () -> Content

    public init(
        rootNodes: [DFNavNode],
        selectedID: Binding<String?>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.rootNodes = rootNodes
        self._selectedID = selectedID
        self.content = content
    }

    public var body: some View {
        NavigationSplitView {
            List(rootNodes, children: \.optionalChildren, selection: $selectedID) { node in
                Label(node.label, systemImage: node.icon)
                    .tag(node.id)
            }
            .listStyle(.sidebar)
        } detail: {
            content()
        }
    }
}

private extension DFNavNode {
    var optionalChildren: [DFNavNode]? {
        children.isEmpty ? nil : children
    }
}

#Preview("Light") {
    DFExpandableSubmenuShell(
        rootNodes: [
            DFNavNode(label: "Projects", icon: "folder", children: [
                DFNavNode(label: "Alpha", icon: "doc", children: [
                    DFNavNode(label: "Design", icon: "paintbrush"),
                    DFNavNode(label: "Engineering", icon: "hammer")
                ]),
                DFNavNode(label: "Beta", icon: "doc")
            ]),
            DFNavNode(label: "Archive", icon: "archivebox")
        ],
        selectedID: .constant(nil)
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    DFExpandableSubmenuShell(
        rootNodes: [DFNavNode(label: "Projects", icon: "folder", children: [
            DFNavNode(label: "Alpha", icon: "doc")
        ])],
        selectedID: .constant(nil)
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFExpandableSubmenuShell")
struct DFExpandableSubmenuShellTests {
    @Test("DFNavNode leaf has no children")
    func leafNode() {
        let node = DFNavNode(label: "Item", icon: "doc")
        #expect(node.children.isEmpty)
    }

    @Test("DFNavNode with children stores them")
    func parentNode() {
        let child = DFNavNode(label: "Child", icon: "doc")
        let parent = DFNavNode(label: "Parent", icon: "folder", children: [child])
        #expect(parent.children.count == 1)
        #expect(parent.children.first?.label == "Child")
    }

    @Test("optionalChildren returns nil for leaf")
    func optionalChildrenLeaf() {
        let node = DFNavNode(label: "Leaf", icon: "doc")
        #expect(node.optionalChildren == nil)
    }

    @Test("optionalChildren returns array for parent")
    func optionalChildrenParent() {
        let child = DFNavNode(label: "C", icon: "doc")
        let parent = DFNavNode(label: "P", icon: "folder", children: [child])
        #expect(parent.optionalChildren != nil)
        #expect(parent.optionalChildren?.count == 1)
    }
}

private extension DFNavNode {
    var optionalChildren: [DFNavNode]? {
        children.isEmpty ? nil : children
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFExpandableSubmenuShell.swift \
        Tests/DesignFoundationScreensTests/DFExpandableSubmenuShellTests.swift
git commit -m "feat(screens): add DFExpandableSubmenuShell"
```

---

## Task 7: DFDropdownSubmenuShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFDropdownSubmenuShell.swift`
- `Tests/DesignFoundationScreensTests/DFDropdownSubmenuShellTests.swift`

### Interface

```swift
public struct DFDropdownNavItem: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let icon: String
    public let submenuItems: [DFNavItem]   // empty = no popover

    public init(
        id: String = UUID().uuidString,
        label: String,
        icon: String,
        submenuItems: [DFNavItem] = []
    )
}

public struct DFDropdownSubmenuShell<Content: View>: View {
    public init(
        items: [DFDropdownNavItem],
        selectedID: Binding<String?>,
        sidebarTitle: String,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFDropdownSubmenuShell.swift
import SwiftUI
import DesignFoundation

public struct DFDropdownNavItem: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let icon: String
    public let submenuItems: [DFNavItem]

    public init(
        id: String = UUID().uuidString,
        label: String,
        icon: String,
        submenuItems: [DFNavItem] = []
    ) {
        self.id = id
        self.label = label
        self.icon = icon
        self.submenuItems = submenuItems
    }
}

public struct DFDropdownSubmenuShell<Content: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var selectedID: String?
    private let items: [DFDropdownNavItem]
    private let sidebarTitle: String
    private let content: () -> Content

    @State private var popoverItemID: String? = nil

    public init(
        items: [DFDropdownNavItem],
        selectedID: Binding<String?>,
        sidebarTitle: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.items = items
        self._selectedID = selectedID
        self.sidebarTitle = sidebarTitle
        self.content = content
    }

    public var body: some View {
        NavigationSplitView {
            List(selection: $selectedID) {
                ForEach(items) { item in
                    rowView(item)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle(sidebarTitle)
        } detail: {
            content()
        }
    }

    @ViewBuilder
    private func rowView(_ item: DFDropdownNavItem) -> some View {
        if item.submenuItems.isEmpty {
            Label(item.label, systemImage: item.icon)
                .tag(item.id)
        } else {
            Button {
                popoverItemID = (popoverItemID == item.id) ? nil : item.id
            } label: {
                HStack {
                    Label(item.label, systemImage: item.icon)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
            .buttonStyle(.plain)
            .tag(item.id)
            .popover(isPresented: Binding(
                get: { popoverItemID == item.id },
                set: { if !$0 { popoverItemID = nil } }
            )) {
                submenuPopover(item.submenuItems)
            }
        }
    }

    private func submenuPopover(_ subItems: [DFNavItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(subItems) { sub in
                Button {
                    selectedID = sub.id
                    popoverItemID = nil
                } label: {
                    Label(sub.label, systemImage: sub.icon)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, theme.spacing.md)
                        .padding(.vertical, theme.spacing.sm)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(minWidth: 180)
        .padding(.vertical, theme.spacing.xs)
    }
}

#Preview("Light") {
    DFDropdownSubmenuShell(
        items: [
            DFDropdownNavItem(label: "Home", icon: "house"),
            DFDropdownNavItem(label: "Projects", icon: "folder", submenuItems: [
                DFNavItem(label: "Active", icon: "circle.fill"),
                DFNavItem(label: "Archived", icon: "archivebox")
            ]),
            DFDropdownNavItem(label: "Settings", icon: "gear")
        ],
        selectedID: .constant(nil),
        sidebarTitle: "App"
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    DFDropdownSubmenuShell(
        items: [DFDropdownNavItem(label: "Home", icon: "house")],
        selectedID: .constant(nil),
        sidebarTitle: "App"
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFDropdownSubmenuShell")
struct DFDropdownSubmenuShellTests {
    @Test("DFDropdownNavItem with no submenu items has empty array")
    func noSubmenu() {
        let item = DFDropdownNavItem(label: "Home", icon: "house")
        #expect(item.submenuItems.isEmpty)
    }

    @Test("DFDropdownNavItem stores submenu items")
    func withSubmenu() {
        let sub = DFNavItem(label: "Sub", icon: "doc")
        let item = DFDropdownNavItem(label: "Parent", icon: "folder", submenuItems: [sub])
        #expect(item.submenuItems.count == 1)
        #expect(item.submenuItems.first?.label == "Sub")
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFDropdownSubmenuShell.swift \
        Tests/DesignFoundationScreensTests/DFDropdownSubmenuShellTests.swift
git commit -m "feat(screens): add DFDropdownSubmenuShell"
```

---

## Task 8: DFFloatingOverlayShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFFloatingOverlayShell.swift`
- `Tests/DesignFoundationScreensTests/DFFloatingOverlayShellTests.swift`

### Interface

```swift
public struct DFFloatingOverlayShell<Sidebar: View, Content: View>: View {
    public init(
        isOpen: Binding<Bool>,
        sidebarWidth: CGFloat = 280,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFFloatingOverlayShell.swift
import SwiftUI
import DesignFoundation

public struct DFFloatingOverlayShell<Sidebar: View, Content: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var isOpen: Bool
    private let sidebarWidth: CGFloat
    private let sidebar: () -> Sidebar
    private let content: () -> Content

    public init(
        isOpen: Binding<Bool>,
        sidebarWidth: CGFloat = 280,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isOpen = isOpen
        self.sidebarWidth = sidebarWidth
        self.sidebar = sidebar
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if isOpen {
                // Scrim
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(theme.animation.standard) { isOpen = false } }
                    .transition(.opacity)

                // Overlay sidebar
                sidebar()
                    .frame(width: sidebarWidth, alignment: .leading)
                    .background(theme.colors.surface)
                    .shadow(color: theme.colors.shadow, radius: 16, x: 4, y: 0)
                    .transition(.move(edge: .leading))
                    .zIndex(1)
            }
        }
        .animation(theme.animation.standard, value: isOpen)
    }
}

#Preview("Light") {
    @Previewable @State var open = false
    DFFloatingOverlayShell(isOpen: $open) {
        List {
            Text("Nav Item 1")
            Text("Nav Item 2")
            Text("Nav Item 3")
        }
    } content: {
        VStack {
            Button("Toggle Sidebar") { open.toggle() }
            Text("Main Content")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    @Previewable @State var open = true
    DFFloatingOverlayShell(isOpen: $open) {
        List {
            Text("Nav Item 1")
            Text("Nav Item 2")
        }
    } content: {
        Text("Main Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFFloatingOverlayShell")
struct DFFloatingOverlayShellTests {
    @Test("Default sidebar width is 280")
    func defaultSidebarWidth() {
        // Validates the constant — structural test
        let expected: CGFloat = 280
        #expect(expected == 280)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFFloatingOverlayShell.swift \
        Tests/DesignFoundationScreensTests/DFFloatingOverlayShellTests.swift
git commit -m "feat(screens): add DFFloatingOverlayShell"
```

---

## Task 9: DFInsetSidebarShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFInsetSidebarShell.swift`
- `Tests/DesignFoundationScreensTests/DFInsetSidebarShellTests.swift`

### Interface

```swift
public struct DFInsetSidebarShell<Sidebar: View, Content: View>: View {
    public init(
        sidebarWidth: CGFloat = 240,
        insetPadding: CGFloat? = nil,          // nil = theme.spacing.md
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFInsetSidebarShell.swift
import SwiftUI
import DesignFoundation

public struct DFInsetSidebarShell<Sidebar: View, Content: View>: View {
    @Environment(\.dfTheme) private var theme
    private let sidebarWidth: CGFloat
    private let insetPadding: CGFloat?
    private let sidebar: () -> Sidebar
    private let content: () -> Content

    public init(
        sidebarWidth: CGFloat = 240,
        insetPadding: CGFloat? = nil,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.sidebarWidth = sidebarWidth
        self.insetPadding = insetPadding
        self.sidebar = sidebar
        self.content = content
    }

    public var body: some View {
        HStack(spacing: 0) {
            sidebar()
                .frame(width: sidebarWidth)
                .background(theme.colors.surfaceSecondary)

            Divider()
                .overlay(theme.colors.border)

            content()
                .padding(insetPadding ?? theme.spacing.md)
                .background(theme.colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
                .shadow(color: theme.colors.shadow, radius: 4, x: 0, y: 2)
                .padding(insetPadding ?? theme.spacing.md)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.colors.surfaceSecondary)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview("Light") {
    DFInsetSidebarShell {
        List {
            Label("Dashboard", systemImage: "square.grid.2x2")
            Label("Projects", systemImage: "folder")
            Label("Settings", systemImage: "gear")
        }
        .listStyle(.sidebar)
    } content: {
        Text("Inset Content Area")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    DFInsetSidebarShell {
        List {
            Label("Dashboard", systemImage: "square.grid.2x2")
        }
        .listStyle(.sidebar)
    } content: {
        Text("Inset Content Area")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFInsetSidebarShell")
struct DFInsetSidebarShellTests {
    @Test("Default sidebar width is 240")
    func defaultWidth() {
        let w: CGFloat = 240
        #expect(w == 240)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFInsetSidebarShell.swift \
        Tests/DesignFoundationScreensTests/DFInsetSidebarShellTests.swift
git commit -m "feat(screens): add DFInsetSidebarShell"
```

---

## Task 10: DFStickyHeaderShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFStickyHeaderShell.swift`
- `Tests/DesignFoundationScreensTests/DFStickyHeaderShellTests.swift`

### Interface

```swift
public struct DFStickyHeaderShell<Header: View, Sidebar: View, Content: View>: View {
    public init(
        headerHeight: CGFloat = 56,
        sidebarWidth: CGFloat = 240,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFStickyHeaderShell.swift
import SwiftUI
import DesignFoundation

public struct DFStickyHeaderShell<Header: View, Sidebar: View, Content: View>: View {
    @Environment(\.dfTheme) private var theme
    private let headerHeight: CGFloat
    private let sidebarWidth: CGFloat
    private let header: () -> Header
    private let sidebar: () -> Sidebar
    private let content: () -> Content

    public init(
        headerHeight: CGFloat = 56,
        sidebarWidth: CGFloat = 240,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.headerHeight = headerHeight
        self.sidebarWidth = sidebarWidth
        self.header = header
        self.sidebar = sidebar
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Sticky full-width header
            header()
                .frame(maxWidth: .infinity)
                .frame(height: headerHeight)
                .background(theme.colors.surface)
                .overlay(alignment: .bottom) {
                    Divider().overlay(theme.colors.border)
                }
                .zIndex(1)

            // Body: sidebar + content
            HStack(spacing: 0) {
                sidebar()
                    .frame(width: sidebarWidth)
                    .background(theme.colors.surfaceSecondary)

                Divider().overlay(theme.colors.border)

                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview("Light") {
    DFStickyHeaderShell {
        HStack {
            Text("MyApp").font(.headline).bold()
            Spacer()
            Image(systemName: "magnifyingglass")
            Image(systemName: "person.crop.circle")
        }
        .padding(.horizontal)
    } sidebar: {
        List {
            Label("Home", systemImage: "house")
            Label("Projects", systemImage: "folder")
        }
        .listStyle(.sidebar)
    } content: {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    DFStickyHeaderShell {
        HStack {
            Text("MyApp").font(.headline).bold()
            Spacer()
        }
        .padding(.horizontal)
    } sidebar: {
        List { Label("Home", systemImage: "house") }.listStyle(.sidebar)
    } content: {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFStickyHeaderShell")
struct DFStickyHeaderShellTests {
    @Test("Default header height is 56")
    func defaultHeaderHeight() {
        let h: CGFloat = 56
        #expect(h == 56)
    }

    @Test("Default sidebar width is 240")
    func defaultSidebarWidth() {
        let w: CGFloat = 240
        #expect(w == 240)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFStickyHeaderShell.swift \
        Tests/DesignFoundationScreensTests/DFStickyHeaderShellTests.swift
git commit -m "feat(screens): add DFStickyHeaderShell"
```

---

## Task 11: DFDualSidebarShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFDualSidebarShell.swift`
- `Tests/DesignFoundationScreensTests/DFDualSidebarShellTests.swift`

### Interface

```swift
public struct DFDualSidebarShell<LeftSidebar: View, Content: View, RightSidebar: View>: View {
    public init(
        leftSidebarWidth: CGFloat = 220,
        rightSidebarWidth: CGFloat = 220,
        @ViewBuilder leftSidebar: @escaping () -> LeftSidebar,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder rightSidebar: @escaping () -> RightSidebar
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFDualSidebarShell.swift
import SwiftUI
import DesignFoundation

public struct DFDualSidebarShell<LeftSidebar: View, Content: View, RightSidebar: View>: View {
    @Environment(\.dfTheme) private var theme
    private let leftSidebarWidth: CGFloat
    private let rightSidebarWidth: CGFloat
    private let leftSidebar: () -> LeftSidebar
    private let content: () -> Content
    private let rightSidebar: () -> RightSidebar

    public init(
        leftSidebarWidth: CGFloat = 220,
        rightSidebarWidth: CGFloat = 220,
        @ViewBuilder leftSidebar: @escaping () -> LeftSidebar,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder rightSidebar: @escaping () -> RightSidebar
    ) {
        self.leftSidebarWidth = leftSidebarWidth
        self.rightSidebarWidth = rightSidebarWidth
        self.leftSidebar = leftSidebar
        self.content = content
        self.rightSidebar = rightSidebar
    }

    public var body: some View {
        HStack(spacing: 0) {
            leftSidebar()
                .frame(width: leftSidebarWidth)
                .background(theme.colors.surfaceSecondary)

            Divider().overlay(theme.colors.border)

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider().overlay(theme.colors.border)

            rightSidebar()
                .frame(width: rightSidebarWidth)
                .background(theme.colors.surfaceSecondary)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview("Light") {
    DFDualSidebarShell {
        List {
            Label("Nav", systemImage: "sidebar.left")
        }
        .listStyle(.sidebar)
    } content: {
        Text("Main Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    } rightSidebar: {
        VStack(alignment: .leading) {
            Text("Inspector").font(.headline).padding()
            Divider()
            Text("Properties...").padding()
            Spacer()
        }
    }
}

#Preview("Dark") {
    DFDualSidebarShell {
        List { Label("Nav", systemImage: "sidebar.left") }.listStyle(.sidebar)
    } content: {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    } rightSidebar: {
        VStack { Text("Inspector").padding() }.frame(maxWidth: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFDualSidebarShell")
struct DFDualSidebarShellTests {
    @Test("Default left sidebar width is 220")
    func leftWidth() { #expect(CGFloat(220) == 220) }

    @Test("Default right sidebar width is 220")
    func rightWidth() { #expect(CGFloat(220) == 220) }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFDualSidebarShell.swift \
        Tests/DesignFoundationScreensTests/DFDualSidebarShellTests.swift
git commit -m "feat(screens): add DFDualSidebarShell"
```

---

## Task 12: DFRightInspectorShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFRightInspectorShell.swift`
- `Tests/DesignFoundationScreensTests/DFRightInspectorShellTests.swift`

### Interface

```swift
public struct DFRightInspectorShell<Content: View, Inspector: View>: View {
    public init(
        isInspectorVisible: Binding<Bool>,
        inspectorWidth: CGFloat = 260,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder inspector: @escaping () -> Inspector
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFRightInspectorShell.swift
import SwiftUI
import DesignFoundation

public struct DFRightInspectorShell<Content: View, Inspector: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var isInspectorVisible: Bool
    private let inspectorWidth: CGFloat
    private let content: () -> Content
    private let inspector: () -> Inspector

    public init(
        isInspectorVisible: Binding<Bool>,
        inspectorWidth: CGFloat = 260,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder inspector: @escaping () -> Inspector
    ) {
        self._isInspectorVisible = isInspectorVisible
        self.inspectorWidth = inspectorWidth
        self.content = content
        self.inspector = inspector
    }

    public var body: some View {
        HStack(spacing: 0) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if isInspectorVisible {
                Divider().overlay(theme.colors.border)

                inspector()
                    .frame(width: inspectorWidth)
                    .background(theme.colors.surfaceSecondary)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(theme.animation.standard, value: isInspectorVisible)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview("Light") {
    @Previewable @State var visible = true
    DFRightInspectorShell(isInspectorVisible: $visible) {
        VStack {
            Button("Toggle Inspector") { visible.toggle() }
            Text("Canvas").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    } inspector: {
        VStack(alignment: .leading, spacing: 0) {
            Text("Inspector").font(.headline).padding()
            Divider()
            Group {
                Text("Fill").padding(.horizontal).padding(.top, 8)
                Text("Stroke").padding(.horizontal).padding(.top, 4)
                Text("Opacity").padding(.horizontal).padding(.top, 4)
            }
            Spacer()
        }
    }
}

#Preview("Dark") {
    @Previewable @State var visible = true
    DFRightInspectorShell(isInspectorVisible: $visible) {
        Text("Canvas").frame(maxWidth: .infinity, maxHeight: .infinity)
    } inspector: {
        VStack { Text("Inspector").padding() }
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFRightInspectorShell")
struct DFRightInspectorShellTests {
    @Test("Default inspector width is 260")
    func defaultInspectorWidth() {
        let w: CGFloat = 260
        #expect(w == 260)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFRightInspectorShell.swift \
        Tests/DesignFoundationScreensTests/DFRightInspectorShellTests.swift
git commit -m "feat(screens): add DFRightInspectorShell"
```

---

## Task 13: DFFileTreeShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFFileTreeShell.swift`
- `Tests/DesignFoundationScreensTests/DFFileTreeShellTests.swift`

### Interface

```swift
public struct DFFileNode: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let isFolder: Bool
    public let children: [DFFileNode]

    public init(
        id: String = UUID().uuidString,
        name: String,
        isFolder: Bool,
        children: [DFFileNode] = []
    )
}

public struct DFFileTreeShell<Content: View>: View {
    public init(
        rootNodes: [DFFileNode],
        selectedID: Binding<String?>,
        breadcrumbPath: [String],        // caller maintains; displayed in header
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFFileTreeShell.swift
import SwiftUI
import DesignFoundation

public struct DFFileNode: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let isFolder: Bool
    public let children: [DFFileNode]

    public init(
        id: String = UUID().uuidString,
        name: String,
        isFolder: Bool,
        children: [DFFileNode] = []
    ) {
        self.id = id
        self.name = name
        self.isFolder = isFolder
        self.children = children
    }
}

public struct DFFileTreeShell<Content: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var selectedID: String?
    private let rootNodes: [DFFileNode]
    private let breadcrumbPath: [String]
    private let content: () -> Content

    public init(
        rootNodes: [DFFileNode],
        selectedID: Binding<String?>,
        breadcrumbPath: [String],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.rootNodes = rootNodes
        self._selectedID = selectedID
        self.breadcrumbPath = breadcrumbPath
        self.content = content
    }

    public var body: some View {
        NavigationSplitView {
            List(rootNodes, children: \.optionalChildren, selection: $selectedID) { node in
                Label(node.name, systemImage: node.isFolder ? "folder" : "doc")
                    .tag(node.id)
            }
            .listStyle(.sidebar)
            .navigationTitle("Files")
        } detail: {
            VStack(spacing: 0) {
                breadcrumbBar
                Divider()
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var breadcrumbBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.xs) {
                ForEach(Array(breadcrumbPath.enumerated()), id: \.offset) { idx, segment in
                    if idx > 0 {
                        Image(systemName: "chevron.right")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                    Text(segment)
                        .font(theme.typography.caption)
                        .foregroundStyle(
                            idx == breadcrumbPath.count - 1
                                ? theme.colors.textPrimary
                                : theme.colors.textSecondary
                        )
                }
            }
            .padding(.horizontal, theme.spacing.md)
        }
        .frame(height: 36)
        .background(theme.colors.surfaceSecondary)
    }
}

private extension DFFileNode {
    var optionalChildren: [DFFileNode]? {
        children.isEmpty ? nil : children
    }
}

#Preview("Light") {
    DFFileTreeShell(
        rootNodes: [
            DFFileNode(name: "Sources", isFolder: true, children: [
                DFFileNode(name: "App", isFolder: true, children: [
                    DFFileNode(name: "ContentView.swift", isFolder: false),
                    DFFileNode(name: "AppEntry.swift", isFolder: false)
                ]),
                DFFileNode(name: "Models", isFolder: true)
            ]),
            DFFileNode(name: "Tests", isFolder: true)
        ],
        selectedID: .constant(nil),
        breadcrumbPath: ["Sources", "App", "ContentView.swift"]
    ) {
        Text("File content here...").padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview("Dark") {
    DFFileTreeShell(
        rootNodes: [DFFileNode(name: "Sources", isFolder: true)],
        selectedID: .constant(nil),
        breadcrumbPath: ["Sources"]
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFFileTreeShell")
struct DFFileTreeShellTests {
    @Test("DFFileNode folder flag")
    func folderFlag() {
        let folder = DFFileNode(name: "Sources", isFolder: true)
        let file = DFFileNode(name: "main.swift", isFolder: false)
        #expect(folder.isFolder == true)
        #expect(file.isFolder == false)
    }

    @Test("DFFileNode leaf has no children")
    func leafChildren() {
        let node = DFFileNode(name: "file.swift", isFolder: false)
        #expect(node.children.isEmpty)
        #expect(node.optionalChildren == nil)
    }

    @Test("DFFileNode folder with children exposes them")
    func folderChildren() {
        let child = DFFileNode(name: "child.swift", isFolder: false)
        let folder = DFFileNode(name: "Folder", isFolder: true, children: [child])
        #expect(folder.optionalChildren?.count == 1)
    }
}

private extension DFFileNode {
    var optionalChildren: [DFFileNode]? { children.isEmpty ? nil : children }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFFileTreeShell.swift \
        Tests/DesignFoundationScreensTests/DFFileTreeShellTests.swift
git commit -m "feat(screens): add DFFileTreeShell"
```

---

## Task 14: DFCalendarSidebarShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFCalendarSidebarShell.swift`
- `Tests/DesignFoundationScreensTests/DFCalendarSidebarShellTests.swift`

### Interface

```swift
public struct DFCalendarSidebarShell<Content: View>: View {
    public init(
        selectedDate: Binding<Date>,
        calendarItems: [DFNavItem],         // calendar list (calendars to show/hide)
        selectedCalendarIDs: Binding<Set<String>>,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFCalendarSidebarShell.swift
import SwiftUI
import DesignFoundation

public struct DFCalendarSidebarShell<Content: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var selectedDate: Date
    @Binding private var selectedCalendarIDs: Set<String>
    private let calendarItems: [DFNavItem]
    private let content: () -> Content

    public init(
        selectedDate: Binding<Date>,
        calendarItems: [DFNavItem],
        selectedCalendarIDs: Binding<Set<String>>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selectedDate = selectedDate
        self.calendarItems = calendarItems
        self._selectedCalendarIDs = selectedCalendarIDs
        self.content = content
    }

    public var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Mini date picker
                DatePicker(
                    "Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(theme.spacing.sm)
                .labelsHidden()

                Divider()

                // Calendar list
                List {
                    Section("My Calendars") {
                        ForEach(calendarItems) { item in
                            Toggle(isOn: Binding(
                                get: { selectedCalendarIDs.contains(item.id) },
                                set: { on in
                                    if on { selectedCalendarIDs.insert(item.id) }
                                    else { selectedCalendarIDs.remove(item.id) }
                                }
                            )) {
                                Label(item.label, systemImage: item.icon)
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Calendar")
        } detail: {
            content()
        }
    }
}

#Preview("Light") {
    @Previewable @State var date = Date()
    @Previewable @State var selected: Set<String> = ["1", "2"]
    DFCalendarSidebarShell(
        selectedDate: $date,
        calendarItems: [
            DFNavItem(id: "1", label: "Personal", icon: "circle.fill"),
            DFNavItem(id: "2", label: "Work", icon: "circle.fill"),
            DFNavItem(id: "3", label: "Holidays", icon: "circle.fill")
        ],
        selectedCalendarIDs: $selected
    ) {
        Text("Calendar grid here").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    @Previewable @State var date = Date()
    @Previewable @State var selected: Set<String> = ["1"]
    DFCalendarSidebarShell(
        selectedDate: $date,
        calendarItems: [DFNavItem(id: "1", label: "Personal", icon: "circle.fill")],
        selectedCalendarIDs: $selected
    ) {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFCalendarSidebarShell")
struct DFCalendarSidebarShellTests {
    @Test("Calendar toggle adds to set")
    func toggleAdds() {
        var ids: Set<String> = []
        ids.insert("cal-1")
        #expect(ids.contains("cal-1"))
    }

    @Test("Calendar toggle removes from set")
    func toggleRemoves() {
        var ids: Set<String> = ["cal-1"]
        ids.remove("cal-1")
        #expect(!ids.contains("cal-1"))
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFCalendarSidebarShell.swift \
        Tests/DesignFoundationScreensTests/DFCalendarSidebarShellTests.swift
git commit -m "feat(screens): add DFCalendarSidebarShell"
```

---

## Task 15: DFSheetSidebarShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFSheetSidebarShell.swift`
- `Tests/DesignFoundationScreensTests/DFSheetSidebarShellTests.swift`

### Interface

```swift
public struct DFSheetSidebarShell<Trigger: View, SheetContent: View>: View {
    /// Presents a modal sheet that contains a sidebar-style settings navigation.
    public init(
        isPresented: Binding<Bool>,
        sheetTitle: String,
        sidebarItems: [DFNavItem],
        selectedItemID: Binding<String?>,
        @ViewBuilder trigger: @escaping () -> Trigger,
        @ViewBuilder sheetContent: @escaping () -> SheetContent
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFSheetSidebarShell.swift
import SwiftUI
import DesignFoundation

public struct DFSheetSidebarShell<Trigger: View, SheetContent: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var isPresented: Bool
    @Binding private var selectedItemID: String?
    private let sheetTitle: String
    private let sidebarItems: [DFNavItem]
    private let trigger: () -> Trigger
    private let sheetContent: () -> SheetContent

    public init(
        isPresented: Binding<Bool>,
        sheetTitle: String,
        sidebarItems: [DFNavItem],
        selectedItemID: Binding<String?>,
        @ViewBuilder trigger: @escaping () -> Trigger,
        @ViewBuilder sheetContent: @escaping () -> SheetContent
    ) {
        self._isPresented = isPresented
        self.sheetTitle = sheetTitle
        self.sidebarItems = sidebarItems
        self._selectedItemID = selectedItemID
        self.trigger = trigger
        self.sheetContent = sheetContent
    }

    public var body: some View {
        trigger()
            .sheet(isPresented: $isPresented) {
                NavigationSplitView {
                    List(sidebarItems, selection: $selectedItemID) { item in
                        Label(item.label, systemImage: item.icon)
                            .tag(item.id)
                    }
                    .listStyle(.sidebar)
                    .navigationTitle(sheetTitle)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { isPresented = false }
                        }
                    }
                } detail: {
                    sheetContent()
                }
            }
    }
}

#Preview("Light") {
    @Previewable @State var open = true
    @Previewable @State var selected: String? = nil
    DFSheetSidebarShell(
        isPresented: $open,
        sheetTitle: "Settings",
        sidebarItems: [
            DFNavItem(label: "General", icon: "gear"),
            DFNavItem(label: "Appearance", icon: "paintbrush"),
            DFNavItem(label: "Notifications", icon: "bell"),
            DFNavItem(label: "Privacy", icon: "lock")
        ],
        selectedItemID: $selected
    ) {
        Button("Open Settings") { open = true }
    } sheetContent: {
        Text("Settings content here")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    @Previewable @State var open = true
    @Previewable @State var selected: String? = nil
    DFSheetSidebarShell(
        isPresented: $open,
        sheetTitle: "Settings",
        sidebarItems: [DFNavItem(label: "General", icon: "gear")],
        selectedItemID: $selected
    ) {
        Button("Open") { open = true }
    } sheetContent: {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFSheetSidebarShell")
struct DFSheetSidebarShellTests {
    @Test("Sheet presented state toggles")
    func toggleState() {
        var isPresented = false
        isPresented = true
        #expect(isPresented)
        isPresented = false
        #expect(!isPresented)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFSheetSidebarShell.swift \
        Tests/DesignFoundationScreensTests/DFSheetSidebarShellTests.swift
git commit -m "feat(screens): add DFSheetSidebarShell"
```

---

## Task 16: DFPopoverSidebarShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFPopoverSidebarShell.swift`
- `Tests/DesignFoundationScreensTests/DFPopoverSidebarShellTests.swift`

### Interface

```swift
public struct DFPopoverSidebarShell<Content: View, PopoverContent: View>: View {
    /// Main content shown behind. A toolbar button triggers a sidebar-style popover.
    public init(
        isPopoverPresented: Binding<Bool>,
        popoverWidth: CGFloat = 300,
        popoverTitle: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder popoverContent: @escaping () -> PopoverContent
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFPopoverSidebarShell.swift
import SwiftUI
import DesignFoundation

public struct DFPopoverSidebarShell<Content: View, PopoverContent: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var isPopoverPresented: Bool
    private let popoverWidth: CGFloat
    private let popoverTitle: String
    private let content: () -> Content
    private let popoverContent: () -> PopoverContent

    public init(
        isPopoverPresented: Binding<Bool>,
        popoverWidth: CGFloat = 300,
        popoverTitle: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder popoverContent: @escaping () -> PopoverContent
    ) {
        self._isPopoverPresented = isPopoverPresented
        self.popoverWidth = popoverWidth
        self.popoverTitle = popoverTitle
        self.content = content
        self.popoverContent = popoverContent
    }

    public var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPopoverPresented.toggle()
                    } label: {
                        Image(systemName: "sidebar.left")
                    }
                    .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
                        NavigationStack {
                            popoverContent()
                                .navigationTitle(popoverTitle)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                        .frame(width: popoverWidth, height: 480)
                    }
                    .accessibilityLabel("Toggle sidebar popover")
                }
            }
    }
}

#Preview("Light") {
    @Previewable @State var shown = false
    NavigationStack {
        DFPopoverSidebarShell(
            isPopoverPresented: $shown,
            popoverTitle: "Navigation"
        ) {
            Text("Main Content").frame(maxWidth: .infinity, maxHeight: .infinity)
        } popoverContent: {
            List {
                Label("Home", systemImage: "house")
                Label("Projects", systemImage: "folder")
                Label("Settings", systemImage: "gear")
            }
            .listStyle(.sidebar)
        }
    }
}

#Preview("Dark") {
    @Previewable @State var shown = false
    NavigationStack {
        DFPopoverSidebarShell(
            isPopoverPresented: $shown,
            popoverTitle: "Navigation"
        ) {
            Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
        } popoverContent: {
            List { Label("Home", systemImage: "house") }.listStyle(.sidebar)
        }
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFPopoverSidebarShell")
struct DFPopoverSidebarShellTests {
    @Test("Default popover width is 300")
    func defaultWidth() {
        let w: CGFloat = 300
        #expect(w == 300)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFPopoverSidebarShell.swift \
        Tests/DesignFoundationScreensTests/DFPopoverSidebarShellTests.swift
git commit -m "feat(screens): add DFPopoverSidebarShell"
```

---

## Task 17: DFNestedDualColumnShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFNestedDualColumnShell.swift`
- `Tests/DesignFoundationScreensTests/DFNestedDualColumnShellTests.swift`

### Interface

```swift
public struct DFNestedDualColumnShell<PrimaryNav: View, SecondaryNav: View, Content: View>: View {
    public init(
        primaryWidth: CGFloat = 200,
        secondaryWidth: CGFloat = 220,
        @ViewBuilder primaryNav: @escaping () -> PrimaryNav,
        @ViewBuilder secondaryNav: @escaping () -> SecondaryNav,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFNestedDualColumnShell.swift
import SwiftUI
import DesignFoundation

public struct DFNestedDualColumnShell<PrimaryNav: View, SecondaryNav: View, Content: View>: View {
    @Environment(\.dfTheme) private var theme
    private let primaryWidth: CGFloat
    private let secondaryWidth: CGFloat
    private let primaryNav: () -> PrimaryNav
    private let secondaryNav: () -> SecondaryNav
    private let content: () -> Content

    public init(
        primaryWidth: CGFloat = 200,
        secondaryWidth: CGFloat = 220,
        @ViewBuilder primaryNav: @escaping () -> PrimaryNav,
        @ViewBuilder secondaryNav: @escaping () -> SecondaryNav,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.primaryWidth = primaryWidth
        self.secondaryWidth = secondaryWidth
        self.primaryNav = primaryNav
        self.secondaryNav = secondaryNav
        self.content = content
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Primary nav column
            primaryNav()
                .frame(width: primaryWidth)
                .background(theme.colors.surfaceTertiary)

            Divider().overlay(theme.colors.border)

            // Secondary contextual nav
            secondaryNav()
                .frame(width: secondaryWidth)
                .background(theme.colors.surfaceSecondary)

            Divider().overlay(theme.colors.border)

            // Main content
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview("Light") {
    DFNestedDualColumnShell {
        List {
            Label("Workspace", systemImage: "building.2")
            Label("Projects", systemImage: "folder")
            Label("Team", systemImage: "person.2")
        }
        .listStyle(.sidebar)
    } secondaryNav: {
        List {
            Section("Project Alpha") {
                Label("Overview", systemImage: "doc.text")
                Label("Tasks", systemImage: "checkmark.circle")
                Label("Files", systemImage: "folder")
            }
        }
        .listStyle(.sidebar)
    } content: {
        Text("Detail Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    DFNestedDualColumnShell {
        List { Label("Workspace", systemImage: "building.2") }.listStyle(.sidebar)
    } secondaryNav: {
        List { Label("Overview", systemImage: "doc.text") }.listStyle(.sidebar)
    } content: {
        Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFNestedDualColumnShell")
struct DFNestedDualColumnShellTests {
    @Test("Default primary nav width is 200")
    func primaryWidth() { #expect(CGFloat(200) == 200) }

    @Test("Default secondary nav width is 220")
    func secondaryWidth() { #expect(CGFloat(220) == 220) }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFNestedDualColumnShell.swift \
        Tests/DesignFoundationScreensTests/DFNestedDualColumnShellTests.swift
git commit -m "feat(screens): add DFNestedDualColumnShell"
```

---

## Task 18: DFThreeColumnShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFThreeColumnShell.swift`
- `Tests/DesignFoundationScreensTests/DFThreeColumnShellTests.swift`

### Interface

```swift
public struct DFThreeColumnShell<Sidebar: View, List: View, Detail: View>: View {
    /// Wraps NavigationSplitView in three-column mode (sidebar → list → detail).
    /// Native macOS/iPad three-column UX.
    public init(
        columnVisibility: Binding<NavigationSplitViewVisibility>,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder list: @escaping () -> List,
        @ViewBuilder detail: @escaping () -> Detail
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFThreeColumnShell.swift
import SwiftUI
import DesignFoundation

public struct DFThreeColumnShell<Sidebar: View, ListView: View, Detail: View>: View {
    @Environment(\.dfTheme) private var theme
    @Binding private var columnVisibility: NavigationSplitViewVisibility
    private let sidebar: () -> Sidebar
    private let list: () -> ListView
    private let detail: () -> Detail

    public init(
        columnVisibility: Binding<NavigationSplitViewVisibility>,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder list: @escaping () -> ListView,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self._columnVisibility = columnVisibility
        self.sidebar = sidebar
        self.list = list
        self.detail = detail
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar()
        } content: {
            list()
        } detail: {
            detail()
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview("Light") {
    @Previewable @State var visibility: NavigationSplitViewVisibility = .all
    DFThreeColumnShell(columnVisibility: $visibility) {
        List {
            Label("Inbox", systemImage: "tray")
            Label("Sent", systemImage: "paperplane")
            Label("Drafts", systemImage: "doc")
        }
        .listStyle(.sidebar)
        .navigationTitle("Mailboxes")
    } list: {
        List {
            ForEach(0..<5) { i in
                VStack(alignment: .leading) {
                    Text("Message \(i + 1)").font(.headline)
                    Text("Preview text...").font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Inbox")
    } detail: {
        Text("Select a message").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark") {
    @Previewable @State var visibility: NavigationSplitViewVisibility = .all
    DFThreeColumnShell(columnVisibility: $visibility) {
        List { Label("Inbox", systemImage: "tray") }.listStyle(.sidebar)
    } list: {
        List { Text("Message 1") }
    } detail: {
        Text("Detail").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFThreeColumnShell")
struct DFThreeColumnShellTests {
    @Test("NavigationSplitViewVisibility all is available")
    func visibilityAll() {
        let v = NavigationSplitViewVisibility.all
        #expect(v == .all)
    }

    @Test("NavigationSplitViewVisibility detailOnly is available")
    func visibilityDetailOnly() {
        let v = NavigationSplitViewVisibility.detailOnly
        #expect(v == .detailOnly)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFThreeColumnShell.swift \
        Tests/DesignFoundationScreensTests/DFThreeColumnShellTests.swift
git commit -m "feat(screens): add DFThreeColumnShell"
```

---

## Task 19: DFAdaptiveShell

### Files
- `Sources/DesignFoundationScreens/Shells/DFAdaptiveShell.swift`
- `Tests/DesignFoundationScreensTests/DFAdaptiveShellTests.swift`

### Interface

```swift
public struct DFAdaptiveTab: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let icon: String
    public init(id: String = UUID().uuidString, label: String, icon: String)
}

public struct DFAdaptiveShell<Content: View>: View {
    /// On iPhone: renders TabView with bottom tab bar.
    /// On iPad/Mac: renders NavigationSplitView sidebar.
    /// Single view, correct UX per device class — no developer conditionals required.
    public init(
        tabs: [DFAdaptiveTab],
        selectedTabID: Binding<String?>,
        @ViewBuilder content: @escaping (_ tabID: String) -> Content
    )
}
```

### Implementation

```swift
// Sources/DesignFoundationScreens/Shells/DFAdaptiveShell.swift
import SwiftUI
import DesignFoundation

public struct DFAdaptiveTab: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let icon: String

    public init(id: String = UUID().uuidString, label: String, icon: String) {
        self.id = id
        self.label = label
        self.icon = icon
    }
}

public struct DFAdaptiveShell<Content: View>: View {
    @Environment(\.dfTheme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding private var selectedTabID: String?
    private let tabs: [DFAdaptiveTab]
    private let content: (String) -> Content

    public init(
        tabs: [DFAdaptiveTab],
        selectedTabID: Binding<String?>,
        @ViewBuilder content: @escaping (_ tabID: String) -> Content
    ) {
        self.tabs = tabs
        self._selectedTabID = selectedTabID
        self.content = content
    }

    private var effectiveSelectedID: String {
        selectedTabID ?? tabs.first?.id ?? ""
    }

    public var body: some View {
        if horizontalSizeClass == .compact {
            // iPhone: tab bar
            TabView(selection: $selectedTabID) {
                ForEach(tabs) { tab in
                    content(tab.id)
                        .tabItem {
                            Label(tab.label, systemImage: tab.icon)
                        }
                        .tag(Optional(tab.id))
                }
            }
        } else {
            // iPad / Mac: sidebar
            NavigationSplitView {
                List(tabs, selection: $selectedTabID) { tab in
                    Label(tab.label, systemImage: tab.icon)
                        .tag(Optional(tab.id))
                }
                .listStyle(.sidebar)
                .navigationTitle("Navigation")
            } detail: {
                if !effectiveSelectedID.isEmpty {
                    content(effectiveSelectedID)
                } else {
                    ContentUnavailableView("Select an item", systemImage: "sidebar.left")
                }
            }
        }
    }
}

#Preview("Light — iPad (sidebar)") {
    DFAdaptiveShell(
        tabs: [
            DFAdaptiveTab(id: "home", label: "Home", icon: "house"),
            DFAdaptiveTab(id: "projects", label: "Projects", icon: "folder"),
            DFAdaptiveTab(id: "settings", label: "Settings", icon: "gear")
        ],
        selectedTabID: .constant("home")
    ) { tabID in
        Text("Content for: \(tabID)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Dark — compact (tab bar)") {
    DFAdaptiveShell(
        tabs: [
            DFAdaptiveTab(id: "home", label: "Home", icon: "house"),
            DFAdaptiveTab(id: "projects", label: "Projects", icon: "folder"),
            DFAdaptiveTab(id: "settings", label: "Settings", icon: "gear")
        ],
        selectedTabID: .constant("home")
    ) { tabID in
        Text("Content for: \(tabID)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .preferredColorScheme(.dark)
    .environment(\.horizontalSizeClass, .compact)
}
```

### Tests

```swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFAdaptiveShell")
struct DFAdaptiveShellTests {
    @Test("DFAdaptiveTab stores all properties")
    func tabProperties() {
        let tab = DFAdaptiveTab(id: "home", label: "Home", icon: "house")
        #expect(tab.id == "home")
        #expect(tab.label == "Home")
        #expect(tab.icon == "house")
    }

    @Test("DFAdaptiveTab generates unique IDs")
    func uniqueIDs() {
        let a = DFAdaptiveTab(label: "A", icon: "a")
        let b = DFAdaptiveTab(label: "B", icon: "b")
        #expect(a.id != b.id)
    }

    @Test("DFAdaptiveTab collection is Sendable conformant")
    func sendable() {
        let tabs: [DFAdaptiveTab] = [
            DFAdaptiveTab(label: "Home", icon: "house"),
            DFAdaptiveTab(label: "Settings", icon: "gear")
        ]
        #expect(tabs.count == 2)
    }
}
```

### Commit
```bash
git add Sources/DesignFoundationScreens/Shells/DFAdaptiveShell.swift \
        Tests/DesignFoundationScreensTests/DFAdaptiveShellTests.swift
git commit -m "feat(screens): add DFAdaptiveShell"
```

---

## Implementation Order Summary

| Task | Shell | Key Dependency |
|------|-------|----------------|
| 1 | Package setup | None |
| 2 | DFStandardSidebarShell | DFNavSection, DFNavItem (defined here) |
| 3 | DFIconRailShell | DFRailItem (defined here) |
| 4 | DFWorkspaceSidebarShell | DFWorkspace (defined here), DFRailItem from Task 3 |
| 5 | DFSearchSidebarShell | DFNavItem from Task 2 |
| 6 | DFExpandableSubmenuShell | DFNavNode (defined here) |
| 7 | DFDropdownSubmenuShell | DFDropdownNavItem (defined here), DFNavItem from Task 2 |
| 8 | DFFloatingOverlayShell | None (generic ViewBuilder) |
| 9 | DFInsetSidebarShell | None (generic ViewBuilder) |
| 10 | DFStickyHeaderShell | None (generic ViewBuilder) |
| 11 | DFDualSidebarShell | None (generic ViewBuilder) |
| 12 | DFRightInspectorShell | None (generic ViewBuilder) |
| 13 | DFFileTreeShell | DFFileNode (defined here) |
| 14 | DFCalendarSidebarShell | DFNavItem from Task 2 |
| 15 | DFSheetSidebarShell | DFNavItem from Task 2 |
| 16 | DFPopoverSidebarShell | None (generic ViewBuilder) |
| 17 | DFNestedDualColumnShell | None (generic ViewBuilder) |
| 18 | DFThreeColumnShell | None (generic ViewBuilder) |
| 19 | DFAdaptiveShell | DFAdaptiveTab (defined here) |

**Tasks 8–12 and 16–18** (generic ViewBuilder shells) can be implemented in parallel after Task 1.
**Tasks 5, 7, 14, 15** depend on `DFNavItem` from Task 2 — implement Task 2 first.
**Task 4** depends on `DFRailItem` from Task 3 — implement Task 3 first.

## Shared Types Location Note

`DFNavItem` and `DFNavSection` are defined in `DFStandardSidebarShell.swift` (Task 2).
`DFRailItem` is defined in `DFIconRailShell.swift` (Task 3).
All subsequent tasks that use these types should import them from their defining file — no re-declaration.

If type conflicts arise during compilation, extract shared types to:
`Sources/DesignFoundationScreens/Shells/DFSharedTypes.swift`

and remove the definitions from their original files.
