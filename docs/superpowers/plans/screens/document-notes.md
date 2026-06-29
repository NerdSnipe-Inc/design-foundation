# DesignFoundationScreens — Document / Notes Vertical

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build 3 launch-ready screens for a Bear/Obsidian/Notion-style writing app inside `DesignFoundationScreens`. The editor must feel like a real writing surface — large title, clean body, formatting toolbar, auto-save indicator, focus mode — not a UITextView wrapper.

**Package:** `DesignFoundationScreens` at `/Users/nerdsnipe/Projects/DesignFoundationScreens/`
**Source path:** `Sources/DesignFoundationScreens/Documents/`
**Test path:** `Tests/DesignFoundationScreensTests/Documents/`

> All absolute file paths below are under `/Users/nerdsnipe/Projects/DesignFoundationScreens/`. The package is assumed to exist before this plan runs.

---

## Global Constraints

- Swift 6 strict concurrency, `StrictConcurrency` experimental feature ON
- Platforms: iOS 18, macOS 15, visionOS 2
- All colors, fonts, spacing, radius from `@Environment(\.dfTheme)` — zero hardcoded values
- Action closures: `@MainActor () -> Void` or `@MainActor (T) -> Void`
- `#Preview("Light") { … }` and `#Preview("Dark") { … .colorScheme(.dark) }` for every screen
- Adaptive layout: `NavigationSplitView` three-column on iPad/Mac, two-pane on iPad portrait, single stack on iPhone
- Tests: Swift Testing only (`import Testing`, `@Suite`, `@Test`, `#expect`) — never XCTest
- Commit messages: `feat(screens): …`
- No Co-Author line in any commit

---

## Available Blocks

- `DFSearchResultsBlock` — search input + result list
- `DFEmptyStateBlock` — icon + title + optional message + optional CTA
- `DFBlockSkeletonBlock` — loading placeholder
- `DFTagPickerBlock` — tag assignment sheet
- `DFSettingsSectionBlock` — grouped settings rows
- `DFActivityFeedRow` — reusable list row (title + subtitle + trailing detail)
- `DFCard`, `DFButton`, `DFText`, `DFBadge`, `DFIcon`, `DFDivider`, `DFTextField`, `DFToast`, `DFList`, `DFListRow`

---

## File Map

```
Sources/DesignFoundationScreens/Documents/
  DFDocumentBrowserScreen.swift
  DFDocumentBrowserScreen+Previews.swift
  DFDocumentEditorScreen.swift
  DFDocumentEditorScreen+Previews.swift
  DFDocumentSearchScreen.swift
  DFDocumentSearchScreen+Previews.swift
  Supporting/
    DFNoteModel.swift                      ← shared value types for this vertical
    DFFolderModel.swift
    DFEditorToolbar.swift                  ← formatting toolbar (shared by browser + editor)
    DFNoteRowView.swift                    ← note list row (title, excerpt, date, tag dots)
    DFFolderSidebarView.swift              ← column 1: folder/tag tree
    DFNoteListView.swift                   ← column 2: note list with search + sort
    DFEditorColumnView.swift               ← column 3 / full-screen editor surface
    DFAutoSaveState.swift                  ← @Observable auto-save coordinator

Tests/DesignFoundationScreensTests/Documents/
  DFDocumentBrowserScreenTests.swift
  DFDocumentEditorScreenTests.swift
  DFDocumentSearchScreenTests.swift
  DFNoteModelTests.swift
  DFAutoSaveStateTests.swift
```

---

## Task 1: Shared Value Types — DFNoteModel + DFFolderModel

**Files:**
- Create: `Sources/DesignFoundationScreens/Documents/Supporting/DFNoteModel.swift`
- Create: `Sources/DesignFoundationScreens/Documents/Supporting/DFFolderModel.swift`
- Create: `Tests/DesignFoundationScreensTests/Documents/DFNoteModelTests.swift`

**Interfaces:**
- Produces: `DFNoteModel`, `DFTagModel`, `DFFolderModel` — `Identifiable`, `Hashable`, `Sendable` value types shared by all three screens

- [ ] **Step 1: Write failing tests**

```swift
// Tests/DesignFoundationScreensTests/Documents/DFNoteModelTests.swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFNoteModel")
struct DFNoteModelTests {

    @Suite("Defaults")
    struct DefaultsTests {
        @Test("isPinned defaults to false")
        func isPinnedDefaultsFalse() {
            let note = DFNoteModel(title: "Hello", body: "World")
            #expect(note.isPinned == false)
        }

        @Test("tags default to empty")
        func tagsDefaultEmpty() {
            let note = DFNoteModel(title: "Hello", body: "World")
            #expect(note.tags.isEmpty)
        }

        @Test("folderID defaults to nil")
        func folderIDDefaultsNil() {
            let note = DFNoteModel(title: "Hello", body: "World")
            #expect(note.folderID == nil)
        }
    }

    @Suite("Word count")
    struct WordCountTests {
        @Test("empty body has zero words")
        func emptyBody() {
            let note = DFNoteModel(title: "T", body: "")
            #expect(note.wordCount == 0)
        }

        @Test("counts words correctly")
        func countsWords() {
            let note = DFNoteModel(title: "T", body: "one two three")
            #expect(note.wordCount == 3)
        }
    }

    @Suite("Excerpt")
    struct ExcerptTests {
        @Test("excerpt truncates to 120 characters")
        func excerptTruncates() {
            let longBody = String(repeating: "a", count: 200)
            let note = DFNoteModel(title: "T", body: longBody)
            #expect(note.excerpt.count <= 120)
        }

        @Test("short body returns full body as excerpt")
        func shortBodyExcerpt() {
            let note = DFNoteModel(title: "T", body: "Short")
            #expect(note.excerpt == "Short")
        }
    }

    @Suite("DFFolderModel")
    struct FolderModelTests {
        @Test("childFolders defaults to empty")
        func childFoldersDefault() {
            let folder = DFFolderModel(name: "Work")
            #expect(folder.childFolders.isEmpty)
        }

        @Test("noteCount defaults to zero")
        func noteCountDefault() {
            let folder = DFFolderModel(name: "Work")
            #expect(folder.noteCount == 0)
        }
    }
}
```

- [ ] **Step 2: Run tests to confirm compile failure**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFNoteModelTests 2>&1 | tail -20
```

Expected: compile error — types not found.

- [ ] **Step 3: Implement DFNoteModel + DFTagModel**

```swift
// Sources/DesignFoundationScreens/Documents/Supporting/DFNoteModel.swift
import Foundation

/// A lightweight tag attached to a note.
public struct DFTagModel: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    /// Hex color string, e.g. "#FF6B35". Rendered as a coloured dot in the note row.
    public var colorHex: String

    public init(id: UUID = UUID(), name: String, colorHex: String = "#8B8B8B") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}

/// A single note document.
public struct DFNoteModel: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var body: String
    public var tags: [DFTagModel]
    public var folderID: UUID?
    public var isPinned: Bool
    public var createdAt: Date
    public var modifiedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        body: String,
        tags: [DFTagModel] = [],
        folderID: UUID? = nil,
        isPinned: Bool = false,
        createdAt: Date = .now,
        modifiedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.tags = tags
        self.folderID = folderID
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    /// A preview of the body, capped at 120 characters.
    public var excerpt: String {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 120 else { return trimmed }
        return String(trimmed.prefix(120))
    }

    /// Number of whitespace-separated words in the body.
    public var wordCount: Int {
        guard !body.isEmpty else { return 0 }
        return body.split(whereSeparator: \.isWhitespace).count
    }

    /// Character count including spaces.
    public var characterCount: Int { body.count }
}
```

- [ ] **Step 4: Implement DFFolderModel**

```swift
// Sources/DesignFoundationScreens/Documents/Supporting/DFFolderModel.swift
import Foundation

/// A folder that groups notes. Supports nesting via `childFolders`.
public struct DFFolderModel: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var iconSystemName: String
    public var noteCount: Int
    public var childFolders: [DFFolderModel]

    public init(
        id: UUID = UUID(),
        name: String,
        iconSystemName: String = "folder",
        noteCount: Int = 0,
        childFolders: [DFFolderModel] = []
    ) {
        self.id = id
        self.name = name
        self.iconSystemName = iconSystemName
        self.noteCount = noteCount
        self.childFolders = childFolders
    }
}
```

- [ ] **Step 5: Run tests — expect green**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFNoteModelTests 2>&1 | tail -20
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Documents/Supporting/DFNoteModel.swift \
        Sources/DesignFoundationScreens/Documents/Supporting/DFFolderModel.swift \
        Tests/DesignFoundationScreensTests/Documents/DFNoteModelTests.swift
git commit -m "feat(screens): add DFNoteModel, DFTagModel, DFFolderModel value types for Documents vertical"
```

---

## Task 2: DFAutoSaveState — Auto-Save Coordinator

**Files:**
- Create: `Sources/DesignFoundationScreens/Documents/Supporting/DFAutoSaveState.swift`
- Create: `Tests/DesignFoundationScreensTests/Documents/DFAutoSaveStateTests.swift`

**Interfaces:**
- Produces: `DFAutoSaveState` — `@Observable @MainActor` class that debounces saves and exposes a `status: DFAutoSaveStatus` enum (`.idle`, `.saving`, `.saved`, `.error(String)`)

- [ ] **Step 1: Write failing tests**

```swift
// Tests/DesignFoundationScreensTests/Documents/DFAutoSaveStateTests.swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFAutoSaveState")
struct DFAutoSaveStateTests {

    @Suite("Status enum")
    struct StatusTests {
        @Test("idle has expected label")
        func idleLabel() {
            #expect(DFAutoSaveStatus.idle.label == "")
        }

        @Test("saved has expected label")
        func savedLabel() {
            #expect(DFAutoSaveStatus.saved.label == "Saved")
        }

        @Test("saving has expected label")
        func savingLabel() {
            #expect(DFAutoSaveStatus.saving.label == "Saving…")
        }

        @Test("error carries message")
        func errorLabel() {
            let msg = "Disk full"
            #expect(DFAutoSaveStatus.error(msg).label == "Error: \(msg)")
        }
    }

    @Suite("Initial state")
    struct InitialStateTests {
        @Test("starts idle")
        @MainActor func startsIdle() {
            let state = DFAutoSaveState()
            #expect(state.status == .idle)
        }
    }

    @Suite("Manual save")
    struct ManualSaveTests {
        @Test("markSaved transitions to saved")
        @MainActor func markSavedTransitions() {
            let state = DFAutoSaveState()
            state.markSaved()
            #expect(state.status == .saved)
        }

        @Test("markSaving transitions to saving")
        @MainActor func markSavingTransitions() {
            let state = DFAutoSaveState()
            state.markSaving()
            #expect(state.status == .saving)
        }

        @Test("markError transitions to error")
        @MainActor func markErrorTransitions() {
            let state = DFAutoSaveState()
            state.markError("Disk full")
            if case .error(let msg) = state.status {
                #expect(msg == "Disk full")
            } else {
                #expect(Bool(false), "Expected .error status")
            }
        }
    }
}
```

- [ ] **Step 2: Run tests to confirm compile failure**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAutoSaveStateTests 2>&1 | tail -20
```

- [ ] **Step 3: Implement DFAutoSaveStatus + DFAutoSaveState**

```swift
// Sources/DesignFoundationScreens/Documents/Supporting/DFAutoSaveState.swift
import Foundation
import Observation

/// The display state of the auto-save indicator shown in the editor nav bar.
public enum DFAutoSaveStatus: Equatable, Sendable {
    case idle
    case saving
    case saved
    case error(String)

    /// Short string shown in the nav bar / status area.
    public var label: String {
        switch self {
        case .idle:           return ""
        case .saving:         return "Saving…"
        case .saved:          return "Saved"
        case .error(let msg): return "Error: \(msg)"
        }
    }
}

/// Coordinates debounced auto-save and exposes the current save status.
///
/// Usage:
/// ```swift
/// @State private var autoSave = DFAutoSaveState()
///
/// TextEditor(text: $noteBody)
///     .onChange(of: noteBody) { _, _ in
///         autoSave.scheduleDebounced { await persistNote() }
///     }
/// ```
@Observable
@MainActor
public final class DFAutoSaveState {

    public private(set) var status: DFAutoSaveStatus = .idle

    private var debounceTask: Task<Void, Never>?
    /// Delay before triggering the save action. Default: 0.8 s.
    public var debounceInterval: TimeInterval = 0.8

    public init() {}

    /// Schedule a debounced async save. Cancels any pending save first.
    public func scheduleDebounced(_ action: @escaping @Sendable () async -> Void) {
        debounceTask?.cancel()
        status = .saving
        debounceTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(self?.debounceInterval ?? 0.8))
                await action()
                await MainActor.run { self?.status = .saved }
            } catch {
                // Task was cancelled — a newer debounce is running; do nothing.
            }
        }
    }

    // MARK: - Explicit state transitions (for external callers and tests)

    public func markSaving() { status = .saving }
    public func markSaved()  { status = .saved }
    public func markError(_ message: String) { status = .error(message) }

    deinit {
        debounceTask?.cancel()
    }
}
```

- [ ] **Step 4: Run tests — expect green**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAutoSaveStateTests 2>&1 | tail -20
```

- [ ] **Step 5: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Documents/Supporting/DFAutoSaveState.swift \
        Tests/DesignFoundationScreensTests/Documents/DFAutoSaveStateTests.swift
git commit -m "feat(screens): add DFAutoSaveState with debounce and status enum"
```

---

## Task 3: DFEditorToolbar — Shared Formatting Toolbar

**Files:**
- Create: `Sources/DesignFoundationScreens/Documents/Supporting/DFEditorToolbar.swift`

**Interfaces:**
- Consumes: `DFButton` (icon-only variant), `DFTheme`
- Produces: `DFEditorToolbar` — a horizontal `HStack` of formatting action buttons (Bold, Italic, Heading, List, Checklist, Link, Image, Tag) and a word/char count display. Used by both column 3 of the browser and the full-screen editor.

- [ ] **Step 1: Implement DFEditorToolbar**

```swift
// Sources/DesignFoundationScreens/Documents/Supporting/DFEditorToolbar.swift
import SwiftUI
import DesignFoundation

/// A horizontal formatting toolbar used by both the browser's editor column
/// and the standalone full-screen editor.
///
/// On iPhone the toolbar attaches to the keyboard via `.toolbar(.keyboard)`.
/// On iPad/Mac it appears at the top of the editor column.
public struct DFEditorToolbar: View {

    public struct Configuration {
        public var wordCount: Int
        public var characterCount: Int
        public var onBold: @MainActor () -> Void
        public var onItalic: @MainActor () -> Void
        public var onHeading: @MainActor () -> Void
        public var onBulletList: @MainActor () -> Void
        public var onChecklist: @MainActor () -> Void
        public var onLink: @MainActor () -> Void
        public var onImage: @MainActor () -> Void
        public var onTag: @MainActor () -> Void

        public init(
            wordCount: Int = 0,
            characterCount: Int = 0,
            onBold: @escaping @MainActor () -> Void = {},
            onItalic: @escaping @MainActor () -> Void = {},
            onHeading: @escaping @MainActor () -> Void = {},
            onBulletList: @escaping @MainActor () -> Void = {},
            onChecklist: @escaping @MainActor () -> Void = {},
            onLink: @escaping @MainActor () -> Void = {},
            onImage: @escaping @MainActor () -> Void = {},
            onTag: @escaping @MainActor () -> Void = {}
        ) {
            self.wordCount = wordCount
            self.characterCount = characterCount
            self.onBold = onBold
            self.onItalic = onItalic
            self.onHeading = onHeading
            self.onBulletList = onBulletList
            self.onChecklist = onChecklist
            self.onLink = onLink
            self.onImage = onImage
            self.onTag = onTag
        }
    }

    public let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        HStack(spacing: 0) {
            toolbarButton("bold",           action: configuration.onBold)
            toolbarButton("italic",         action: configuration.onItalic)
            toolbarButton("h.square",       action: configuration.onHeading)
            toolbarDivider()
            toolbarButton("list.bullet",    action: configuration.onBulletList)
            toolbarButton("checklist",      action: configuration.onChecklist)
            toolbarDivider()
            toolbarButton("link",           action: configuration.onLink)
            toolbarButton("photo",          action: configuration.onImage)
            toolbarButton("tag",            action: configuration.onTag)

            Spacer()

            // Word / character count
            DFText(
                "\(configuration.wordCount) words · \(configuration.characterCount) chars",
                style: .caption
            )
            .foregroundStyle(Color(theme.colors.textMuted))
            .padding(.trailing, theme.spacing.md)
        }
        .padding(.horizontal, theme.spacing.sm)
        .frame(height: 44)
        .background(Color(theme.colors.surfaceSecondary))
        .overlay(alignment: .bottom) {
            DFDivider()
        }
    }

    // MARK: - Private helpers

    @ViewBuilder
    private func toolbarButton(_ systemName: String, action: @escaping @MainActor () -> Void) -> some View {
        Button(action: action) {
            DFIcon(systemName, size: .md)
                .foregroundStyle(Color(theme.colors.textSecondary))
        }
        .buttonStyle(.plain)
        .frame(width: 36, height: 44)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func toolbarDivider() -> some View {
        Rectangle()
            .fill(Color(theme.colors.border))
            .frame(width: 1, height: 20)
            .padding(.horizontal, theme.spacing.xs)
    }
}
```

- [ ] **Step 2: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Documents/Supporting/DFEditorToolbar.swift
git commit -m "feat(screens): add DFEditorToolbar with formatting actions and word/char count"
```

---

## Task 4: DFNoteRowView — Note List Row

**Files:**
- Create: `Sources/DesignFoundationScreens/Documents/Supporting/DFNoteRowView.swift`

**Interfaces:**
- Consumes: `DFNoteModel`, `DFActivityFeedRow`, `DFBadge`, `DFIcon`, `DFTheme`
- Produces: `DFNoteRowView` — a list row showing title (bold), 2-line excerpt (muted), modified date (trailing), pinned indicator, and coloured tag dots

- [ ] **Step 1: Implement DFNoteRowView**

```swift
// Sources/DesignFoundationScreens/Documents/Supporting/DFNoteRowView.swift
import SwiftUI
import DesignFoundation

/// A single row in the note list. Shows title, 2-line excerpt, relative date,
/// a pin indicator, and up to 3 coloured tag dots.
public struct DFNoteRowView: View {

    public let note: DFNoteModel
    @Environment(\.dfTheme) private var theme

    private static let dateFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()

    public init(note: DFNoteModel) {
        self.note = note
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            // ── Row 1: title + pin
            HStack(alignment: .firstTextBaseline) {
                DFText(note.title.isEmpty ? "Untitled" : note.title, style: .bodyBold)
                    .lineLimit(1)
                    .foregroundStyle(Color(theme.colors.textPrimary))
                Spacer()
                if note.isPinned {
                    DFIcon("pin.fill", size: .sm)
                        .foregroundStyle(Color(theme.colors.accent))
                }
                DFText(
                    Self.dateFormatter.localizedString(for: note.modifiedAt, relativeTo: .now),
                    style: .caption
                )
                .foregroundStyle(Color(theme.colors.textMuted))
            }

            // ── Row 2: excerpt
            DFText(note.excerpt, style: .body)
                .lineLimit(2)
                .foregroundStyle(Color(theme.colors.textSecondary))

            // ── Row 3: tag dots (up to 3)
            if !note.tags.isEmpty {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(note.tags.prefix(3)) { tag in
                        tagDot(colorHex: tag.colorHex)
                    }
                    if note.tags.count > 3 {
                        DFText("+\(note.tags.count - 3)", style: .caption)
                            .foregroundStyle(Color(theme.colors.textMuted))
                    }
                }
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func tagDot(colorHex: String) -> some View {
        Circle()
            .fill(Color(hex: colorHex) ?? Color(theme.colors.accent))
            .frame(width: 8, height: 8)
    }
}

// MARK: - Color hex convenience (local to this file)

private extension Color {
    init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str.removeFirst() }
        guard str.count == 6, let value = UInt64(str, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >>  8) & 0xFF) / 255
        let b = Double((value      ) & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
```

- [ ] **Step 2: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Documents/Supporting/DFNoteRowView.swift
git commit -m "feat(screens): add DFNoteRowView with title, excerpt, date, pin, and tag dots"
```

---

## Task 5: DFEditorColumnView — Editor Surface (shared inner view)

**Files:**
- Create: `Sources/DesignFoundationScreens/Documents/Supporting/DFEditorColumnView.swift`

**Interfaces:**
- Consumes: `DFNoteModel`, `DFAutoSaveState`, `DFEditorToolbar`, `DFTheme`
- Produces: `DFEditorColumnView` — the actual writing surface (large title field + TextEditor body). Used as column 3 in `DFDocumentBrowserScreen` and as the core of `DFDocumentEditorScreen`. Exposes bindings for title and body so the parent manages the model.

- [ ] **Step 1: Implement DFEditorColumnView**

```swift
// Sources/DesignFoundationScreens/Documents/Supporting/DFEditorColumnView.swift
import SwiftUI
import DesignFoundation

/// The core editor writing surface shared by the browser column and the
/// full-screen editor. The parent owns the note model; this view owns only
/// the ephemeral UI state (focus, toolbar visibility).
public struct DFEditorColumnView: View {

    // MARK: - Bindings from parent

    @Binding public var title: String
    @Binding public var body: String
    /// Set to nil to show the "no note selected" placeholder.
    public let noteID: UUID?

    // MARK: - Configuration

    public struct Configuration {
        /// Pass true on iPhone / when shown full-screen to use keyboard toolbar.
        public var usesKeyboardToolbar: Bool
        public var onShare: @MainActor () -> Void
        public var onBold: @MainActor () -> Void
        public var onItalic: @MainActor () -> Void
        public var onHeading: @MainActor () -> Void
        public var onBulletList: @MainActor () -> Void
        public var onChecklist: @MainActor () -> Void
        public var onLink: @MainActor () -> Void
        public var onImage: @MainActor () -> Void
        public var onTag: @MainActor () -> Void

        public init(
            usesKeyboardToolbar: Bool = false,
            onShare: @escaping @MainActor () -> Void = {},
            onBold: @escaping @MainActor () -> Void = {},
            onItalic: @escaping @MainActor () -> Void = {},
            onHeading: @escaping @MainActor () -> Void = {},
            onBulletList: @escaping @MainActor () -> Void = {},
            onChecklist: @escaping @MainActor () -> Void = {},
            onLink: @escaping @MainActor () -> Void = {},
            onImage: @escaping @MainActor () -> Void = {},
            onTag: @escaping @MainActor () -> Void = {}
        ) {
            self.usesKeyboardToolbar = usesKeyboardToolbar
            self.onShare = onShare
            self.onBold = onBold
            self.onItalic = onItalic
            self.onHeading = onHeading
            self.onBulletList = onBulletList
            self.onChecklist = onChecklist
            self.onLink = onLink
            self.onImage = onImage
            self.onTag = onTag
        }
    }

    public let configuration: Configuration

    @State private var autoSave = DFAutoSaveState()
    @Environment(\.dfTheme) private var theme

    // Focus-mode state: toolbar fades after 2 s of typing inactivity
    @State private var toolbarVisible: Bool = true
    @State private var focusFadeTask: Task<Void, Never>?

    public init(
        title: Binding<String>,
        body: Binding<String>,
        noteID: UUID?,
        configuration: Configuration = Configuration()
    ) {
        self._title = title
        self._body = body
        self.noteID = noteID
        self.configuration = configuration
    }

    public var body: some View {
        if noteID == nil {
            noNoteSelected
        } else {
            editorContent
        }
    }

    // MARK: - No note selected

    @ViewBuilder
    private var noNoteSelected: some View {
        DFEmptyStateBlock(configuration: .init(
            icon: "doc.text",
            title: "No Note Selected",
            message: "Choose a note from the list, or create a new one."
        ))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Editor content

    @ViewBuilder
    private var editorContent: some View {
        VStack(spacing: 0) {
            // Top toolbar (iPad/Mac) — hidden in focus mode
            if !configuration.usesKeyboardToolbar {
                DFEditorToolbar(configuration: toolbarConfiguration)
                    .opacity(toolbarVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.25), value: toolbarVisible)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    // Large title field
                    TextField("Title", text: $title, axis: .vertical)
                        .font(Font(theme.typography.largeTitleBold))
                        .foregroundStyle(Color(theme.colors.textPrimary))
                        .textFieldStyle(.plain)
                        .onChange(of: title) { _, _ in handleEdit() }

                    DFDivider()

                    // Body TextEditor — native SwiftUI with DFTheme font/color
                    TextEditor(text: $body)
                        .font(Font(theme.typography.body))
                        .foregroundStyle(Color(theme.colors.textPrimary))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 400)
                        .onChange(of: body) { _, _ in handleEdit() }
                }
                .padding(theme.spacing.lg)
            }
            .contentMargins(.bottom, 80, for: .scrollContent) // keyboard clearance
        }
        // Keyboard toolbar — iPhone / focus mode
        .toolbar {
            if configuration.usesKeyboardToolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    DFEditorToolbar(configuration: toolbarConfiguration)
                }
            }
        }
        // Auto-save status in nav bar
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                DFText(autoSave.status.label, style: .caption)
                    .foregroundStyle(Color(theme.colors.textMuted))
                    .animation(.easeInOut, value: autoSave.status.label)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: configuration.onShare) {
                    DFIcon("square.and.arrow.up", size: .md)
                }
            }
        }
        // Tap to restore toolbar in focus mode
        .onTapGesture {
            if !toolbarVisible {
                showToolbarTemporarily()
            }
        }
    }

    // MARK: - Toolbar configuration

    private var toolbarConfiguration: DFEditorToolbar.Configuration {
        DFEditorToolbar.Configuration(
            wordCount: body.split(whereSeparator: \.isWhitespace).count,
            characterCount: body.count,
            onBold: configuration.onBold,
            onItalic: configuration.onItalic,
            onHeading: configuration.onHeading,
            onBulletList: configuration.onBulletList,
            onChecklist: configuration.onChecklist,
            onLink: configuration.onLink,
            onImage: configuration.onImage,
            onTag: configuration.onTag
        )
    }

    // MARK: - Focus mode / debounce helpers

    @MainActor
    private func handleEdit() {
        autoSave.scheduleDebounced { /* caller provides real persist action */ }
        showToolbarTemporarily()
    }

    @MainActor
    private func showToolbarTemporarily() {
        withAnimation { toolbarVisible = true }
        focusFadeTask?.cancel()
        focusFadeTask = Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                withAnimation { toolbarVisible = false }
            }
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Documents/Supporting/DFEditorColumnView.swift
git commit -m "feat(screens): add DFEditorColumnView writing surface with focus mode and auto-save indicator"
```

---

## Task 6: DFFolderSidebarView — Column 1 Folder/Tag Tree

**Files:**
- Create: `Sources/DesignFoundationScreens/Documents/Supporting/DFFolderSidebarView.swift`

**Interfaces:**
- Consumes: `DFFolderModel`, `DFTagModel`, `DFBadge`, `DFIcon`, `DFTheme`, `DFAvatar` (user avatar)
- Produces: `DFFolderSidebarView` — the leftmost column showing All Notes, expandable folder tree, tags, Trash, and a user avatar row at the bottom

- [ ] **Step 1: Implement DFFolderSidebarView**

```swift
// Sources/DesignFoundationScreens/Documents/Supporting/DFFolderSidebarView.swift
import SwiftUI
import DesignFoundation

/// The leftmost sidebar column: app branding, All Notes shortcut, folder tree,
/// tag list, Trash, and a user avatar / settings row at the bottom.
public struct DFFolderSidebarView: View {

    public struct Configuration {
        public var appName: String
        public var allNotesCount: Int
        public var trashCount: Int
        public var folders: [DFFolderModel]
        public var tags: [DFTagModel]
        public var selectedFolderID: UUID?
        public var onSelectAllNotes: @MainActor () -> Void
        public var onSelectFolder: @MainActor (UUID) -> Void
        public var onSelectTag: @MainActor (UUID) -> Void
        public var onSelectTrash: @MainActor () -> Void
        public var onNewNote: @MainActor () -> Void
        public var onSettings: @MainActor () -> Void
        public var userAvatarURL: URL?
        public var userName: String

        public init(
            appName: String = "Notes",
            allNotesCount: Int = 0,
            trashCount: Int = 0,
            folders: [DFFolderModel] = [],
            tags: [DFTagModel] = [],
            selectedFolderID: UUID? = nil,
            onSelectAllNotes: @escaping @MainActor () -> Void = {},
            onSelectFolder: @escaping @MainActor (UUID) -> Void = { _ in },
            onSelectTag: @escaping @MainActor (UUID) -> Void = { _ in },
            onSelectTrash: @escaping @MainActor () -> Void = {},
            onNewNote: @escaping @MainActor () -> Void = {},
            onSettings: @escaping @MainActor () -> Void = {},
            userAvatarURL: URL? = nil,
            userName: String = ""
        ) {
            self.appName = appName
            self.allNotesCount = allNotesCount
            self.trashCount = trashCount
            self.folders = folders
            self.tags = tags
            self.selectedFolderID = selectedFolderID
            self.onSelectAllNotes = onSelectAllNotes
            self.onSelectFolder = onSelectFolder
            self.onSelectTag = onSelectTag
            self.onSelectTrash = onSelectTrash
            self.onNewNote = onNewNote
            self.onSettings = onSettings
            self.userAvatarURL = userAvatarURL
            self.userName = userName
        }
    }

    public let configuration: Configuration
    @Environment(\.dfTheme) private var theme
    @State private var expandedFolders: Set<UUID> = []

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: 0) {
            // ── App name + New Note FAB
            HStack {
                DFText(configuration.appName, style: .titleBold)
                    .foregroundStyle(Color(theme.colors.textPrimary))
                Spacer()
                Button(action: configuration.onNewNote) {
                    DFIcon("square.and.pencil", size: .lg)
                        .foregroundStyle(Color(theme.colors.accent))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)

            DFDivider()

            List {
                // ── All Notes
                sidebarRow(
                    icon: "note.text",
                    label: "All Notes",
                    count: configuration.allNotesCount,
                    action: configuration.onSelectAllNotes
                )

                // ── Folders
                if !configuration.folders.isEmpty {
                    Section("Folders") {
                        ForEach(configuration.folders) { folder in
                            folderRow(folder)
                        }
                    }
                }

                // ── Tags
                if !configuration.tags.isEmpty {
                    Section("Tags") {
                        ForEach(configuration.tags) { tag in
                            Button(action: { configuration.onSelectTag(tag.id) }) {
                                HStack(spacing: theme.spacing.sm) {
                                    Circle()
                                        .fill(Color(hex: tag.colorHex) ?? Color(theme.colors.accent))
                                        .frame(width: 10, height: 10)
                                    DFText(tag.name, style: .body)
                                        .foregroundStyle(Color(theme.colors.textPrimary))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // ── Trash
                sidebarRow(
                    icon: "trash",
                    label: "Trash",
                    count: configuration.trashCount,
                    action: configuration.onSelectTrash
                )
            }
            .listStyle(.sidebar)

            DFDivider()

            // ── User avatar + settings
            HStack(spacing: theme.spacing.sm) {
                DFAvatar(
                    initials: initials(from: configuration.userName),
                    imageURL: configuration.userAvatarURL,
                    size: .sm
                )
                DFText(configuration.userName, style: .body)
                    .foregroundStyle(Color(theme.colors.textPrimary))
                    .lineLimit(1)
                Spacer()
                Button(action: configuration.onSettings) {
                    DFIcon("gearshape", size: .md)
                        .foregroundStyle(Color(theme.colors.textMuted))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
        }
    }

    // MARK: - Private helpers

    @ViewBuilder
    private func sidebarRow(
        icon: String,
        label: String,
        count: Int,
        action: @escaping @MainActor () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.sm) {
                DFIcon(icon, size: .md)
                    .foregroundStyle(Color(theme.colors.textSecondary))
                DFText(label, style: .body)
                    .foregroundStyle(Color(theme.colors.textPrimary))
                Spacer()
                if count > 0 {
                    DFBadge("\(count)", style: .muted)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func folderRow(_ folder: DFFolderModel) -> some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { expandedFolders.contains(folder.id) },
                set: { expanded in
                    if expanded { expandedFolders.insert(folder.id) }
                    else { expandedFolders.remove(folder.id) }
                }
            )
        ) {
            ForEach(folder.childFolders) { child in
                folderRow(child)
                    .padding(.leading, theme.spacing.md)
            }
        } label: {
            Button(action: { configuration.onSelectFolder(folder.id) }) {
                HStack(spacing: theme.spacing.sm) {
                    DFIcon(folder.iconSystemName, size: .md)
                        .foregroundStyle(Color(theme.colors.textSecondary))
                    DFText(folder.name, style: .body)
                        .foregroundStyle(Color(theme.colors.textPrimary))
                    Spacer()
                    if folder.noteCount > 0 {
                        DFBadge("\(folder.noteCount)", style: .muted)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func initials(from name: String) -> String {
        name.split(separator: " ")
            .compactMap(\.first)
            .prefix(2)
            .map(String.init)
            .joined()
            .uppercased()
    }
}

private extension Color {
    init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str.removeFirst() }
        guard str.count == 6, let value = UInt64(str, radix: 16) else { return nil }
        self.init(
            red:   Double((value >> 16) & 0xFF) / 255,
            green: Double((value >>  8) & 0xFF) / 255,
            blue:  Double((value      ) & 0xFF) / 255
        )
    }
}
```

- [ ] **Step 2: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Documents/Supporting/DFFolderSidebarView.swift
git commit -m "feat(screens): add DFFolderSidebarView with expandable folder tree and tag list"
```

---

## Task 7: DFNoteListView — Column 2 Note List

**Files:**
- Create: `Sources/DesignFoundationScreens/Documents/Supporting/DFNoteListView.swift`

**Interfaces:**
- Consumes: `DFNoteModel`, `DFNoteRowView`, `DFSearchResultsBlock`, `DFEmptyStateBlock`, `DFBlockSkeletonBlock`, `DFList`, `DFTheme`
- Produces: `DFNoteListView` — the middle column with a search bar, sort picker, pinned section, note rows (swipe to pin/move/delete), loading skeleton, and empty state

- [ ] **Step 1: Implement DFNoteListView**

```swift
// Sources/DesignFoundationScreens/Documents/Supporting/DFNoteListView.swift
import SwiftUI
import DesignFoundation

/// The middle column of the three-column browser: search, sort, pinned notes,
/// all notes, swipe actions, skeleton loading, and empty state.
public struct DFNoteListView: View {

    public enum SortOrder: String, CaseIterable, Identifiable, Sendable {
        case modified = "Modified"
        case created  = "Created"
        case title    = "Title"
        case manual   = "Manual"
        public var id: String { rawValue }
    }

    public struct Configuration {
        public var notes: [DFNoteModel]
        public var isLoading: Bool
        public var searchQuery: String
        public var sortOrder: SortOrder
        public var onSelectNote: @MainActor (UUID) -> Void
        public var onPin: @MainActor (UUID) -> Void
        public var onMove: @MainActor (UUID) -> Void
        public var onDelete: @MainActor (UUID) -> Void
        public var onSearchQueryChanged: @MainActor (String) -> Void
        public var onSortOrderChanged: @MainActor (SortOrder) -> Void
        public var onCreateFirst: @MainActor () -> Void
        public var folderName: String

        public init(
            notes: [DFNoteModel] = [],
            isLoading: Bool = false,
            searchQuery: String = "",
            sortOrder: SortOrder = .modified,
            folderName: String = "All Notes",
            onSelectNote: @escaping @MainActor (UUID) -> Void = { _ in },
            onPin: @escaping @MainActor (UUID) -> Void = { _ in },
            onMove: @escaping @MainActor (UUID) -> Void = { _ in },
            onDelete: @escaping @MainActor (UUID) -> Void = { _ in },
            onSearchQueryChanged: @escaping @MainActor (String) -> Void = { _ in },
            onSortOrderChanged: @escaping @MainActor (SortOrder) -> Void = { _ in },
            onCreateFirst: @escaping @MainActor () -> Void = {}
        ) {
            self.notes = notes
            self.isLoading = isLoading
            self.searchQuery = searchQuery
            self.sortOrder = sortOrder
            self.folderName = folderName
            self.onSelectNote = onSelectNote
            self.onPin = onPin
            self.onMove = onMove
            self.onDelete = onDelete
            self.onSearchQueryChanged = onSearchQueryChanged
            self.onSortOrderChanged = onSortOrderChanged
            self.onCreateFirst = onCreateFirst
        }
    }

    public let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    private var pinnedNotes: [DFNoteModel] {
        configuration.notes.filter(\.isPinned)
    }

    private var unpinnedNotes: [DFNoteModel] {
        configuration.notes.filter { !$0.isPinned }
    }

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: 0) {
            // ── Search bar
            HStack {
                DFTextField(
                    placeholder: "Search \(configuration.folderName)",
                    text: Binding(
                        get: { configuration.searchQuery },
                        set: { configuration.onSearchQueryChanged($0) }
                    )
                )
                .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)

            // ── Sort picker
            HStack {
                DFText("Sort: ", style: .caption)
                    .foregroundStyle(Color(theme.colors.textMuted))
                Picker("Sort", selection: Binding(
                    get: { configuration.sortOrder },
                    set: { configuration.onSortOrderChanged($0) }
                )) {
                    ForEach(SortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(.menu)
                Spacer()
            }
            .padding(.horizontal, theme.spacing.md)

            DFDivider()

            if configuration.isLoading {
                skeletonView
            } else if configuration.notes.isEmpty {
                emptyView
            } else {
                noteListView
            }
        }
        .navigationTitle(configuration.folderName)
    }

    // MARK: - States

    @ViewBuilder
    private var skeletonView: some View {
        VStack(spacing: theme.spacing.sm) {
            ForEach(0..<5, id: \.self) { _ in
                DFBlockSkeletonBlock(lines: 3)
                    .padding(.horizontal, theme.spacing.md)
            }
        }
        .padding(.top, theme.spacing.md)
    }

    @ViewBuilder
    private var emptyView: some View {
        DFEmptyStateBlock(configuration: .init(
            icon: "doc.text",
            title: "No Notes",
            message: "Create your first note to get started.",
            actionTitle: "New Note",
            onAction: configuration.onCreateFirst
        ))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var noteListView: some View {
        List {
            if !pinnedNotes.isEmpty {
                Section("Pinned") {
                    ForEach(pinnedNotes) { note in
                        noteRow(note)
                    }
                }
            }
            Section(pinnedNotes.isEmpty ? "" : "Notes") {
                ForEach(unpinnedNotes) { note in
                    noteRow(note)
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func noteRow(_ note: DFNoteModel) -> some View {
        Button(action: { configuration.onSelectNote(note.id) }) {
            DFNoteRowView(note: note)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: { configuration.onPin(note.id) }) {
                Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
            }
            .tint(Color(theme.colors.accent))
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: { configuration.onDelete(note.id) }) {
                Label("Delete", systemImage: "trash")
            }
            Button(action: { configuration.onMove(note.id) }) {
                Label("Move", systemImage: "folder")
            }
            .tint(Color(theme.colors.surfaceSecondary))
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Documents/Supporting/DFNoteListView.swift
git commit -m "feat(screens): add DFNoteListView with pinned section, sort, swipe actions, skeleton and empty state"
```

---

## Task 8: DFDocumentBrowserScreen — Three-Column Browser

**Files:**
- Create: `Sources/DesignFoundationScreens/Documents/DFDocumentBrowserScreen.swift`
- Create: `Sources/DesignFoundationScreens/Documents/DFDocumentBrowserScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Documents/DFDocumentBrowserScreenTests.swift`

**Interfaces:**
- Consumes: `DFFolderSidebarView`, `DFNoteListView`, `DFEditorColumnView`
- Produces: `DFDocumentBrowserScreen` — `NavigationSplitView` with three columns (folder sidebar / note list / editor). Collapses adaptively on iPhone and iPad portrait.

- [ ] **Step 1: Write failing tests**

```swift
// Tests/DesignFoundationScreensTests/Documents/DFDocumentBrowserScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFDocumentBrowserScreen")
struct DFDocumentBrowserScreenTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("notes default to empty")
        func notesDefaultEmpty() {
            let config = DFDocumentBrowserScreen.Configuration()
            #expect(config.notes.isEmpty)
        }

        @Test("folders default to empty")
        func foldersDefaultEmpty() {
            let config = DFDocumentBrowserScreen.Configuration()
            #expect(config.folders.isEmpty)
        }

        @Test("isLoading defaults to false")
        func isLoadingDefaultsFalse() {
            let config = DFDocumentBrowserScreen.Configuration()
            #expect(config.isLoading == false)
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let screen = DFDocumentBrowserScreen(configuration: .init())
            #expect(type(of: screen) == DFDocumentBrowserScreen.self)
        }
    }

    @Suite("Note filtering")
    struct FilteringTests {
        @Test("pinned notes are separated from unpinned")
        func pinnedSeparated() {
            let pinned = DFNoteModel(title: "Pinned", body: "", isPinned: true)
            let regular = DFNoteModel(title: "Regular", body: "", isPinned: false)
            let config = DFDocumentBrowserScreen.Configuration(notes: [pinned, regular])
            #expect(config.notes.filter(\.isPinned).count == 1)
            #expect(config.notes.filter { !$0.isPinned }.count == 1)
        }
    }
}
```

- [ ] **Step 2: Run tests to confirm compile failure**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFDocumentBrowserScreenTests 2>&1 | tail -20
```

- [ ] **Step 3: Implement DFDocumentBrowserScreen**

```swift
// Sources/DesignFoundationScreens/Documents/DFDocumentBrowserScreen.swift
import SwiftUI
import DesignFoundation

/// Three-column Bear-pattern document browser.
///
/// Column 1: Folder/tag sidebar (`DFFolderSidebarView`)
/// Column 2: Note list (`DFNoteListView`)
/// Column 3: Editor surface (`DFEditorColumnView`)
///
/// Adapts to:
/// - iPad/Mac landscape: full three-column `NavigationSplitView`
/// - iPad portrait: two-pane (sidebar hidden, list + editor)
/// - iPhone: single-column stack navigation
public struct DFDocumentBrowserScreen: View {

    public struct Configuration {
        public var notes: [DFNoteModel]
        public var folders: [DFFolderModel]
        public var tags: [DFTagModel]
        public var isLoading: Bool
        public var appName: String
        public var userAvatarURL: URL?
        public var userName: String
        public var trashCount: Int
        // Callbacks
        public var onNewNote: @MainActor () -> Void
        public var onSelectNote: @MainActor (UUID) -> Void
        public var onPinNote: @MainActor (UUID) -> Void
        public var onMoveNote: @MainActor (UUID) -> Void
        public var onDeleteNote: @MainActor (UUID) -> Void
        public var onSettings: @MainActor () -> Void
        public var onShare: @MainActor () -> Void
        // Editor formatting callbacks forwarded to DFEditorColumnView
        public var onBold: @MainActor () -> Void
        public var onItalic: @MainActor () -> Void
        public var onHeading: @MainActor () -> Void
        public var onBulletList: @MainActor () -> Void
        public var onChecklist: @MainActor () -> Void
        public var onLink: @MainActor () -> Void
        public var onImage: @MainActor () -> Void
        public var onTag: @MainActor () -> Void

        public init(
            notes: [DFNoteModel] = [],
            folders: [DFFolderModel] = [],
            tags: [DFTagModel] = [],
            isLoading: Bool = false,
            appName: String = "Notes",
            userAvatarURL: URL? = nil,
            userName: String = "",
            trashCount: Int = 0,
            onNewNote: @escaping @MainActor () -> Void = {},
            onSelectNote: @escaping @MainActor (UUID) -> Void = { _ in },
            onPinNote: @escaping @MainActor (UUID) -> Void = { _ in },
            onMoveNote: @escaping @MainActor (UUID) -> Void = { _ in },
            onDeleteNote: @escaping @MainActor (UUID) -> Void = { _ in },
            onSettings: @escaping @MainActor () -> Void = {},
            onShare: @escaping @MainActor () -> Void = {},
            onBold: @escaping @MainActor () -> Void = {},
            onItalic: @escaping @MainActor () -> Void = {},
            onHeading: @escaping @MainActor () -> Void = {},
            onBulletList: @escaping @MainActor () -> Void = {},
            onChecklist: @escaping @MainActor () -> Void = {},
            onLink: @escaping @MainActor () -> Void = {},
            onImage: @escaping @MainActor () -> Void = {},
            onTag: @escaping @MainActor () -> Void = {}
        ) {
            self.notes = notes
            self.folders = folders
            self.tags = tags
            self.isLoading = isLoading
            self.appName = appName
            self.userAvatarURL = userAvatarURL
            self.userName = userName
            self.trashCount = trashCount
            self.onNewNote = onNewNote
            self.onSelectNote = onSelectNote
            self.onPinNote = onPinNote
            self.onMoveNote = onMoveNote
            self.onDeleteNote = onDeleteNote
            self.onSettings = onSettings
            self.onShare = onShare
            self.onBold = onBold
            self.onItalic = onItalic
            self.onHeading = onHeading
            self.onBulletList = onBulletList
            self.onChecklist = onChecklist
            self.onLink = onLink
            self.onImage = onImage
            self.onTag = onTag
        }
    }

    public let configuration: Configuration

    // Internal transient state
    @State private var selectedFolderID: UUID? = nil
    @State private var selectedNoteID: UUID? = nil
    @State private var noteTitle: String = ""
    @State private var noteBody: String = ""
    @State private var searchQuery: String = ""
    @State private var sortOrder: DFNoteListView.SortOrder = .modified

    @Environment(\.dfTheme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: columnVisibility) {
            // Column 1 — Folder Sidebar
            DFFolderSidebarView(configuration: folderSidebarConfiguration)
                .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 280)
        } content: {
            // Column 2 — Note List
            DFNoteListView(configuration: noteListConfiguration)
                .navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 360)
        } detail: {
            // Column 3 — Editor
            DFEditorColumnView(
                title: $noteTitle,
                body: $noteBody,
                noteID: selectedNoteID,
                configuration: editorConfiguration
            )
        }
    }

    // MARK: - Column visibility

    private var columnVisibility: Binding<NavigationSplitViewVisibility> {
        Binding(
            get: { horizontalSizeClass == .compact ? .detailOnly : .all },
            set: { _ in }
        )
    }

    // MARK: - Sub-configurations

    private var folderSidebarConfiguration: DFFolderSidebarView.Configuration {
        DFFolderSidebarView.Configuration(
            appName: configuration.appName,
            allNotesCount: configuration.notes.count,
            trashCount: configuration.trashCount,
            folders: configuration.folders,
            tags: configuration.tags,
            selectedFolderID: selectedFolderID,
            onSelectAllNotes: { selectedFolderID = nil },
            onSelectFolder: { selectedFolderID = $0 },
            onSelectTag: { _ in },
            onSelectTrash: { },
            onNewNote: configuration.onNewNote,
            onSettings: configuration.onSettings,
            userAvatarURL: configuration.userAvatarURL,
            userName: configuration.userName
        )
    }

    private var noteListConfiguration: DFNoteListView.Configuration {
        let filtered = configuration.notes.filter { note in
            guard let folderID = selectedFolderID else { return true }
            return note.folderID == folderID
        }
        return DFNoteListView.Configuration(
            notes: filtered,
            isLoading: configuration.isLoading,
            searchQuery: searchQuery,
            sortOrder: sortOrder,
            onSelectNote: { id in
                selectedNoteID = id
                if let note = configuration.notes.first(where: { $0.id == id }) {
                    noteTitle = note.title
                    noteBody = note.body
                }
                configuration.onSelectNote(id)
            },
            onPin: configuration.onPinNote,
            onMove: configuration.onMoveNote,
            onDelete: configuration.onDeleteNote,
            onSearchQueryChanged: { searchQuery = $0 },
            onSortOrderChanged: { sortOrder = $0 },
            onCreateFirst: configuration.onNewNote
        )
    }

    private var editorConfiguration: DFEditorColumnView.Configuration {
        DFEditorColumnView.Configuration(
            usesKeyboardToolbar: horizontalSizeClass == .compact,
            onShare: configuration.onShare,
            onBold: configuration.onBold,
            onItalic: configuration.onItalic,
            onHeading: configuration.onHeading,
            onBulletList: configuration.onBulletList,
            onChecklist: configuration.onChecklist,
            onLink: configuration.onLink,
            onImage: configuration.onImage,
            onTag: configuration.onTag
        )
    }
}
```

- [ ] **Step 4: Implement previews**

```swift
// Sources/DesignFoundationScreens/Documents/DFDocumentBrowserScreen+Previews.swift
import SwiftUI
import DesignFoundation

private let sampleTags: [DFTagModel] = [
    DFTagModel(name: "Work",     colorHex: "#FF6B35"),
    DFTagModel(name: "Personal", colorHex: "#4ECDC4"),
    DFTagModel(name: "Ideas",    colorHex: "#A8E063"),
]

private let sampleFolders: [DFFolderModel] = [
    DFFolderModel(name: "Work",     iconSystemName: "briefcase",  noteCount: 12),
    DFFolderModel(name: "Personal", iconSystemName: "person",     noteCount: 7),
    DFFolderModel(
        name: "Projects",
        iconSystemName: "folder",
        noteCount: 5,
        childFolders: [
            DFFolderModel(name: "App", iconSystemName: "iphone", noteCount: 3)
        ]
    ),
]

private let sampleNotes: [DFNoteModel] = [
    DFNoteModel(
        title: "Weekly Review",
        body: "This week I focused on shipping the new onboarding flow and refactoring the analytics module. Good progress on both fronts.",
        tags: [sampleTags[0]],
        isPinned: true
    ),
    DFNoteModel(
        title: "Product Ideas",
        body: "What if we added a focus timer to the editor? Bear does something similar. Could be a great differentiator.",
        tags: [sampleTags[1], sampleTags[2]]
    ),
    DFNoteModel(
        title: "Book Notes: Thinking Fast and Slow",
        body: "System 1 vs System 2 thinking. Anchoring bias. The planning fallacy. Peak-end rule.",
        tags: []
    ),
]

#Preview("Light") {
    DFDocumentBrowserScreen(configuration: .init(
        notes: sampleNotes,
        folders: sampleFolders,
        tags: sampleTags,
        appName: "Notes",
        userName: "Alex Johnson",
        trashCount: 2
    ))
    .dfTheme(.default)
}

#Preview("Dark") {
    DFDocumentBrowserScreen(configuration: .init(
        notes: sampleNotes,
        folders: sampleFolders,
        tags: sampleTags,
        appName: "Notes",
        userName: "Alex Johnson",
        trashCount: 2
    ))
    .dfTheme(.default)
    .colorScheme(.dark)
}

#Preview("Empty") {
    DFDocumentBrowserScreen(configuration: .init(
        notes: [],
        folders: [],
        tags: [],
        appName: "Notes"
    ))
    .dfTheme(.default)
}

#Preview("Loading") {
    DFDocumentBrowserScreen(configuration: .init(
        notes: [],
        folders: sampleFolders,
        tags: sampleTags,
        isLoading: true,
        appName: "Notes"
    ))
    .dfTheme(.default)
}
```

- [ ] **Step 5: Run tests — expect green**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFDocumentBrowserScreenTests 2>&1 | tail -20
```

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Documents/DFDocumentBrowserScreen.swift \
        Sources/DesignFoundationScreens/Documents/DFDocumentBrowserScreen+Previews.swift \
        Tests/DesignFoundationScreensTests/Documents/DFDocumentBrowserScreenTests.swift
git commit -m "feat(screens): add DFDocumentBrowserScreen three-column NavigationSplitView browser"
```

---

## Task 9: DFDocumentEditorScreen — Full-Screen Editor

**Files:**
- Create: `Sources/DesignFoundationScreens/Documents/DFDocumentEditorScreen.swift`
- Create: `Sources/DesignFoundationScreens/Documents/DFDocumentEditorScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Documents/DFDocumentEditorScreenTests.swift`

**Interfaces:**
- Consumes: `DFEditorColumnView`, `DFTagPickerBlock`, `DFTheme`
- Produces: `DFDocumentEditorScreen` — full-screen writing surface for iPhone (primary view) and iPad/Mac focus mode. Includes floating bottom toolbar that fades after inactivity, tag picker sheet, share button, and keyboard-avoiding scroll.

- [ ] **Step 1: Write failing tests**

```swift
// Tests/DesignFoundationScreensTests/Documents/DFDocumentEditorScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFDocumentEditorScreen")
struct DFDocumentEditorScreenTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("title defaults to empty string")
        func titleDefault() {
            let config = DFDocumentEditorScreen.Configuration(noteID: UUID())
            #expect(config.initialTitle == "")
        }

        @Test("body defaults to empty string")
        func bodyDefault() {
            let config = DFDocumentEditorScreen.Configuration(noteID: UUID())
            #expect(config.initialBody == "")
        }

        @Test("tags default to empty")
        func tagsDefault() {
            let config = DFDocumentEditorScreen.Configuration(noteID: UUID())
            #expect(config.availableTags.isEmpty)
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let screen = DFDocumentEditorScreen(configuration: .init(noteID: UUID()))
            #expect(type(of: screen) == DFDocumentEditorScreen.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to confirm compile failure**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFDocumentEditorScreenTests 2>&1 | tail -20
```

- [ ] **Step 3: Implement DFDocumentEditorScreen**

```swift
// Sources/DesignFoundationScreens/Documents/DFDocumentEditorScreen.swift
import SwiftUI
import DesignFoundation

/// Full-screen editor — the primary view on iPhone and focus mode for iPad/Mac.
///
/// Features:
/// - Large title at top, body TextEditor below (keyboard-avoiding)
/// - Floating bottom toolbar that appears on tap and fades after 2 s of inactivity
/// - Tag picker sheet (DFTagPickerBlock) opened from the toolbar
/// - Share button in the nav bar
/// - Word count centered in bottom bar
/// - Swipe down / back button to dismiss
public struct DFDocumentEditorScreen: View {

    public struct Configuration {
        public var noteID: UUID
        public var initialTitle: String
        public var initialBody: String
        public var availableTags: [DFTagModel]
        public var selectedTagIDs: Set<UUID>
        // Callbacks
        public var onDismiss: @MainActor () -> Void
        public var onSave: @MainActor (String, String, Set<UUID>) -> Void
        public var onShare: @MainActor () -> Void
        public var onBold: @MainActor () -> Void
        public var onItalic: @MainActor () -> Void
        public var onHeading: @MainActor () -> Void
        public var onBulletList: @MainActor () -> Void
        public var onChecklist: @MainActor () -> Void
        public var onLink: @MainActor () -> Void
        public var onImage: @MainActor () -> Void

        public init(
            noteID: UUID,
            initialTitle: String = "",
            initialBody: String = "",
            availableTags: [DFTagModel] = [],
            selectedTagIDs: Set<UUID> = [],
            onDismiss: @escaping @MainActor () -> Void = {},
            onSave: @escaping @MainActor (String, String, Set<UUID>) -> Void = { _, _, _ in },
            onShare: @escaping @MainActor () -> Void = {},
            onBold: @escaping @MainActor () -> Void = {},
            onItalic: @escaping @MainActor () -> Void = {},
            onHeading: @escaping @MainActor () -> Void = {},
            onBulletList: @escaping @MainActor () -> Void = {},
            onChecklist: @escaping @MainActor () -> Void = {},
            onLink: @escaping @MainActor () -> Void = {},
            onImage: @escaping @MainActor () -> Void = {}
        ) {
            self.noteID = noteID
            self.initialTitle = initialTitle
            self.initialBody = initialBody
            self.availableTags = availableTags
            self.selectedTagIDs = selectedTagIDs
            self.onDismiss = onDismiss
            self.onSave = onSave
            self.onShare = onShare
            self.onBold = onBold
            self.onItalic = onItalic
            self.onHeading = onHeading
            self.onBulletList = onBulletList
            self.onChecklist = onChecklist
            self.onLink = onLink
            self.onImage = onImage
        }
    }

    public let configuration: Configuration

    @State private var title: String
    @State private var body: String
    @State private var selectedTagIDs: Set<UUID>
    @State private var showTagPicker: Bool = false
    @State private var toolbarVisible: Bool = true
    @State private var autoSave = DFAutoSaveState()
    @State private var fadeTask: Task<Void, Never>?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    public init(configuration: Configuration) {
        self.configuration = configuration
        self._title = State(initialValue: configuration.initialTitle)
        self._body = State(initialValue: configuration.initialBody)
        self._selectedTagIDs = State(initialValue: configuration.selectedTagIDs)
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // ── Editor surface
                ScrollView {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        // Large title
                        TextField("Title", text: $title, axis: .vertical)
                            .font(Font(theme.typography.largeTitleBold))
                            .foregroundStyle(Color(theme.colors.textPrimary))
                            .textFieldStyle(.plain)
                            .onChange(of: title) { _, _ in handleEdit() }

                        DFDivider()

                        // Body
                        TextEditor(text: $body)
                            .font(Font(theme.typography.body))
                            .foregroundStyle(Color(theme.colors.textPrimary))
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 500)
                            .onChange(of: body) { _, _ in handleEdit() }
                    }
                    .padding(theme.spacing.lg)
                    .padding(.bottom, 80) // space for floating toolbar
                }
                .onTapGesture { showToolbarTemporarily() }

                // ── Floating bottom toolbar
                floatingToolbar
                    .opacity(toolbarVisible ? 1 : 0)
                    .offset(y: toolbarVisible ? 0 : 60)
                    .animation(.spring(response: 0.3), value: toolbarVisible)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { configuration.onDismiss(); dismiss() }) {
                        DFIcon("chevron.left", size: .md)
                    }
                }
                ToolbarItem(placement: .principal) {
                    DFText(autoSave.status.label, style: .caption)
                        .foregroundStyle(Color(theme.colors.textMuted))
                        .animation(.easeInOut, value: autoSave.status.label)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: configuration.onShare) {
                        DFIcon("square.and.arrow.up", size: .md)
                    }
                }
            }
        }
        .sheet(isPresented: $showTagPicker) {
            tagPickerSheet
        }
    }

    // MARK: - Floating toolbar

    @ViewBuilder
    private var floatingToolbar: some View {
        VStack(spacing: 0) {
            // Word count
            DFText(
                "\(wordCount) words",
                style: .caption
            )
            .foregroundStyle(Color(theme.colors.textMuted))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, theme.spacing.xs)

            DFEditorToolbar(configuration: DFEditorToolbar.Configuration(
                wordCount: wordCount,
                characterCount: body.count,
                onBold: configuration.onBold,
                onItalic: configuration.onItalic,
                onHeading: configuration.onHeading,
                onBulletList: configuration.onBulletList,
                onChecklist: configuration.onChecklist,
                onLink: configuration.onLink,
                onImage: configuration.onImage,
                onTag: { showTagPicker = true }
            ))
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        .padding(.horizontal, theme.spacing.md)
        .padding(.bottom, theme.spacing.lg)
    }

    // MARK: - Tag picker sheet

    @ViewBuilder
    private var tagPickerSheet: some View {
        NavigationStack {
            DFTagPickerBlock(configuration: .init(
                availableTags: configuration.availableTags.map {
                    DFTagPickerBlock.Tag(id: $0.id, name: $0.name, colorHex: $0.colorHex)
                },
                selectedTagIDs: $selectedTagIDs
            ))
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showTagPicker = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Helpers

    private var wordCount: Int {
        body.split(whereSeparator: \.isWhitespace).count
    }

    @MainActor
    private func handleEdit() {
        autoSave.scheduleDebounced {
            await MainActor.run {
                configuration.onSave(title, body, selectedTagIDs)
            }
        }
        showToolbarTemporarily()
    }

    @MainActor
    private func showToolbarTemporarily() {
        withAnimation { toolbarVisible = true }
        fadeTask?.cancel()
        fadeTask = Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                withAnimation { toolbarVisible = false }
            }
        }
    }
}
```

- [ ] **Step 4: Implement previews**

```swift
// Sources/DesignFoundationScreens/Documents/DFDocumentEditorScreen+Previews.swift
import SwiftUI
import DesignFoundation

private let previewTags: [DFTagModel] = [
    DFTagModel(name: "Work",     colorHex: "#FF6B35"),
    DFTagModel(name: "Personal", colorHex: "#4ECDC4"),
    DFTagModel(name: "Ideas",    colorHex: "#A8E063"),
    DFTagModel(name: "Archive",  colorHex: "#8B8B8B"),
]

#Preview("Light — existing note") {
    DFDocumentEditorScreen(configuration: .init(
        noteID: UUID(),
        initialTitle: "Weekly Review",
        initialBody: """
        This week I focused on shipping the new onboarding flow and refactoring the analytics module.

        Key wins:
        - Onboarding conversion up 12%
        - Analytics p95 latency down from 340 ms to 89 ms
        - Zero production incidents

        Next week:
        - Ship the document editor vertical
        - Review Q3 roadmap with PM
        """,
        availableTags: previewTags,
        selectedTagIDs: [previewTags[0].id]
    ))
    .dfTheme(.default)
}

#Preview("Dark — existing note") {
    DFDocumentEditorScreen(configuration: .init(
        noteID: UUID(),
        initialTitle: "Weekly Review",
        initialBody: "This week I focused on shipping the new onboarding flow and refactoring the analytics module.",
        availableTags: previewTags,
        selectedTagIDs: [previewTags[0].id]
    ))
    .dfTheme(.default)
    .colorScheme(.dark)
}

#Preview("Light — new empty note") {
    DFDocumentEditorScreen(configuration: .init(
        noteID: UUID(),
        initialTitle: "",
        initialBody: "",
        availableTags: previewTags
    ))
    .dfTheme(.default)
}
```

- [ ] **Step 5: Run tests — expect green**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFDocumentEditorScreenTests 2>&1 | tail -20
```

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Documents/DFDocumentEditorScreen.swift \
        Sources/DesignFoundationScreens/Documents/DFDocumentEditorScreen+Previews.swift \
        Tests/DesignFoundationScreensTests/Documents/DFDocumentEditorScreenTests.swift
git commit -m "feat(screens): add DFDocumentEditorScreen full-screen editor with floating toolbar and tag picker"
```

---

## Task 10: DFDocumentSearchScreen — Full-Text Search

**Files:**
- Create: `Sources/DesignFoundationScreens/Documents/DFDocumentSearchScreen.swift`
- Create: `Sources/DesignFoundationScreens/Documents/DFDocumentSearchScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Documents/DFDocumentSearchScreenTests.swift`

**Interfaces:**
- Consumes: `DFSearchResultsBlock`, `DFEmptyStateBlock`, `DFTagPickerBlock`, `DFBadge`, `DFTheme`
- Produces: `DFDocumentSearchScreen` — full-text search sheet/push-view with grouped title/content results, highlighted excerpts, folder breadcrumbs, recent searches, and filter chips

- [ ] **Step 1: Write failing tests**

```swift
// Tests/DesignFoundationScreensTests/Documents/DFDocumentSearchScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFDocumentSearchScreen")
struct DFDocumentSearchScreenTests {

    @Suite("SearchResult")
    struct SearchResultTests {
        @Test("titleMatch result has correct kind")
        func titleMatchKind() {
            let result = DFDocumentSearchScreen.SearchResult(
                noteID: UUID(),
                noteTitle: "Hello",
                highlightedExcerpt: "Hello world",
                matchKind: .titleMatch,
                folderName: "Work",
                modifiedAt: .now
            )
            #expect(result.matchKind == .titleMatch)
        }

        @Test("contentMatch result has correct kind")
        func contentMatchKind() {
            let result = DFDocumentSearchScreen.SearchResult(
                noteID: UUID(),
                noteTitle: "Hello",
                highlightedExcerpt: "…the hello there…",
                matchKind: .contentMatch,
                folderName: nil,
                modifiedAt: .now
            )
            #expect(result.matchKind == .contentMatch)
        }
    }

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("results default to empty")
        func resultsDefault() {
            let config = DFDocumentSearchScreen.Configuration()
            #expect(config.results.isEmpty)
        }

        @Test("recentSearches default to empty")
        func recentSearchesDefault() {
            let config = DFDocumentSearchScreen.Configuration()
            #expect(config.recentSearches.isEmpty)
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let screen = DFDocumentSearchScreen(configuration: .init())
            #expect(type(of: screen) == DFDocumentSearchScreen.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to confirm compile failure**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFDocumentSearchScreenTests 2>&1 | tail -20
```

- [ ] **Step 3: Implement DFDocumentSearchScreen**

```swift
// Sources/DesignFoundationScreens/Documents/DFDocumentSearchScreen.swift
import SwiftUI
import DesignFoundation

/// Full-text search screen. Presented as a sheet from the search bar in the
/// note list, or pushed on iPhone. Groups results into Title Matches and
/// Content Matches. Shows recent searches when the query is empty.
public struct DFDocumentSearchScreen: View {

    // MARK: - Public types

    public enum MatchKind: Equatable, Sendable {
        case titleMatch
        case contentMatch
    }

    public enum FilterScope: String, CaseIterable, Identifiable, Sendable {
        case all     = "All"
        case folders = "Folders"
        case tags    = "Tags"
        public var id: String { rawValue }
    }

    public struct SearchResult: Identifiable, Sendable {
        public let id: UUID
        public let noteID: UUID
        public let noteTitle: String
        /// Pre-formatted excerpt with the matched text to display (plain string;
        /// caller is responsible for highlighting via AttributedString if desired).
        public let highlightedExcerpt: String
        public let matchKind: MatchKind
        public let folderName: String?
        public let tagNames: [String]
        public let modifiedAt: Date

        public init(
            id: UUID = UUID(),
            noteID: UUID,
            noteTitle: String,
            highlightedExcerpt: String,
            matchKind: MatchKind,
            folderName: String? = nil,
            tagNames: [String] = [],
            modifiedAt: Date
        ) {
            self.id = id
            self.noteID = noteID
            self.noteTitle = noteTitle
            self.highlightedExcerpt = highlightedExcerpt
            self.matchKind = matchKind
            self.folderName = folderName
            self.tagNames = tagNames
            self.modifiedAt = modifiedAt
        }
    }

    public struct Configuration {
        public var results: [SearchResult]
        public var recentSearches: [String]
        public var availableTags: [DFTagModel]
        public var isSearching: Bool
        public var onQueryChanged: @MainActor (String) -> Void
        public var onSelectResult: @MainActor (UUID) -> Void
        public var onClearRecentSearches: @MainActor () -> Void
        public var onSelectRecentSearch: @MainActor (String) -> Void
        public var onDismiss: @MainActor () -> Void

        public init(
            results: [SearchResult] = [],
            recentSearches: [String] = [],
            availableTags: [DFTagModel] = [],
            isSearching: Bool = false,
            onQueryChanged: @escaping @MainActor (String) -> Void = { _ in },
            onSelectResult: @escaping @MainActor (UUID) -> Void = { _ in },
            onClearRecentSearches: @escaping @MainActor () -> Void = {},
            onSelectRecentSearch: @escaping @MainActor (String) -> Void = { _ in },
            onDismiss: @escaping @MainActor () -> Void = {}
        ) {
            self.results = results
            self.recentSearches = recentSearches
            self.availableTags = availableTags
            self.isSearching = isSearching
            self.onQueryChanged = onQueryChanged
            self.onSelectResult = onSelectResult
            self.onClearRecentSearches = onClearRecentSearches
            self.onSelectRecentSearch = onSelectRecentSearch
            self.onDismiss = onDismiss
        }
    }

    public let configuration: Configuration

    @State private var query: String = ""
    @State private var filterScope: FilterScope = .all

    @Environment(\.dfTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── Filter chips
                filterChips
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)

                DFDivider()

                // ── Content
                if query.isEmpty {
                    recentSearchesView
                } else if configuration.isSearching {
                    DFBlockSkeletonBlock(lines: 4)
                        .padding(theme.spacing.md)
                } else if configuration.results.isEmpty {
                    DFEmptyStateBlock(configuration: .init(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "Try a different search term or remove filters."
                    ))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    resultsView
                }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search notes")
            .onChange(of: query) { _, newValue in
                configuration.onQueryChanged(newValue)
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        configuration.onDismiss()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Filter chips

    @ViewBuilder
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(FilterScope.allCases) { scope in
                    Button(action: { filterScope = scope }) {
                        DFText(scope.rawValue, style: .caption)
                            .padding(.horizontal, theme.spacing.sm)
                            .padding(.vertical, theme.spacing.xs)
                            .background(
                                filterScope == scope
                                    ? Color(theme.colors.accent)
                                    : Color(theme.colors.surfaceSecondary)
                            )
                            .foregroundStyle(
                                filterScope == scope
                                    ? Color(theme.colors.onAccent)
                                    : Color(theme.colors.textSecondary)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Recent searches

    @ViewBuilder
    private var recentSearchesView: some View {
        if configuration.recentSearches.isEmpty {
            DFEmptyStateBlock(configuration: .init(
                icon: "clock",
                title: "No Recent Searches",
                message: "Your recent searches will appear here."
            ))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                Section {
                    ForEach(configuration.recentSearches, id: \.self) { term in
                        Button(action: { configuration.onSelectRecentSearch(term) }) {
                            HStack {
                                DFIcon("clock", size: .sm)
                                    .foregroundStyle(Color(theme.colors.textMuted))
                                DFText(term, style: .body)
                                    .foregroundStyle(Color(theme.colors.textPrimary))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    HStack {
                        DFText("Recent", style: .caption)
                            .foregroundStyle(Color(theme.colors.textMuted))
                        Spacer()
                        Button("Clear", action: configuration.onClearRecentSearches)
                            .font(Font(theme.typography.caption))
                            .foregroundStyle(Color(theme.colors.accent))
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    // MARK: - Grouped results

    private var titleMatches: [SearchResult] {
        configuration.results.filter { $0.matchKind == .titleMatch }
    }

    private var contentMatches: [SearchResult] {
        configuration.results.filter { $0.matchKind == .contentMatch }
    }

    @ViewBuilder
    private var resultsView: some View {
        List {
            if !titleMatches.isEmpty {
                Section("Title Matches") {
                    ForEach(titleMatches) { result in
                        resultRow(result)
                    }
                }
            }
            if !contentMatches.isEmpty {
                Section("Content Matches") {
                    ForEach(contentMatches) { result in
                        resultRow(result)
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func resultRow(_ result: SearchResult) -> some View {
        Button(action: { configuration.onSelectResult(result.noteID) }) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                DFText(result.noteTitle, style: .bodyBold)
                    .foregroundStyle(Color(theme.colors.textPrimary))
                    .lineLimit(1)

                DFText(result.highlightedExcerpt, style: .body)
                    .foregroundStyle(Color(theme.colors.textSecondary))
                    .lineLimit(2)

                // Breadcrumb row: folder · tag1 · tag2 · date
                HStack(spacing: theme.spacing.xs) {
                    if let folderName = result.folderName {
                        DFIcon("folder", size: .sm)
                            .foregroundStyle(Color(theme.colors.textMuted))
                        DFText(folderName, style: .caption)
                            .foregroundStyle(Color(theme.colors.textMuted))
                        DFText("·", style: .caption)
                            .foregroundStyle(Color(theme.colors.textMuted))
                    }
                    ForEach(result.tagNames, id: \.self) { tag in
                        DFBadge(tag, style: .muted)
                    }
                    Spacer()
                    DFText(result.modifiedAt.formatted(.relative(presentation: .named)), style: .caption)
                        .foregroundStyle(Color(theme.colors.textMuted))
                }
            }
            .padding(.vertical, theme.spacing.xs)
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 4: Implement previews**

```swift
// Sources/DesignFoundationScreens/Documents/DFDocumentSearchScreen+Previews.swift
import SwiftUI
import DesignFoundation

private let sampleResults: [DFDocumentSearchScreen.SearchResult] = [
    .init(
        noteID: UUID(),
        noteTitle: "Weekly Review",
        highlightedExcerpt: "…focused on shipping the new onboarding flow and refactoring…",
        matchKind: .titleMatch,
        folderName: "Work",
        tagNames: ["Work"],
        modifiedAt: Date(timeIntervalSinceNow: -3600)
    ),
    .init(
        noteID: UUID(),
        noteTitle: "Product Ideas",
        highlightedExcerpt: "…what if we added a focus timer to the editor? Bear does something similar…",
        matchKind: .contentMatch,
        folderName: "Personal",
        tagNames: ["Ideas"],
        modifiedAt: Date(timeIntervalSinceNow: -86400)
    ),
    .init(
        noteID: UUID(),
        noteTitle: "Book Notes",
        highlightedExcerpt: "…focus on the process, not the outcome. Deep work requires…",
        matchKind: .contentMatch,
        folderName: nil,
        tagNames: [],
        modifiedAt: Date(timeIntervalSinceNow: -172800)
    ),
]

#Preview("Light — with results") {
    DFDocumentSearchScreen(configuration: .init(
        results: sampleResults,
        recentSearches: ["weekly review", "product ideas", "focus timer"]
    ))
    .dfTheme(.default)
}

#Preview("Dark — with results") {
    DFDocumentSearchScreen(configuration: .init(
        results: sampleResults,
        recentSearches: ["weekly review"]
    ))
    .dfTheme(.default)
    .colorScheme(.dark)
}

#Preview("Light — recent searches") {
    DFDocumentSearchScreen(configuration: .init(
        results: [],
        recentSearches: ["weekly review", "product ideas", "focus timer", "deep work"]
    ))
    .dfTheme(.default)
}

#Preview("Light — no results") {
    DFDocumentSearchScreen(configuration: .init(
        results: [],
        recentSearches: []
    ))
    .dfTheme(.default)
}

#Preview("Light — loading") {
    DFDocumentSearchScreen(configuration: .init(
        results: [],
        recentSearches: [],
        isSearching: true
    ))
    .dfTheme(.default)
}
```

- [ ] **Step 5: Run tests — expect green**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFDocumentSearchScreenTests 2>&1 | tail -20
```

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Documents/DFDocumentSearchScreen.swift \
        Sources/DesignFoundationScreens/Documents/DFDocumentSearchScreen+Previews.swift \
        Tests/DesignFoundationScreensTests/Documents/DFDocumentSearchScreenTests.swift
git commit -m "feat(screens): add DFDocumentSearchScreen with grouped results, recent searches, and filter chips"
```

---

## Task 11: Full Test Suite Pass

- [ ] **Run all Documents tests**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter "DFNoteModel|DFAutoSave|DFDocumentBrowser|DFDocumentEditor|DFDocumentSearch" 2>&1 | tail -40
```

Expected: all suites pass with zero failures.

- [ ] **Build for all platforms**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift build 2>&1 | tail -20
xcodebuild -scheme DesignFoundationScreens -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -20
xcodebuild -scheme DesignFoundationScreens -destination 'platform=macOS' build 2>&1 | tail -20
```

Expected: clean build on iOS 18 simulator and macOS.

- [ ] **Commit final verification**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git commit --allow-empty -m "feat(screens): Document/Notes vertical complete — 3 screens, all tests green"
```

---

## Completion Checklist

| Item | Done |
|---|---|
| `DFNoteModel` + `DFTagModel` + `DFFolderModel` | ⬜ |
| `DFAutoSaveState` with debounce + status enum | ⬜ |
| `DFEditorToolbar` formatting toolbar | ⬜ |
| `DFNoteRowView` list row | ⬜ |
| `DFEditorColumnView` editor surface with focus mode | ⬜ |
| `DFFolderSidebarView` expandable folder/tag tree | ⬜ |
| `DFNoteListView` with sort, swipe, skeleton, empty state | ⬜ |
| `DFDocumentBrowserScreen` three-column NavigationSplitView | ⬜ |
| `DFDocumentEditorScreen` full-screen with floating toolbar | ⬜ |
| `DFDocumentSearchScreen` grouped results + recent searches | ⬜ |
| Light + Dark previews for all 3 screens | ⬜ |
| All tests green (`swift test`) | ⬜ |
| Clean build: iOS 18, macOS 15 | ⬜ |
