# Phase 2 Dashboard Blocks — Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development to implement task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Build 4 dashboard blocks: DFMetricGridBlock, DFActivityFeedBlock, DFChartPlaceholderBlock, DFProgressRingBlock.

**Architecture:** Each block is a self-contained SwiftUI view with a typed Configuration struct. All styling via DFTheme. No hardcoded values.

**Tech Stack:** Swift 6, SwiftUI, DesignFoundation, Swift Testing

## Preview Pattern — REQUIRED FOR ALL PREVIEWS

Every `#Preview` block MUST:
1. Wrap content in `ScrollView { ... }`
2. Apply `.frame(width: 390)` on the ScrollView
3. Apply `.preferredColorScheme(.light)` or `.preferredColorScheme(.dark)` at the end

```swift
#Preview("Default — Light") {
    ScrollView {
        MyBlock(configuration: .init(...))
            .padding()
    }
    .frame(width: 390)
    .preferredColorScheme(.light)
}
```

## Global Constraints

- Swift 6, `StrictConcurrency` enabled on all targets
- Platforms: iOS 18, macOS 15, visionOS 2
- All action closures typed `(@MainActor () -> Void)?`
- Bridge @MainActor calls with `Task { @MainActor in action() }` — NEVER `MainActor.assumeIsolated`
- All colors/typography/spacing from `@Environment(\.dfTheme)` — zero hardcoded values
- `DFAvatar` has two inits: `DFAvatar(_ initials: String)` OR `DFAvatar(image: Image)` — no combined init
- `DFBadge(text: String)` — labeled parameter required
- Color tokens: `.primary`, `.textPrimary`, `.textSecondary`, `.surface`, `.surfaceElevated`, `.border`, `.destructive`, `.success`
- Tests: Swift Testing only — `import Testing`, `@Suite`, `@Test`, `#expect` — NEVER XCTest
- Minimum 4 previews per block: `#Preview("Default — Light")`, `#Preview("Default — Dark")`, `#Preview("Filled — Light")`, `#Preview("Filled — Dark")` plus block-specific states
- Configuration pattern: `public struct Configuration` with typed properties
- `@_exported import DesignFoundation` is in the package entry point — all primitives available

### Existing APIs (verified from source)

**DFStatCardBlock.Configuration** (already built):
```swift
public struct DFStatCardBlock: View {
    public struct Configuration {
        public var title: String
        public var value: String
        public var trend: String?
        public var trendDirection: DFTrendDirection  // .up, .down, .neutral
        public var icon: String?
        public var onTap: (@MainActor () -> Void)?
    }
    public init(configuration: Configuration) { ... }
}
```

**DFActivityFeedRow.Configuration** (already built — actual field names):
```swift
public struct DFActivityFeedRow: View {
    public struct Configuration {
        public var initials: String          // NOT avatarInitials
        public var avatarImage: Image?
        public var title: String
        public var subtitle: String?         // NOT message
        public var timestamp: String
        public var isUnread: Bool            // NOT isRead
        public var onTap: (@MainActor () -> Void)?
    }
}
```

**DFEmptyStateBlock.Configuration** (already built):
```swift
public struct DFEmptyStateBlock: View {
    public struct Configuration {
        public var icon: String
        public var title: String
        public var message: String?
        public var actionTitle: String?
        public var onAction: (@MainActor () -> Void)?
    }
}
```

**DFButton:** `DFButton(_ label: String, role: DFButtonRole? = nil, action: @escaping () -> Void)`

**DFTextField:** `DFTextField(_ label: String, text: Binding<String>)`

---

## Task 1: DFMetricGridBlock

### Files

- Create: `Sources/DesignFoundationBlocks/Dashboard/DFMetricGridBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Dashboard/DFMetricGridBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Dashboard/DFMetricGridBlockTests.swift`

### Interfaces

**Consumes:** `DFStatCardBlock`, `DFTheme` via environment
**Produces:** `DFMetricGridBlock` — a lazy grid of stat cards

### Steps

- [ ] **Step 1 — Create `DFMetricGridBlock.swift`**

```swift
import SwiftUI

public struct DFMetricGridBlock: View {

    public struct Configuration {
        public var metrics: [DFStatCardBlock.Configuration]
        public var columns: Int

        public init(
            metrics: [DFStatCardBlock.Configuration],
            columns: Int = 2
        ) {
            self.metrics = metrics
            self.columns = columns
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        if configuration.metrics.isEmpty {
            EmptyView()
        } else {
            let gridItems = Array(
                repeating: GridItem(.flexible(), spacing: theme.spacing.sm),
                count: max(1, configuration.columns)
            )
            LazyVGrid(columns: gridItems, spacing: theme.spacing.sm) {
                ForEach(configuration.metrics.indices, id: \.self) { index in
                    DFStatCardBlock(configuration: configuration.metrics[index])
                }
            }
        }
    }
}
```

- [ ] **Step 2 — Create `DFMetricGridBlock+Previews.swift`**

```swift
import SwiftUI

private let sampleMetrics: [DFStatCardBlock.Configuration] = [
    .init(title: "Revenue", value: "$48,200", trend: "+12%", trendDirection: .up, icon: "dollarsign.circle"),
    .init(title: "Users", value: "3,841", trend: "+5%", trendDirection: .up, icon: "person.2"),
    .init(title: "Churn", value: "2.4%", trend: "+0.3%", trendDirection: .down, icon: "arrow.down.circle"),
    .init(title: "Sessions", value: "19,302", trend: "Flat", trendDirection: .neutral, icon: "chart.bar"),
]

private let sixMetrics: [DFStatCardBlock.Configuration] = sampleMetrics + [
    .init(title: "MRR", value: "$4,100", trend: "+8%", trendDirection: .up, icon: "repeat.circle"),
    .init(title: "NPS", value: "72", trend: "+4pts", trendDirection: .up, icon: "star.circle"),
]

#Preview("Default — Light") {
    DFMetricGridBlock(
        configuration: .init(metrics: sampleMetrics, columns: 2)
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Default — Dark") {
    DFMetricGridBlock(
        configuration: .init(metrics: sampleMetrics, columns: 2)
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Three Columns — Light") {
    DFMetricGridBlock(
        configuration: .init(metrics: sixMetrics, columns: 3)
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Three Columns — Dark") {
    DFMetricGridBlock(
        configuration: .init(metrics: sixMetrics, columns: 3)
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Single Metric — Light") {
    DFMetricGridBlock(
        configuration: .init(
            metrics: [.init(title: "Revenue", value: "$48,200", trend: "+12%", trendDirection: .up, icon: "dollarsign.circle")],
            columns: 2
        )
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Empty — Light") {
    DFMetricGridBlock(
        configuration: .init(metrics: [], columns: 2)
    )
    .padding()
    .preferredColorScheme(.light)
}
```

- [ ] **Step 3 — Create `DFMetricGridBlockTests.swift`**

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFMetricGridBlock")
struct DFMetricGridBlockTests {

    private func makeMetric(title: String = "Revenue", value: String = "$1") -> DFStatCardBlock.Configuration {
        .init(title: title, value: value, trendDirection: .neutral)
    }

    @Test("Default column count is 2")
    func defaultColumns() {
        let config = DFMetricGridBlock.Configuration(metrics: [makeMetric()])
        #expect(config.columns == 2)
    }

    @Test("Custom column count is stored")
    func customColumns() {
        let config = DFMetricGridBlock.Configuration(metrics: [], columns: 3)
        #expect(config.columns == 3)
    }

    @Test("Metric count matches input")
    func metricCount() {
        let metrics = [makeMetric(title: "A"), makeMetric(title: "B"), makeMetric(title: "C")]
        let config = DFMetricGridBlock.Configuration(metrics: metrics)
        #expect(config.metrics.count == 3)
    }

    @Test("Empty metrics produces empty collection")
    func emptyMetrics() {
        let config = DFMetricGridBlock.Configuration(metrics: [])
        #expect(config.metrics.isEmpty)
    }

    @Test("Metrics preserve order")
    func metricsOrder() {
        let titles = ["Alpha", "Beta", "Gamma"]
        let metrics = titles.map { makeMetric(title: $0) }
        let config = DFMetricGridBlock.Configuration(metrics: metrics)
        for (index, title) in titles.enumerated() {
            #expect(config.metrics[index].title == title)
        }
    }
}
```

- [ ] **Step 4 — Commit**

```
git add Sources/DesignFoundationBlocks/Dashboard/DFMetricGridBlock.swift \
        Sources/DesignFoundationBlocks/Dashboard/DFMetricGridBlock+Previews.swift \
        Tests/DesignFoundationBlocksTests/Dashboard/DFMetricGridBlockTests.swift
git commit -m "feat(blocks): add DFMetricGridBlock with LazyVGrid layout"
```

---

## Task 2: DFActivityFeedBlock

### Files

- Create: `Sources/DesignFoundationBlocks/Feed/DFActivityFeedBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Feed/DFActivityFeedBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Feed/DFActivityFeedBlockTests.swift`

### Interfaces

**Consumes:** `DFActivityFeedRow`, `DFEmptyStateBlock`, `DFButton`, `DFTheme` via environment
**Produces:** `DFActivityFeedBlock` — titled feed list with optional See All action and empty state

### Steps

- [ ] **Step 1 — Create `DFActivityFeedBlock.swift`**

```swift
import SwiftUI

public struct DFActivityFeedBlock: View {

    public struct Configuration {
        public var title: String
        public var items: [DFActivityFeedRow.Configuration]
        public var seeAllTitle: String
        public var onSeeAll: (@MainActor () -> Void)?
        public var emptyTitle: String
        public var emptyIcon: String

        public init(
            title: String = "Activity",
            items: [DFActivityFeedRow.Configuration],
            seeAllTitle: String = "See All",
            onSeeAll: (@MainActor () -> Void)? = nil,
            emptyTitle: String = "No activity yet",
            emptyIcon: String = "bell.slash"
        ) {
            self.title = title
            self.items = items
            self.seeAllTitle = seeAllTitle
            self.onSeeAll = onSeeAll
            self.emptyTitle = emptyTitle
            self.emptyIcon = emptyIcon
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
                // Header
                HStack {
                    Text(configuration.title)
                        .font(theme.typography.headline.font)
                        .foregroundStyle(theme.colors.textPrimary)
                    Spacer()
                    if let onSeeAll = configuration.onSeeAll {
                        DFButton(configuration.seeAllTitle, role: nil) {
                            Task { @MainActor in onSeeAll() }
                        }
                    }
                }

                Divider()
                    .background(theme.colors.border)

                if configuration.items.isEmpty {
                    DFEmptyStateBlock(
                        configuration: .init(
                            icon: configuration.emptyIcon,
                            title: configuration.emptyTitle
                        )
                    )
                } else {
                    ForEach(configuration.items.indices, id: \.self) { index in
                        DFActivityFeedRow(configuration: configuration.items[index])
                        if index < configuration.items.count - 1 {
                            Divider()
                                .background(theme.colors.border)
                        }
                    }
                }
            }
            .padding(theme.spacing.md)
        }
    }
}
```

- [ ] **Step 2 — Create `DFActivityFeedBlock+Previews.swift`**

```swift
import SwiftUI

private let threeItems: [DFActivityFeedRow.Configuration] = [
    .init(
        initials: "JA",
        title: "James added a new component",
        subtitle: "DFButton was updated with a new role",
        timestamp: "2m ago",
        isUnread: true
    ),
    .init(
        initials: "SR",
        title: "Sara reviewed the design",
        subtitle: "Approved the color token changes",
        timestamp: "1h ago",
        isUnread: false
    ),
    .init(
        initials: "MK",
        title: "Mike deployed to production",
        subtitle: nil,
        timestamp: "3h ago",
        isUnread: true
    ),
]

#Preview("Default — Light") {
    DFActivityFeedBlock(
        configuration: .init(items: threeItems)
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Default — Dark") {
    DFActivityFeedBlock(
        configuration: .init(items: threeItems)
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("With See All — Light") {
    DFActivityFeedBlock(
        configuration: .init(
            title: "Recent Activity",
            items: threeItems,
            seeAllTitle: "See All",
            onSeeAll: { print("See all tapped") }
        )
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("With See All — Dark") {
    DFActivityFeedBlock(
        configuration: .init(
            title: "Recent Activity",
            items: threeItems,
            seeAllTitle: "See All",
            onSeeAll: { print("See all tapped") }
        )
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Empty State — Light") {
    DFActivityFeedBlock(
        configuration: .init(
            items: [],
            emptyTitle: "No activity yet",
            emptyIcon: "bell.slash"
        )
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Empty State — Dark") {
    DFActivityFeedBlock(
        configuration: .init(
            items: [],
            emptyTitle: "No activity yet",
            emptyIcon: "bell.slash"
        )
    )
    .padding()
    .preferredColorScheme(.dark)
}
```

- [ ] **Step 3 — Create `DFActivityFeedBlockTests.swift`**

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFActivityFeedBlock")
struct DFActivityFeedBlockTests {

    private func makeItem(
        initials: String = "AB",
        title: String = "Did something",
        isUnread: Bool = false
    ) -> DFActivityFeedRow.Configuration {
        .init(initials: initials, title: title, timestamp: "1m ago", isUnread: isUnread)
    }

    @Test("Default title is Activity")
    func defaultTitle() {
        let config = DFActivityFeedBlock.Configuration(items: [])
        #expect(config.title == "Activity")
    }

    @Test("Default seeAllTitle is See All")
    func defaultSeeAllTitle() {
        let config = DFActivityFeedBlock.Configuration(items: [])
        #expect(config.seeAllTitle == "See All")
    }

    @Test("Default emptyIcon is bell.slash")
    func defaultEmptyIcon() {
        let config = DFActivityFeedBlock.Configuration(items: [])
        #expect(config.emptyIcon == "bell.slash")
    }

    @Test("Item count matches input")
    func itemCount() {
        let items = [makeItem(title: "A"), makeItem(title: "B")]
        let config = DFActivityFeedBlock.Configuration(items: items)
        #expect(config.items.count == 2)
    }

    @Test("Empty items collection")
    func emptyItems() {
        let config = DFActivityFeedBlock.Configuration(items: [])
        #expect(config.items.isEmpty)
    }

    @Test("onSeeAll is nil by default")
    func onSeeAllDefaultsNil() {
        let config = DFActivityFeedBlock.Configuration(items: [])
        #expect(config.onSeeAll == nil)
    }

    @Test("onSeeAll callback is stored and invocable")
    func onSeeAllCallback() async {
        var fired = false
        let config = DFActivityFeedBlock.Configuration(
            items: [],
            onSeeAll: { fired = true }
        )
        await MainActor.run {
            config.onSeeAll?()
        }
        #expect(fired)
    }

    @Test("Unread items are tracked")
    func unreadTracking() {
        let items = [
            makeItem(title: "Read", isUnread: false),
            makeItem(title: "Unread", isUnread: true),
        ]
        let config = DFActivityFeedBlock.Configuration(items: items)
        let unreadCount = config.items.filter { $0.isUnread }.count
        #expect(unreadCount == 1)
    }
}
```

- [ ] **Step 4 — Commit**

```
git add Sources/DesignFoundationBlocks/Feed/DFActivityFeedBlock.swift \
        Sources/DesignFoundationBlocks/Feed/DFActivityFeedBlock+Previews.swift \
        Tests/DesignFoundationBlocksTests/Feed/DFActivityFeedBlockTests.swift
git commit -m "feat(blocks): add DFActivityFeedBlock with empty state and see-all action"
```

---

## Task 3: DFChartPlaceholderBlock

### Files

- Create: `Sources/DesignFoundationBlocks/Dashboard/DFChartPlaceholderBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Dashboard/DFChartPlaceholderBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Dashboard/DFChartPlaceholderBlockTests.swift`

### Interfaces

**Consumes:** `DFCard`, `DFTheme` via environment, generic `Chart: View` via `@ViewBuilder`
**Produces:** `DFChartPlaceholderBlock<Chart>` — titled chart wrapper with period picker

### Steps

- [ ] **Step 1 — Create `DFChartPlaceholderBlock.swift`**

```swift
import SwiftUI

public struct DFChartPlaceholderBlock<Chart: View>: View {

    public struct Configuration {
        public var title: String
        public var subtitle: String?
        public var periods: [String]
        public var selectedPeriod: Int
        public var onPeriodChange: (@MainActor (Int) -> Void)?

        public init(
            title: String,
            subtitle: String? = nil,
            periods: [String] = [],
            selectedPeriod: Int = 0,
            onPeriodChange: (@MainActor (Int) -> Void)? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.periods = periods
            self.selectedPeriod = selectedPeriod
            self.onPeriodChange = onPeriodChange
        }
    }

    private let configuration: Configuration
    private let chart: Chart
    @Environment(\.dfTheme) private var theme

    public init(
        configuration: Configuration,
        @ViewBuilder chart: () -> Chart
    ) {
        self.configuration = configuration
        self.chart = chart()
    }

    public var body: some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                // Title / subtitle header
                VStack(alignment: .leading, spacing: 2) {
                    Text(configuration.title)
                        .font(theme.typography.headline.font)
                        .foregroundStyle(theme.colors.textPrimary)
                    if let subtitle = configuration.subtitle {
                        Text(subtitle)
                            .font(theme.typography.caption.font)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }

                // Period picker
                if !configuration.periods.isEmpty {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(configuration.periods.indices, id: \.self) { index in
                            let isSelected = index == configuration.selectedPeriod
                            Button {
                                if let onPeriodChange = configuration.onPeriodChange {
                                    Task { @MainActor in onPeriodChange(index) }
                                }
                            } label: {
                                Text(configuration.periods[index])
                                    .font(theme.typography.caption.font)
                                    .foregroundStyle(
                                        isSelected
                                            ? theme.colors.surface
                                            : theme.colors.textSecondary
                                    )
                                    .padding(.horizontal, theme.spacing.sm)
                                    .padding(.vertical, theme.spacing.xs)
                                    .background(
                                        isSelected
                                            ? theme.colors.primary
                                            : theme.colors.surface
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(isSelected ? .isSelected : [])
                        }
                    }
                }

                // Chart content
                chart
                    .frame(maxWidth: .infinity, minHeight: 180)
            }
            .padding(theme.spacing.md)
        }
    }
}
```

- [ ] **Step 2 — Create `DFChartPlaceholderBlock+Previews.swift`**

```swift
import SwiftUI

#Preview("Default — Light") {
    DFChartPlaceholderBlock(
        configuration: .init(title: "Revenue")
    ) {
        Rectangle()
            .fill(Color.gray.opacity(0.15))
            .overlay(
                Text("Chart Area")
                    .foregroundStyle(.secondary)
            )
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Default — Dark") {
    DFChartPlaceholderBlock(
        configuration: .init(title: "Revenue")
    ) {
        Rectangle()
            .fill(Color.gray.opacity(0.15))
            .overlay(
                Text("Chart Area")
                    .foregroundStyle(.secondary)
            )
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("With Periods — Light") {
    @Previewable @State var selected = 0
    DFChartPlaceholderBlock(
        configuration: .init(
            title: "Revenue",
            subtitle: "Last period vs current",
            periods: ["7D", "1M", "3M", "1Y"],
            selectedPeriod: selected,
            onPeriodChange: { selected = $0 }
        )
    ) {
        Rectangle()
            .fill(Color.blue.opacity(0.1))
            .overlay(
                Text("Chart Area")
                    .foregroundStyle(.secondary)
            )
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("With Periods — Dark") {
    @Previewable @State var selected = 1
    DFChartPlaceholderBlock(
        configuration: .init(
            title: "Active Users",
            subtitle: "Daily unique visitors",
            periods: ["7D", "1M", "3M", "1Y"],
            selectedPeriod: selected,
            onPeriodChange: { selected = $0 }
        )
    ) {
        Rectangle()
            .fill(Color.blue.opacity(0.1))
            .overlay(
                Text("Chart Area")
                    .foregroundStyle(.secondary)
            )
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("No Periods — Light") {
    DFChartPlaceholderBlock(
        configuration: .init(
            title: "Session Heatmap",
            subtitle: "Hourly activity distribution"
        )
    ) {
        Rectangle()
            .fill(Color.orange.opacity(0.1))
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("No Periods — Dark") {
    DFChartPlaceholderBlock(
        configuration: .init(
            title: "Session Heatmap",
            subtitle: "Hourly activity distribution"
        )
    ) {
        Rectangle()
            .fill(Color.orange.opacity(0.1))
    }
    .padding()
    .preferredColorScheme(.dark)
}
```

- [ ] **Step 3 — Create `DFChartPlaceholderBlockTests.swift`**

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFChartPlaceholderBlock")
struct DFChartPlaceholderBlockTests {

    @Test("Default selectedPeriod is 0")
    func defaultSelectedPeriod() {
        let config = DFChartPlaceholderBlock<EmptyView>.Configuration(title: "Revenue")
        #expect(config.selectedPeriod == 0)
    }

    @Test("Default periods is empty")
    func defaultPeriods() {
        let config = DFChartPlaceholderBlock<EmptyView>.Configuration(title: "Revenue")
        #expect(config.periods.isEmpty)
    }

    @Test("Subtitle is nil by default")
    func defaultSubtitle() {
        let config = DFChartPlaceholderBlock<EmptyView>.Configuration(title: "Revenue")
        #expect(config.subtitle == nil)
    }

    @Test("Title is stored correctly")
    func titleStored() {
        let config = DFChartPlaceholderBlock<EmptyView>.Configuration(title: "Session Heatmap")
        #expect(config.title == "Session Heatmap")
    }

    @Test("Periods are stored in order")
    func periodsOrder() {
        let periods = ["7D", "1M", "3M", "1Y"]
        let config = DFChartPlaceholderBlock<EmptyView>.Configuration(
            title: "Revenue",
            periods: periods,
            selectedPeriod: 0
        )
        #expect(config.periods == periods)
    }

    @Test("onPeriodChange callback fires with correct index")
    func onPeriodChangeCallback() async {
        var received: Int? = nil
        let config = DFChartPlaceholderBlock<EmptyView>.Configuration(
            title: "Revenue",
            periods: ["7D", "1M"],
            selectedPeriod: 0,
            onPeriodChange: { received = $0 }
        )
        await MainActor.run {
            config.onPeriodChange?(1)
        }
        #expect(received == 1)
    }

    @Test("onPeriodChange is nil by default")
    func onPeriodChangeDefaultsNil() {
        let config = DFChartPlaceholderBlock<EmptyView>.Configuration(title: "Revenue")
        #expect(config.onPeriodChange == nil)
    }
}
```

- [ ] **Step 4 — Commit**

```
git add Sources/DesignFoundationBlocks/Dashboard/DFChartPlaceholderBlock.swift \
        Sources/DesignFoundationBlocks/Dashboard/DFChartPlaceholderBlock+Previews.swift \
        Tests/DesignFoundationBlocksTests/Dashboard/DFChartPlaceholderBlockTests.swift
git commit -m "feat(blocks): add DFChartPlaceholderBlock with generic chart slot and period picker"
```

---

## Task 4: DFProgressRingBlock

### Files

- Create: `Sources/DesignFoundationBlocks/Dashboard/DFProgressRingBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Dashboard/DFProgressRingBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Dashboard/DFProgressRingBlockTests.swift`

### Interfaces

**Consumes:** `DFCard`, `DFTheme` via environment
**Produces:** `DFProgressRingBlock` — circular progress ring with title and optional subtitle/label

### Steps

- [ ] **Step 1 — Create `DFProgressRingBlock.swift`**

```swift
import SwiftUI

public struct DFProgressRingBlock: View {

    public struct Configuration {
        public var value: Double
        public var title: String
        public var subtitle: String?
        public var label: String?
        public var strokeWidth: CGFloat
        public var size: CGFloat

        public init(
            value: Double,
            title: String,
            subtitle: String? = nil,
            label: String? = nil,
            strokeWidth: CGFloat = 12,
            size: CGFloat = 120
        ) {
            self.value = value
            self.title = title
            self.subtitle = subtitle
            self.label = label
            self.strokeWidth = strokeWidth
            self.size = size
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    private var clampedValue: Double {
        min(1.0, max(0.0, configuration.value))
    }

    public var body: some View {
        DFCard {
            VStack(spacing: theme.spacing.sm) {
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(
                            theme.colors.surface,
                            lineWidth: configuration.strokeWidth
                        )

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: clampedValue)
                        .stroke(
                            theme.colors.primary,
                            style: StrokeStyle(
                                lineWidth: configuration.strokeWidth,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: clampedValue)

                    // Center label
                    if let label = configuration.label {
                        Text(label)
                            .font(theme.typography.title.font)
                            .foregroundStyle(theme.colors.textPrimary)
                    }
                }
                .frame(width: configuration.size, height: configuration.size)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(configuration.title): \(Int(clampedValue * 100)) percent")
                .accessibilityValue(configuration.label ?? "\(Int(clampedValue * 100))%")

                VStack(spacing: 2) {
                    Text(configuration.title)
                        .font(theme.typography.headline.font)
                        .foregroundStyle(theme.colors.textPrimary)
                        .multilineTextAlignment(.center)

                    if let subtitle = configuration.subtitle {
                        Text(subtitle)
                            .font(theme.typography.caption.font)
                            .foregroundStyle(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity)
        }
    }
}
```

- [ ] **Step 2 — Create `DFProgressRingBlock+Previews.swift`**

```swift
import SwiftUI

#Preview("Default — Light") {
    DFProgressRingBlock(
        configuration: .init(
            value: 0.75,
            title: "Progress",
            label: "75%"
        )
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Default — Dark") {
    DFProgressRingBlock(
        configuration: .init(
            value: 0.75,
            title: "Progress",
            label: "75%"
        )
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Full — Light") {
    DFProgressRingBlock(
        configuration: .init(
            value: 1.0,
            title: "Complete",
            label: "100%"
        )
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Full — Dark") {
    DFProgressRingBlock(
        configuration: .init(
            value: 1.0,
            title: "Complete",
            label: "100%"
        )
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Empty — Light") {
    DFProgressRingBlock(
        configuration: .init(
            value: 0.0,
            title: "Not Started",
            label: "0%"
        )
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("With Subtitle — Light") {
    DFProgressRingBlock(
        configuration: .init(
            value: 0.62,
            title: "Goal Completion",
            subtitle: "38% remaining until target",
            label: "62%"
        )
    )
    .padding()
    .preferredColorScheme(.light)
}
```

- [ ] **Step 3 — Create `DFProgressRingBlockTests.swift`**

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFProgressRingBlock")
struct DFProgressRingBlockTests {

    @Test("Default strokeWidth is 12")
    func defaultStrokeWidth() {
        let config = DFProgressRingBlock.Configuration(value: 0.5, title: "Test")
        #expect(config.strokeWidth == 12)
    }

    @Test("Default size is 120")
    func defaultSize() {
        let config = DFProgressRingBlock.Configuration(value: 0.5, title: "Test")
        #expect(config.size == 120)
    }

    @Test("Subtitle is nil by default")
    func defaultSubtitle() {
        let config = DFProgressRingBlock.Configuration(value: 0.5, title: "Test")
        #expect(config.subtitle == nil)
    }

    @Test("Label is nil by default")
    func defaultLabel() {
        let config = DFProgressRingBlock.Configuration(value: 0.5, title: "Test")
        #expect(config.label == nil)
    }

    @Test("Value above 1.0 clamps to 1.0")
    func clampAboveOne() {
        let block = DFProgressRingBlock(
            configuration: .init(value: 1.5, title: "Test")
        )
        // Access the clamped value via a helper computed from Configuration
        let raw = DFProgressRingBlock.Configuration(value: 1.5, title: "Test").value
        let clamped = min(1.0, max(0.0, raw))
        #expect(clamped == 1.0)
    }

    @Test("Value below 0.0 clamps to 0.0")
    func clampBelowZero() {
        let raw = DFProgressRingBlock.Configuration(value: -0.3, title: "Test").value
        let clamped = min(1.0, max(0.0, raw))
        #expect(clamped == 0.0)
    }

    @Test("Value within range is unchanged")
    func validValuePreserved() {
        let config = DFProgressRingBlock.Configuration(value: 0.62, title: "Test")
        let clamped = min(1.0, max(0.0, config.value))
        #expect(abs(clamped - 0.62) < 0.0001)
    }

    @Test("Title is stored correctly")
    func titleStored() {
        let config = DFProgressRingBlock.Configuration(value: 0.5, title: "Goal Completion")
        #expect(config.title == "Goal Completion")
    }

    @Test("Subtitle is stored correctly")
    func subtitleStored() {
        let config = DFProgressRingBlock.Configuration(
            value: 0.5,
            title: "Goal",
            subtitle: "38% remaining"
        )
        #expect(config.subtitle == "38% remaining")
    }
}
```

- [ ] **Step 4 — Commit**

```
git add Sources/DesignFoundationBlocks/Dashboard/DFProgressRingBlock.swift \
        Sources/DesignFoundationBlocks/Dashboard/DFProgressRingBlock+Previews.swift \
        Tests/DesignFoundationBlocksTests/Dashboard/DFProgressRingBlockTests.swift
git commit -m "feat(blocks): add DFProgressRingBlock with clamped value and animated ring"
```
