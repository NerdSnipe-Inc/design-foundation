# DesignFoundationScreens — Analytics Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build 4 production-ready analytics screens in `DesignFoundationScreens`, forming the **Analytics Dashboard** vertical. These screens cover the core founder/product-analytics workflow: overview metrics, revenue tracking, user acquisition and retention, and a live event feed. Think Mixpanel, Amplitude, or a founders' morning dashboard — real numbers, real decisions.

**Architecture:** Screens live at `Sources/DesignFoundationScreens/Analytics/`. Each screen is a self-contained `struct … : View` with a `Configuration` struct holding all content data and action closures. All visual tokens come from `@Environment(\.dfTheme)`. Screens compose existing blocks — `DFStatCardBlock`, `DFMetricGridBlock`, `DFChartPlaceholderBlock`, `DFProgressRingBlock`, `DFActivityFeedBlock`, etc. — rather than re-implementing primitives. No direct use of `Color`, `Font`, or numeric spacing literals.

> **All file paths are relative to `/Users/nerdsnipe/Projects/DesignFoundationScreens/` unless otherwise noted.** The package is assumed to already exist.

**Tech Stack:** Swift 6, SwiftUI, Swift Testing, `DesignFoundationBlocks` (all block types listed below), `DesignFoundation` (DFTheme, DFButton, DFText, DFBadge, DFCard, DFDivider, DFToast, DFTable, DFList, DFListRow)

---

## Global Constraints

- Swift 6 strict concurrency: `StrictConcurrency` experimental feature ON in all targets
- Platforms: iOS 18.0, macOS 15.0, visionOS 2.0
- All colors, typography, spacing, radius from `@Environment(\.dfTheme)` — zero hardcoded values
- Action closures in Configuration structs: `@MainActor () -> Void` (or `@MainActor (T) -> Void`)
- Configuration structs do NOT declare `Sendable` (they hold closures + SwiftUI `Binding`)
- Pure data enums/structs (no closures, no Binding): declare `Sendable, Equatable`
- Previews: one `#Preview("Light") { … }` and one `#Preview("Dark") { … .colorScheme(.dark) }` per screen
- Adaptive layout: sidebar navigation on iPad + Mac, tab bar on iPhone — use `NavigationSplitView` / `NavigationStack` appropriately, driven by environment size class
- Tests: Swift Testing only (`import Testing`, `@Suite`, `@Test`, `#expect`) — never XCTest
- Source path: `Sources/DesignFoundationScreens/Analytics/` (relative to package root)
- Test path: `Tests/DesignFoundationScreensTests/Analytics/` (relative to package root)
- Commit messages: `feat(screens): …`, `test(screens): …`
- No Co-Author line in any commit

---

## Available Blocks

```
DFStatCardBlock            — single KPI tile with label, value, trend delta
DFMetricGridBlock          — 2×N grid of metric tiles
DFChartPlaceholderBlock    — sized placeholder for any chart zone (line, bar, donut, heatmap)
DFProgressRingBlock        — circular progress dial with center label
DFProgressBar              — linear progress with label
DFActivityFeedBlock        — scrollable event feed with rows
DFActivityFeedRow          — single row: icon, title, subtitle, timestamp
DFDateRangeBlock           — date range picker (used in sheet)
DFTagPickerBlock           — horizontal chip-row filter selector
DFEmptyStateBlock          — centered empty state with icon, title, body, optional CTA
DFBlockSkeletonBlock       — animated shimmer skeleton matching a block's shape
DFSearchResultsBlock       — search input + results list pattern
DFTable                    — sortable data table with typed columns
DFList / DFListRow         — list with swipe-delete, reorder, multi-select
DFCard                     — surface container
DFButton                   — themed button (primary, secondary, destructive, ghost)
DFText                     — themed text with style variants
DFBadge                    — small labelled chip (color, text)
DFDivider                  — themed separator
DFToast                    — ephemeral notification overlay
```

---

## File Map

```
Sources/DesignFoundationScreens/Analytics/
  Shared/
    DFAnalyticsPeriod.swift                   ← shared period enum + date range model
    DFAnalyticsPeriodSelector.swift           ← period tab bar + custom sheet trigger
  Overview/
    DFAnalyticsOverviewScreen.swift
    DFAnalyticsOverviewScreen+Previews.swift
  Revenue/
    DFAnalyticsRevenueScreen.swift
    DFAnalyticsRevenueScreen+Previews.swift
  Users/
    DFAnalyticsUsersScreen.swift
    DFAnalyticsUsersScreen+Previews.swift
  Events/
    DFAnalyticsEventsScreen.swift
    DFAnalyticsEventsScreen+Previews.swift

Tests/DesignFoundationScreensTests/Analytics/
  DFAnalyticsPeriodTests.swift
  DFAnalyticsOverviewScreenTests.swift
  DFAnalyticsRevenueScreenTests.swift
  DFAnalyticsUsersScreenTests.swift
  DFAnalyticsEventsScreenTests.swift
```

---

## Task 1: Shared Period Model + Selector Component

**Files:**
- Create: `Sources/DesignFoundationScreens/Analytics/Shared/DFAnalyticsPeriod.swift`
- Create: `Sources/DesignFoundationScreens/Analytics/Shared/DFAnalyticsPeriodSelector.swift`
- Create: `Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsPeriodTests.swift`

**Interfaces:**
- Produces: `DFAnalyticsPeriod` enum (shared by all 4 screens), `DFDateRange` model, `DFAnalyticsPeriodSelector` view
- Consumes: `DFButton`, `DFDateRangeBlock` (in sheet), `DFTheme`

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsPeriodTests.swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFAnalyticsPeriod")
struct DFAnalyticsPeriodTests {

    @Suite("Labels")
    struct LabelTests {
        @Test("today label is correct")
        func todayLabel() {
            #expect(DFAnalyticsPeriod.today.label == "Today")
        }

        @Test("seven day label")
        func sevenDayLabel() {
            #expect(DFAnalyticsPeriod.sevenDays.label == "7D")
        }

        @Test("thirty day label")
        func thirtyDayLabel() {
            #expect(DFAnalyticsPeriod.thirtyDays.label == "30D")
        }

        @Test("ninety day label")
        func ninetyDayLabel() {
            #expect(DFAnalyticsPeriod.ninetyDays.label == "90D")
        }

        @Test("custom label")
        func customLabel() {
            let start = Date(timeIntervalSinceReferenceDate: 0)
            let end = Date(timeIntervalSinceReferenceDate: 86400)
            #expect(DFAnalyticsPeriod.custom(DFDateRange(start: start, end: end)).label == "Custom")
        }
    }

    @Suite("DFDateRange")
    struct DateRangeTests {
        @Test("stores start and end")
        func storesStartAndEnd() {
            let start = Date(timeIntervalSinceReferenceDate: 1000)
            let end = Date(timeIntervalSinceReferenceDate: 9000)
            let range = DFDateRange(start: start, end: end)
            #expect(range.start == start)
            #expect(range.end == end)
        }

        @Test("duration is non-negative")
        func durationNonNegative() {
            let start = Date(timeIntervalSinceReferenceDate: 0)
            let end = Date(timeIntervalSinceReferenceDate: 86400)
            let range = DFDateRange(start: start, end: end)
            #expect(range.end >= range.start)
        }
    }

    @Suite("Equatability")
    struct EquatableTests {
        @Test("same cases are equal")
        func sameCasesEqual() {
            #expect(DFAnalyticsPeriod.today == DFAnalyticsPeriod.today)
            #expect(DFAnalyticsPeriod.sevenDays == DFAnalyticsPeriod.sevenDays)
        }

        @Test("different cases are not equal")
        func differentCasesNotEqual() {
            #expect(DFAnalyticsPeriod.today != DFAnalyticsPeriod.sevenDays)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAnalyticsPeriodTests 2>&1 | tail -20
```

Expected: compile error — `DFAnalyticsPeriod` not found.

- [ ] **Step 3: Implement `DFAnalyticsPeriod` and `DFDateRange`**

Create `Sources/DesignFoundationScreens/Analytics/Shared/DFAnalyticsPeriod.swift`:

```swift
// Sources/DesignFoundationScreens/Analytics/Shared/DFAnalyticsPeriod.swift
import Foundation

/// A date range with an explicit start and end.
public struct DFDateRange: Sendable, Equatable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}

/// The selectable time period for analytics screens.
public enum DFAnalyticsPeriod: Sendable, Equatable {
    case today
    case sevenDays
    case thirtyDays
    case ninetyDays
    case custom(DFDateRange)

    /// Short label shown in the period selector tabs.
    public var label: String {
        switch self {
        case .today:       return "Today"
        case .sevenDays:   return "7D"
        case .thirtyDays:  return "30D"
        case .ninetyDays:  return "90D"
        case .custom:      return "Custom"
        }
    }
}
```

- [ ] **Step 4: Implement `DFAnalyticsPeriodSelector`**

Create `Sources/DesignFoundationScreens/Analytics/Shared/DFAnalyticsPeriodSelector.swift`:

```swift
// Sources/DesignFoundationScreens/Analytics/Shared/DFAnalyticsPeriodSelector.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

/// A segmented period tab bar with a "Custom" option that opens a DFDateRangeBlock sheet.
///
/// Usage:
/// ```swift
/// DFAnalyticsPeriodSelector(selected: $period)
/// ```
public struct DFAnalyticsPeriodSelector: View {
    @Environment(\.dfTheme) private var theme

    @Binding public var selected: DFAnalyticsPeriod
    @State private var showingCustomSheet = false
    @State private var customRange: DFDateRange = {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -30, to: end) ?? end
        return DFDateRange(start: start, end: end)
    }()

    private let fixedPeriods: [DFAnalyticsPeriod] = [.today, .sevenDays, .thirtyDays, .ninetyDays]

    public init(selected: Binding<DFAnalyticsPeriod>) {
        self._selected = selected
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.xs) {
                ForEach(fixedPeriods, id: \.label) { period in
                    periodButton(period)
                }
                customButton
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.xs)
        }
        .sheet(isPresented: $showingCustomSheet) {
            customSheet
        }
    }

    @ViewBuilder
    private func periodButton(_ period: DFAnalyticsPeriod) -> some View {
        let isSelected = selected == period
        DFButton(
            period.label,
            style: isSelected ? .primary : .ghost,
            action: { selected = period }
        )
    }

    @ViewBuilder
    private var customButton: some View {
        let isSelected: Bool
        if case .custom = selected { isSelected = true } else { isSelected = false }
        DFButton(
            "Custom",
            style: isSelected ? .primary : .ghost,
            action: { showingCustomSheet = true }
        )
    }

    @ViewBuilder
    private var customSheet: some View {
        NavigationStack {
            DFDateRangeBlock(
                configuration: .init(
                    start: customRange.start,
                    end: customRange.end,
                    onConfirm: { start, end in
                        customRange = DFDateRange(start: start, end: end)
                        selected = .custom(customRange)
                        showingCustomSheet = false
                    },
                    onCancel: { showingCustomSheet = false }
                )
            )
            .navigationTitle("Custom Range")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}
```

- [ ] **Step 5: Run tests — all pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAnalyticsPeriodTests 2>&1 | tail -20
```

Expected: all tests pass, 0 failures.

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Analytics/Shared/ Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsPeriodTests.swift
git commit -m "feat(screens): add DFAnalyticsPeriod model and period selector component"
```

---

## Task 2: DFAnalyticsOverviewScreen

*The founder checks this before standup — must load fast and show what matters.*

**Files:**
- Create: `Sources/DesignFoundationScreens/Analytics/Overview/DFAnalyticsOverviewScreen.swift`
- Create: `Sources/DesignFoundationScreens/Analytics/Overview/DFAnalyticsOverviewScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsOverviewScreenTests.swift`

**Interfaces:**
- Consumes: `DFAnalyticsPeriodSelector`, `DFMetricGridBlock`, `DFChartPlaceholderBlock`, `DFActivityFeedBlock`, `DFBlockSkeletonBlock`, `DFTheme`
- Produces: `DFAnalyticsOverviewScreen` — top-level analytics dashboard view

**Layout (top → bottom):**
1. `DFAnalyticsPeriodSelector` — pinned below nav bar
2. Hero metric row — 3 large KPI tiles side-by-side, value + vs-prior-period delta with trend arrow
3. `DFMetricGridBlock` — 6 secondary metrics (2×3): Sessions, Bounce Rate, Avg Session, Pages/Session, Conversions, Revenue
4. `DFChartPlaceholderBlock(.large)` — primary trend line over selected period
5. `DFChartPlaceholderBlock(.medium)` — secondary breakdown (bar chart zone)
6. `DFActivityFeedBlock` — recent notable events (milestone hits, anomalies, new records)
7. Skeleton loading state covers all blocks simultaneously when `isLoading == true`

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsOverviewScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFAnalyticsOverviewScreen")
struct DFAnalyticsOverviewScreenTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("isLoading defaults to false")
        func isLoadingDefaultsFalse() {
            let config = DFAnalyticsOverviewScreen.Configuration(
                heroMetrics: [],
                secondaryMetrics: [],
                activityItems: []
            )
            #expect(config.isLoading == false)
        }

        @Test("onPeriodChange defaults to nil")
        func onPeriodChangeDefaultsNil() {
            let config = DFAnalyticsOverviewScreen.Configuration(
                heroMetrics: [],
                secondaryMetrics: [],
                activityItems: []
            )
            #expect(config.onPeriodChange == nil)
        }
    }

    @Suite("Hero metric model")
    struct HeroMetricTests {
        @Test("stores all fields")
        func storesAllFields() {
            let metric = DFAnalyticsOverviewScreen.HeroMetric(
                label: "MRR",
                value: "$12,400",
                delta: "+8.3%",
                deltaIsPositive: true
            )
            #expect(metric.label == "MRR")
            #expect(metric.value == "$12,400")
            #expect(metric.delta == "+8.3%")
            #expect(metric.deltaIsPositive == true)
        }

        @Test("negative delta stored correctly")
        func negativeDelta() {
            let metric = DFAnalyticsOverviewScreen.HeroMetric(
                label: "Churn",
                value: "3.2%",
                delta: "+0.4%",
                deltaIsPositive: false
            )
            #expect(metric.deltaIsPositive == false)
        }
    }

    @Suite("Configuration custom values")
    struct CustomValueTests {
        @Test("stores hero metrics")
        func storesHeroMetrics() {
            let metrics = [
                DFAnalyticsOverviewScreen.HeroMetric(label: "Users", value: "1,200", delta: "+5%", deltaIsPositive: true),
                DFAnalyticsOverviewScreen.HeroMetric(label: "MRR", value: "$9,800", delta: "-1%", deltaIsPositive: false),
                DFAnalyticsOverviewScreen.HeroMetric(label: "NPS", value: "72", delta: "+3", deltaIsPositive: true)
            ]
            let config = DFAnalyticsOverviewScreen.Configuration(
                heroMetrics: metrics,
                secondaryMetrics: [],
                activityItems: []
            )
            #expect(config.heroMetrics.count == 3)
        }

        @Test("isLoading can be set to true")
        func isLoadingTrue() {
            var config = DFAnalyticsOverviewScreen.Configuration(
                heroMetrics: [],
                secondaryMetrics: [],
                activityItems: []
            )
            config.isLoading = true
            #expect(config.isLoading == true)
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let screen = DFAnalyticsOverviewScreen(
                configuration: .init(heroMetrics: [], secondaryMetrics: [], activityItems: [])
            )
            #expect(type(of: screen) == DFAnalyticsOverviewScreen.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAnalyticsOverviewScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFAnalyticsOverviewScreen` not found.

- [ ] **Step 3: Implement `DFAnalyticsOverviewScreen`**

Create `Sources/DesignFoundationScreens/Analytics/Overview/DFAnalyticsOverviewScreen.swift`:

```swift
// Sources/DesignFoundationScreens/Analytics/Overview/DFAnalyticsOverviewScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

/// The founder's morning dashboard — shows the 3 most important numbers and secondary metrics
/// at a glance. Period selection drives all displayed data.
public struct DFAnalyticsOverviewScreen: View {
    @Environment(\.dfTheme) private var theme

    public let configuration: Configuration
    @State private var selectedPeriod: DFAnalyticsPeriod = .thirtyDays

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                DFAnalyticsPeriodSelector(selected: $selectedPeriod)
                    .onChange(of: selectedPeriod) { _, newPeriod in
                        configuration.onPeriodChange?(newPeriod)
                    }

                if configuration.isLoading {
                    skeletonState
                } else {
                    heroSection
                    secondaryMetricsSection
                    primaryChartSection
                    secondaryChartSection
                    activitySection
                }
            }
            .padding(.vertical, theme.spacing.md)
        }
        .navigationTitle("Overview")
    }

    // MARK: - Sections

    @ViewBuilder
    private var heroSection: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(configuration.heroMetrics.prefix(3), id: \.label) { metric in
                heroTile(metric)
            }
        }
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private func heroTile(_ metric: HeroMetric) -> some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                DFText(metric.label, style: .caption)
                    .foregroundStyle(theme.colors.textSecondary)
                DFText(metric.value, style: .largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.colors.textPrimary)
                HStack(spacing: theme.spacing.xxs) {
                    Image(systemName: metric.deltaIsPositive ? "arrow.up.right" : "arrow.down.right")
                        .imageScale(.small)
                    DFText(metric.delta, style: .caption)
                }
                .foregroundStyle(metric.deltaIsPositive ? theme.colors.success : theme.colors.destructive)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.sm)
        }
    }

    @ViewBuilder
    private var secondaryMetricsSection: some View {
        DFMetricGridBlock(
            configuration: .init(
                metrics: configuration.secondaryMetrics
            )
        )
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var primaryChartSection: some View {
        DFChartPlaceholderBlock(
            configuration: .init(
                title: "Trend",
                subtitle: selectedPeriod.label,
                chartType: .line,
                size: .large
            )
        )
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var secondaryChartSection: some View {
        DFChartPlaceholderBlock(
            configuration: .init(
                title: "Breakdown",
                chartType: .bar,
                size: .medium
            )
        )
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Notable Events", style: .headline)
                .padding(.horizontal, theme.spacing.md)
            DFActivityFeedBlock(
                configuration: .init(items: configuration.activityItems)
            )
        }
    }

    @ViewBuilder
    private var skeletonState: some View {
        VStack(spacing: theme.spacing.md) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(0..<3, id: \.self) { _ in
                    DFBlockSkeletonBlock(configuration: .init(height: 100))
                }
            }
            .padding(.horizontal, theme.spacing.md)
            DFBlockSkeletonBlock(configuration: .init(height: 160))
                .padding(.horizontal, theme.spacing.md)
            DFBlockSkeletonBlock(configuration: .init(height: 240))
                .padding(.horizontal, theme.spacing.md)
            DFBlockSkeletonBlock(configuration: .init(height: 160))
                .padding(.horizontal, theme.spacing.md)
            DFBlockSkeletonBlock(configuration: .init(height: 200))
                .padding(.horizontal, theme.spacing.md)
        }
    }
}

// MARK: - Configuration

extension DFAnalyticsOverviewScreen {

    public struct HeroMetric: Sendable, Equatable {
        public let label: String
        public let value: String
        public let delta: String
        /// `true` → green/success color; `false` → red/destructive color.
        public let deltaIsPositive: Bool

        public init(label: String, value: String, delta: String, deltaIsPositive: Bool) {
            self.label = label
            self.value = value
            self.delta = delta
            self.deltaIsPositive = deltaIsPositive
        }
    }

    public struct Configuration {
        /// Up to 3 hero metrics displayed prominently at the top.
        public let heroMetrics: [HeroMetric]
        /// 6 secondary metrics for the DFMetricGridBlock (2×3 grid).
        public let secondaryMetrics: [DFMetricGridBlock.Metric]
        /// Recent notable events shown in the activity feed.
        public let activityItems: [DFActivityFeedRow.Configuration]
        /// When true, all blocks are replaced with skeleton loading states.
        public var isLoading: Bool
        /// Called when the user changes the selected period.
        public var onPeriodChange: (@MainActor (DFAnalyticsPeriod) -> Void)?

        public init(
            heroMetrics: [HeroMetric],
            secondaryMetrics: [DFMetricGridBlock.Metric],
            activityItems: [DFActivityFeedRow.Configuration],
            isLoading: Bool = false,
            onPeriodChange: (@MainActor (DFAnalyticsPeriod) -> Void)? = nil
        ) {
            self.heroMetrics = heroMetrics
            self.secondaryMetrics = secondaryMetrics
            self.activityItems = activityItems
            self.isLoading = isLoading
            self.onPeriodChange = onPeriodChange
        }
    }
}
```

- [ ] **Step 4: Create previews**

Create `Sources/DesignFoundationScreens/Analytics/Overview/DFAnalyticsOverviewScreen+Previews.swift`:

```swift
// Sources/DesignFoundationScreens/Analytics/Overview/DFAnalyticsOverviewScreen+Previews.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

private extension DFAnalyticsOverviewScreen.Configuration {
    static let sample = DFAnalyticsOverviewScreen.Configuration(
        heroMetrics: [
            .init(label: "MRR", value: "$14,200", delta: "+12.4%", deltaIsPositive: true),
            .init(label: "Active Users", value: "3,841", delta: "+6.1%", deltaIsPositive: true),
            .init(label: "Churn", value: "2.1%", delta: "+0.3%", deltaIsPositive: false)
        ],
        secondaryMetrics: [
            .init(label: "Sessions", value: "28,419"),
            .init(label: "Bounce Rate", value: "34%"),
            .init(label: "Avg Session", value: "4m 12s"),
            .init(label: "Pages/Session", value: "3.8"),
            .init(label: "Conversions", value: "1,204"),
            .init(label: "Revenue", value: "$42,800")
        ],
        activityItems: [
            .init(icon: "flag.fill", title: "New MRR record", subtitle: "Surpassed $14k for the first time", timestamp: "2m ago"),
            .init(icon: "exclamationmark.triangle.fill", title: "Bounce rate spike", subtitle: "Landing page bounce +18% in last hour", timestamp: "34m ago"),
            .init(icon: "star.fill", title: "100th customer", subtitle: "Acme Corp signed up via referral", timestamp: "2h ago")
        ]
    )

    static let loading = DFAnalyticsOverviewScreen.Configuration(
        heroMetrics: [],
        secondaryMetrics: [],
        activityItems: [],
        isLoading: true
    )
}

#Preview("Light") {
    NavigationStack {
        DFAnalyticsOverviewScreen(configuration: .sample)
    }
}

#Preview("Dark") {
    NavigationStack {
        DFAnalyticsOverviewScreen(configuration: .sample)
    }
    .colorScheme(.dark)
}

#Preview("Loading") {
    NavigationStack {
        DFAnalyticsOverviewScreen(configuration: .loading)
    }
}
```

- [ ] **Step 5: Run tests — all pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAnalyticsOverviewScreenTests 2>&1 | tail -20
```

Expected: all tests pass, 0 failures.

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Analytics/Overview/ Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsOverviewScreenTests.swift
git commit -m "feat(screens): add DFAnalyticsOverviewScreen with hero metrics, chart zones, and skeleton loading"
```

---

## Task 3: DFAnalyticsRevenueScreen

*Where they track the business — MRR, churn, growth.*

**Files:**
- Create: `Sources/DesignFoundationScreens/Analytics/Revenue/DFAnalyticsRevenueScreen.swift`
- Create: `Sources/DesignFoundationScreens/Analytics/Revenue/DFAnalyticsRevenueScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsRevenueScreenTests.swift`

**Interfaces:**
- Consumes: `DFAnalyticsPeriodSelector`, `DFStatCardBlock`, `DFChartPlaceholderBlock`, `DFProgressRingBlock`, `DFMetricGridBlock`, `DFTable`, `DFTheme`
- Produces: `DFAnalyticsRevenueScreen`

**Layout (top → bottom):**
1. `DFAnalyticsPeriodSelector`
2. Hero: MRR value (large), vs last month delta, ARR label below
3. `DFStatCardBlock` row: New MRR / Expansion MRR / Churned MRR / Net New MRR
4. `DFChartPlaceholderBlock(.large)` — MRR over time (area chart zone)
5. `DFProgressRingBlock` — Churn rate dial with target indicator label
6. `DFMetricGridBlock` — 6 metrics: ARPU, LTV, Payback Period, Trial Conversion %, Active Subscriptions, Trials Active
7. `DFChartPlaceholderBlock(.medium)` — Revenue by Plan (donut chart zone)
8. `DFTable` — Top Customers: Customer, Plan, MRR, Since — sortable columns

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsRevenueScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFAnalyticsRevenueScreen")
struct DFAnalyticsRevenueScreenTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("isLoading defaults to false")
        func isLoadingDefaultsFalse() {
            let config = DFAnalyticsRevenueScreen.Configuration(
                mrrValue: "$0",
                mrrDelta: "0%",
                mrrDeltaIsPositive: true,
                arrLabel: "ARR $0",
                mrrCards: [],
                churnRate: 0,
                churnTarget: 0,
                secondaryMetrics: [],
                topCustomers: []
            )
            #expect(config.isLoading == false)
        }
    }

    @Suite("CustomerRow model")
    struct CustomerRowTests {
        @Test("stores all fields")
        func storesAllFields() {
            let row = DFAnalyticsRevenueScreen.CustomerRow(
                customer: "Acme Corp",
                plan: "Pro",
                mrr: "$1,200",
                since: "Jan 2024"
            )
            #expect(row.customer == "Acme Corp")
            #expect(row.plan == "Pro")
            #expect(row.mrr == "$1,200")
            #expect(row.since == "Jan 2024")
        }
    }

    @Suite("MRR card model")
    struct MRRCardTests {
        @Test("stores label and value")
        func storesLabelAndValue() {
            let card = DFAnalyticsRevenueScreen.MRRCard(
                label: "New MRR",
                value: "$3,400",
                delta: "+18%",
                deltaIsPositive: true
            )
            #expect(card.label == "New MRR")
            #expect(card.value == "$3,400")
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let screen = DFAnalyticsRevenueScreen(
                configuration: .init(
                    mrrValue: "$0",
                    mrrDelta: "0%",
                    mrrDeltaIsPositive: true,
                    arrLabel: "ARR $0",
                    mrrCards: [],
                    churnRate: 0,
                    churnTarget: 5,
                    secondaryMetrics: [],
                    topCustomers: []
                )
            )
            #expect(type(of: screen) == DFAnalyticsRevenueScreen.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAnalyticsRevenueScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFAnalyticsRevenueScreen` not found.

- [ ] **Step 3: Implement `DFAnalyticsRevenueScreen`**

Create `Sources/DesignFoundationScreens/Analytics/Revenue/DFAnalyticsRevenueScreen.swift`:

```swift
// Sources/DesignFoundationScreens/Analytics/Revenue/DFAnalyticsRevenueScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

/// Revenue tracking screen — MRR, churn, growth, and top customers.
public struct DFAnalyticsRevenueScreen: View {
    @Environment(\.dfTheme) private var theme

    public let configuration: Configuration
    @State private var selectedPeriod: DFAnalyticsPeriod = .thirtyDays

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                DFAnalyticsPeriodSelector(selected: $selectedPeriod)
                    .onChange(of: selectedPeriod) { _, period in
                        configuration.onPeriodChange?(period)
                    }

                if configuration.isLoading {
                    skeletonState
                } else {
                    heroSection
                    mrrCardsSection
                    mrrChartSection
                    churnSection
                    secondaryMetricsSection
                    revenueByPlanSection
                    topCustomersSection
                }
            }
            .padding(.vertical, theme.spacing.md)
        }
        .navigationTitle("Revenue")
    }

    // MARK: - Sections

    @ViewBuilder
    private var heroSection: some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                DFText("MRR", style: .caption)
                    .foregroundStyle(theme.colors.textSecondary)
                DFText(configuration.mrrValue, style: .largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.colors.textPrimary)
                HStack(spacing: theme.spacing.xxs) {
                    Image(systemName: configuration.mrrDeltaIsPositive ? "arrow.up.right" : "arrow.down.right")
                        .imageScale(.small)
                    DFText("\(configuration.mrrDelta) vs last month", style: .caption)
                }
                .foregroundStyle(configuration.mrrDeltaIsPositive ? theme.colors.success : theme.colors.destructive)
                DFText(configuration.arrLabel, style: .caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.md)
        }
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var mrrCardsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(configuration.mrrCards, id: \.label) { card in
                    DFStatCardBlock(
                        configuration: .init(
                            label: card.label,
                            value: card.value,
                            delta: card.delta,
                            deltaIsPositive: card.deltaIsPositive
                        )
                    )
                    .frame(width: 160)
                }
            }
            .padding(.horizontal, theme.spacing.md)
        }
    }

    @ViewBuilder
    private var mrrChartSection: some View {
        DFChartPlaceholderBlock(
            configuration: .init(
                title: "MRR Over Time",
                subtitle: selectedPeriod.label,
                chartType: .area,
                size: .large
            )
        )
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var churnSection: some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            DFProgressRingBlock(
                configuration: .init(
                    label: "Churn Rate",
                    value: configuration.churnRate,
                    total: 100,
                    centerLabel: "\(Int(configuration.churnRate))%",
                    sublabel: "Target: \(Int(configuration.churnTarget))%"
                )
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var secondaryMetricsSection: some View {
        DFMetricGridBlock(
            configuration: .init(metrics: configuration.secondaryMetrics)
        )
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var revenueByPlanSection: some View {
        DFChartPlaceholderBlock(
            configuration: .init(
                title: "Revenue by Plan",
                chartType: .donut,
                size: .medium
            )
        )
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var topCustomersSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Top Customers", style: .headline)
                .padding(.horizontal, theme.spacing.md)
            DFTable(
                configuration: .init(
                    columns: [
                        .init(id: "customer", label: "Customer", sortable: true),
                        .init(id: "plan",     label: "Plan",     sortable: true),
                        .init(id: "mrr",      label: "MRR",      sortable: true),
                        .init(id: "since",    label: "Since",    sortable: false)
                    ],
                    rows: configuration.topCustomers.map { row in
                        DFTable.Row(cells: [
                            "customer": row.customer,
                            "plan":     row.plan,
                            "mrr":      row.mrr,
                            "since":    row.since
                        ])
                    }
                )
            )
            .padding(.horizontal, theme.spacing.md)
        }
    }

    @ViewBuilder
    private var skeletonState: some View {
        VStack(spacing: theme.spacing.md) {
            ForEach([120, 80, 240, 120, 160, 160, 200] as [CGFloat], id: \.self) { h in
                DFBlockSkeletonBlock(configuration: .init(height: h))
                    .padding(.horizontal, theme.spacing.md)
            }
        }
    }
}

// MARK: - Configuration

extension DFAnalyticsRevenueScreen {

    public struct MRRCard: Sendable, Equatable {
        public let label: String
        public let value: String
        public let delta: String
        public let deltaIsPositive: Bool

        public init(label: String, value: String, delta: String, deltaIsPositive: Bool) {
            self.label = label
            self.value = value
            self.delta = delta
            self.deltaIsPositive = deltaIsPositive
        }
    }

    public struct CustomerRow: Sendable, Equatable {
        public let customer: String
        public let plan: String
        public let mrr: String
        public let since: String

        public init(customer: String, plan: String, mrr: String, since: String) {
            self.customer = customer
            self.plan = plan
            self.mrr = mrr
            self.since = since
        }
    }

    public struct Configuration {
        public let mrrValue: String
        public let mrrDelta: String
        public let mrrDeltaIsPositive: Bool
        public let arrLabel: String
        public let mrrCards: [MRRCard]
        /// Churn rate as a percentage 0–100.
        public let churnRate: Double
        /// Target churn rate shown as sublabel on the ring.
        public let churnTarget: Double
        public let secondaryMetrics: [DFMetricGridBlock.Metric]
        public let topCustomers: [CustomerRow]
        public var isLoading: Bool
        public var onPeriodChange: (@MainActor (DFAnalyticsPeriod) -> Void)?

        public init(
            mrrValue: String,
            mrrDelta: String,
            mrrDeltaIsPositive: Bool,
            arrLabel: String,
            mrrCards: [MRRCard],
            churnRate: Double,
            churnTarget: Double,
            secondaryMetrics: [DFMetricGridBlock.Metric],
            topCustomers: [CustomerRow],
            isLoading: Bool = false,
            onPeriodChange: (@MainActor (DFAnalyticsPeriod) -> Void)? = nil
        ) {
            self.mrrValue = mrrValue
            self.mrrDelta = mrrDelta
            self.mrrDeltaIsPositive = mrrDeltaIsPositive
            self.arrLabel = arrLabel
            self.mrrCards = mrrCards
            self.churnRate = churnRate
            self.churnTarget = churnTarget
            self.secondaryMetrics = secondaryMetrics
            self.topCustomers = topCustomers
            self.isLoading = isLoading
            self.onPeriodChange = onPeriodChange
        }
    }
}
```

- [ ] **Step 4: Create previews**

Create `Sources/DesignFoundationScreens/Analytics/Revenue/DFAnalyticsRevenueScreen+Previews.swift`:

```swift
// Sources/DesignFoundationScreens/Analytics/Revenue/DFAnalyticsRevenueScreen+Previews.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

private extension DFAnalyticsRevenueScreen.Configuration {
    static let sample = DFAnalyticsRevenueScreen.Configuration(
        mrrValue: "$14,200",
        mrrDelta: "+12.4%",
        mrrDeltaIsPositive: true,
        arrLabel: "ARR $170,400",
        mrrCards: [
            .init(label: "New MRR",       value: "$3,400", delta: "+18%",  deltaIsPositive: true),
            .init(label: "Expansion MRR", value: "$1,100", delta: "+5%",   deltaIsPositive: true),
            .init(label: "Churned MRR",   value: "$420",   delta: "+2%",   deltaIsPositive: false),
            .init(label: "Net New MRR",   value: "$4,080", delta: "+21%",  deltaIsPositive: true)
        ],
        churnRate: 2.1,
        churnTarget: 2.0,
        secondaryMetrics: [
            .init(label: "ARPU",                 value: "$47"),
            .init(label: "LTV",                  value: "$2,256"),
            .init(label: "Payback Period",        value: "8 mo"),
            .init(label: "Trial Conversion %",   value: "28%"),
            .init(label: "Active Subscriptions", value: "302"),
            .init(label: "Trials Active",        value: "89")
        ],
        topCustomers: [
            .init(customer: "Acme Corp",     plan: "Enterprise", mrr: "$2,400", since: "Jan 2023"),
            .init(customer: "Globex Inc",    plan: "Pro",        mrr: "$1,200", since: "Mar 2023"),
            .init(customer: "Initech",       plan: "Pro",        mrr: "$1,200", since: "Jun 2023"),
            .init(customer: "Umbrella Ltd",  plan: "Growth",     mrr: "$800",   since: "Sep 2023"),
            .init(customer: "Duff Beer Co",  plan: "Growth",     mrr: "$800",   since: "Nov 2023")
        ]
    )
}

#Preview("Light") {
    NavigationStack {
        DFAnalyticsRevenueScreen(configuration: .sample)
    }
}

#Preview("Dark") {
    NavigationStack {
        DFAnalyticsRevenueScreen(configuration: .sample)
    }
    .colorScheme(.dark)
}

#Preview("Loading") {
    NavigationStack {
        DFAnalyticsRevenueScreen(
            configuration: .init(
                mrrValue: "", mrrDelta: "", mrrDeltaIsPositive: true,
                arrLabel: "", mrrCards: [], churnRate: 0, churnTarget: 2,
                secondaryMetrics: [], topCustomers: [], isLoading: true
            )
        )
    }
}
```

- [ ] **Step 5: Run tests — all pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAnalyticsRevenueScreenTests 2>&1 | tail -20
```

Expected: all tests pass, 0 failures.

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Analytics/Revenue/ Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsRevenueScreenTests.swift
git commit -m "feat(screens): add DFAnalyticsRevenueScreen with MRR hero, churn ring, and sortable customer table"
```

---

## Task 4: DFAnalyticsUsersScreen

*Acquisition and retention — are people coming back.*

**Files:**
- Create: `Sources/DesignFoundationScreens/Analytics/Users/DFAnalyticsUsersScreen.swift`
- Create: `Sources/DesignFoundationScreens/Analytics/Users/DFAnalyticsUsersScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsUsersScreenTests.swift`

**Interfaces:**
- Consumes: `DFAnalyticsPeriodSelector`, `DFStatCardBlock`, `DFChartPlaceholderBlock`, `DFProgressRingBlock`, `DFMetricGridBlock`, `DFActivityFeedBlock`, `DFBadge`, `DFTheme`
- Produces: `DFAnalyticsUsersScreen`

**Layout (top → bottom):**
1. `DFAnalyticsPeriodSelector`
2. `DFStatCardBlock` row: Total Users / DAU / MAU / DAU/MAU Ratio
3. `DFChartPlaceholderBlock(.large)` — New Users over time (bar chart zone)
4. `DFProgressRingBlock` — 30-day retention ring with percentage center label
5. `DFChartPlaceholderBlock(.medium)` — Retention cohort grid placeholder (heatmap zone, labeled "Cohort Retention")
6. `DFMetricGridBlock` — 4 metrics: Avg Session Length, Sessions/User, Feature Adoption %, Support Tickets/User
7. Recent signups: `DFActivityFeedBlock` with rows carrying a source `DFBadge` (Organic / Referral / Paid)
8. `DFChartPlaceholderBlock(.medium)` — Acquisition by Channel (horizontal bar zone)

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsUsersScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFAnalyticsUsersScreen")
struct DFAnalyticsUsersScreenTests {

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("isLoading defaults to false")
        func isLoadingDefaultsFalse() {
            let config = DFAnalyticsUsersScreen.Configuration(
                statCards: [],
                retentionRate: 0,
                secondaryMetrics: [],
                recentSignups: []
            )
            #expect(config.isLoading == false)
        }
    }

    @Suite("AcquisitionSource")
    struct AcquisitionSourceTests {
        @Test("organic label")
        func organicLabel() {
            #expect(DFAnalyticsUsersScreen.AcquisitionSource.organic.label == "Organic")
        }

        @Test("referral label")
        func referralLabel() {
            #expect(DFAnalyticsUsersScreen.AcquisitionSource.referral.label == "Referral")
        }

        @Test("paid label")
        func paidLabel() {
            #expect(DFAnalyticsUsersScreen.AcquisitionSource.paid.label == "Paid")
        }
    }

    @Suite("SignupRow model")
    struct SignupRowTests {
        @Test("stores all fields")
        func storesAllFields() {
            let row = DFAnalyticsUsersScreen.SignupRow(
                identifier: "alice@example.com",
                source: .referral,
                timestamp: "5m ago"
            )
            #expect(row.identifier == "alice@example.com")
            #expect(row.source == .referral)
            #expect(row.timestamp == "5m ago")
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let screen = DFAnalyticsUsersScreen(
                configuration: .init(
                    statCards: [],
                    retentionRate: 72,
                    secondaryMetrics: [],
                    recentSignups: []
                )
            )
            #expect(type(of: screen) == DFAnalyticsUsersScreen.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAnalyticsUsersScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFAnalyticsUsersScreen` not found.

- [ ] **Step 3: Implement `DFAnalyticsUsersScreen`**

Create `Sources/DesignFoundationScreens/Analytics/Users/DFAnalyticsUsersScreen.swift`:

```swift
// Sources/DesignFoundationScreens/Analytics/Users/DFAnalyticsUsersScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

/// Acquisition and retention screen — are people coming back?
public struct DFAnalyticsUsersScreen: View {
    @Environment(\.dfTheme) private var theme

    public let configuration: Configuration
    @State private var selectedPeriod: DFAnalyticsPeriod = .thirtyDays

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                DFAnalyticsPeriodSelector(selected: $selectedPeriod)
                    .onChange(of: selectedPeriod) { _, period in
                        configuration.onPeriodChange?(period)
                    }

                if configuration.isLoading {
                    skeletonState
                } else {
                    statCardsSection
                    newUsersChartSection
                    retentionSection
                    secondaryMetricsSection
                    recentSignupsSection
                    acquisitionChartSection
                }
            }
            .padding(.vertical, theme.spacing.md)
        }
        .navigationTitle("Users")
    }

    // MARK: - Sections

    @ViewBuilder
    private var statCardsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(configuration.statCards, id: \.label) { card in
                    DFStatCardBlock(
                        configuration: .init(
                            label: card.label,
                            value: card.value,
                            delta: card.delta,
                            deltaIsPositive: card.deltaIsPositive
                        )
                    )
                    .frame(width: 160)
                }
            }
            .padding(.horizontal, theme.spacing.md)
        }
    }

    @ViewBuilder
    private var newUsersChartSection: some View {
        DFChartPlaceholderBlock(
            configuration: .init(
                title: "New Users",
                subtitle: selectedPeriod.label,
                chartType: .bar,
                size: .large
            )
        )
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var retentionSection: some View {
        HStack(spacing: theme.spacing.md) {
            DFProgressRingBlock(
                configuration: .init(
                    label: "30-Day Retention",
                    value: configuration.retentionRate,
                    total: 100,
                    centerLabel: "\(Int(configuration.retentionRate))%"
                )
            )
            .frame(maxWidth: .infinity)

            DFChartPlaceholderBlock(
                configuration: .init(
                    title: "Cohort Retention",
                    chartType: .heatmap,
                    size: .medium
                )
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var secondaryMetricsSection: some View {
        DFMetricGridBlock(
            configuration: .init(metrics: configuration.secondaryMetrics)
        )
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var recentSignupsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Recent Signups", style: .headline)
                .padding(.horizontal, theme.spacing.md)
            DFActivityFeedBlock(
                configuration: .init(
                    items: configuration.recentSignups.map { signup in
                        DFActivityFeedRow.Configuration(
                            icon: "person.fill.badge.plus",
                            title: signup.identifier,
                            subtitle: signup.source.label,
                            timestamp: signup.timestamp,
                            badge: .init(label: signup.source.label, color: signup.source.badgeColor)
                        )
                    }
                )
            )
        }
    }

    @ViewBuilder
    private var acquisitionChartSection: some View {
        DFChartPlaceholderBlock(
            configuration: .init(
                title: "Acquisition by Channel",
                chartType: .horizontalBar,
                size: .medium
            )
        )
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var skeletonState: some View {
        VStack(spacing: theme.spacing.md) {
            ForEach([80, 240, 160, 160, 200, 160] as [CGFloat], id: \.self) { h in
                DFBlockSkeletonBlock(configuration: .init(height: h))
                    .padding(.horizontal, theme.spacing.md)
            }
        }
    }
}

// MARK: - Configuration

extension DFAnalyticsUsersScreen {

    public enum AcquisitionSource: String, Sendable, Equatable, CaseIterable {
        case organic
        case referral
        case paid

        public var label: String {
            switch self {
            case .organic:  return "Organic"
            case .referral: return "Referral"
            case .paid:     return "Paid"
            }
        }

        /// Theme-mapped badge color key — actual color resolved via DFTheme at render time.
        var badgeColor: DFBadge.BadgeColor {
            switch self {
            case .organic:  return .success
            case .referral: return .accent
            case .paid:     return .warning
            }
        }
    }

    public struct StatCard: Sendable, Equatable {
        public let label: String
        public let value: String
        public let delta: String
        public let deltaIsPositive: Bool

        public init(label: String, value: String, delta: String, deltaIsPositive: Bool) {
            self.label = label
            self.value = value
            self.delta = delta
            self.deltaIsPositive = deltaIsPositive
        }
    }

    public struct SignupRow: Sendable, Equatable {
        public let identifier: String
        public let source: AcquisitionSource
        public let timestamp: String

        public init(identifier: String, source: AcquisitionSource, timestamp: String) {
            self.identifier = identifier
            self.source = source
            self.timestamp = timestamp
        }
    }

    public struct Configuration {
        public let statCards: [StatCard]
        /// 30-day retention rate 0–100.
        public let retentionRate: Double
        public let secondaryMetrics: [DFMetricGridBlock.Metric]
        public let recentSignups: [SignupRow]
        public var isLoading: Bool
        public var onPeriodChange: (@MainActor (DFAnalyticsPeriod) -> Void)?

        public init(
            statCards: [StatCard],
            retentionRate: Double,
            secondaryMetrics: [DFMetricGridBlock.Metric],
            recentSignups: [SignupRow],
            isLoading: Bool = false,
            onPeriodChange: (@MainActor (DFAnalyticsPeriod) -> Void)? = nil
        ) {
            self.statCards = statCards
            self.retentionRate = retentionRate
            self.secondaryMetrics = secondaryMetrics
            self.recentSignups = recentSignups
            self.isLoading = isLoading
            self.onPeriodChange = onPeriodChange
        }
    }
}
```

- [ ] **Step 4: Create previews**

Create `Sources/DesignFoundationScreens/Analytics/Users/DFAnalyticsUsersScreen+Previews.swift`:

```swift
// Sources/DesignFoundationScreens/Analytics/Users/DFAnalyticsUsersScreen+Previews.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

private extension DFAnalyticsUsersScreen.Configuration {
    static let sample = DFAnalyticsUsersScreen.Configuration(
        statCards: [
            .init(label: "Total Users",    value: "12,841", delta: "+8.3%",  deltaIsPositive: true),
            .init(label: "DAU",            value: "2,104",  delta: "+4.1%",  deltaIsPositive: true),
            .init(label: "MAU",            value: "8,930",  delta: "+6.7%",  deltaIsPositive: true),
            .init(label: "DAU/MAU Ratio",  value: "23.6%",  delta: "-0.8%",  deltaIsPositive: false)
        ],
        retentionRate: 67,
        secondaryMetrics: [
            .init(label: "Avg Session Length",  value: "4m 12s"),
            .init(label: "Sessions/User",       value: "3.4"),
            .init(label: "Feature Adoption %",  value: "58%"),
            .init(label: "Tickets/User",        value: "0.08")
        ],
        recentSignups: [
            .init(identifier: "alice@startup.io",  source: .referral, timestamp: "2m ago"),
            .init(identifier: "bob@example.com",   source: .organic,  timestamp: "8m ago"),
            .init(identifier: "carol@agency.co",   source: .paid,     timestamp: "15m ago"),
            .init(identifier: "dave@corp.net",     source: .organic,  timestamp: "22m ago"),
            .init(identifier: "eve@freelance.io",  source: .referral, timestamp: "31m ago")
        ]
    )
}

#Preview("Light") {
    NavigationStack {
        DFAnalyticsUsersScreen(configuration: .sample)
    }
}

#Preview("Dark") {
    NavigationStack {
        DFAnalyticsUsersScreen(configuration: .sample)
    }
    .colorScheme(.dark)
}

#Preview("Loading") {
    NavigationStack {
        DFAnalyticsUsersScreen(
            configuration: .init(
                statCards: [], retentionRate: 0,
                secondaryMetrics: [], recentSignups: [], isLoading: true
            )
        )
    }
}
```

- [ ] **Step 5: Run tests — all pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAnalyticsUsersScreenTests 2>&1 | tail -20
```

Expected: all tests pass, 0 failures.

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Analytics/Users/ Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsUsersScreenTests.swift
git commit -m "feat(screens): add DFAnalyticsUsersScreen with stat cards, retention ring, cohort placeholder, and signup feed"
```

---

## Task 5: DFAnalyticsEventsScreen

*The live event feed — what's happening right now.*

**Files:**
- Create: `Sources/DesignFoundationScreens/Analytics/Events/DFAnalyticsEventsScreen.swift`
- Create: `Sources/DesignFoundationScreens/Analytics/Events/DFAnalyticsEventsScreen+Previews.swift`
- Create: `Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsEventsScreenTests.swift`

**Interfaces:**
- Consumes: `DFActivityFeedBlock`, `DFTagPickerBlock`, `DFChartPlaceholderBlock`, `DFSearchResultsBlock`, `DFEmptyStateBlock`, `DFBadge`, `DFButton`, `DFTheme`
- Produces: `DFAnalyticsEventsScreen`

**Layout (top → bottom):**
1. Nav bar: title "Events", trailing Export button (`DFButton(.ghost)`)
2. Live indicator row: pulsing "● LIVE" badge + "Last updated X ago" `DFText`
3. `DFTagPickerBlock` — filter chips: All Events / Errors / Conversions / Custom
4. Search: `DFSearchResultsBlock` pattern (search input, results inline below)
5. `DFChartPlaceholderBlock(.small)` — event volume sparkline (auto-updates label when `lastUpdated` changes)
6. `DFActivityFeedBlock` — real-time event stream rows: event name, user identifier, properties summary, timestamp
7. `DFEmptyStateBlock` when `filteredEvents` is empty

**Live auto-refresh:** The screen accepts `lastUpdated: Date` and `onRefresh: @MainActor () -> Void` — the caller drives the timer; the screen renders the state it receives. No `Timer` inside the view.

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsEventsScreenTests.swift
import Testing
import SwiftUI
import Foundation
@testable import DesignFoundationScreens

@Suite("DFAnalyticsEventsScreen")
struct DFAnalyticsEventsScreenTests {

    @Suite("EventFilter")
    struct EventFilterTests {
        @Test("all cases have distinct labels")
        func distinctLabels() {
            let labels = DFAnalyticsEventsScreen.EventFilter.allCases.map(\.label)
            let unique = Set(labels)
            #expect(unique.count == DFAnalyticsEventsScreen.EventFilter.allCases.count)
        }

        @Test("all label is first")
        func allLabelIsFirst() {
            #expect(DFAnalyticsEventsScreen.EventFilter.allCases.first == .all)
        }
    }

    @Suite("EventRow model")
    struct EventRowTests {
        @Test("stores all fields")
        func storesAllFields() {
            let row = DFAnalyticsEventsScreen.EventRow(
                id: UUID(),
                eventName: "page_view",
                userIdentifier: "user_abc123",
                propertiesSummary: "path=/dashboard, ref=email",
                timestamp: "just now",
                filter: .all
            )
            #expect(row.eventName == "page_view")
            #expect(row.userIdentifier == "user_abc123")
        }
    }

    @Suite("Configuration defaults")
    struct DefaultsTests {
        @Test("searchQuery defaults to empty")
        func searchQueryDefaultsEmpty() {
            let config = DFAnalyticsEventsScreen.Configuration(
                events: [],
                lastUpdated: Date()
            )
            #expect(config.searchQuery == "")
        }

        @Test("selectedFilter defaults to all")
        func selectedFilterDefaultsAll() {
            let config = DFAnalyticsEventsScreen.Configuration(
                events: [],
                lastUpdated: Date()
            )
            #expect(config.selectedFilter == .all)
        }
    }

    @Suite("Filtering logic")
    struct FilteringTests {
        @Test("all filter returns all events")
        func allFilterReturnsAll() {
            let events: [DFAnalyticsEventsScreen.EventRow] = [
                .init(id: UUID(), eventName: "page_view",    userIdentifier: "u1", propertiesSummary: "", timestamp: "", filter: .all),
                .init(id: UUID(), eventName: "error_thrown", userIdentifier: "u2", propertiesSummary: "", timestamp: "", filter: .errors),
                .init(id: UUID(), eventName: "conversion",   userIdentifier: "u3", propertiesSummary: "", timestamp: "", filter: .conversions)
            ]
            let config = DFAnalyticsEventsScreen.Configuration(
                events: events,
                lastUpdated: Date(),
                selectedFilter: .all
            )
            #expect(config.filteredEvents.count == 3)
        }

        @Test("errors filter returns only error events")
        func errorsFilterReturnsErrors() {
            let events: [DFAnalyticsEventsScreen.EventRow] = [
                .init(id: UUID(), eventName: "page_view",    userIdentifier: "u1", propertiesSummary: "", timestamp: "", filter: .all),
                .init(id: UUID(), eventName: "error_thrown", userIdentifier: "u2", propertiesSummary: "", timestamp: "", filter: .errors)
            ]
            let config = DFAnalyticsEventsScreen.Configuration(
                events: events,
                lastUpdated: Date(),
                selectedFilter: .errors
            )
            #expect(config.filteredEvents.count == 1)
            #expect(config.filteredEvents.first?.eventName == "error_thrown")
        }

        @Test("search query filters by event name")
        func searchFiltersEventName() {
            let events: [DFAnalyticsEventsScreen.EventRow] = [
                .init(id: UUID(), eventName: "page_view",   userIdentifier: "u1", propertiesSummary: "", timestamp: "", filter: .all),
                .init(id: UUID(), eventName: "button_click", userIdentifier: "u2", propertiesSummary: "", timestamp: "", filter: .all)
            ]
            let config = DFAnalyticsEventsScreen.Configuration(
                events: events,
                lastUpdated: Date(),
                searchQuery: "button"
            )
            #expect(config.filteredEvents.count == 1)
            #expect(config.filteredEvents.first?.eventName == "button_click")
        }
    }

    @Suite("View creation")
    struct ViewCreationTests {
        @Test("initializes without crashing")
        func initializesWithoutCrashing() {
            let screen = DFAnalyticsEventsScreen(
                configuration: .init(events: [], lastUpdated: Date())
            )
            #expect(type(of: screen) == DFAnalyticsEventsScreen.self)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAnalyticsEventsScreenTests 2>&1 | tail -20
```

Expected: compile error — `DFAnalyticsEventsScreen` not found.

- [ ] **Step 3: Implement `DFAnalyticsEventsScreen`**

Create `Sources/DesignFoundationScreens/Analytics/Events/DFAnalyticsEventsScreen.swift`:

```swift
// Sources/DesignFoundationScreens/Analytics/Events/DFAnalyticsEventsScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

/// Live event feed — what's happening right now across the product.
/// The caller owns the refresh timer; this screen renders state it receives.
public struct DFAnalyticsEventsScreen: View {
    @Environment(\.dfTheme) private var theme

    public let configuration: Configuration
    @State private var searchText: String = ""
    @State private var selectedFilter: EventFilter = .all

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: 0) {
            liveIndicatorBar
            DFDivider()
            filterChipsRow
            searchRow
            volumeSparkline
            DFDivider()
            eventFeedOrEmpty
        }
        .navigationTitle("Events")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                DFButton("Export", style: .ghost, action: {
                    configuration.onExport?()
                })
            }
        }
    }

    // MARK: - Computed filtered events

    private var effectiveConfig: Configuration {
        Configuration(
            events: configuration.events,
            lastUpdated: configuration.lastUpdated,
            searchQuery: searchText,
            selectedFilter: selectedFilter,
            onExport: configuration.onExport,
            onRefresh: configuration.onRefresh
        )
    }

    private var displayedEvents: [EventRow] {
        effectiveConfig.filteredEvents
    }

    // MARK: - Subviews

    @ViewBuilder
    private var liveIndicatorBar: some View {
        HStack(spacing: theme.spacing.sm) {
            DFBadge("● LIVE", color: .destructive)
            DFText(lastUpdatedLabel, style: .caption)
                .foregroundStyle(theme.colors.textSecondary)
            Spacer()
            DFButton("Refresh", style: .ghost, size: .small, action: {
                configuration.onRefresh?()
            })
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.xs)
    }

    private var lastUpdatedLabel: String {
        let interval = Date().timeIntervalSince(configuration.lastUpdated)
        if interval < 60 { return "Updated just now" }
        let minutes = Int(interval / 60)
        return "Updated \(minutes)m ago"
    }

    @ViewBuilder
    private var filterChipsRow: some View {
        DFTagPickerBlock(
            configuration: .init(
                tags: EventFilter.allCases.map { filter in
                    DFTagPickerBlock.Tag(
                        id: filter.rawValue,
                        label: filter.label,
                        isSelected: selectedFilter == filter
                    )
                },
                onSelect: { tagId in
                    if let filter = EventFilter(rawValue: tagId) {
                        selectedFilter = filter
                    }
                }
            )
        )
        .padding(.vertical, theme.spacing.xs)
    }

    @ViewBuilder
    private var searchRow: some View {
        DFSearchResultsBlock(
            configuration: .init(
                placeholder: "Search events…",
                query: $searchText,
                results: [] // results are shown inline in the feed; search drives filtering
            )
        )
        .padding(.horizontal, theme.spacing.md)
        .padding(.bottom, theme.spacing.xs)
    }

    @ViewBuilder
    private var volumeSparkline: some View {
        DFChartPlaceholderBlock(
            configuration: .init(
                title: "Event Volume",
                subtitle: lastUpdatedLabel,
                chartType: .sparkline,
                size: .small
            )
        )
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.xs)
    }

    @ViewBuilder
    private var eventFeedOrEmpty: some View {
        if displayedEvents.isEmpty {
            DFEmptyStateBlock(
                configuration: .init(
                    icon: "antenna.radiowaves.left.and.right.slash",
                    title: "No events",
                    message: searchText.isEmpty
                        ? "No events match the selected filter."
                        : "No events match "\(searchText)".",
                    actionTitle: "Clear Filter",
                    onAction: {
                        searchText = ""
                        selectedFilter = .all
                    }
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            DFActivityFeedBlock(
                configuration: .init(
                    items: displayedEvents.map { event in
                        DFActivityFeedRow.Configuration(
                            icon: event.filter.icon,
                            title: event.eventName,
                            subtitle: "\(event.userIdentifier) · \(event.propertiesSummary)",
                            timestamp: event.timestamp
                        )
                    }
                )
            )
        }
    }
}

// MARK: - Supporting Types

extension DFAnalyticsEventsScreen {

    public enum EventFilter: String, Sendable, Equatable, CaseIterable {
        case all
        case errors
        case conversions
        case custom

        public var label: String {
            switch self {
            case .all:         return "All Events"
            case .errors:      return "Errors"
            case .conversions: return "Conversions"
            case .custom:      return "Custom"
            }
        }

        var icon: String {
            switch self {
            case .all:         return "bolt.fill"
            case .errors:      return "exclamationmark.triangle.fill"
            case .conversions: return "checkmark.circle.fill"
            case .custom:      return "star.fill"
            }
        }
    }

    public struct EventRow: Sendable, Equatable, Identifiable {
        public let id: UUID
        public let eventName: String
        public let userIdentifier: String
        public let propertiesSummary: String
        public let timestamp: String
        /// Which filter bucket this event belongs to; `.all` means it matches every filter.
        public let filter: EventFilter

        public init(
            id: UUID = UUID(),
            eventName: String,
            userIdentifier: String,
            propertiesSummary: String,
            timestamp: String,
            filter: EventFilter
        ) {
            self.id = id
            self.eventName = eventName
            self.userIdentifier = userIdentifier
            self.propertiesSummary = propertiesSummary
            self.timestamp = timestamp
            self.filter = filter
        }
    }

    public struct Configuration {
        public let events: [EventRow]
        public let lastUpdated: Date
        public var searchQuery: String
        public var selectedFilter: EventFilter
        public var onExport: (@MainActor () -> Void)?
        public var onRefresh: (@MainActor () -> Void)?

        public init(
            events: [EventRow],
            lastUpdated: Date,
            searchQuery: String = "",
            selectedFilter: EventFilter = .all,
            onExport: (@MainActor () -> Void)? = nil,
            onRefresh: (@MainActor () -> Void)? = nil
        ) {
            self.events = events
            self.lastUpdated = lastUpdated
            self.searchQuery = searchQuery
            self.selectedFilter = selectedFilter
            self.onExport = onExport
            self.onRefresh = onRefresh
        }

        /// Events filtered by both `selectedFilter` and `searchQuery`.
        public var filteredEvents: [EventRow] {
            events
                .filter { event in
                    selectedFilter == .all || event.filter == selectedFilter
                }
                .filter { event in
                    guard !searchQuery.isEmpty else { return true }
                    let q = searchQuery.lowercased()
                    return event.eventName.lowercased().contains(q)
                        || event.userIdentifier.lowercased().contains(q)
                        || event.propertiesSummary.lowercased().contains(q)
                }
        }
    }
}
```

- [ ] **Step 4: Create previews**

Create `Sources/DesignFoundationScreens/Analytics/Events/DFAnalyticsEventsScreen+Previews.swift`:

```swift
// Sources/DesignFoundationScreens/Analytics/Events/DFAnalyticsEventsScreen+Previews.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

private let sampleEvents: [DFAnalyticsEventsScreen.EventRow] = [
    .init(eventName: "page_view",       userIdentifier: "user_a3x9",  propertiesSummary: "path=/dashboard",           timestamp: "just now",  filter: .all),
    .init(eventName: "button_click",    userIdentifier: "user_b7k2",  propertiesSummary: "id=cta_hero, label=Sign up", timestamp: "3s ago",    filter: .conversions),
    .init(eventName: "api_error",       userIdentifier: "user_c1m8",  propertiesSummary: "status=503, endpoint=/sync", timestamp: "8s ago",    filter: .errors),
    .init(eventName: "checkout_start",  userIdentifier: "user_d4p5",  propertiesSummary: "plan=Pro, cycle=annual",     timestamp: "12s ago",   filter: .conversions),
    .init(eventName: "js_exception",    userIdentifier: "user_e9r3",  propertiesSummary: "TypeError in BillingForm",   timestamp: "21s ago",   filter: .errors),
    .init(eventName: "feature_flag",    userIdentifier: "user_f2n7",  propertiesSummary: "flag=new_editor, val=true",  timestamp: "35s ago",   filter: .custom),
    .init(eventName: "page_view",       userIdentifier: "user_g6l1",  propertiesSummary: "path=/pricing",             timestamp: "44s ago",   filter: .all),
    .init(eventName: "signup_complete", userIdentifier: "user_h0q4",  propertiesSummary: "method=email, ref=product_hunt", timestamp: "1m ago", filter: .conversions)
]

#Preview("Light") {
    NavigationStack {
        DFAnalyticsEventsScreen(
            configuration: .init(
                events: sampleEvents,
                lastUpdated: Date()
            )
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFAnalyticsEventsScreen(
            configuration: .init(
                events: sampleEvents,
                lastUpdated: Date()
            )
        )
    }
    .colorScheme(.dark)
}

#Preview("Errors Only") {
    NavigationStack {
        DFAnalyticsEventsScreen(
            configuration: .init(
                events: sampleEvents,
                lastUpdated: Date(),
                selectedFilter: .errors
            )
        )
    }
}

#Preview("Empty State") {
    NavigationStack {
        DFAnalyticsEventsScreen(
            configuration: .init(
                events: [],
                lastUpdated: Date()
            )
        )
    }
}
```

- [ ] **Step 5: Run tests — all pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFAnalyticsEventsScreenTests 2>&1 | tail -20
```

Expected: all tests pass, 0 failures.

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Analytics/Events/ Tests/DesignFoundationScreensTests/Analytics/DFAnalyticsEventsScreenTests.swift
git commit -m "feat(screens): add DFAnalyticsEventsScreen with live feed, filter chips, search, and empty state"
```

---

## Task 6: Full Test Suite Run + Verification

- [ ] **Step 1: Run all Analytics tests**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter Analytics 2>&1 | tail -40
```

Expected: all suites pass, 0 failures across `DFAnalyticsPeriodTests`, `DFAnalyticsOverviewScreenTests`, `DFAnalyticsRevenueScreenTests`, `DFAnalyticsUsersScreenTests`, `DFAnalyticsEventsScreenTests`.

- [ ] **Step 2: Verify the full package still builds**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift build 2>&1 | tail -20
```

Expected: build succeeds, 0 errors, 0 warnings about strict concurrency.

- [ ] **Step 3: Spot-check preview files compile**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift build --target DesignFoundationScreens 2>&1 | grep -i error | head -20
```

Expected: no output (no errors).

- [ ] **Step 4: Final verification commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add -A
git commit -m "feat(screens): analytics dashboard vertical complete — 4 screens, shared period model, full test suite green"
```

---

## Summary

| Task | Screen / Component | Key blocks used | Tests |
|------|--------------------|-----------------|-------|
| 1 | `DFAnalyticsPeriod` + `DFAnalyticsPeriodSelector` | `DFButton`, `DFDateRangeBlock` | `DFAnalyticsPeriodTests` |
| 2 | `DFAnalyticsOverviewScreen` | `DFMetricGridBlock`, `DFChartPlaceholderBlock` ×2, `DFActivityFeedBlock`, `DFBlockSkeletonBlock`, `DFCard` | `DFAnalyticsOverviewScreenTests` |
| 3 | `DFAnalyticsRevenueScreen` | `DFStatCardBlock` ×4, `DFChartPlaceholderBlock` ×2, `DFProgressRingBlock`, `DFMetricGridBlock`, `DFTable` | `DFAnalyticsRevenueScreenTests` |
| 4 | `DFAnalyticsUsersScreen` | `DFStatCardBlock` ×4, `DFChartPlaceholderBlock` ×3, `DFProgressRingBlock`, `DFMetricGridBlock`, `DFActivityFeedBlock`, `DFBadge` | `DFAnalyticsUsersScreenTests` |
| 5 | `DFAnalyticsEventsScreen` | `DFActivityFeedBlock`, `DFTagPickerBlock`, `DFChartPlaceholderBlock`, `DFSearchResultsBlock`, `DFEmptyStateBlock`, `DFBadge`, `DFButton` | `DFAnalyticsEventsScreenTests` |
| 6 | Full suite run + build verification | — | All 5 suites |
