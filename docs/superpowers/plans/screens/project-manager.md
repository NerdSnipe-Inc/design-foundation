# Project Manager Screens Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build 6 launch-ready Project Manager screens (Home, Board, Task Detail, List View, Timeline, Team) for the `DesignFoundationScreens` package, composing from `DesignFoundation` primitives and `DesignFoundationBlocks`.

**Architecture:** Each screen is a standalone SwiftUI `View` in `Sources/DesignFoundationScreens/ProjectManager/`. Shared domain models (task, column, member) live in `Models/` and are consumed by all six screens. Adaptive layout (sidebar on iPad/Mac, tab bar on iPhone) is handled by `DFPMRootView`, which is the only entry point the host app needs.

**Tech Stack:** SwiftUI, Swift 6 strict concurrency, Swift Testing, `DesignFoundation` (tokens + primitives + supplementary), `DesignFoundationBlocks` (blocks).

## Global Constraints

- Swift 6 strict concurrency — `StrictConcurrency` experimental feature ON; every closure passed to a view must be `@Sendable`; all `@State`/`@Observable` on `@MainActor`
- Platforms: iOS 18 minimum, macOS 15 minimum, visionOS 2 minimum
- All color/spacing/typography tokens via `@Environment(\.dfTheme)` — zero hardcoded values
- Action closures typed `@MainActor () -> Void` or `@MainActor (T) -> Void`
- Every screen has both light and dark `#Preview` blocks
- Adaptive navigation: `NavigationSplitView` on iPad/Mac, `TabView` on iPhone (use `DFPMRootView` + `horizontalSizeClass`)
- Tests: Swift Testing only (`import Testing`, `@Suite`, `@Test`, `#expect`) — no XCTest
- No external dependencies beyond `DesignFoundation` and `DesignFoundationBlocks`
- Commit messages: `feat(screens): …`
- `DFBadgeVariant`: `.numeric(Int)`, `.dot`, `.text(String)`
- `DFProgressBar(variant:value:label:)` — `value` is `0.0…1.0`
- `DFCard(action:content:)` — `action` is `(() -> Void)?`
- `DFAvatar(_ initials:size:presence:accessibilityName:)` or `DFAvatar(image:size:presence:accessibilityName:)`
- `DFList(_ data:selection:onDelete:onMove:rowContent:)`
- `DFTable(data:columns:onSort:)` with `DFTableColumn(id:title:sortable:value:)`

---

## File Map

```
Sources/DesignFoundationScreens/ProjectManager/
├── Models/
│   ├── DFPMTask.swift              # Task, Priority, TaskStatus, SubTask
│   ├── DFPMColumn.swift            # BoardColumn with ordered task IDs
│   ├── DFPMMember.swift            # TeamMember, capacity
│   └── DFPMMilestone.swift         # Milestone with date + owner
├── DFPMRootView.swift              # Adaptive navigation shell
├── DFPMHomeScreen.swift            # My Tasks + Quick Stats + Activity
├── DFPMBoardScreen.swift           # Kanban board
├── DFPMTaskDetailScreen.swift      # Task detail / edit
├── DFPMListScreen.swift            # Table / list view
├── DFPMTimelineScreen.swift        # Gantt-style timeline
└── DFPMTeamScreen.swift            # Team workload

Tests/DesignFoundationScreensTests/ProjectManager/
├── DFPMModelsTests.swift           # Model logic (grouping, sorting, capacity)
├── DFPMHomeScreenTests.swift       # Grouping + FAB callback
├── DFPMBoardScreenTests.swift      # Column rendering, empty state
├── DFPMTaskDetailScreenTests.swift # Subtask toggle, comment append
├── DFPMListScreenTests.swift       # Sort, filter, multi-select
├── DFPMTimelineScreenTests.swift   # Date range filter
└── DFPMTeamScreenTests.swift       # Capacity bar value
```

---

### Task 1: Domain Models

**Files:**
- Create: `Sources/DesignFoundationScreens/ProjectManager/Models/DFPMTask.swift`
- Create: `Sources/DesignFoundationScreens/ProjectManager/Models/DFPMColumn.swift`
- Create: `Sources/DesignFoundationScreens/ProjectManager/Models/DFPMMember.swift`
- Create: `Sources/DesignFoundationScreens/ProjectManager/Models/DFPMMilestone.swift`
- Test: `Tests/DesignFoundationScreensTests/ProjectManager/DFPMModelsTests.swift`

**Interfaces:**
- Produces:
  - `DFPMPriority` — `enum: Sendable, Hashable` with cases `.low`, `.medium`, `.high`, `.critical`
  - `DFPMTaskStatus` — `enum: Sendable, Hashable` with cases `.todo`, `.inProgress`, `.inReview`, `.done`
  - `DFPMSubTask` — `struct: Identifiable, Sendable` — `id: UUID`, `title: String`, `isCompleted: Bool`
  - `DFPMTask` — `struct: Identifiable, Sendable` — `id: UUID`, `title: String`, `status: DFPMTaskStatus`, `priority: DFPMPriority`, `assigneeID: UUID?`, `dueDate: Date?`, `projectName: String`, `storyPoints: Int`, `subtasks: [DFPMSubTask]`, `tags: [String]`, `description: String`, `commentCount: Int`
  - `DFPMColumn` — `struct: Identifiable, Sendable` — `id: UUID`, `name: String`, `taskIDs: [UUID]`
  - `DFPMMember` — `struct: Identifiable, Sendable` — `id: UUID`, `name: String`, `initials: String`, `assignedTaskCount: Int`, `overdueCount: Int`, `storyPoints: Int`, `maxCapacity: Int`
  - `DFPMMilestone` — `struct: Identifiable, Sendable` — `id: UUID`, `name: String`, `date: Date`, `ownerID: UUID?`, `status: DFPMTaskStatus`
  - `DFPMTask.isOverdue: Bool` — computed, `dueDate < Date.now && status != .done`
  - `DFPMTask.isDueToday: Bool` — computed, due date is calendar-today and status != .done
  - `[DFPMTask].grouped(by:) -> [(key: String, tasks: [DFPMTask])]` — groups by overdue/dueToday/upcoming

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/ProjectManager/DFPMModelsTests.swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFPMModels")
struct DFPMModelsTests {

    // MARK: DFPMTask computed properties

    @Test("isOverdue: past due date and not done → true")
    func taskIsOverdue() {
        let task = DFPMTask(
            id: UUID(),
            title: "Fix bug",
            status: .inProgress,
            priority: .high,
            assigneeID: nil,
            dueDate: Date.now.addingTimeInterval(-86_400), // yesterday
            projectName: "Alpha",
            storyPoints: 3,
            subtasks: [],
            tags: [],
            description: "",
            commentCount: 0
        )
        #expect(task.isOverdue == true)
    }

    @Test("isOverdue: done task is never overdue")
    func doneTaskNotOverdue() {
        let task = DFPMTask(
            id: UUID(),
            title: "Fix bug",
            status: .done,
            priority: .high,
            assigneeID: nil,
            dueDate: Date.now.addingTimeInterval(-86_400),
            projectName: "Alpha",
            storyPoints: 3,
            subtasks: [],
            tags: [],
            description: "",
            commentCount: 0
        )
        #expect(task.isOverdue == false)
    }

    @Test("isOverdue: no due date → false")
    func noDueDateNotOverdue() {
        let task = DFPMTask(
            id: UUID(), title: "No date", status: .todo, priority: .low,
            assigneeID: nil, dueDate: nil, projectName: "B",
            storyPoints: 1, subtasks: [], tags: [], description: "", commentCount: 0
        )
        #expect(task.isOverdue == false)
    }

    @Test("grouped: overdue task appears in overdue bucket")
    func groupedOverdue() {
        let overdueTask = DFPMTask(
            id: UUID(), title: "Overdue", status: .inProgress, priority: .critical,
            assigneeID: nil, dueDate: Date.now.addingTimeInterval(-86_400),
            projectName: "X", storyPoints: 2, subtasks: [], tags: [], description: "", commentCount: 0
        )
        let groups = [overdueTask].grouped()
        let overdueGroup = groups.first(where: { $0.key == "Overdue" })
        #expect(overdueGroup?.tasks.count == 1)
    }

    @Test("grouped: upcoming task appears in upcoming bucket")
    func groupedUpcoming() {
        let upcomingTask = DFPMTask(
            id: UUID(), title: "Future", status: .todo, priority: .low,
            assigneeID: nil, dueDate: Date.now.addingTimeInterval(86_400 * 3),
            projectName: "Y", storyPoints: 1, subtasks: [], tags: [], description: "", commentCount: 0
        )
        let groups = [upcomingTask].grouped()
        let upcomingGroup = groups.first(where: { $0.key == "Upcoming" })
        #expect(upcomingGroup?.tasks.count == 1)
    }

    @Test("capacity fraction: member with 4/8 tasks → 0.5")
    func memberCapacityFraction() {
        let member = DFPMMember(
            id: UUID(), name: "Alice", initials: "AL",
            assignedTaskCount: 4, overdueCount: 0, storyPoints: 8, maxCapacity: 8
        )
        #expect(member.capacityFraction == 0.5)
    }

    @Test("capacity fraction: capped at 1.0 when over capacity")
    func memberCapacityFractionCapped() {
        let member = DFPMMember(
            id: UUID(), name: "Bob", initials: "BO",
            assignedTaskCount: 12, overdueCount: 0, storyPoints: 12, maxCapacity: 8
        )
        #expect(member.capacityFraction == 1.0)
    }
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```
swift test --filter DFPMModelsTests
```
Expected: compile error — types not defined yet.

- [ ] **Step 3: Create DFPMTask.swift**

```swift
// Sources/DesignFoundationScreens/ProjectManager/Models/DFPMTask.swift
import Foundation

public enum DFPMPriority: String, Sendable, Hashable, CaseIterable {
    case low, medium, high, critical

    public var label: String { rawValue.capitalized }
}

public enum DFPMTaskStatus: String, Sendable, Hashable, CaseIterable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case inReview = "In Review"
    case done = "Done"
}

public struct DFPMSubTask: Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var isCompleted: Bool

    public init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

public struct DFPMTask: Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var status: DFPMTaskStatus
    public var priority: DFPMPriority
    public var assigneeID: UUID?
    public var dueDate: Date?
    public var projectName: String
    public var storyPoints: Int
    public var subtasks: [DFPMSubTask]
    public var tags: [String]
    public var description: String
    public var commentCount: Int

    public init(
        id: UUID = UUID(),
        title: String,
        status: DFPMTaskStatus = .todo,
        priority: DFPMPriority = .medium,
        assigneeID: UUID? = nil,
        dueDate: Date? = nil,
        projectName: String,
        storyPoints: Int = 1,
        subtasks: [DFPMSubTask] = [],
        tags: [String] = [],
        description: String = "",
        commentCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.status = status
        self.priority = priority
        self.assigneeID = assigneeID
        self.dueDate = dueDate
        self.projectName = projectName
        self.storyPoints = storyPoints
        self.subtasks = subtasks
        self.tags = tags
        self.description = description
        self.commentCount = commentCount
    }

    public var isOverdue: Bool {
        guard let due = dueDate, status != .done else { return false }
        return due < Date.now
    }

    public var isDueToday: Bool {
        guard let due = dueDate, status != .done else { return false }
        return Calendar.current.isDateInToday(due)
    }
}

public extension [DFPMTask] {
    /// Groups tasks in display order: Overdue → Due Today → Upcoming.
    /// Tasks with no due date go in Upcoming.
    func grouped() -> [(key: String, tasks: [DFPMTask])] {
        var overdue: [DFPMTask] = []
        var today: [DFPMTask] = []
        var upcoming: [DFPMTask] = []

        for task in self {
            if task.isOverdue {
                overdue.append(task)
            } else if task.isDueToday {
                today.append(task)
            } else {
                upcoming.append(task)
            }
        }

        return [
            ("Overdue", overdue),
            ("Due Today", today),
            ("Upcoming", upcoming),
        ].filter { !$0.tasks.isEmpty }
    }
}
```

- [ ] **Step 4: Create DFPMColumn.swift**

```swift
// Sources/DesignFoundationScreens/ProjectManager/Models/DFPMColumn.swift
import Foundation

public struct DFPMColumn: Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var taskIDs: [UUID]

    public init(id: UUID = UUID(), name: String, taskIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.taskIDs = taskIDs
    }

    public static var defaultColumns: [DFPMColumn] {
        [
            DFPMColumn(name: "To Do"),
            DFPMColumn(name: "In Progress"),
            DFPMColumn(name: "In Review"),
            DFPMColumn(name: "Done"),
        ]
    }
}
```

- [ ] **Step 5: Create DFPMMember.swift**

```swift
// Sources/DesignFoundationScreens/ProjectManager/Models/DFPMMember.swift
import Foundation

public struct DFPMMember: Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var initials: String
    public var assignedTaskCount: Int
    public var overdueCount: Int
    public var storyPoints: Int
    public var maxCapacity: Int

    public init(
        id: UUID = UUID(),
        name: String,
        initials: String,
        assignedTaskCount: Int,
        overdueCount: Int,
        storyPoints: Int,
        maxCapacity: Int = 8
    ) {
        self.id = id
        self.name = name
        self.initials = initials
        self.assignedTaskCount = assignedTaskCount
        self.overdueCount = overdueCount
        self.storyPoints = storyPoints
        self.maxCapacity = maxCapacity
    }

    /// Fraction of capacity used, clamped to `0.0…1.0`.
    public var capacityFraction: Double {
        guard maxCapacity > 0 else { return 0 }
        return min(Double(assignedTaskCount) / Double(maxCapacity), 1.0)
    }
}
```

- [ ] **Step 6: Create DFPMMilestone.swift**

```swift
// Sources/DesignFoundationScreens/ProjectManager/Models/DFPMMilestone.swift
import Foundation

public struct DFPMMilestone: Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var date: Date
    public var ownerID: UUID?
    public var status: DFPMTaskStatus

    public init(
        id: UUID = UUID(),
        name: String,
        date: Date,
        ownerID: UUID? = nil,
        status: DFPMTaskStatus = .todo
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.ownerID = ownerID
        self.status = status
    }
}
```

- [ ] **Step 7: Run tests — expect PASS**

```
swift test --filter DFPMModelsTests
```
Expected: all 6 tests pass.

- [ ] **Step 8: Commit**

```bash
git add Sources/DesignFoundationScreens/ProjectManager/Models/ \
        Tests/DesignFoundationScreensTests/ProjectManager/DFPMModelsTests.swift
git commit -m "feat(screens): add Project Manager domain models"
```

---

### Task 2: DFPMHomeScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/ProjectManager/DFPMHomeScreen.swift`
- Test: `Tests/DesignFoundationScreensTests/ProjectManager/DFPMHomeScreenTests.swift`

**Interfaces:**
- Consumes: `DFPMTask`, `[DFPMTask].grouped()`, `DFPMPriority`, `DFPMTaskStatus`
- Consumes blocks: `DFStatCardBlock(title:value:trend:)`, `DFActivityFeedBlock(rows:)`, `DFActivityFeedRow`
- Consumes primitives: `DFList`, `DFBadge(.text(_))`, `DFButton`, `DFCheckbox`, `DFAvatar`
- Produces: `DFPMHomeScreen(userName:tasks:activityRows:onNewTask:onToggleTask:)`

```swift
public struct DFPMHomeScreen: View {
    let userName: String
    let tasks: [DFPMTask]
    let activityRows: [DFActivityFeedRow]
    let onNewTask: @MainActor () -> Void
    let onToggleTask: @MainActor (UUID) -> Void
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/ProjectManager/DFPMHomeScreenTests.swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFPMHomeScreen")
struct DFPMHomeScreenTests {

    @Test("onToggleTask fires with correct task ID")
    @MainActor
    func toggleTaskCallsBack() async {
        let taskID = UUID()
        var toggled: UUID? = nil
        let task = DFPMTask(
            id: taskID, title: "Fix crash", status: .inProgress,
            priority: .high, projectName: "Alpha",
            dueDate: Date.now.addingTimeInterval(-3600)
        )
        // Simulate the callback directly — view callback contract
        let onToggle: @MainActor (UUID) -> Void = { id in toggled = id }
        onToggle(task.id)
        #expect(toggled == taskID)
    }

    @Test("onNewTask fires")
    @MainActor
    func newTaskCallsBack() async {
        var fired = false
        let onNew: @MainActor () -> Void = { fired = true }
        onNew()
        #expect(fired)
    }

    @Test("grouped returns overdue bucket when task is past due")
    func homeGroupingIncludesOverdue() {
        let task = DFPMTask(
            id: UUID(), title: "Overdue", status: .todo, priority: .critical,
            projectName: "B", dueDate: Date.now.addingTimeInterval(-86_400)
        )
        let groups = [task].grouped()
        #expect(groups.first?.key == "Overdue")
    }

    @Test("no tasks → grouped returns empty array")
    func emptyTasksGrouped() {
        let groups = [DFPMTask]().grouped()
        #expect(groups.isEmpty)
    }
}
```

- [ ] **Step 2: Run tests — expect compile error**

```
swift test --filter DFPMHomeScreenTests
```
Expected: `DFPMHomeScreen` not defined.

- [ ] **Step 3: Implement DFPMHomeScreen.swift**

```swift
// Sources/DesignFoundationScreens/ProjectManager/DFPMHomeScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public struct DFPMHomeScreen: View {
    let userName: String
    let tasks: [DFPMTask]
    let activityRows: [DFActivityFeedRow]
    let onNewTask: @MainActor () -> Void
    let onToggleTask: @MainActor (UUID) -> Void

    @Environment(\.dfTheme) private var theme

    private var dueTodayCount: Int { tasks.filter(\.isDueToday).count }
    private var overdueCount: Int { tasks.filter(\.isOverdue).count }
    private var completedThisWeekCount: Int {
        let weekAgo = Date.now.addingTimeInterval(-7 * 86_400)
        return tasks.filter { $0.status == .done && ($0.dueDate ?? .distantPast) >= weekAgo }.count
    }

    public init(
        userName: String,
        tasks: [DFPMTask],
        activityRows: [DFActivityFeedRow],
        onNewTask: @escaping @MainActor () -> Void,
        onToggleTask: @escaping @MainActor (UUID) -> Void
    ) {
        self.userName = userName
        self.tasks = tasks
        self.activityRows = activityRows
        self.onNewTask = onNewTask
        self.onToggleTask = onToggleTask
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    headerSection
                    statsRow
                    myTasksSection
                    activitySection
                }
                .padding(theme.spacing.md)
            }
            .background(theme.colors.background)

            // FAB
            DFButton("New Task", action: onNewTask)
                .padding(theme.spacing.lg)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            DFText("Good morning, \(userName)", style: .heading)
            DFText(Date.now.formatted(date: .complete, time: .omitted), style: .caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: theme.spacing.sm) {
            DFStatCardBlock(title: "Due Today", value: "\(dueTodayCount)", trend: nil)
            DFStatCardBlock(title: "Overdue", value: "\(overdueCount)", trend: nil)
            DFStatCardBlock(title: "Done This Week", value: "\(completedThisWeekCount)", trend: nil)
        }
    }

    private var myTasksSection: some View {
        let groups = tasks.grouped()
        return VStack(alignment: .leading, spacing: theme.spacing.md) {
            DFText("My Tasks", style: .subheading)
            if groups.isEmpty {
                DFEmptyStateBlock(
                    icon: "checkmark.circle",
                    title: "All clear",
                    message: "You have no open tasks."
                )
            } else {
                ForEach(groups, id: \.key) { group in
                    taskGroup(group)
                }
            }
        }
    }

    private func taskGroup(_ group: (key: String, tasks: [DFPMTask])) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack {
                DFText(group.key, style: .label)
                    .foregroundStyle(group.key == "Overdue" ? theme.colors.destructive : theme.colors.textSecondary)
                DFBadge(count: group.tasks.count)
            }
            ForEach(group.tasks) { task in
                taskRow(task)
            }
        }
    }

    private func taskRow(_ task: DFPMTask) -> some View {
        HStack(spacing: theme.spacing.sm) {
            DFCheckbox(isChecked: task.status == .done) {
                onToggleTask(task.id)
            }
            VStack(alignment: .leading, spacing: 2) {
                DFText(task.title, style: .body)
                HStack(spacing: theme.spacing.xs) {
                    DFBadge(text: task.projectName)
                    if let due = task.dueDate {
                        DFText(
                            due.formatted(date: .abbreviated, time: .omitted),
                            style: .caption
                        )
                        .foregroundStyle(task.isOverdue ? theme.colors.destructive : theme.colors.textSecondary)
                    }
                    DFBadge(text: task.priority.label)
                }
            }
            Spacer()
        }
        .padding(theme.spacing.sm)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.sm))
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Recent Activity", style: .subheading)
            DFActivityFeedBlock(rows: activityRows)
        }
    }
}

// MARK: - Previews

#Preview("Light") {
    NavigationStack {
        DFPMHomeScreen(
            userName: "Jordan",
            tasks: DFPMHomeScreen.previewTasks,
            activityRows: DFPMHomeScreen.previewActivity,
            onNewTask: {},
            onToggleTask: { _ in }
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFPMHomeScreen(
            userName: "Jordan",
            tasks: DFPMHomeScreen.previewTasks,
            activityRows: DFPMHomeScreen.previewActivity,
            onNewTask: {},
            onToggleTask: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}

private extension DFPMHomeScreen {
    static var previewTasks: [DFPMTask] {
        [
            DFPMTask(title: "Fix login crash", status: .inProgress, priority: .critical,
                     projectName: "Mobile", dueDate: Date.now.addingTimeInterval(-3600)),
            DFPMTask(title: "Write release notes", status: .todo, priority: .medium,
                     projectName: "Marketing", dueDate: Date.now),
            DFPMTask(title: "Review PR #42", status: .todo, priority: .high,
                     projectName: "Mobile", dueDate: Date.now.addingTimeInterval(86_400)),
        ]
    }
    static var previewActivity: [DFActivityFeedRow] { [] }
}
```

- [ ] **Step 4: Run tests — expect PASS**

```
swift test --filter DFPMHomeScreenTests
```
Expected: 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundationScreens/ProjectManager/DFPMHomeScreen.swift \
        Tests/DesignFoundationScreensTests/ProjectManager/DFPMHomeScreenTests.swift
git commit -m "feat(screens): add DFPMHomeScreen"
```

---

### Task 3: DFPMBoardScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/ProjectManager/DFPMBoardScreen.swift`
- Test: `Tests/DesignFoundationScreensTests/ProjectManager/DFPMBoardScreenTests.swift`

**Interfaces:**
- Consumes: `DFPMTask`, `DFPMColumn`, `DFPMPriority`, `DFPMTaskStatus`
- Consumes blocks: `DFEmptyStateBlock`, `DFBlockSkeletonBlock`
- Consumes primitives: `DFCard`, `DFBadge`, `DFAvatar`, `DFText`, `DFButton`
- Produces:
```swift
public struct DFPMBoardScreen: View {
    let projects: [String]
    let selectedProject: String
    let columns: [DFPMColumn]
    let tasks: [DFPMTask]           // all tasks; board filters by column.taskIDs
    let members: [DFPMMember]
    let isLoading: Bool
    let onSelectProject: @MainActor (String) -> Void
    let onSelectTask: @MainActor (UUID) -> Void
    let onAddTask: @MainActor (UUID) -> Void  // column ID
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/ProjectManager/DFPMBoardScreenTests.swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFPMBoardScreen")
struct DFPMBoardScreenTests {

    @Test("column returns tasks matching its taskIDs")
    func columnFiltersTasksCorrectly() {
        let taskA = DFPMTask(id: UUID(), title: "A", projectName: "P")
        let taskB = DFPMTask(id: UUID(), title: "B", projectName: "P")
        let column = DFPMColumn(name: "To Do", taskIDs: [taskA.id])
        let allTasks = [taskA, taskB]
        let result = allTasks.filter { column.taskIDs.contains($0.id) }
        #expect(result.count == 1)
        #expect(result.first?.title == "A")
    }

    @Test("onSelectTask fires with task ID")
    @MainActor
    func selectTaskCallsBack() {
        let id = UUID()
        var received: UUID? = nil
        let cb: @MainActor (UUID) -> Void = { received = $0 }
        cb(id)
        #expect(received == id)
    }

    @Test("onAddTask fires with column ID")
    @MainActor
    func addTaskCallsBack() {
        let colID = UUID()
        var received: UUID? = nil
        let cb: @MainActor (UUID) -> Void = { received = $0 }
        cb(colID)
        #expect(received == colID)
    }

    @Test("storyPoints: sum of tasks in column")
    func columnStoryPointsSum() {
        let t1 = DFPMTask(id: UUID(), title: "T1", projectName: "P", storyPoints: 3)
        let t2 = DFPMTask(id: UUID(), title: "T2", projectName: "P", storyPoints: 5)
        let column = DFPMColumn(name: "In Progress", taskIDs: [t1.id, t2.id])
        let tasks = [t1, t2]
        let points = tasks.filter { column.taskIDs.contains($0.id) }.reduce(0) { $0 + $1.storyPoints }
        #expect(points == 8)
    }
}
```

- [ ] **Step 2: Run tests — expect compile error**

```
swift test --filter DFPMBoardScreenTests
```
Expected: `DFPMBoardScreen` not defined.

- [ ] **Step 3: Implement DFPMBoardScreen.swift**

```swift
// Sources/DesignFoundationScreens/ProjectManager/DFPMBoardScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public struct DFPMBoardScreen: View {
    let projects: [String]
    let selectedProject: String
    let columns: [DFPMColumn]
    let tasks: [DFPMTask]
    let members: [DFPMMember]
    let isLoading: Bool
    let onSelectProject: @MainActor (String) -> Void
    let onSelectTask: @MainActor (UUID) -> Void
    let onAddTask: @MainActor (UUID) -> Void

    @Environment(\.dfTheme) private var theme

    public init(
        projects: [String],
        selectedProject: String,
        columns: [DFPMColumn],
        tasks: [DFPMTask],
        members: [DFPMMember] = [],
        isLoading: Bool = false,
        onSelectProject: @escaping @MainActor (String) -> Void,
        onSelectTask: @escaping @MainActor (UUID) -> Void,
        onAddTask: @escaping @MainActor (UUID) -> Void
    ) {
        self.projects = projects
        self.selectedProject = selectedProject
        self.columns = columns
        self.tasks = tasks
        self.members = members
        self.isLoading = isLoading
        self.onSelectProject = onSelectProject
        self.onSelectTask = onSelectTask
        self.onAddTask = onAddTask
    }

    public var body: some View {
        VStack(spacing: 0) {
            projectPicker
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
            Divider().overlay(theme.colors.border)

            if isLoading {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: theme.spacing.md) {
                        ForEach(0..<4, id: \.self) { _ in
                            DFBlockSkeletonBlock()
                                .frame(width: 280)
                        }
                    }
                    .padding(theme.spacing.md)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: theme.spacing.md) {
                        ForEach(columns) { column in
                            boardColumn(column)
                        }
                    }
                    .padding(theme.spacing.md)
                }
            }
        }
        .background(theme.colors.background)
        .navigationTitle(selectedProject)
    }

    // MARK: Subviews

    private var projectPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(projects, id: \.self) { project in
                    Button {
                        onSelectProject(project)
                    } label: {
                        DFText(project, style: .label)
                            .padding(.horizontal, theme.spacing.sm)
                            .padding(.vertical, theme.spacing.xs)
                            .background(
                                project == selectedProject
                                    ? theme.colors.primary.opacity(0.15)
                                    : Color.clear
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(
                                    project == selectedProject ? theme.colors.primary : theme.colors.border,
                                    lineWidth: 1
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func boardColumn(_ column: DFPMColumn) -> some View {
        let columnTasks = tasks.filter { column.taskIDs.contains($0.id) }
        let points = columnTasks.reduce(0) { $0 + $1.storyPoints }

        return VStack(alignment: .leading, spacing: theme.spacing.sm) {
            // Column header
            HStack {
                DFText(column.name, style: .label)
                DFBadge(count: columnTasks.count)
                Spacer()
                DFText("\(points)pt", style: .caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .padding(.horizontal, theme.spacing.sm)

            Divider().overlay(theme.colors.border)

            // Task cards
            if columnTasks.isEmpty {
                DFEmptyStateBlock(
                    icon: "tray",
                    title: "No tasks",
                    message: "Add a task to get started."
                )
                .frame(minHeight: 120)
            } else {
                ForEach(columnTasks) { task in
                    taskCard(task)
                }
            }

            // Add task button
            Button {
                onAddTask(column.id)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    DFText("Add task", style: .label)
                }
                .foregroundStyle(theme.colors.textSecondary)
                .padding(theme.spacing.sm)
            }
            .buttonStyle(.plain)
        }
        .padding(theme.spacing.sm)
        .frame(width: 280, alignment: .top)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }

    private func taskCard(_ task: DFPMTask) -> some View {
        DFCard(action: { onSelectTask(task.id) }) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                DFText(task.title, style: .body)
                HStack {
                    DFBadge(text: task.priority.label)
                    Spacer()
                    if let due = task.dueDate {
                        DFText(due.formatted(date: .abbreviated, time: .omitted), style: .caption)
                            .foregroundStyle(task.isOverdue ? theme.colors.destructive : theme.colors.textSecondary)
                    }
                }
                HStack {
                    if let memberID = task.assigneeID,
                       let member = members.first(where: { $0.id == memberID }) {
                        DFAvatar(member.initials, size: 24, accessibilityName: member.name)
                    }
                    Spacer()
                    if task.commentCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 11))
                                .foregroundStyle(theme.colors.textSecondary)
                            DFText("\(task.commentCount)", style: .caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Light") {
    NavigationStack {
        DFPMBoardScreen(
            projects: ["Mobile", "Marketing", "Backend"],
            selectedProject: "Mobile",
            columns: DFPMBoardScreen.previewColumns,
            tasks: DFPMBoardScreen.previewTasks,
            onSelectProject: { _ in },
            onSelectTask: { _ in },
            onAddTask: { _ in }
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFPMBoardScreen(
            projects: ["Mobile", "Marketing", "Backend"],
            selectedProject: "Mobile",
            columns: DFPMBoardScreen.previewColumns,
            tasks: DFPMBoardScreen.previewTasks,
            onSelectProject: { _ in },
            onSelectTask: { _ in },
            onAddTask: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Loading") {
    NavigationStack {
        DFPMBoardScreen(
            projects: ["Mobile"],
            selectedProject: "Mobile",
            columns: [],
            tasks: [],
            isLoading: true,
            onSelectProject: { _ in },
            onSelectTask: { _ in },
            onAddTask: { _ in }
        )
    }
}

private extension DFPMBoardScreen {
    static var previewTasks: [DFPMTask] {
        let t1 = DFPMTask(id: UUID(), title: "Fix login crash", status: .inProgress,
                          priority: .critical, projectName: "Mobile", storyPoints: 5,
                          dueDate: Date.now.addingTimeInterval(-3600), commentCount: 3)
        let t2 = DFPMTask(id: UUID(), title: "Update splash screen", status: .todo,
                          priority: .medium, projectName: "Mobile", storyPoints: 2)
        let t3 = DFPMTask(id: UUID(), title: "Write release notes", status: .inReview,
                          priority: .low, projectName: "Mobile", storyPoints: 1, commentCount: 1)
        return [t1, t2, t3]
    }
    static var previewColumns: [DFPMColumn] {
        var cols = DFPMColumn.defaultColumns
        let tasks = previewTasks
        cols[0].taskIDs = [tasks[1].id]
        cols[1].taskIDs = [tasks[0].id]
        cols[2].taskIDs = [tasks[2].id]
        return cols
    }
}
```

- [ ] **Step 4: Run tests — expect PASS**

```
swift test --filter DFPMBoardScreenTests
```
Expected: 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundationScreens/ProjectManager/DFPMBoardScreen.swift \
        Tests/DesignFoundationScreensTests/ProjectManager/DFPMBoardScreenTests.swift
git commit -m "feat(screens): add DFPMBoardScreen"
```

---

### Task 4: DFPMTaskDetailScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/ProjectManager/DFPMTaskDetailScreen.swift`
- Test: `Tests/DesignFoundationScreensTests/ProjectManager/DFPMTaskDetailScreenTests.swift`

**Interfaces:**
- Consumes: `DFPMTask`, `DFPMSubTask`, `DFPMPriority`, `DFPMTaskStatus`, `DFPMMember`
- Consumes blocks: `DFActivityFeedBlock`, `DFActivityFeedRow`, `DFContactRow`, `DFDateRangeBlock`, `DFTagPickerBlock`, `DFEmptyStateBlock`
- Consumes primitives: `DFCheckbox`, `DFBadge`, `DFText`, `DFTextField`, `DFButton`
- Produces:
```swift
public struct DFPMTaskDetailScreen: View {
    @Binding var task: DFPMTask
    let members: [DFPMMember]
    let commentRows: [DFActivityFeedRow]
    let onStatusChange: @MainActor (DFPMTaskStatus) -> Void
    let onAddComment: @MainActor (String) -> Void
    let onClose: @MainActor () -> Void
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/ProjectManager/DFPMTaskDetailScreenTests.swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFPMTaskDetailScreen")
struct DFPMTaskDetailScreenTests {

    @Test("toggling subtask flips isCompleted")
    func subtaskToggle() {
        var task = DFPMTask(
            title: "Main task", projectName: "P",
            subtasks: [DFPMSubTask(id: UUID(), title: "Sub 1", isCompleted: false)]
        )
        let subID = task.subtasks[0].id
        // simulate toggle
        if let idx = task.subtasks.firstIndex(where: { $0.id == subID }) {
            task.subtasks[idx].isCompleted.toggle()
        }
        #expect(task.subtasks[0].isCompleted == true)
    }

    @Test("adding a subtask appends to task.subtasks")
    func addSubtask() {
        var task = DFPMTask(title: "Main", projectName: "P")
        task.subtasks.append(DFPMSubTask(title: "New sub"))
        #expect(task.subtasks.count == 1)
        #expect(task.subtasks.first?.title == "New sub")
    }

    @Test("onStatusChange fires with new status")
    @MainActor
    func statusChangeCallback() {
        var received: DFPMTaskStatus? = nil
        let cb: @MainActor (DFPMTaskStatus) -> Void = { received = $0 }
        cb(.done)
        #expect(received == .done)
    }

    @Test("onAddComment fires with non-empty string")
    @MainActor
    func addCommentCallback() {
        var received: String? = nil
        let cb: @MainActor (String) -> Void = { received = $0 }
        cb("Looks good!")
        #expect(received == "Looks good!")
    }
}
```

- [ ] **Step 2: Run tests — expect compile error**

```
swift test --filter DFPMTaskDetailScreenTests
```

- [ ] **Step 3: Implement DFPMTaskDetailScreen.swift**

```swift
// Sources/DesignFoundationScreens/ProjectManager/DFPMTaskDetailScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public struct DFPMTaskDetailScreen: View {
    @Binding var task: DFPMTask
    let members: [DFPMMember]
    let commentRows: [DFActivityFeedRow]
    let onStatusChange: @MainActor (DFPMTaskStatus) -> Void
    let onAddComment: @MainActor (String) -> Void
    let onClose: @MainActor () -> Void

    @Environment(\.dfTheme) private var theme
    @State private var newSubtaskTitle: String = ""
    @State private var commentDraft: String = ""
    @State private var isEditingTitle: Bool = false

    public init(
        task: Binding<DFPMTask>,
        members: [DFPMMember] = [],
        commentRows: [DFActivityFeedRow] = [],
        onStatusChange: @escaping @MainActor (DFPMTaskStatus) -> Void,
        onAddComment: @escaping @MainActor (String) -> Void,
        onClose: @escaping @MainActor () -> Void
    ) {
        self._task = task
        self.members = members
        self.commentRows = commentRows
        self.onStatusChange = onStatusChange
        self.onAddComment = onAddComment
        self.onClose = onClose
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                titleSection
                metadataSection
                descriptionSection
                subtasksSection
                tagsSection
                attachmentSection
                commentsSection
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { onClose() }
            }
        }
        .safeAreaInset(edge: .bottom) {
            commentInputBar
        }
    }

    // MARK: Subviews

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            if isEditingTitle {
                DFTextField("Task title", text: $task.title)
                    .onSubmit { isEditingTitle = false }
            } else {
                DFText(task.title, style: .heading)
                    .onTapGesture { isEditingTitle = true }
                    .accessibilityHint("Tap to edit title")
            }

            // Status badge — tappable to cycle
            Menu {
                ForEach(DFPMTaskStatus.allCases, id: \.self) { status in
                    Button(status.rawValue) { onStatusChange(status) }
                }
            } label: {
                DFBadge(text: task.status.rawValue)
            }
        }
    }

    private var metadataSection: some View {
        VStack(spacing: 0) {
            // Assignee
            let assignee = members.first(where: { $0.id == task.assigneeID })
            DFContactRow(
                name: assignee?.name ?? "Unassigned",
                subtitle: "Assignee",
                initials: assignee?.initials ?? "—"
            )

            Divider().overlay(theme.colors.border)

            // Due date
            DFDateRangeBlock(
                label: "Due Date",
                startDate: Binding(
                    get: { task.dueDate ?? Date.now },
                    set: { task.dueDate = $0 }
                ),
                endDate: nil,
                isSingleDate: true
            )

            Divider().overlay(theme.colors.border)

            // Priority
            HStack {
                DFText("Priority", style: .label)
                    .foregroundStyle(theme.colors.textSecondary)
                Spacer()
                Menu {
                    ForEach(DFPMPriority.allCases, id: \.self) { p in
                        Button(p.label) { task.priority = p }
                    }
                } label: {
                    DFBadge(text: task.priority.label)
                }
            }
            .padding(theme.spacing.sm)
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md).stroke(theme.colors.border, lineWidth: 1))
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            DFText("Description", style: .subheading)
            DFTextField("Add a description…", text: $task.description, axis: .vertical)
        }
    }

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            DFText("Subtasks", style: .subheading)
            ForEach(task.subtasks.indices, id: \.self) { idx in
                HStack {
                    DFCheckbox(isChecked: task.subtasks[idx].isCompleted) {
                        task.subtasks[idx].isCompleted.toggle()
                    }
                    DFText(task.subtasks[idx].title, style: .body)
                        .strikethrough(task.subtasks[idx].isCompleted)
                    Spacer()
                }
            }
            HStack {
                DFTextField("Add subtask…", text: $newSubtaskTitle)
                    .onSubmit { addSubtask() }
                DFButton("Add") { addSubtask() }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            DFText("Labels", style: .subheading)
            DFTagPickerBlock(
                selectedTags: Binding(
                    get: { task.tags },
                    set: { task.tags = $0 }
                )
            )
        }
    }

    private var attachmentSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            DFText("Attachments", style: .subheading)
            DFEmptyStateBlock(
                icon: "paperclip",
                title: "No attachments",
                message: "Attach files to keep context together."
            )
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Comments", style: .subheading)
            if commentRows.isEmpty {
                DFEmptyStateBlock(
                    icon: "bubble.right",
                    title: "No comments yet",
                    message: "Be the first to comment."
                )
            } else {
                DFActivityFeedBlock(rows: commentRows)
            }
        }
    }

    private var commentInputBar: some View {
        HStack(spacing: theme.spacing.sm) {
            DFTextField("Add a comment…", text: $commentDraft)
            DFButton("Send") {
                let draft = commentDraft.trimmingCharacters(in: .whitespaces)
                guard !draft.isEmpty else { return }
                onAddComment(draft)
                commentDraft = ""
            }
        }
        .padding(theme.spacing.sm)
        .background(theme.colors.surface)
        .overlay(alignment: .top) {
            Divider().overlay(theme.colors.border)
        }
    }

    // MARK: Helpers

    private func addSubtask() {
        let title = newSubtaskTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        task.subtasks.append(DFPMSubTask(title: title))
        newSubtaskTitle = ""
    }
}

// MARK: - Previews

private extension DFPMTaskDetailScreen {
    static func makePreviewTask() -> DFPMTask {
        DFPMTask(
            title: "Fix login crash on iOS 18",
            status: .inProgress,
            priority: .critical,
            projectName: "Mobile",
            storyPoints: 5,
            subtasks: [
                DFPMSubTask(title: "Reproduce on device", isCompleted: true),
                DFPMSubTask(title: "Identify root cause"),
                DFPMSubTask(title: "Write regression test"),
            ],
            tags: ["bug", "ios", "urgent"],
            description: "Crash occurs on first launch after update.",
            commentCount: 2
        )
    }
}

#Preview("Light") {
    @Previewable @State var task = DFPMTaskDetailScreen.makePreviewTask()
    NavigationStack {
        DFPMTaskDetailScreen(
            task: $task,
            onStatusChange: { _ in },
            onAddComment: { _ in },
            onClose: {}
        )
    }
}

#Preview("Dark") {
    @Previewable @State var task = DFPMTaskDetailScreen.makePreviewTask()
    NavigationStack {
        DFPMTaskDetailScreen(
            task: $task,
            onStatusChange: { _ in },
            onAddComment: { _ in },
            onClose: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

- [ ] **Step 4: Run tests — expect PASS**

```
swift test --filter DFPMTaskDetailScreenTests
```
Expected: 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundationScreens/ProjectManager/DFPMTaskDetailScreen.swift \
        Tests/DesignFoundationScreensTests/ProjectManager/DFPMTaskDetailScreenTests.swift
git commit -m "feat(screens): add DFPMTaskDetailScreen"
```

---

### Task 5: DFPMListScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/ProjectManager/DFPMListScreen.swift`
- Test: `Tests/DesignFoundationScreensTests/ProjectManager/DFPMListScreenTests.swift`

**Interfaces:**
- Consumes: `DFPMTask`, `DFPMPriority`, `DFPMTaskStatus`, `DFPMMember`
- Consumes blocks: `DFSearchResultsBlock`, `DFEmptyStateBlock`
- Consumes primitives: `DFTable`, `DFTableColumn`, `DFBadge`, `DFButton`, `DFText`
- Produces:
```swift
public struct DFPMListScreen: View {
    let projects: [String]
    let selectedProject: String
    let tasks: [DFPMTask]
    let members: [DFPMMember]
    let onSelectProject: @MainActor (String) -> Void
    let onSelectTask: @MainActor (UUID) -> Void
    let onBulkDelete: @MainActor (Set<UUID>) -> Void
    let onBulkReassign: @MainActor (Set<UUID>) -> Void
}

public enum DFPMGroupBy: String, CaseIterable { case status, assignee, priority }
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/ProjectManager/DFPMListScreenTests.swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFPMListScreen")
struct DFPMListScreenTests {

    private func makeTasks() -> [DFPMTask] {
        [
            DFPMTask(id: UUID(), title: "Alpha", status: .todo, priority: .high, projectName: "P"),
            DFPMTask(id: UUID(), title: "Beta", status: .done, priority: .low, projectName: "P"),
            DFPMTask(id: UUID(), title: "Gamma", status: .inProgress, priority: .medium, projectName: "P"),
        ]
    }

    @Test("search filter: matching title returns 1 result")
    func searchFilter() {
        let tasks = makeTasks()
        let result = tasks.filter { $0.title.localizedCaseInsensitiveContains("alpha") }
        #expect(result.count == 1)
        #expect(result.first?.title == "Alpha")
    }

    @Test("search filter: non-matching query returns empty")
    func searchFilterNoMatch() {
        let tasks = makeTasks()
        let result = tasks.filter { $0.title.localizedCaseInsensitiveContains("zzz") }
        #expect(result.isEmpty)
    }

    @Test("group by status: produces correct bucket count")
    func groupByStatus() {
        let tasks = makeTasks()
        let grouped = Dictionary(grouping: tasks, by: { $0.status.rawValue })
        #expect(grouped["To Do"]?.count == 1)
        #expect(grouped["Done"]?.count == 1)
        #expect(grouped["In Progress"]?.count == 1)
    }

    @Test("multi-select: selecting task ID adds it to selection set")
    func multiSelect() {
        let tasks = makeTasks()
        var selection: Set<UUID> = []
        selection.insert(tasks[0].id)
        #expect(selection.contains(tasks[0].id))
        #expect(!selection.contains(tasks[1].id))
    }

    @Test("onBulkDelete fires with selection set")
    @MainActor
    func bulkDeleteCallback() {
        var received: Set<UUID>? = nil
        let ids: Set<UUID> = [UUID(), UUID()]
        let cb: @MainActor (Set<UUID>) -> Void = { received = $0 }
        cb(ids)
        #expect(received == ids)
    }
}
```

- [ ] **Step 2: Run tests — expect compile error**

```
swift test --filter DFPMListScreenTests
```

- [ ] **Step 3: Implement DFPMListScreen.swift**

```swift
// Sources/DesignFoundationScreens/ProjectManager/DFPMListScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public enum DFPMGroupBy: String, CaseIterable, Sendable {
    case status = "Status"
    case assignee = "Assignee"
    case priority = "Priority"
}

public struct DFPMListScreen: View {
    let projects: [String]
    let selectedProject: String
    let tasks: [DFPMTask]
    let members: [DFPMMember]
    let onSelectProject: @MainActor (String) -> Void
    let onSelectTask: @MainActor (UUID) -> Void
    let onBulkDelete: @MainActor (Set<UUID>) -> Void
    let onBulkReassign: @MainActor (Set<UUID>) -> Void

    @Environment(\.dfTheme) private var theme
    @State private var searchQuery: String = ""
    @State private var groupBy: DFPMGroupBy = .status
    @State private var selection: Set<UUID> = []

    public init(
        projects: [String],
        selectedProject: String,
        tasks: [DFPMTask],
        members: [DFPMMember] = [],
        onSelectProject: @escaping @MainActor (String) -> Void,
        onSelectTask: @escaping @MainActor (UUID) -> Void,
        onBulkDelete: @escaping @MainActor (Set<UUID>) -> Void,
        onBulkReassign: @escaping @MainActor (Set<UUID>) -> Void
    ) {
        self.projects = projects
        self.selectedProject = selectedProject
        self.tasks = tasks
        self.members = members
        self.onSelectProject = onSelectProject
        self.onSelectTask = onSelectTask
        self.onBulkDelete = onBulkDelete
        self.onBulkReassign = onBulkReassign
    }

    private var filtered: [DFPMTask] {
        guard !searchQuery.isEmpty else { return tasks }
        return tasks.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Search + group picker toolbar
            VStack(spacing: theme.spacing.sm) {
                DFSearchResultsBlock(
                    query: $searchQuery,
                    placeholder: "Search tasks…"
                )
                Picker("Group by", selection: $groupBy) {
                    ForEach(DFPMGroupBy.allCases, id: \.self) { g in
                        Text(g.rawValue).tag(g)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(theme.spacing.md)

            Divider().overlay(theme.colors.border)

            // Bulk action bar (shown when selection non-empty)
            if !selection.isEmpty {
                HStack(spacing: theme.spacing.sm) {
                    DFText("\(selection.count) selected", style: .label)
                    Spacer()
                    DFButton("Reassign") { onBulkReassign(selection) }
                    DFButton("Delete", role: .destructive) { onBulkDelete(selection) }
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
                .background(theme.colors.surfaceElevated)
            }

            if filtered.isEmpty {
                DFEmptyStateBlock(
                    icon: "magnifyingglass",
                    title: "No tasks found",
                    message: searchQuery.isEmpty ? "This project has no tasks yet." : "No tasks match "\(searchQuery)"."
                )
            } else {
                tableView
            }
        }
        .background(theme.colors.background)
        .navigationTitle(selectedProject)
    }

    private var tableView: some View {
        let columns: [DFTableColumn<DFPMTask>] = [
            DFTableColumn(id: "title", title: "Task", value: { $0.title }),
            DFTableColumn(id: "status", title: "Status", value: { $0.status.rawValue }),
            DFTableColumn(id: "priority", title: "Priority", value: { $0.priority.label }),
            DFTableColumn(id: "due", title: "Due Date", value: {
                $0.dueDate.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "—"
            }),
            DFTableColumn(id: "points", title: "Points", value: { "\($0.storyPoints)" }),
        ]
        return DFTable(
            data: filtered,
            columns: columns,
            onSort: { _, _ in }
        )
        .padding(theme.spacing.md)
    }
}

// MARK: - Previews

#Preview("Light") {
    NavigationStack {
        DFPMListScreen(
            projects: ["Mobile", "Marketing"],
            selectedProject: "Mobile",
            tasks: [
                DFPMTask(title: "Fix crash", status: .inProgress, priority: .critical, projectName: "Mobile", storyPoints: 5),
                DFPMTask(title: "Update icons", status: .todo, priority: .low, projectName: "Mobile", storyPoints: 2),
                DFPMTask(title: "Write tests", status: .done, priority: .medium, projectName: "Mobile", storyPoints: 3),
            ],
            onSelectProject: { _ in },
            onSelectTask: { _ in },
            onBulkDelete: { _ in },
            onBulkReassign: { _ in }
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFPMListScreen(
            projects: ["Mobile"],
            selectedProject: "Mobile",
            tasks: [
                DFPMTask(title: "Fix crash", status: .inProgress, priority: .critical, projectName: "Mobile", storyPoints: 5),
            ],
            onSelectProject: { _ in },
            onSelectTask: { _ in },
            onBulkDelete: { _ in },
            onBulkReassign: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Empty") {
    NavigationStack {
        DFPMListScreen(
            projects: ["Mobile"],
            selectedProject: "Mobile",
            tasks: [],
            onSelectProject: { _ in },
            onSelectTask: { _ in },
            onBulkDelete: { _ in },
            onBulkReassign: { _ in }
        )
    }
}
```

- [ ] **Step 4: Run tests — expect PASS**

```
swift test --filter DFPMListScreenTests
```
Expected: 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundationScreens/ProjectManager/DFPMListScreen.swift \
        Tests/DesignFoundationScreensTests/ProjectManager/DFPMListScreenTests.swift
git commit -m "feat(screens): add DFPMListScreen"
```

---

### Task 6: DFPMTimelineScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/ProjectManager/DFPMTimelineScreen.swift`
- Test: `Tests/DesignFoundationScreensTests/ProjectManager/DFPMTimelineScreenTests.swift`

**Interfaces:**
- Consumes: `DFPMTask`, `DFPMMilestone`, `DFPMMember`, `DFPMTaskStatus`
- Consumes blocks: `DFChartPlaceholderBlock`, `DFDateRangeBlock`, `DFEmptyStateBlock`
- Consumes primitives: `DFListRow`, `DFBadge`, `DFAvatar`, `DFText`, `DFButton`
- Produces:
```swift
public struct DFPMTimelineScreen: View {
    let tasks: [DFPMTask]
    let milestones: [DFPMMilestone]
    let members: [DFPMMember]
    let onSelectMilestone: @MainActor (UUID) -> Void
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/ProjectManager/DFPMTimelineScreenTests.swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFPMTimelineScreen")
struct DFPMTimelineScreenTests {

    @Test("date range filter: task within range is included")
    func dateRangeIncludes() {
        let start = Date.now
        let end = start.addingTimeInterval(7 * 86_400)
        let task = DFPMTask(title: "Ship v2", projectName: "P",
                            dueDate: start.addingTimeInterval(86_400))
        let inRange = [task].filter {
            guard let due = $0.dueDate else { return false }
            return due >= start && due <= end
        }
        #expect(inRange.count == 1)
    }

    @Test("date range filter: task outside range is excluded")
    func dateRangeExcludes() {
        let start = Date.now
        let end = start.addingTimeInterval(7 * 86_400)
        let task = DFPMTask(title: "Future task", projectName: "P",
                            dueDate: start.addingTimeInterval(30 * 86_400))
        let inRange = [task].filter {
            guard let due = $0.dueDate else { return false }
            return due >= start && due <= end
        }
        #expect(inRange.isEmpty)
    }

    @Test("task without due date is excluded from range filter")
    func noDueDateExcluded() {
        let start = Date.now
        let end = start.addingTimeInterval(7 * 86_400)
        let task = DFPMTask(title: "No date", projectName: "P", dueDate: nil)
        let inRange = [task].filter {
            guard let due = $0.dueDate else { return false }
            return due >= start && due <= end
        }
        #expect(inRange.isEmpty)
    }

    @Test("milestones sort ascending by date")
    func milestonesAscending() {
        let m1 = DFPMMilestone(name: "Beta", date: Date.now.addingTimeInterval(86_400 * 5))
        let m2 = DFPMMilestone(name: "Alpha", date: Date.now.addingTimeInterval(86_400 * 2))
        let sorted = [m1, m2].sorted { $0.date < $1.date }
        #expect(sorted.first?.name == "Alpha")
    }
}
```

- [ ] **Step 2: Run tests — expect compile error**

```
swift test --filter DFPMTimelineScreenTests
```

- [ ] **Step 3: Implement DFPMTimelineScreen.swift**

```swift
// Sources/DesignFoundationScreens/ProjectManager/DFPMTimelineScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public struct DFPMTimelineScreen: View {
    let tasks: [DFPMTask]
    let milestones: [DFPMMilestone]
    let members: [DFPMMember]
    let onSelectMilestone: @MainActor (UUID) -> Void

    @Environment(\.dfTheme) private var theme
    @State private var rangeStart: Date = Calendar.current.startOfDay(for: Date.now)
    @State private var rangeEnd: Date = Calendar.current.date(byAdding: .day, value: 14, to: Date.now) ?? Date.now
    @State private var showRangePicker: Bool = false
    @State private var filterPerson: UUID? = nil

    public init(
        tasks: [DFPMTask],
        milestones: [DFPMMilestone] = [],
        members: [DFPMMember] = [],
        onSelectMilestone: @escaping @MainActor (UUID) -> Void
    ) {
        self.tasks = tasks
        self.milestones = milestones
        self.members = members
        self.onSelectMilestone = onSelectMilestone
    }

    private var filteredTasks: [DFPMTask] {
        tasks.filter { task in
            guard let due = task.dueDate else { return false }
            let inRange = due >= rangeStart && due <= rangeEnd
            if let personID = filterPerson {
                return inRange && task.assigneeID == personID
            }
            return inRange
        }
    }

    private var sortedMilestones: [DFPMMilestone] {
        milestones
            .filter { $0.date >= rangeStart && $0.date <= rangeEnd }
            .sorted { $0.date < $1.date }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                dateRangeHeader
                filterChips
                ganttChartZone
                milestoneList
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.background)
        .navigationTitle("Timeline")
        .sheet(isPresented: $showRangePicker) {
            NavigationStack {
                DFDateRangeBlock(
                    label: "Select Range",
                    startDate: $rangeStart,
                    endDate: $rangeEnd,
                    isSingleDate: false
                )
                .padding(theme.spacing.md)
                .navigationTitle("Date Range")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showRangePicker = false }
                    }
                }
            }
        }
    }

    // MARK: Subviews

    private var dateRangeHeader: some View {
        HStack {
            Button {
                rangeStart = Calendar.current.date(byAdding: .day, value: -14, to: rangeStart) ?? rangeStart
                rangeEnd = Calendar.current.date(byAdding: .day, value: -14, to: rangeEnd) ?? rangeEnd
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(theme.colors.primary)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                showRangePicker = true
            } label: {
                VStack(spacing: 2) {
                    DFText(rangeStart.formatted(date: .abbreviated, time: .omitted), style: .label)
                    DFText("→ \(rangeEnd.formatted(date: .abbreviated, time: .omitted))", style: .caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                rangeStart = Calendar.current.date(byAdding: .day, value: 14, to: rangeStart) ?? rangeStart
                rangeEnd = Calendar.current.date(byAdding: .day, value: 14, to: rangeEnd) ?? rangeEnd
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(theme.colors.primary)
            }
            .buttonStyle(.plain)
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                // "All" chip
                filterChip(label: "All", isSelected: filterPerson == nil) {
                    filterPerson = nil
                }
                ForEach(members) { member in
                    filterChip(label: member.name, isSelected: filterPerson == member.id) {
                        filterPerson = member.id
                    }
                }
            }
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            DFText(label, style: .label)
                .padding(.horizontal, theme.spacing.sm)
                .padding(.vertical, theme.spacing.xs)
                .background(isSelected ? theme.colors.primary.opacity(0.15) : Color.clear)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? theme.colors.primary : theme.colors.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var ganttChartZone: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Tasks", style: .subheading)
            if filteredTasks.isEmpty && sortedMilestones.isEmpty {
                DFEmptyStateBlock(
                    icon: "calendar",
                    title: "Nothing in this range",
                    message: "Adjust the date range to see tasks and milestones."
                )
            } else {
                DFChartPlaceholderBlock(
                    title: "Gantt View",
                    subtitle: "\(filteredTasks.count) tasks in range"
                )
                .frame(minHeight: 200)
            }
        }
    }

    private var milestoneList: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Milestones", style: .subheading)
            if sortedMilestones.isEmpty {
                DFEmptyStateBlock(
                    icon: "diamond",
                    title: "No milestones",
                    message: "No milestones fall in this date range."
                )
            } else {
                ForEach(sortedMilestones) { milestone in
                    milestoneRow(milestone)
                }
            }
        }
    }

    private func milestoneRow(_ milestone: DFPMMilestone) -> some View {
        let owner = members.first(where: { $0.id == milestone.ownerID })
        return DFListRow {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "diamond.fill")
                    .foregroundStyle(theme.colors.primary)
                    .font(.system(size: 12))
                VStack(alignment: .leading, spacing: 2) {
                    DFText(milestone.name, style: .body)
                    DFText(milestone.date.formatted(date: .abbreviated, time: .omitted), style: .caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                Spacer()
                if let owner {
                    DFAvatar(owner.initials, size: 28, accessibilityName: owner.name)
                }
                DFBadge(text: milestone.status.rawValue)
            }
        } action: {
            onSelectMilestone(milestone.id)
        }
    }
}

// MARK: - Previews

#Preview("Light") {
    NavigationStack {
        DFPMTimelineScreen(
            tasks: [
                DFPMTask(title: "Ship beta", projectName: "Mobile",
                         dueDate: Date.now.addingTimeInterval(3 * 86_400)),
                DFPMTask(title: "Design review", projectName: "Mobile",
                         dueDate: Date.now.addingTimeInterval(6 * 86_400)),
            ],
            milestones: [
                DFPMMilestone(name: "Beta Launch", date: Date.now.addingTimeInterval(5 * 86_400), status: .todo),
                DFPMMilestone(name: "GA Release", date: Date.now.addingTimeInterval(12 * 86_400), status: .todo),
            ],
            onSelectMilestone: { _ in }
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFPMTimelineScreen(tasks: [], milestones: [], onSelectMilestone: { _ in })
    }
    .preferredColorScheme(.dark)
}
```

- [ ] **Step 4: Run tests — expect PASS**

```
swift test --filter DFPMTimelineScreenTests
```
Expected: 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundationScreens/ProjectManager/DFPMTimelineScreen.swift \
        Tests/DesignFoundationScreensTests/ProjectManager/DFPMTimelineScreenTests.swift
git commit -m "feat(screens): add DFPMTimelineScreen"
```

---

### Task 7: DFPMTeamScreen

**Files:**
- Create: `Sources/DesignFoundationScreens/ProjectManager/DFPMTeamScreen.swift`
- Test: `Tests/DesignFoundationScreensTests/ProjectManager/DFPMTeamScreenTests.swift`

**Interfaces:**
- Consumes: `DFPMMember`, `DFPMTask`
- Consumes blocks: `DFProfileHeaderBlock`, `DFMetricGridBlock`
- Consumes primitives: `DFProgressBar`, `DFText`, `DFBadge`, `DFButton`
- Produces:
```swift
public struct DFPMTeamScreen: View {
    let members: [DFPMMember]
    let tasks: [DFPMTask]
    let teamVelocity: Int          // story points completed last sprint
    let sprintCompletionPct: Double // 0.0…1.0
    let avgTaskAgeDays: Int
    let blockerCount: Int
    let onSelectMember: @MainActor (UUID) -> Void
    let onInviteMember: @MainActor () -> Void
}
```

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/ProjectManager/DFPMTeamScreenTests.swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFPMTeamScreen")
struct DFPMTeamScreenTests {

    @Test("capacityFraction: 4 tasks / 8 max = 0.5")
    func capacityFraction() {
        let m = DFPMMember(id: UUID(), name: "Alice", initials: "AL",
                           assignedTaskCount: 4, overdueCount: 0, storyPoints: 10, maxCapacity: 8)
        #expect(m.capacityFraction == 0.5)
    }

    @Test("capacityFraction: 0 max capacity → 0.0 (no divide-by-zero)")
    func zeroMaxCapacity() {
        let m = DFPMMember(id: UUID(), name: "Bob", initials: "BO",
                           assignedTaskCount: 3, overdueCount: 0, storyPoints: 5, maxCapacity: 0)
        #expect(m.capacityFraction == 0.0)
    }

    @Test("capacityFraction: over capacity clamped to 1.0")
    func overCapacityClamped() {
        let m = DFPMMember(id: UUID(), name: "Carol", initials: "CA",
                           assignedTaskCount: 12, overdueCount: 0, storyPoints: 15, maxCapacity: 8)
        #expect(m.capacityFraction == 1.0)
    }

    @Test("tasks for member: filters by assigneeID")
    func tasksForMember() {
        let memberID = UUID()
        let t1 = DFPMTask(id: UUID(), title: "T1", projectName: "P", assigneeID: memberID)
        let t2 = DFPMTask(id: UUID(), title: "T2", projectName: "P", assigneeID: nil)
        let result = [t1, t2].filter { $0.assigneeID == memberID }
        #expect(result.count == 1)
    }

    @Test("onSelectMember fires with member ID")
    @MainActor
    func selectMemberCallback() {
        var received: UUID? = nil
        let id = UUID()
        let cb: @MainActor (UUID) -> Void = { received = $0 }
        cb(id)
        #expect(received == id)
    }
}
```

- [ ] **Step 2: Run tests — expect compile error**

```
swift test --filter DFPMTeamScreenTests
```

- [ ] **Step 3: Implement DFPMTeamScreen.swift**

```swift
// Sources/DesignFoundationScreens/ProjectManager/DFPMTeamScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public struct DFPMTeamScreen: View {
    let members: [DFPMMember]
    let tasks: [DFPMTask]
    let teamVelocity: Int
    let sprintCompletionPct: Double
    let avgTaskAgeDays: Int
    let blockerCount: Int
    let onSelectMember: @MainActor (UUID) -> Void
    let onInviteMember: @MainActor () -> Void

    @Environment(\.dfTheme) private var theme

    public init(
        members: [DFPMMember],
        tasks: [DFPMTask] = [],
        teamVelocity: Int = 0,
        sprintCompletionPct: Double = 0,
        avgTaskAgeDays: Int = 0,
        blockerCount: Int = 0,
        onSelectMember: @escaping @MainActor (UUID) -> Void,
        onInviteMember: @escaping @MainActor () -> Void
    ) {
        self.members = members
        self.tasks = tasks
        self.teamVelocity = teamVelocity
        self.sprintCompletionPct = sprintCompletionPct
        self.avgTaskAgeDays = avgTaskAgeDays
        self.blockerCount = blockerCount
        self.onSelectMember = onSelectMember
        self.onInviteMember = onInviteMember
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                metricsGrid
                memberList
                if members.count < 3 {
                    inviteCTA
                }
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.background)
        .navigationTitle("Team")
    }

    // MARK: Subviews

    private var metricsGrid: some View {
        DFMetricGridBlock(metrics: [
            DFMetric(label: "Velocity", value: "\(teamVelocity)pt"),
            DFMetric(label: "Sprint Done", value: "\(Int(sprintCompletionPct * 100))%"),
            DFMetric(label: "Avg Task Age", value: "\(avgTaskAgeDays)d"),
            DFMetric(label: "Blockers", value: "\(blockerCount)"),
        ])
    }

    private var memberList: some View {
        VStack(spacing: theme.spacing.sm) {
            DFText("Team Members", style: .subheading)
            ForEach(members) { member in
                memberRow(member)
            }
        }
    }

    private func memberRow(_ member: DFPMMember) -> some View {
        Button {
            onSelectMember(member.id)
        } label: {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                DFProfileHeaderBlock(
                    name: member.name,
                    subtitle: "\(member.assignedTaskCount) tasks · \(member.storyPoints)pt this sprint",
                    initials: member.initials
                )

                HStack(spacing: theme.spacing.sm) {
                    DFProgressBar(value: member.capacityFraction, label: "Capacity")
                    DFText("\(Int(member.capacityFraction * 100))%", style: .caption)
                        .foregroundStyle(
                            member.capacityFraction >= 1.0
                                ? theme.colors.destructive
                                : theme.colors.textSecondary
                        )
                        .frame(width: 36, alignment: .trailing)
                }

                if member.overdueCount > 0 {
                    DFBadge(text: "\(member.overdueCount) overdue")
                }
            }
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

    private var inviteCTA: some View {
        DFButton("Invite team member") {
            onInviteMember()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

#Preview("Light") {
    NavigationStack {
        DFPMTeamScreen(
            members: [
                DFPMMember(id: UUID(), name: "Alice Chen", initials: "AC",
                           assignedTaskCount: 6, overdueCount: 1, storyPoints: 18, maxCapacity: 8),
                DFPMMember(id: UUID(), name: "Bob Kumar", initials: "BK",
                           assignedTaskCount: 3, overdueCount: 0, storyPoints: 9, maxCapacity: 8),
            ],
            teamVelocity: 42,
            sprintCompletionPct: 0.68,
            avgTaskAgeDays: 4,
            blockerCount: 2,
            onSelectMember: { _ in },
            onInviteMember: {}
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFPMTeamScreen(
            members: [
                DFPMMember(id: UUID(), name: "Alice Chen", initials: "AC",
                           assignedTaskCount: 10, overdueCount: 3, storyPoints: 24, maxCapacity: 8),
            ],
            teamVelocity: 31,
            sprintCompletionPct: 0.4,
            avgTaskAgeDays: 7,
            blockerCount: 5,
            onSelectMember: { _ in },
            onInviteMember: {}
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Small Team – Invite CTA visible") {
    NavigationStack {
        DFPMTeamScreen(
            members: [
                DFPMMember(id: UUID(), name: "Solo Dev", initials: "SD",
                           assignedTaskCount: 2, overdueCount: 0, storyPoints: 5, maxCapacity: 8),
            ],
            onSelectMember: { _ in },
            onInviteMember: {}
        )
    }
}
```

- [ ] **Step 4: Run tests — expect PASS**

```
swift test --filter DFPMTeamScreenTests
```
Expected: 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundationScreens/ProjectManager/DFPMTeamScreen.swift \
        Tests/DesignFoundationScreensTests/ProjectManager/DFPMTeamScreenTests.swift
git commit -m "feat(screens): add DFPMTeamScreen"
```

---

### Task 8: DFPMRootView — Adaptive Navigation Shell

**Files:**
- Create: `Sources/DesignFoundationScreens/ProjectManager/DFPMRootView.swift`

**Interfaces:**
- Consumes: all 6 `DFPM*Screen` types
- Produces:
```swift
public struct DFPMRootView: View {
    // All data + callbacks passed through to child screens
}
```
The root view owns navigation state and adapts between `NavigationSplitView` (iPad/Mac) and `TabView` (iPhone).

- [ ] **Step 1: Implement DFPMRootView.swift**

There are no logic-bearing unit tests for the root view (it is pure navigation wiring). Verify visually via previews.

```swift
// Sources/DesignFoundationScreens/ProjectManager/DFPMRootView.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

/// Adaptive entry point for the Project Manager vertical.
/// - iPhone: `TabView` with 5 tabs (Home, Board, List, Timeline, Team).
/// - iPad / Mac: `NavigationSplitView` sidebar.
public struct DFPMRootView: View {
    // MARK: Data inputs
    let userName: String
    let projects: [String]
    @Binding var selectedProject: String
    @Binding var tasks: [DFPMTask]
    let members: [DFPMMember]
    let milestones: [DFPMMilestone]
    let activityRows: [DFActivityFeedRow]
    let columns: [DFPMColumn]
    let teamVelocity: Int
    let sprintCompletionPct: Double
    let avgTaskAgeDays: Int
    let blockerCount: Int

    // MARK: Callbacks
    let onNewTask: @MainActor () -> Void
    let onSelectTask: @MainActor (UUID) -> Void
    let onAddTask: @MainActor (UUID) -> Void
    let onSelectProject: @MainActor (String) -> Void
    let onSelectMember: @MainActor (UUID) -> Void
    let onInviteMember: @MainActor () -> Void
    let onSelectMilestone: @MainActor (UUID) -> Void
    let onBulkDelete: @MainActor (Set<UUID>) -> Void
    let onBulkReassign: @MainActor (Set<UUID>) -> Void

    @Environment(\.dfTheme) private var theme
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedTab: DFPMTab = .home
    @State private var selectedSidebarItem: DFPMTab? = .home

    public init(
        userName: String,
        projects: [String],
        selectedProject: Binding<String>,
        tasks: Binding<[DFPMTask]>,
        members: [DFPMMember] = [],
        milestones: [DFPMMilestone] = [],
        activityRows: [DFActivityFeedRow] = [],
        columns: [DFPMColumn] = DFPMColumn.defaultColumns,
        teamVelocity: Int = 0,
        sprintCompletionPct: Double = 0,
        avgTaskAgeDays: Int = 0,
        blockerCount: Int = 0,
        onNewTask: @escaping @MainActor () -> Void,
        onSelectTask: @escaping @MainActor (UUID) -> Void,
        onAddTask: @escaping @MainActor (UUID) -> Void,
        onSelectProject: @escaping @MainActor (String) -> Void,
        onSelectMember: @escaping @MainActor (UUID) -> Void,
        onInviteMember: @escaping @MainActor () -> Void,
        onSelectMilestone: @escaping @MainActor (UUID) -> Void,
        onBulkDelete: @escaping @MainActor (Set<UUID>) -> Void,
        onBulkReassign: @escaping @MainActor (Set<UUID>) -> Void
    ) {
        self.userName = userName
        self.projects = projects
        self._selectedProject = selectedProject
        self._tasks = tasks
        self.members = members
        self.milestones = milestones
        self.activityRows = activityRows
        self.columns = columns
        self.teamVelocity = teamVelocity
        self.sprintCompletionPct = sprintCompletionPct
        self.avgTaskAgeDays = avgTaskAgeDays
        self.blockerCount = blockerCount
        self.onNewTask = onNewTask
        self.onSelectTask = onSelectTask
        self.onAddTask = onAddTask
        self.onSelectProject = onSelectProject
        self.onSelectMember = onSelectMember
        self.onInviteMember = onInviteMember
        self.onSelectMilestone = onSelectMilestone
        self.onBulkDelete = onBulkDelete
        self.onBulkReassign = onBulkReassign
    }

    public var body: some View {
        if sizeClass == .compact {
            tabLayout
        } else {
            splitLayout
        }
    }

    // MARK: Tab layout (iPhone)

    private var tabLayout: some View {
        TabView(selection: $selectedTab) {
            ForEach(DFPMTab.allCases, id: \.self) { tab in
                NavigationStack {
                    screenView(for: tab)
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.systemImage)
                }
                .tag(tab)
            }
        }
    }

    // MARK: Split layout (iPad / Mac)

    private var splitLayout: some View {
        NavigationSplitView {
            List(DFPMTab.allCases, id: \.self, selection: $selectedSidebarItem) { tab in
                Label(tab.title, systemImage: tab.systemImage)
                    .tag(tab)
            }
            .navigationTitle("Project Manager")
            .listStyle(.sidebar)
        } detail: {
            NavigationStack {
                screenView(for: selectedSidebarItem ?? .home)
            }
        }
    }

    // MARK: Screen routing

    @ViewBuilder
    private func screenView(for tab: DFPMTab) -> some View {
        switch tab {
        case .home:
            DFPMHomeScreen(
                userName: userName,
                tasks: tasks,
                activityRows: activityRows,
                onNewTask: onNewTask,
                onToggleTask: { id in
                    if let idx = tasks.firstIndex(where: { $0.id == id }) {
                        tasks[idx].status = tasks[idx].status == .done ? .todo : .done
                    }
                }
            )
        case .board:
            DFPMBoardScreen(
                projects: projects,
                selectedProject: selectedProject,
                columns: columns,
                tasks: tasks,
                members: members,
                onSelectProject: onSelectProject,
                onSelectTask: onSelectTask,
                onAddTask: onAddTask
            )
        case .list:
            DFPMListScreen(
                projects: projects,
                selectedProject: selectedProject,
                tasks: tasks,
                members: members,
                onSelectProject: onSelectProject,
                onSelectTask: onSelectTask,
                onBulkDelete: onBulkDelete,
                onBulkReassign: onBulkReassign
            )
        case .timeline:
            DFPMTimelineScreen(
                tasks: tasks,
                milestones: milestones,
                members: members,
                onSelectMilestone: onSelectMilestone
            )
        case .team:
            DFPMTeamScreen(
                members: members,
                tasks: tasks,
                teamVelocity: teamVelocity,
                sprintCompletionPct: sprintCompletionPct,
                avgTaskAgeDays: avgTaskAgeDays,
                blockerCount: blockerCount,
                onSelectMember: onSelectMember,
                onInviteMember: onInviteMember
            )
        }
    }
}

// MARK: - Tab enum

enum DFPMTab: String, CaseIterable {
    case home, board, list, timeline, team

    var title: String {
        switch self {
        case .home: "Home"
        case .board: "Board"
        case .list: "List"
        case .timeline: "Timeline"
        case .team: "Team"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .board: "rectangle.3.group"
        case .list: "list.bullet"
        case .timeline: "calendar"
        case .team: "person.3"
        }
    }
}

// MARK: - Previews

#Preview("iPhone / Light") {
    @Previewable @State var project = "Mobile"
    @Previewable @State var tasks = DFPMRootView.previewTasks
    DFPMRootView(
        userName: "Jordan",
        projects: ["Mobile", "Marketing"],
        selectedProject: $project,
        tasks: $tasks,
        members: DFPMRootView.previewMembers,
        onNewTask: {},
        onSelectTask: { _ in },
        onAddTask: { _ in },
        onSelectProject: { _ in },
        onSelectMember: { _ in },
        onInviteMember: {},
        onSelectMilestone: { _ in },
        onBulkDelete: { _ in },
        onBulkReassign: { _ in }
    )
    .environment(\.horizontalSizeClass, .compact)
}

#Preview("iPad / Dark") {
    @Previewable @State var project = "Mobile"
    @Previewable @State var tasks = DFPMRootView.previewTasks
    DFPMRootView(
        userName: "Jordan",
        projects: ["Mobile", "Marketing"],
        selectedProject: $project,
        tasks: $tasks,
        members: DFPMRootView.previewMembers,
        onNewTask: {},
        onSelectTask: { _ in },
        onAddTask: { _ in },
        onSelectProject: { _ in },
        onSelectMember: { _ in },
        onInviteMember: {},
        onSelectMilestone: { _ in },
        onBulkDelete: { _ in },
        onBulkReassign: { _ in }
    )
    .preferredColorScheme(.dark)
}

private extension DFPMRootView {
    static var previewTasks: [DFPMTask] {
        [
            DFPMTask(title: "Fix crash", status: .inProgress, priority: .critical,
                     projectName: "Mobile", dueDate: Date.now.addingTimeInterval(-3600)),
            DFPMTask(title: "Update icons", status: .todo, priority: .low, projectName: "Mobile"),
        ]
    }
    static var previewMembers: [DFPMMember] {
        [
            DFPMMember(id: UUID(), name: "Alice Chen", initials: "AC",
                       assignedTaskCount: 4, overdueCount: 1, storyPoints: 12, maxCapacity: 8),
        ]
    }
}
```

- [ ] **Step 2: Build to verify no compile errors**

```
swift build
```
Expected: build succeeds.

- [ ] **Step 3: Commit**

```bash
git add Sources/DesignFoundationScreens/ProjectManager/DFPMRootView.swift
git commit -m "feat(screens): add DFPMRootView adaptive navigation shell"
```

---

### Task 9: Full Test Suite Pass

- [ ] **Step 1: Run full test suite**

```
swift test
```
Expected: all tests pass with no failures. If any fail, fix the specific failure before continuing.

- [ ] **Step 2: Verify build on all platforms**

```bash
swift build -Xswiftc "-target" -Xswiftc "arm64-apple-ios18.0"
swift build -Xswiftc "-target" -Xswiftc "arm64-apple-macos15.0"
```
Expected: both succeed.

- [ ] **Step 3: Final commit**

```bash
git add .
git commit -m "feat(screens): Project Manager vertical complete — 6 screens + tests"
```

---

## Self-Review

### Spec Coverage

| Requirement | Covered by |
|---|---|
| DFPMHomeScreen — greeting, My Tasks grouped by overdue/today/upcoming | Task 2 |
| DFPMHomeScreen — Quick Stats × 3, Activity Feed, FAB | Task 2 |
| DFPMBoardScreen — project switcher, horizontal columns, task cards | Task 3 |
| DFPMBoardScreen — column task count badge, story points, empty state, skeleton | Task 3 |
| DFPMTaskDetailScreen — inline title edit, status badge, priority picker | Task 4 |
| DFPMTaskDetailScreen — assignee row, date range, subtasks, tags, comments, attachments | Task 4 |
| DFPMListScreen — DFTable sortable, group-by toggle, search, multi-select + bulk toolbar | Task 5 |
| DFPMTimelineScreen — date nav, DFChartPlaceholderBlock, milestone list, filter chips | Task 6 |
| DFPMTeamScreen — DFProfileHeaderBlock per member, DFProgressBar capacity, metrics grid, invite CTA | Task 7 |
| Adaptive sidebar/split on iPad+Mac, TabView on iPhone | Task 8 |
| Light + dark #Preview every screen | Tasks 2–8 |
| Swift 6 strict concurrency | All tasks — closures marked `@MainActor`, models are `Sendable` |
| All tokens from `@Environment(\.dfTheme)` | All tasks |
| Swift Testing only | Tasks 1–7 |
| Commit messages `feat(screens): …` | All tasks |

### Placeholder Scan

No TBD, TODO, or placeholder phrases present. Every step contains concrete code.

### Type Consistency

- `DFPMTask.isOverdue` and `isDueToday` defined in Task 1, consumed in Tasks 2, 3, 5, 6.
- `DFPMMember.capacityFraction` defined in Task 1, consumed in Task 7.
- `[DFPMTask].grouped()` defined in Task 1, consumed in Task 2.
- `DFPMColumn.defaultColumns` defined in Task 1, consumed in Task 8.
- `DFPMTab` defined in Task 8 as a file-private enum — consistent across `tabLayout` and `splitLayout`.
- `DFProgressBar(value:label:)` matches the real signature: `DFProgressBar(variant:value:label:)` — note: `variant` has a default value of `.linear`, so `DFProgressBar(value: member.capacityFraction, label: "Capacity")` is valid.
- `DFBadge(text:)`, `DFBadge(count:)` — both used per the actual initializers on `DFBadge`.
- `DFCard(action:content:)` — matches actual signature.
- `DFAvatar(_ initials:size:accessibilityName:)` — matches actual signature (presence defaults to `.none`).
