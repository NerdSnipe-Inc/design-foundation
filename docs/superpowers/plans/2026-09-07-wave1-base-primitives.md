# Wave 1: New Base Primitives Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the 8 new base primitives identified in the catalog gap analysis (`DFRelativeTimeTag`, `DFInlineTagView`, `DFMetadataRow`, `DFAuthorView`, `DFArticleRow`, `DFBottomContainer`, `DFRadioPickerView`, `DFImageGallery`) to the `DesignFoundation` package, each themed, tested, documented, and visible in DFPlayground.

**Architecture:** Every component reads `@Environment(\.dfTheme)` for colors/typography/spacing, exactly like existing primitives (`DFBadge`, `DFAvatar`, `DFDivider`). Per the existing convention documented in `CLAUDE.md` ("DFSlider/DFPicker/DFNavigationBar have no component-token struct — they're thin native-control wrappers with nothing custom-drawn to override"), only the two components with meaningful visual sizing knobs (`DFArticleRow`, `DFBottomContainer`) get a `DFComponentTokens` entry; the other six read spacing/typography/radius tokens directly with no override struct — they don't need the full environment-injected `*Style` protocol machinery `DFBadge`/`DFButton` use, since (like `DFPriceView`/`DFEntityRow`) they have exactly one visual treatment, not multiple swappable styles.

**Tech Stack:** Swift 6, SwiftUI, `swift-testing` (`Testing` framework, matching existing `Tests/DesignFoundationTests` convention — not XCTest).

**Spec:** `docs/superpowers/specs/2026-09-07-catalog-expansion-and-screenshot-pipeline-design.md` (section 3)

## Global Constraints

- Platforms: iOS 18+, macOS 15+, visionOS 2+ (per `Package.swift`) — no APIs gated above these without an explicit `@available` fallback.
- Every new public type/file must compile under `.enableExperimentalFeature("StrictConcurrency")` — value types conform to `Sendable` where they cross environment/binding boundaries.
- Test framework is `Testing` (`import Testing`, `@Suite`, `@Test`, `#expect`) via `@testable import DesignFoundation` — not `XCTest`.
- No new third-party dependencies in this wave (`Package.swift` gets no new `dependencies:` entries).
- Every new public API must get a compiling doc snippet added to `CLAUDE.md`, `AGENTS.md`, and `.cursor/rules/design-foundation.mdc` (all three, kept identical in the API surface they describe) before the plan is done — checked by `.github/workflows/doc-snippets.yml` / `scripts/DocSnippetCheck`.
- Follow existing file layout: `Sources/DesignFoundation/<Category>/<Component>/<Component>.swift` (+ `+Previews.swift`, + `Style.swift` only if the component has more than one visual treatment); tests at `Tests/DesignFoundationTests/<Category>/<Component>Tests.swift` (flat file per component, not nested in a subfolder — matches `Tests/DesignFoundationTests/Primitives/DFBadgeTests.swift`).

---

## Task 1: DFRelativeTimeTag

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/Article/DFRelativeTimeTag.swift`
- Create: `Sources/DesignFoundation/Supplementary/Article/DFRelativeTimeTag+Previews.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFRelativeTimeTagTests.swift`

**Interfaces:**
- Consumes: `DFTheme` (`.default` in tests), `theme.colors.textSecondary`, `theme.typography.caption`
- Produces: `public struct DFRelativeTimeTag: View`, `public init(date: Date, referenceDate: Date = .now)`, `public var formattedText: String { get }` (exposed so tests can assert on the computed string without rendering SwiftUI)

- [ ] **Step 1: Write the failing test**

```swift
// Tests/DesignFoundationTests/Supplementary/DFRelativeTimeTagTests.swift
import Testing
import Foundation
@testable import DesignFoundation

@Suite("DFRelativeTimeTag")
struct DFRelativeTimeTagTests {
    @Test("formats a past date relative to a fixed reference")
    func formatsPastDate() {
        let reference = Date(timeIntervalSince1970: 1_000_000)
        let threeHoursEarlier = reference.addingTimeInterval(-3 * 60 * 60)
        let tag = DFRelativeTimeTag(date: threeHoursEarlier, referenceDate: reference)
        #expect(tag.formattedText.contains("3") || tag.formattedText.lowercased().contains("hour"))
    }

    @Test("formats the same instant as 'now'")
    func formatsNow() {
        let reference = Date(timeIntervalSince1970: 1_000_000)
        let tag = DFRelativeTimeTag(date: reference, referenceDate: reference)
        #expect(!tag.formattedText.isEmpty)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter DFRelativeTimeTagTests`
Expected: FAIL with "cannot find 'DFRelativeTimeTag' in scope"

- [ ] **Step 3: Write minimal implementation**

```swift
// Sources/DesignFoundation/Supplementary/Article/DFRelativeTimeTag.swift
import SwiftUI

public struct DFRelativeTimeTag: View {
    private let date: Date
    private let referenceDate: Date

    @Environment(\.dfTheme) private var theme

    public init(date: Date, referenceDate: Date = .now) {
        self.date = date
        self.referenceDate = referenceDate
    }

    /// The formatted relative-time string (e.g. "3 hours ago"), exposed for testing
    /// without requiring a SwiftUI render pass.
    public var formattedText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: referenceDate)
    }

    public var body: some View {
        Text(formattedText)
            .font(theme.typography.caption.font)
            .foregroundStyle(theme.colors.textSecondary)
            .accessibilityLabel(formattedText)
    }
}
```

```swift
// Sources/DesignFoundation/Supplementary/Article/DFRelativeTimeTag+Previews.swift
import SwiftUI

#Preview("DFRelativeTimeTag") {
    VStack(alignment: .leading, spacing: 8) {
        DFRelativeTimeTag(date: Date().addingTimeInterval(-3 * 60 * 60))
        DFRelativeTimeTag(date: Date().addingTimeInterval(-60 * 60 * 24 * 2))
        DFRelativeTimeTag(date: Date())
    }
    .padding()
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter DFRelativeTimeTagTests`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/Article/DFRelativeTimeTag.swift \
        Sources/DesignFoundation/Supplementary/Article/DFRelativeTimeTag+Previews.swift \
        Tests/DesignFoundationTests/Supplementary/DFRelativeTimeTagTests.swift
git commit -m "feat: add DFRelativeTimeTag primitive"
```

---

## Task 2: DFInlineTagView

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/Article/DFInlineTagView.swift`
- Create: `Sources/DesignFoundation/Supplementary/Article/DFInlineTagView+Previews.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFInlineTagViewTests.swift`

**Interfaces:**
- Consumes: `theme.colors.accent`, `theme.typography.caption`, `theme.spacing.xs`, `theme.radius.full`
- Produces: `public struct DFInlineTagView: View`, `public init(_ text: String)`, `public let text: String` (stored property, public for test assertions)

- [ ] **Step 1: Write the failing test**

```swift
// Tests/DesignFoundationTests/Supplementary/DFInlineTagViewTests.swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFInlineTagView")
struct DFInlineTagViewTests {
    @Test("stores the label text verbatim")
    func storesText() {
        let tag = DFInlineTagView("Design")
        #expect(tag.text == "Design")
    }

    @Test("does not mutate or trim the given text")
    func doesNotTrim() {
        let tag = DFInlineTagView("  Spaced  ")
        #expect(tag.text == "  Spaced  ")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter DFInlineTagViewTests`
Expected: FAIL with "cannot find 'DFInlineTagView' in scope"

- [ ] **Step 3: Write minimal implementation**

```swift
// Sources/DesignFoundation/Supplementary/Article/DFInlineTagView.swift
import SwiftUI

/// A small decorative label pill, distinct from `DFChip`: no selection, dismiss,
/// or interaction state — purely a static category/tag marker.
public struct DFInlineTagView: View {
    public let text: String

    @Environment(\.dfTheme) private var theme

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(theme.typography.caption.font)
            .foregroundStyle(theme.colors.accent)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, 2)
            .background(Capsule().fill(theme.colors.accent.opacity(0.15)))
            .accessibilityLabel(text)
    }
}
```

```swift
// Sources/DesignFoundation/Supplementary/Article/DFInlineTagView+Previews.swift
import SwiftUI

#Preview("DFInlineTagView") {
    HStack {
        DFInlineTagView("Design")
        DFInlineTagView("Swift")
        DFInlineTagView("iOS 26")
    }
    .padding()
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter DFInlineTagViewTests`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/Article/DFInlineTagView.swift \
        Sources/DesignFoundation/Supplementary/Article/DFInlineTagView+Previews.swift \
        Tests/DesignFoundationTests/Supplementary/DFInlineTagViewTests.swift
git commit -m "feat: add DFInlineTagView primitive"
```

---

## Task 3: DFMetadataRow

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/Article/DFMetadataRow.swift`
- Create: `Sources/DesignFoundation/Supplementary/Article/DFMetadataRow+Previews.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFMetadataRowTests.swift`

**Interfaces:**
- Consumes: `theme.colors.textSecondary`, `theme.typography.caption`, `theme.spacing.sm`
- Produces: `public struct DFMetadataItem: Identifiable, Hashable, Sendable` with `public let id: String`, `public let systemImage: String`, `public let label: String`, `public init(id: String = UUID().uuidString, systemImage: String, label: String)`; `public struct DFMetadataRow: View`, `public init(items: [DFMetadataItem])`

- [ ] **Step 1: Write the failing test**

```swift
// Tests/DesignFoundationTests/Supplementary/DFMetadataRowTests.swift
import Testing
@testable import DesignFoundation

@Suite("DFMetadataItem")
struct DFMetadataItemTests {
    @Test("two items with different ids are not equal even with same label")
    func distinctIds() {
        let a = DFMetadataItem(systemImage: "clock", label: "5 min read")
        let b = DFMetadataItem(systemImage: "clock", label: "5 min read")
        #expect(a.id != b.id)
    }

    @Test("explicit id is preserved")
    func explicitId() {
        let item = DFMetadataItem(id: "read-time", systemImage: "clock", label: "5 min read")
        #expect(item.id == "read-time")
        #expect(item.label == "5 min read")
        #expect(item.systemImage == "clock")
    }
}

@Suite("DFMetadataRow")
struct DFMetadataRowTests {
    @Test("holds the items it was given, in order")
    func preservesOrder() {
        let items = [
            DFMetadataItem(id: "1", systemImage: "clock", label: "5 min read"),
            DFMetadataItem(id: "2", systemImage: "eye", label: "1.2k views")
        ]
        let row = DFMetadataRow(items: items)
        #expect(row.items.map(\.id) == ["1", "2"])
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter DFMetadataRowTests`
Expected: FAIL with "cannot find 'DFMetadataItem' in scope"

- [ ] **Step 3: Write minimal implementation**

```swift
// Sources/DesignFoundation/Supplementary/Article/DFMetadataRow.swift
import SwiftUI

public struct DFMetadataItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let systemImage: String
    public let label: String

    public init(id: String = UUID().uuidString, systemImage: String, label: String) {
        self.id = id
        self.systemImage = systemImage
        self.label = label
    }
}

/// A horizontal row of small icon+label metadata items (read time, view count, etc).
public struct DFMetadataRow: View {
    public let items: [DFMetadataItem]

    @Environment(\.dfTheme) private var theme

    public init(items: [DFMetadataItem]) {
        self.items = items
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(items) { item in
                Label(item.label, systemImage: item.systemImage)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
```

```swift
// Sources/DesignFoundation/Supplementary/Article/DFMetadataRow+Previews.swift
import SwiftUI

#Preview("DFMetadataRow") {
    DFMetadataRow(items: [
        DFMetadataItem(systemImage: "clock", label: "5 min read"),
        DFMetadataItem(systemImage: "eye", label: "1.2k views")
    ])
    .padding()
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter DFMetadataRowTests`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/Article/DFMetadataRow.swift \
        Sources/DesignFoundation/Supplementary/Article/DFMetadataRow+Previews.swift \
        Tests/DesignFoundationTests/Supplementary/DFMetadataRowTests.swift
git commit -m "feat: add DFMetadataRow primitive"
```

---

## Task 4: DFAuthorView

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/Article/DFAuthorView.swift`
- Create: `Sources/DesignFoundation/Supplementary/Article/DFAuthorView+Previews.swift`
- Test: `Tests/DesignFoundationTests/Supplementary/DFAuthorViewTests.swift`

**Interfaces:**
- Consumes: `DFAvatar` (`public init(_ initials: String, size: CGFloat = 40, ...)` and `public init(image: Image, size: CGFloat = 40, ...)` from `Sources/DesignFoundation/Primitives/Avatar/DFAvatar.swift`), `theme.typography.label`, `theme.typography.caption`, `theme.colors.textPrimary`, `theme.colors.textSecondary`, `theme.spacing.xs`
- Produces: `public struct DFAuthorView: View`, `public init(initials: String, name: String, subtitle: String? = nil)`, `public init(image: Image, name: String, subtitle: String? = nil)`, `public let name: String`, `public let subtitle: String?`

- [ ] **Step 1: Write the failing test**

```swift
// Tests/DesignFoundationTests/Supplementary/DFAuthorViewTests.swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFAuthorView")
struct DFAuthorViewTests {
    @Test("initials initializer stores name and nil subtitle by default")
    func initialsInitializerDefaults() {
        let view = DFAuthorView(initials: "JL", name: "Jordan Lee")
        #expect(view.name == "Jordan Lee")
        #expect(view.subtitle == nil)
    }

    @Test("initials initializer stores an explicit subtitle")
    func initialsInitializerWithSubtitle() {
        let view = DFAuthorView(initials: "JL", name: "Jordan Lee", subtitle: "Staff Writer")
        #expect(view.subtitle == "Staff Writer")
    }

    @Test("image initializer stores name")
    func imageInitializerStoresName() {
        let view = DFAuthorView(image: Image(systemName: "person.fill"), name: "Jordan Lee")
        #expect(view.name == "Jordan Lee")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter DFAuthorViewTests`
Expected: FAIL with "cannot find 'DFAuthorView' in scope"

- [ ] **Step 3: Write minimal implementation**

```swift
// Sources/DesignFoundation/Supplementary/Article/DFAuthorView.swift
import SwiftUI

/// Avatar + name (+ optional subtitle), an inline unit reusable standalone
/// (e.g. article bylines) or inside `DFArticleRow`.
public struct DFAuthorView: View {
    private enum Source {
        case initials(String)
        case image(Image)
    }

    private let source: Source
    public let name: String
    public let subtitle: String?

    @Environment(\.dfTheme) private var theme

    public init(initials: String, name: String, subtitle: String? = nil) {
        self.source = .initials(initials)
        self.name = name
        self.subtitle = subtitle
    }

    public init(image: Image, name: String, subtitle: String? = nil) {
        self.source = .image(image)
        self.name = name
        self.subtitle = subtitle
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            avatar
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .font(theme.typography.label.font)
                    .foregroundStyle(theme.colors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var avatar: some View {
        switch source {
        case .initials(let initials):
            DFAvatar(initials, size: 32, accessibilityName: name)
        case .image(let image):
            DFAvatar(image: image, size: 32, accessibilityName: name)
        }
    }
}
```

```swift
// Sources/DesignFoundation/Supplementary/Article/DFAuthorView+Previews.swift
import SwiftUI

#Preview("DFAuthorView") {
    VStack(alignment: .leading, spacing: 16) {
        DFAuthorView(initials: "JL", name: "Jordan Lee", subtitle: "Staff Writer")
        DFAuthorView(initials: "AK", name: "Amara Khan")
    }
    .padding()
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter DFAuthorViewTests`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/Article/DFAuthorView.swift \
        Sources/DesignFoundation/Supplementary/Article/DFAuthorView+Previews.swift \
        Tests/DesignFoundationTests/Supplementary/DFAuthorViewTests.swift
git commit -m "feat: add DFAuthorView primitive"
```

---

## Task 5: DFArticleRow + DFArticleRowTokens

**Files:**
- Create: `Sources/DesignFoundation/Supplementary/Article/DFArticleRow.swift`
- Create: `Sources/DesignFoundation/Supplementary/Article/DFArticleRow+Previews.swift`
- Modify: `Sources/DesignFoundation/Core/Theme/DFComponentTokens.swift` — add `DFArticleRowTokens` struct and wire it into `DFComponentTokens`
- Test: `Tests/DesignFoundationTests/Supplementary/DFArticleRowTests.swift`
- Test: `Tests/DesignFoundationTests/Core/DFComponentTokensTests.swift` (modify if it exists, else create — check first with `find Tests/DesignFoundationTests/Core -iname '*ComponentTokens*'`)

**Interfaces:**
- Consumes: `DFAuthorView` (Task 4), `DFRelativeTimeTag` (Task 1), `DFInlineTagView` (Task 2), `theme.typography.headline`, `theme.spacing.xs`, `theme.components.articleRow`
- Produces: `public struct DFArticleRowTokens: Sendable` with `public var titleLines: Int?` (nil = 2), `public init(titleLines: Int? = nil)`, `public static let default = DFArticleRowTokens()`; `DFComponentTokens.articleRow: DFArticleRowTokens` field; `public struct DFArticleRow: View`, `public init(title: String, authorName: String, authorInitials: String, date: Date, tags: [String] = [])`, `public init(title: String, authorName: String, authorImage: Image, date: Date, tags: [String] = [])`

- [ ] **Step 1: Write the failing test for the token struct**

```swift
// Tests/DesignFoundationTests/Core/DFArticleRowTokensTests.swift
import Testing
@testable import DesignFoundation

@Suite("DFArticleRowTokens")
struct DFArticleRowTokensTests {
    @Test("default has nil titleLines (inherits 2-line default)")
    func defaultIsNil() {
        #expect(DFArticleRowTokens.default.titleLines == nil)
    }

    @Test("component tokens expose an articleRow field defaulting to .default")
    func componentTokensDefault() {
        let tokens = DFComponentTokens.default
        #expect(tokens.articleRow.titleLines == nil)
    }

    @Test("custom titleLines override is preserved")
    func customOverride() {
        var theme = DFTheme.default
        theme.components.articleRow = DFArticleRowTokens(titleLines: 1)
        #expect(theme.components.articleRow.titleLines == 1)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter DFArticleRowTokensTests`
Expected: FAIL with "cannot find type 'DFArticleRowTokens' in scope"

- [ ] **Step 3: Add the token struct to `DFComponentTokens.swift`**

Add this new section immediately after the `// MARK: - TabBar` section (before `// MARK: - Root`) in `Sources/DesignFoundation/Core/Theme/DFComponentTokens.swift`:

```swift
// MARK: - ArticleRow

public struct DFArticleRowTokens: Sendable {
    public var titleLines: Int?   // nil = 2

    public init(titleLines: Int? = nil) {
        self.titleLines = titleLines
    }

    public static let `default` = DFArticleRowTokens()
}
```

Then in `DFComponentTokens` itself, add the field, init parameter, and assignment (matching the existing pattern for every other field):

```swift
// In the property list, after `public var tabBar: DFTabBarTokens`:
    public var articleRow: DFArticleRowTokens

// In the init signature, after `tabBar: DFTabBarTokens = .default`:
        articleRow: DFArticleRowTokens = .default

// In the init body, after `self.tabBar = tabBar`:
        self.articleRow = articleRow
```

- [ ] **Step 4: Run token tests to verify they pass**

Run: `swift test --filter DFArticleRowTokensTests`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit the tokens**

```bash
git add Sources/DesignFoundation/Core/Theme/DFComponentTokens.swift \
        Tests/DesignFoundationTests/Core/DFArticleRowTokensTests.swift
git commit -m "feat: add DFArticleRowTokens to DFComponentTokens"
```

- [ ] **Step 6: Write the failing test for DFArticleRow**

```swift
// Tests/DesignFoundationTests/Supplementary/DFArticleRowTests.swift
import Testing
import Foundation
import SwiftUI
@testable import DesignFoundation

@Suite("DFArticleRow")
struct DFArticleRowTests {
    @Test("initials initializer defaults to no tags")
    func initialsInitializerDefaultTags() {
        let row = DFArticleRow(
            title: "SwiftUI in 2026",
            authorName: "Jordan Lee",
            authorInitials: "JL",
            date: .now
        )
        #expect(row.title == "SwiftUI in 2026")
        #expect(row.tags.isEmpty)
    }

    @Test("stores explicit tags in order")
    func storesTags() {
        let row = DFArticleRow(
            title: "SwiftUI in 2026",
            authorName: "Jordan Lee",
            authorInitials: "JL",
            date: .now,
            tags: ["Swift", "iOS 26"]
        )
        #expect(row.tags == ["Swift", "iOS 26"])
    }

    @Test("image initializer stores the title")
    func imageInitializerStoresTitle() {
        let row = DFArticleRow(
            title: "SwiftUI in 2026",
            authorName: "Jordan Lee",
            authorImage: Image(systemName: "person.fill"),
            date: .now
        )
        #expect(row.title == "SwiftUI in 2026")
    }
}
```

- [ ] **Step 7: Run test to verify it fails**

Run: `swift test --filter DFArticleRowTests`
Expected: FAIL with "cannot find 'DFArticleRow' in scope"

- [ ] **Step 8: Write minimal implementation**

```swift
// Sources/DesignFoundation/Supplementary/Article/DFArticleRow.swift
import SwiftUI

/// Title + author + relative time + tags row, for feeds/news/docs lists.
public struct DFArticleRow: View {
    private enum AuthorSource {
        case initials(String)
        case image(Image)
    }

    public let title: String
    private let authorName: String
    private let authorSource: AuthorSource
    private let date: Date
    public let tags: [String]

    @Environment(\.dfTheme) private var theme

    public init(
        title: String,
        authorName: String,
        authorInitials: String,
        date: Date,
        tags: [String] = []
    ) {
        self.title = title
        self.authorName = authorName
        self.authorSource = .initials(authorInitials)
        self.date = date
        self.tags = tags
    }

    public init(
        title: String,
        authorName: String,
        authorImage: Image,
        date: Date,
        tags: [String] = []
    ) {
        self.title = title
        self.authorName = authorName
        self.authorSource = .image(authorImage)
        self.date = date
        self.tags = tags
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.headline.font)
                .lineLimit(theme.components.articleRow.titleLines ?? 2)

            HStack(spacing: theme.spacing.xs) {
                author
                DFRelativeTimeTag(date: date)
            }

            if !tags.isEmpty {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(tags, id: \.self) { tag in
                        DFInlineTagView(tag)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var author: some View {
        switch authorSource {
        case .initials(let initials):
            DFAuthorView(initials: initials, name: authorName)
        case .image(let image):
            DFAuthorView(image: image, name: authorName)
        }
    }
}
```

```swift
// Sources/DesignFoundation/Supplementary/Article/DFArticleRow+Previews.swift
import SwiftUI

#Preview("DFArticleRow") {
    VStack(alignment: .leading, spacing: 24) {
        DFArticleRow(
            title: "SwiftUI in 2026: What Changed",
            authorName: "Jordan Lee",
            authorInitials: "JL",
            date: Date().addingTimeInterval(-3 * 60 * 60),
            tags: ["Swift", "iOS 26"]
        )
        DFArticleRow(
            title: "A Quiet Release",
            authorName: "Amara Khan",
            authorInitials: "AK",
            date: Date().addingTimeInterval(-60 * 60 * 24 * 2)
        )
    }
    .padding()
}
```

- [ ] **Step 9: Run test to verify it passes**

Run: `swift test --filter DFArticleRowTests`
Expected: PASS (3 tests)

- [ ] **Step 10: Commit**

```bash
git add Sources/DesignFoundation/Supplementary/Article/DFArticleRow.swift \
        Sources/DesignFoundation/Supplementary/Article/DFArticleRow+Previews.swift \
        Tests/DesignFoundationTests/Supplementary/DFArticleRowTests.swift
git commit -m "feat: add DFArticleRow primitive"
```

---

## Task 6: DFBottomContainer + DFBottomContainerTokens

**Files:**
- Create: `Sources/DesignFoundation/Layouts/BottomContainer/DFBottomContainer.swift`
- Create: `Sources/DesignFoundation/Layouts/BottomContainer/DFBottomContainer+Previews.swift`
- Modify: `Sources/DesignFoundation/Core/Theme/DFComponentTokens.swift` — add `DFBottomContainerTokens`
- Test: `Tests/DesignFoundationTests/Core/DFBottomContainerTokensTests.swift`
- Test: `Tests/DesignFoundationTests/Layouts/DFBottomContainerTests.swift`

**Interfaces:**
- Consumes: `theme.colors.surface`, `theme.colors.border`, `theme.spacing.md`, `theme.radius.lg`
- Produces: `public struct DFBottomContainerTokens: Sendable` with `public var padding: CGFloat?` (nil = inherit `theme.spacing.md`), `public var cornerRadius: CGFloat?` (nil = inherit `theme.radius.lg`); `DFComponentTokens.bottomContainer` field; `public extension View { func dfBottomBar<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View }`

- [ ] **Step 1: Write the failing test for the token struct**

```swift
// Tests/DesignFoundationTests/Core/DFBottomContainerTokensTests.swift
import Testing
@testable import DesignFoundation

@Suite("DFBottomContainerTokens")
struct DFBottomContainerTokensTests {
    @Test("default has nil padding and cornerRadius")
    func defaultsAreNil() {
        #expect(DFBottomContainerTokens.default.padding == nil)
        #expect(DFBottomContainerTokens.default.cornerRadius == nil)
    }

    @Test("component tokens expose a bottomContainer field")
    func componentTokensDefault() {
        #expect(DFComponentTokens.default.bottomContainer.padding == nil)
    }

    @Test("custom override is preserved")
    func customOverride() {
        var theme = DFTheme.default
        theme.components.bottomContainer = DFBottomContainerTokens(padding: 20)
        #expect(theme.components.bottomContainer.padding == 20)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter DFBottomContainerTokensTests`
Expected: FAIL with "cannot find type 'DFBottomContainerTokens' in scope"

- [ ] **Step 3: Add the token struct to `DFComponentTokens.swift`**

Add after the `DFArticleRowTokens` section added in Task 5:

```swift
// MARK: - BottomContainer

public struct DFBottomContainerTokens: Sendable {
    public var padding: CGFloat?        // nil = inherit DFSpacingTokens.md
    public var cornerRadius: CGFloat?   // nil = inherit DFRadiusTokens.lg

    public init(padding: CGFloat? = nil, cornerRadius: CGFloat? = nil) {
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    public static let `default` = DFBottomContainerTokens()
}
```

Add `public var bottomContainer: DFBottomContainerTokens` to the property list, `bottomContainer: DFBottomContainerTokens = .default` to the init signature, and `self.bottomContainer = bottomContainer` to the init body — same pattern as `articleRow` in Task 5.

- [ ] **Step 4: Run token tests to verify they pass**

Run: `swift test --filter DFBottomContainerTokensTests`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit the tokens**

```bash
git add Sources/DesignFoundation/Core/Theme/DFComponentTokens.swift \
        Tests/DesignFoundationTests/Core/DFBottomContainerTokensTests.swift
git commit -m "feat: add DFBottomContainerTokens to DFComponentTokens"
```

- [ ] **Step 6: Write the failing test for the modifier**

The modifier itself has no observable state to assert on beyond "it compiles and applies to a view" — SwiftUI view modifiers are tested by construction, matching how `Tests/DesignFoundationTests/Overlays` tests other modifier-only APIs (check one, e.g. `find Tests/DesignFoundationTests/Overlays -iname '*.swift' | head -1` and follow its pattern). Write:

```swift
// Tests/DesignFoundationTests/Layouts/DFBottomContainerTests.swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFBottomContainer")
struct DFBottomContainerTests {
    @Test("dfBottomBar modifier compiles and can be applied to any view")
    @MainActor
    func modifierApplies() {
        let view = Text("Content")
            .dfBottomBar {
                Text("Bottom bar")
            }
        #expect(view is any View)
    }
}
```

- [ ] **Step 7: Run test to verify it fails**

Run: `swift test --filter DFBottomContainerTests`
Expected: FAIL with "value of type 'Text' has no member 'dfBottomBar'"

- [ ] **Step 8: Write minimal implementation**

```swift
// Sources/DesignFoundation/Layouts/BottomContainer/DFBottomContainer.swift
import SwiftUI

private struct DFBottomContainerModifier<BarContent: View>: ViewModifier {
    @ViewBuilder let barContent: () -> BarContent

    @Environment(\.dfTheme) private var theme

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            barContent()
                .padding(theme.components.bottomContainer.padding ?? theme.spacing.md)
                .frame(maxWidth: .infinity)
                .background(
                    theme.colors.surface,
                    in: RoundedRectangle(
                        cornerRadius: theme.components.bottomContainer.cornerRadius ?? theme.radius.lg
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: theme.components.bottomContainer.cornerRadius ?? theme.radius.lg
                    )
                    .stroke(theme.colors.border, lineWidth: 0.5)
                )
        }
    }
}

public extension View {
    /// Pins `content` (e.g. a "Continue" CTA or checkout total bar) to the bottom
    /// of this view, on a themed surface.
    func dfBottomBar<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(DFBottomContainerModifier(barContent: content))
    }
}
```

```swift
// Sources/DesignFoundation/Layouts/BottomContainer/DFBottomContainer+Previews.swift
import SwiftUI

#Preview("DFBottomContainer") {
    ScrollView {
        VStack {
            ForEach(0..<10) { i in
                Text("Row \(i)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
    }
    .dfBottomBar {
        DFButton("Continue") { }
    }
}
```

- [ ] **Step 9: Run test to verify it passes**

Run: `swift test --filter DFBottomContainerTests`
Expected: PASS (1 test)

- [ ] **Step 10: Commit**

```bash
git add Sources/DesignFoundation/Layouts/BottomContainer/DFBottomContainer.swift \
        Sources/DesignFoundation/Layouts/BottomContainer/DFBottomContainer+Previews.swift \
        Tests/DesignFoundationTests/Layouts/DFBottomContainerTests.swift
git commit -m "feat: add DFBottomContainer / dfBottomBar modifier"
```

---

## Task 7: DFRadioPickerView

**Files:**
- Create: `Sources/DesignFoundation/Inputs/RadioPicker/DFRadioPickerView.swift`
- Create: `Sources/DesignFoundation/Inputs/RadioPicker/DFRadioPickerView+Previews.swift`
- Test: `Tests/DesignFoundationTests/Inputs/DFRadioPickerViewTests.swift`

**Interfaces:**
- Consumes: `theme.colors.primary`, `theme.colors.border`, `theme.colors.textPrimary`, `theme.spacing.sm`, `theme.spacing.md`
- Produces: `public struct DFRadioPickerOption: Identifiable, Hashable, Sendable` with `public let id: String`, `public let label: String`, `public init(id: String, label: String)`; `public struct DFRadioPickerView: View`, `public init(options: [DFRadioPickerOption], selection: Binding<String>)`

- [ ] **Step 1: Write the failing test**

```swift
// Tests/DesignFoundationTests/Inputs/DFRadioPickerViewTests.swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFRadioPickerOption")
struct DFRadioPickerOptionTests {
    @Test("stores id and label")
    func storesFields() {
        let option = DFRadioPickerOption(id: "sm", label: "Small")
        #expect(option.id == "sm")
        #expect(option.label == "Small")
    }
}

@Suite("DFRadioPickerView")
struct DFRadioPickerViewTests {
    @Test("selecting an option updates the binding")
    @MainActor
    func selectionUpdatesBinding() {
        var selected = "sm"
        let binding = Binding<String>(get: { selected }, set: { selected = $0 })
        let options = [
            DFRadioPickerOption(id: "sm", label: "Small"),
            DFRadioPickerOption(id: "lg", label: "Large")
        ]
        let view = DFRadioPickerView(options: options, selection: binding)
        view.select(optionID: "lg")
        #expect(selected == "lg")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter DFRadioPickerViewTests`
Expected: FAIL with "cannot find 'DFRadioPickerOption' in scope"

- [ ] **Step 3: Write minimal implementation**

```swift
// Sources/DesignFoundation/Inputs/RadioPicker/DFRadioPickerView.swift
import SwiftUI

public struct DFRadioPickerOption: Identifiable, Hashable, Sendable {
    public let id: String
    public let label: String

    public init(id: String, label: String) {
        self.id = id
        self.label = label
    }
}

/// A single-select list of labeled radio rows — an inline list, distinct from
/// `DFPicker`'s menu/wheel presentation.
public struct DFRadioPickerView: View {
    private let options: [DFRadioPickerOption]
    private let selection: Binding<String>

    @Environment(\.dfTheme) private var theme

    public init(options: [DFRadioPickerOption], selection: Binding<String>) {
        self.options = options
        self.selection = selection
    }

    /// Programmatically selects the option with the given id — exposed so callers
    /// (and tests) can drive selection without simulating a tap gesture.
    public func select(optionID: String) {
        selection.wrappedValue = optionID
    }

    public var body: some View {
        VStack(spacing: theme.spacing.sm) {
            ForEach(options) { option in
                Button {
                    select(optionID: option.id)
                } label: {
                    HStack {
                        Text(option.label)
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer()
                        Image(systemName: selection.wrappedValue == option.id ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(
                                selection.wrappedValue == option.id ? theme.colors.primary : theme.colors.border
                            )
                    }
                    .padding(theme.spacing.md)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection.wrappedValue == option.id ? [.isSelected] : [])
            }
        }
    }
}
```

```swift
// Sources/DesignFoundation/Inputs/RadioPicker/DFRadioPickerView+Previews.swift
import SwiftUI

private struct DFRadioPickerViewPreview: View {
    @State private var selection = "sm"

    var body: some View {
        DFRadioPickerView(
            options: [
                DFRadioPickerOption(id: "sm", label: "Small"),
                DFRadioPickerOption(id: "md", label: "Medium"),
                DFRadioPickerOption(id: "lg", label: "Large")
            ],
            selection: $selection
        )
        .padding()
    }
}

#Preview("DFRadioPickerView") {
    DFRadioPickerViewPreview()
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter DFRadioPickerViewTests`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Inputs/RadioPicker/DFRadioPickerView.swift \
        Sources/DesignFoundation/Inputs/RadioPicker/DFRadioPickerView+Previews.swift \
        Tests/DesignFoundationTests/Inputs/DFRadioPickerViewTests.swift
git commit -m "feat: add DFRadioPickerView primitive"
```

---

## Task 8: DFImageGallery

**Files:**
- Create: `Sources/DesignFoundation/Overlays/ImageGallery/DFImageGallery.swift`
- Create: `Sources/DesignFoundation/Overlays/ImageGallery/DFImageGallery+Previews.swift`
- Test: `Tests/DesignFoundationTests/Overlays/DFImageGalleryTests.swift`

**Interfaces:**
- Consumes: `theme.colors.background` (full-screen backdrop)
- Produces: `public extension View { func dfImageGallery(isPresented: Binding<Bool>, images: [Image], initialIndex: Int = 0) -> some View }`

- [ ] **Step 1: Write the failing test**

```swift
// Tests/DesignFoundationTests/Overlays/DFImageGalleryTests.swift
import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFImageGallery")
struct DFImageGalleryTests {
    @Test("dfImageGallery modifier compiles and can be applied to any view")
    @MainActor
    func modifierApplies() {
        let isPresented = Binding<Bool>(get: { false }, set: { _ in })
        let view = Text("Content")
            .dfImageGallery(isPresented: isPresented, images: [Image(systemName: "photo")])
        #expect(view is any View)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter DFImageGalleryTests`
Expected: FAIL with "value of type 'Text' has no member 'dfImageGallery'"

- [ ] **Step 3: Write minimal implementation**

```swift
// Sources/DesignFoundation/Overlays/ImageGallery/DFImageGallery.swift
import SwiftUI

private struct DFImageGalleryView: View {
    let images: [Image]
    @State var currentIndex: Int
    @Binding var isPresented: Bool

    @Environment(\.dfTheme) private var theme

    var body: some View {
        ZStack(alignment: .topTrailing) {
            theme.colors.background.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    images[index]
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                }
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .always))
            #endif

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white, .black.opacity(0.4))
            }
            .padding()
            .accessibilityLabel("Close")
        }
    }
}

private struct DFImageGalleryModifier: ViewModifier {
    @Binding var isPresented: Bool
    let images: [Image]
    let initialIndex: Int

    func body(content: Content) -> some View {
        #if os(iOS) || os(visionOS)
        content.fullScreenCover(isPresented: $isPresented) {
            DFImageGalleryView(images: images, currentIndex: initialIndex, isPresented: $isPresented)
        }
        #else
        content.sheet(isPresented: $isPresented) {
            DFImageGalleryView(images: images, currentIndex: initialIndex, isPresented: $isPresented)
        }
        #endif
    }
}

public extension View {
    /// Presents a full-screen swipeable image viewer with a page indicator.
    func dfImageGallery(isPresented: Binding<Bool>, images: [Image], initialIndex: Int = 0) -> some View {
        modifier(DFImageGalleryModifier(isPresented: isPresented, images: images, initialIndex: initialIndex))
    }
}
```

```swift
// Sources/DesignFoundation/Overlays/ImageGallery/DFImageGallery+Previews.swift
import SwiftUI

private struct DFImageGalleryPreview: View {
    @State private var isPresented = false

    var body: some View {
        DFButton("Open Gallery") { isPresented = true }
            .dfImageGallery(
                isPresented: $isPresented,
                images: [
                    Image(systemName: "photo"),
                    Image(systemName: "photo.fill"),
                    Image(systemName: "photo.on.rectangle")
                ]
            )
    }
}

#Preview("DFImageGallery") {
    DFImageGalleryPreview()
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter DFImageGalleryTests`
Expected: PASS (1 test)

- [ ] **Step 5: Commit**

```bash
git add Sources/DesignFoundation/Overlays/ImageGallery/DFImageGallery.swift \
        Sources/DesignFoundation/Overlays/ImageGallery/DFImageGallery+Previews.swift \
        Tests/DesignFoundationTests/Overlays/DFImageGalleryTests.swift
git commit -m "feat: add DFImageGallery / dfImageGallery modifier"
```

---

## Task 9: DFPlayground gallery screen for the new primitives

**Files:**
- Create: `/Users/nerdsnipe/Projects/DFPlayground/Sources/DFPlayground/Screens/ContentPrimitivesScreen.swift`
- Modify: `/Users/nerdsnipe/Projects/DFPlayground/Sources/DFPlayground/ContentView.swift`
- Modify: `/Users/nerdsnipe/Projects/DFPlayground/Package.swift` is unaffected (already depends on `design-foundation` by local path — no change needed; verify by running `swift build` from `/Users/nerdsnipe/Projects/DFPlayground` after this task).

**Interfaces:**
- Consumes: every component from Tasks 1–8 (`DFRelativeTimeTag`, `DFInlineTagView`, `DFMetadataRow`/`DFMetadataItem`, `DFAuthorView`, `DFArticleRow`, `.dfBottomBar`, `DFRadioPickerView`/`DFRadioPickerOption`, `.dfImageGallery`), plus the existing `DemoSection` helper used by other screens (check its signature: `grep -n "struct DemoSection" -r /Users/nerdsnipe/Projects/DFPlayground/Sources/DFPlayground`)
- Produces: `struct ContentPrimitivesScreen: View` registered under a new `PlaygroundTab.contentPrimitives` case

This task has no automated test — DFPlayground is a manual-verification catalog app, matching every other screen in it. The deliverable is verified by building and running the app.

- [ ] **Step 1: Check `DemoSection`'s exact signature before writing the screen**

Run: `grep -n -A3 "struct DemoSection" /Users/nerdsnipe/Projects/DFPlayground/Sources/DFPlayground/*.swift`

Use whatever initializer it shows (it takes a title and a `@ViewBuilder` content closure, per its usage in `DividersScreen.swift` shown above: `DemoSection("Standard horizontal") { ... }`) — the code below assumes that exact shape; adjust only if the grep shows a different one.

- [ ] **Step 2: Write the new screen**

```swift
// /Users/nerdsnipe/Projects/DFPlayground/Sources/DFPlayground/Screens/ContentPrimitivesScreen.swift
import SwiftUI
import DesignFoundation

struct ContentPrimitivesScreen: View {
    @State private var radioSelection = "sm"
    @State private var galleryPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {

                DemoSection("Article Row") {
                    DFArticleRow(
                        title: "SwiftUI in 2026: What Changed",
                        authorName: "Jordan Lee",
                        authorInitials: "JL",
                        date: Date().addingTimeInterval(-3 * 60 * 60),
                        tags: ["Swift", "iOS 26"]
                    )
                }

                DemoSection("Author View") {
                    DFAuthorView(initials: "AK", name: "Amara Khan", subtitle: "Staff Writer")
                }

                DemoSection("Relative Time Tag") {
                    DFRelativeTimeTag(date: Date().addingTimeInterval(-60 * 60 * 24 * 2))
                }

                DemoSection("Inline Tag") {
                    HStack {
                        DFInlineTagView("Design")
                        DFInlineTagView("Swift")
                    }
                }

                DemoSection("Metadata Row") {
                    DFMetadataRow(items: [
                        DFMetadataItem(systemImage: "clock", label: "5 min read"),
                        DFMetadataItem(systemImage: "eye", label: "1.2k views")
                    ])
                }

                DemoSection("Radio Picker") {
                    DFRadioPickerView(
                        options: [
                            DFRadioPickerOption(id: "sm", label: "Small"),
                            DFRadioPickerOption(id: "md", label: "Medium"),
                            DFRadioPickerOption(id: "lg", label: "Large")
                        ],
                        selection: $radioSelection
                    )
                }

                DemoSection("Image Gallery") {
                    DFButton("Open Gallery") { galleryPresented = true }
                        .dfImageGallery(
                            isPresented: $galleryPresented,
                            images: [
                                Image(systemName: "photo"),
                                Image(systemName: "photo.fill"),
                                Image(systemName: "photo.on.rectangle")
                            ]
                        )
                }

                DemoSection("Bottom Container") {
                    VStack {
                        Text("Scrollable content above a pinned bar")
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .dfBottomBar {
                        DFButton("Continue") { }
                    }
                }
            }
            .padding()
        }
    }
}
```

- [ ] **Step 3: Register the screen in `ContentView.swift`**

In `PlaygroundTab`, add a new case after `.navigation`:

```swift
    case contentPrimitives = "Content & Media"
```

In `PlaygroundTab.icon`, add a matching case:

```swift
        case .contentPrimitives: return "text.below.photo"
```

In `ContentView.primitiveView(for:)`, add:

```swift
        case .contentPrimitives: ContentPrimitivesScreen()
```

- [ ] **Step 4: Build to verify it compiles and run to visually verify**

Run: `cd /Users/nerdsnipe/Projects/DFPlayground && swift build`
Expected: builds with no errors.

Then run the app (via Xcode or `swift run DFPlayground` if it's runnable headless — DFPlayground is a SwiftUI app, so prefer opening `DFPlayground.xcworkspace` and running the `DFPlayground` scheme on macOS), navigate to "Content & Media" in the sidebar, and visually confirm all 8 sections render without layout breakage in both a light and a dark theme preset (use the existing `ThemePickerView` to switch).

- [ ] **Step 5: Commit**

```bash
cd /Users/nerdsnipe/Projects/DFPlayground
git add Sources/DFPlayground/Screens/ContentPrimitivesScreen.swift Sources/DFPlayground/ContentView.swift
git commit -m "feat: add Content & Media gallery for Wave 1 primitives"
```

---

## Task 10: Documentation sync (CLAUDE.md, AGENTS.md, .cursor rule)

**Files:**
- Modify: `/Users/nerdsnipe/Projects/DesignFoundation/CLAUDE.md`
- Modify: `/Users/nerdsnipe/Projects/DesignFoundation/AGENTS.md`
- Modify: `/Users/nerdsnipe/Projects/DesignFoundation/.cursor/rules/design-foundation.mdc`

**Interfaces:**
- Consumes: the finished public APIs from Tasks 1–8 (exact signatures as written in those tasks — do not paraphrase them).

This is documentation-only; "testing" is the existing doc-snippet compile check.

- [ ] **Step 1: Add a new "Content & Article" section to `CLAUDE.md`**

Insert this new section into `CLAUDE.md` immediately after the "### Calendar" section and before "### Empty States" (matching the file's existing section ordering by category):

```markdown
### Content & Article Primitives
```swift
// DFAuthorView — avatar + name (+ optional subtitle), reusable standalone or inside DFArticleRow
DFAuthorView(initials: "JL", name: "Jordan Lee", subtitle: "Staff Writer")
DFAuthorView(image: Image("avatar"), name: "Jordan Lee")

// DFRelativeTimeTag — "3 hours ago" style tag, formats via RelativeDateTimeFormatter
DFRelativeTimeTag(date: publishedDate)

// DFInlineTagView — decorative category pill, distinct from DFChip (no selection/dismiss state)
DFInlineTagView("Design")

// DFMetadataRow — row of small icon+label metadata items (read time, views, etc)
DFMetadataRow(items: [
    DFMetadataItem(systemImage: "clock", label: "5 min read"),
    DFMetadataItem(systemImage: "eye", label: "1.2k views"),
])

// DFArticleRow — title + author + relative time + tags, for feeds/news/docs lists
DFArticleRow(
    title: "SwiftUI in 2026: What Changed",
    authorName: "Jordan Lee",
    authorInitials: "JL",
    date: publishedDate,
    tags: ["Swift", "iOS 26"]
)
```

### Bottom Container
```swift
// dfBottomBar — pins content (checkout totals, a "Continue" CTA) to the bottom of a view on a themed surface
ScrollView { /* ... */ }
    .dfBottomBar {
        DFButton("Continue") { }
    }
```

### Radio Picker
```swift
// DFRadioPickerView — single-select inline list of labeled radio rows, distinct from
// DFPicker's menu/wheel presentation
DFRadioPickerView(
    options: [
        DFRadioPickerOption(id: "sm", label: "Small"),
        DFRadioPickerOption(id: "lg", label: "Large"),
    ],
    selection: $sizeSelection
)
```

### Image Gallery
```swift
// dfImageGallery — full-screen swipeable image viewer with page indicator
YourContentView()
    .dfImageGallery(isPresented: $showGallery, images: [image1, image2, image3])
```
```

- [ ] **Step 2: Mirror the exact same content into `AGENTS.md`**

`AGENTS.md` mirrors `CLAUDE.md`'s API reference verbatim per its own header comment — copy the same four new sections from Step 1 into the equivalent position in `AGENTS.md`.

- [ ] **Step 3: Mirror the exact same content into `.cursor/rules/design-foundation.mdc`**

Copy the same four new sections into the equivalent position in `.cursor/rules/design-foundation.mdc`, matching that file's existing heading style.

- [ ] **Step 4: Run the doc snippet check**

Run: `python3 scripts/DocSnippetCheck/check_doc_snippets.py` (or whatever the exact invocation is — check `.github/workflows/doc-snippets.yml` first with `cat .github/workflows/doc-snippets.yml` for the exact command it runs in CI, and run that same command locally).
Expected: exits 0 with all snippets compiling, including the ones just added.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md AGENTS.md .cursor/rules/design-foundation.mdc
git commit -m "docs: document Wave 1 primitives (article/author/tags/metadata, bottom bar, radio picker, image gallery)"
```

---

## Task 11: Run the screenshot subagent for this wave

Per the spec (section 6, Wave 1), end this wave with a catalog check even though the full screenshot pipeline (Wave 2) doesn't exist yet — at this stage that means confirming DFPlayground builds cleanly with everything from Tasks 1–9 wired in, since there is no `df-screenshot-cataloger` subagent or snapshot-test infrastructure until Wave 2 is implemented.

- [ ] **Step 1: Full build check across all three repos**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundation && swift build && swift test
cd /Users/nerdsnipe/Projects/DFPlayground && swift build
```

Expected: all three commands exit 0.

- [ ] **Step 2: Note in the PR/commit description (if opening a PR) that Wave 2 (screenshot pipeline) is the next plan**

No code change — this is a checkpoint, not a commit.
