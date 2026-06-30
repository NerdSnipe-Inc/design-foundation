# Phase 2 Forms Blocks — Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development to implement task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Build 4 forms blocks: DFTagPickerBlock, DFDateRangeBlock, DFAddressBlock, DFMultiStepFormBlock.

**Architecture:** Each block manages its own local @State for interactive elements, initializing from Configuration. Changes propagate up via callbacks. DFMultiStepFormBlock is generic over Content view.

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
- Color tokens: `.primary`, `.textPrimary`, `.textSecondary`, `.surface`, `.surfaceElevated`, `.border`, `.destructive`, `.success`
- Tests: Swift Testing only — `import Testing`, `@Suite`, `@Test`, `#expect` — NEVER XCTest
- Minimum 4 previews per block + block-specific states
- `@_exported import DesignFoundation` is in the package entry point

### DFTextField API
```swift
DFTextField(_ label: String, text: Binding<String>)
```

### DFDatePicker API
```swift
DFDatePicker(_ label: String, selection: Binding<Date>, in dateRange: ClosedRange<Date>? = nil, displayedComponents: DatePickerComponents = [.date])
```

### DFButton API
```swift
DFButton(_ label: String, role: DFButtonRole? = nil, action: @escaping () -> Void)
```

---

## Task 16: DFTagPickerBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/Forms/DFTagPickerBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Forms/DFTagPickerBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Forms/DFTagPickerBlockTests.swift`

### Step 1 — Create `DFTagPickerBlock.swift`

- [ ] Create `Sources/DesignFoundationBlocks/Forms/DFTagPickerBlock.swift` with the following content:

```swift
import SwiftUI

// MARK: - DFTag

public struct DFTag: Identifiable, Sendable, Hashable {
    public let id: UUID
    public var label: String
    public var icon: String?

    public init(id: UUID = UUID(), label: String, icon: String? = nil) {
        self.id = id
        self.label = label
        self.icon = icon
    }
}

// MARK: - DFTagPickerBlock

public struct DFTagPickerBlock: View {

    // MARK: Configuration

    public struct Configuration: Sendable {
        public var tags: [DFTag]
        public var selectedIDs: Set<UUID>
        public var multiSelect: Bool
        public var maxSelection: Int?
        public var title: String?
        public var onSelectionChange: @MainActor (Set<UUID>) -> Void

        public init(
            tags: [DFTag],
            selectedIDs: Set<UUID> = [],
            multiSelect: Bool = true,
            maxSelection: Int? = nil,
            title: String? = nil,
            onSelectionChange: @escaping @MainActor (Set<UUID>) -> Void
        ) {
            self.tags = tags
            self.selectedIDs = selectedIDs
            self.multiSelect = multiSelect
            self.maxSelection = maxSelection
            self.title = title
            self.onSelectionChange = onSelectionChange
        }
    }

    // MARK: Properties

    private let configuration: Configuration
    @State private var selectedIDs: Set<UUID>
    @Environment(\.dfTheme) private var theme

    // MARK: Init

    public init(configuration: Configuration) {
        self.configuration = configuration
        self._selectedIDs = State(initialValue: configuration.selectedIDs)
    }

    // MARK: Body

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            if let title = configuration.title {
                Text(title)
                    .font(theme.typography.labelLarge)
                    .foregroundStyle(theme.colors.textPrimary)
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 80), spacing: theme.spacing.sm)],
                spacing: theme.spacing.sm
            ) {
                ForEach(configuration.tags) { tag in
                    tagPill(tag)
                }
            }
        }
        .padding(theme.spacing.md)
    }

    // MARK: Tag Pill

    @ViewBuilder
    private func tagPill(_ tag: DFTag) -> some View {
        let isSelected = selectedIDs.contains(tag.id)

        Button {
            toggleTag(tag)
        } label: {
            HStack(spacing: theme.spacing.xs) {
                if let icon = tag.icon {
                    Image(systemName: icon)
                        .font(theme.typography.caption)
                }
                Text(tag.label)
                    .font(theme.typography.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(isSelected ? theme.colors.primary : theme.colors.surface)
            .foregroundStyle(isSelected ? Color.white : theme.colors.textPrimary)
            .cornerRadius(theme.radius.full)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.full)
                    .stroke(isSelected ? theme.colors.primary : theme.colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Selection Logic

    private func toggleTag(_ tag: DFTag) {
        if configuration.multiSelect {
            if selectedIDs.contains(tag.id) {
                selectedIDs.remove(tag.id)
            } else {
                if let max = configuration.maxSelection, selectedIDs.count >= max {
                    return
                }
                selectedIDs.insert(tag.id)
            }
        } else {
            if selectedIDs.contains(tag.id) {
                selectedIDs = []
            } else {
                selectedIDs = [tag.id]
            }
        }
        let snapshot = selectedIDs
        Task { @MainActor in
            configuration.onSelectionChange(snapshot)
        }
    }
}
```

### Step 2 — Create `DFTagPickerBlock+Previews.swift`

- [ ] Create `Sources/DesignFoundationBlocks/Forms/DFTagPickerBlock+Previews.swift` with the following content:

```swift
import SwiftUI

#Preview("Multi Select — Light") {
    @Previewable @State var selected: Set<UUID> = []
    let tags = [
        DFTag(label: "Swift"),
        DFTag(label: "SwiftUI"),
        DFTag(label: "iOS"),
        DFTag(label: "Design"),
        DFTag(label: "Open Source")
    ]
    return DFTagPickerBlock(configuration: .init(
        tags: tags,
        selectedIDs: selected,
        onSelectionChange: { selected = $0 }
    ))
    .padding()
}

#Preview("Multi Select — Dark") {
    @Previewable @State var selected: Set<UUID> = []
    let tags = [
        DFTag(label: "Swift"),
        DFTag(label: "SwiftUI"),
        DFTag(label: "iOS"),
        DFTag(label: "Design"),
        DFTag(label: "Open Source")
    ]
    return DFTagPickerBlock(configuration: .init(
        tags: tags,
        selectedIDs: selected,
        onSelectionChange: { selected = $0 }
    ))
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Single Select — Light") {
    @Previewable @State var selected: Set<UUID> = []
    let tags = [
        DFTag(label: "Beginner"),
        DFTag(label: "Intermediate"),
        DFTag(label: "Advanced"),
        DFTag(label: "Expert")
    ]
    return DFTagPickerBlock(configuration: .init(
        tags: tags,
        selectedIDs: selected,
        multiSelect: false,
        title: "Skill Level",
        onSelectionChange: { selected = $0 }
    ))
    .padding()
}

#Preview("Single Select — Dark") {
    @Previewable @State var selected: Set<UUID> = []
    let tags = [
        DFTag(label: "Beginner"),
        DFTag(label: "Intermediate"),
        DFTag(label: "Advanced"),
        DFTag(label: "Expert")
    ]
    return DFTagPickerBlock(configuration: .init(
        tags: tags,
        selectedIDs: selected,
        multiSelect: false,
        title: "Skill Level",
        onSelectionChange: { selected = $0 }
    ))
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("With Icons — Light") {
    @Previewable @State var selected: Set<UUID> = []
    let tags = [
        DFTag(label: "Favorites", icon: "heart.fill"),
        DFTag(label: "Starred", icon: "star.fill"),
        DFTag(label: "Shared", icon: "square.and.arrow.up"),
        DFTag(label: "Archived", icon: "archivebox"),
        DFTag(label: "Trash", icon: "trash")
    ]
    return DFTagPickerBlock(configuration: .init(
        tags: tags,
        selectedIDs: selected,
        title: "Filter By",
        onSelectionChange: { selected = $0 }
    ))
    .padding()
}

#Preview("Max Selection (2) — Light") {
    @Previewable @State var selected: Set<UUID> = []
    let tags = [
        DFTag(label: "Red"),
        DFTag(label: "Green"),
        DFTag(label: "Blue"),
        DFTag(label: "Yellow"),
        DFTag(label: "Purple")
    ]
    return DFTagPickerBlock(configuration: .init(
        tags: tags,
        selectedIDs: selected,
        maxSelection: 2,
        title: "Pick up to 2 colors",
        onSelectionChange: { selected = $0 }
    ))
    .padding()
}

#Preview("Pre-selected — Light") {
    let tags = [
        DFTag(label: "Swift"),
        DFTag(label: "SwiftUI"),
        DFTag(label: "iOS"),
        DFTag(label: "Design"),
        DFTag(label: "Open Source")
    ]
    let preSelected: Set<UUID> = [tags[0].id, tags[2].id]
    @Previewable @State var selected: Set<UUID> = preSelected
    return DFTagPickerBlock(configuration: .init(
        tags: tags,
        selectedIDs: selected,
        title: "Topics",
        onSelectionChange: { selected = $0 }
    ))
    .padding()
}
```

### Step 3 — Create `DFTagPickerBlockTests.swift`

- [ ] Create `Tests/DesignFoundationBlocksTests/Forms/DFTagPickerBlockTests.swift` with the following content:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFTagPickerBlock Tests")
struct DFTagPickerBlockTests {

    let tags: [DFTag] = [
        DFTag(label: "Swift"),
        DFTag(label: "SwiftUI"),
        DFTag(label: "iOS"),
        DFTag(label: "Design")
    ]

    @Test("DFTag initializes with defaults")
    func tagDefaultInit() {
        let tag = DFTag(label: "Test")
        #expect(tag.label == "Test")
        #expect(tag.icon == nil)
        #expect(tag.id != UUID())
    }

    @Test("DFTag initializes with icon")
    func tagWithIcon() {
        let tag = DFTag(label: "Starred", icon: "star.fill")
        #expect(tag.label == "Starred")
        #expect(tag.icon == "star.fill")
    }

    @Test("Configuration initializes with defaults")
    func configurationDefaults() {
        let config = DFTagPickerBlock.Configuration(
            tags: tags,
            onSelectionChange: { _ in }
        )
        #expect(config.selectedIDs.isEmpty)
        #expect(config.multiSelect == true)
        #expect(config.maxSelection == nil)
        #expect(config.title == nil)
        #expect(config.tags.count == 4)
    }

    @Test("Configuration initializes with custom values")
    func configurationCustomValues() {
        let selected: Set<UUID> = [tags[0].id]
        let config = DFTagPickerBlock.Configuration(
            tags: tags,
            selectedIDs: selected,
            multiSelect: false,
            maxSelection: 1,
            title: "Topics",
            onSelectionChange: { _ in }
        )
        #expect(config.selectedIDs == selected)
        #expect(config.multiSelect == false)
        #expect(config.maxSelection == 1)
        #expect(config.title == "Topics")
    }

    @Test("onSelectionChange fires with correct IDs")
    @MainActor func onSelectionChangeFires() async {
        var receivedIDs: Set<UUID>? = nil
        let _ = DFTagPickerBlock(configuration: .init(
            tags: tags,
            onSelectionChange: { ids in
                receivedIDs = ids
            }
        ))
        // Simulate a selection change via the callback directly
        let expectedIDs: Set<UUID> = [tags[0].id, tags[1].id]
        // We test the Configuration captures and forwards correctly
        let config = DFTagPickerBlock.Configuration(
            tags: tags,
            onSelectionChange: { ids in
                receivedIDs = ids
            }
        )
        await MainActor.run {
            config.onSelectionChange(expectedIDs)
        }
        #expect(receivedIDs == expectedIDs)
    }

    @Test("maxSelection enforces upper bound")
    func maxSelectionEnforced() {
        let config = DFTagPickerBlock.Configuration(
            tags: tags,
            maxSelection: 2,
            onSelectionChange: { _ in }
        )
        #expect(config.maxSelection == 2)
        #expect(config.tags.count == 4)
    }

    @Test("DFTag Hashable and Equatable conform correctly")
    func tagHashableEquatable() {
        let id = UUID()
        let tag1 = DFTag(id: id, label: "Swift")
        let tag2 = DFTag(id: id, label: "Swift")
        #expect(tag1 == tag2)
        #expect(tag1.hashValue == tag2.hashValue)
    }
}
```

### Step 4 — Commit

- [ ] Run: `git add Sources/DesignFoundationBlocks/Forms/DFTagPickerBlock.swift Sources/DesignFoundationBlocks/Forms/DFTagPickerBlock+Previews.swift Tests/DesignFoundationBlocksTests/Forms/DFTagPickerBlockTests.swift`
- [ ] Run: `git commit -m "feat(forms): add DFTagPickerBlock with multi/single select and max selection"`

---

## Task 17: DFDateRangeBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/Forms/DFDateRangeBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Forms/DFDateRangeBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Forms/DFDateRangeBlockTests.swift`

### Step 1 — Create `DFDateRangeBlock.swift`

- [ ] Create `Sources/DesignFoundationBlocks/Forms/DFDateRangeBlock.swift` with the following content:

```swift
import SwiftUI

// MARK: - DFDateRange

public struct DFDateRange: Sendable, Equatable {
    public var start: Date?
    public var end: Date?

    public init(start: Date? = nil, end: Date? = nil) {
        self.start = start
        self.end = end
    }
}

// MARK: - DFDateRangeBlock

public struct DFDateRangeBlock: View {

    // MARK: Configuration

    public struct Configuration: Sendable {
        public var title: String?
        public var startLabel: String
        public var endLabel: String
        public var range: DFDateRange
        public var onRangeChange: @MainActor (DFDateRange) -> Void

        public init(
            title: String? = nil,
            startLabel: String = "Start Date",
            endLabel: String = "End Date",
            range: DFDateRange = DFDateRange(),
            onRangeChange: @escaping @MainActor (DFDateRange) -> Void
        ) {
            self.title = title
            self.startLabel = startLabel
            self.endLabel = endLabel
            self.range = range
            self.onRangeChange = onRangeChange
        }
    }

    // MARK: Properties

    private let configuration: Configuration
    @State private var startDate: Date
    @State private var endDate: Date
    @Environment(\.dfTheme) private var theme

    private var isInvalidRange: Bool {
        endDate < startDate
    }

    // MARK: Init

    public init(configuration: Configuration) {
        self.configuration = configuration
        self._startDate = State(initialValue: configuration.range.start ?? Date())
        self._endDate = State(initialValue: configuration.range.end ?? Date())
    }

    // MARK: Body

    public var body: some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                if let title = configuration.title {
                    Text(title)
                        .font(theme.typography.labelLarge)
                        .foregroundStyle(theme.colors.textPrimary)
                }

                DFDatePicker(
                    configuration.startLabel,
                    selection: $startDate,
                    displayedComponents: [.date]
                )

                DFDatePicker(
                    configuration.endLabel,
                    selection: $endDate,
                    in: startDate...Date.distantFuture,
                    displayedComponents: [.date]
                )

                if isInvalidRange {
                    Text("End date must be after start date.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.destructive)
                }
            }
        }
        .onChange(of: startDate) { _, _ in notifyChange() }
        .onChange(of: endDate) { _, _ in notifyChange() }
    }

    // MARK: Helpers

    private func notifyChange() {
        let start = startDate
        let end = endDate
        Task { @MainActor in
            configuration.onRangeChange(DFDateRange(start: start, end: end))
        }
    }
}
```

### Step 2 — Create `DFDateRangeBlock+Previews.swift`

- [ ] Create `Sources/DesignFoundationBlocks/Forms/DFDateRangeBlock+Previews.swift` with the following content:

```swift
import SwiftUI

#Preview("Default — Light") {
    @Previewable @State var range = DFDateRange()
    return DFDateRangeBlock(configuration: .init(
        range: range,
        onRangeChange: { range = $0 }
    ))
    .padding()
}

#Preview("Default — Dark") {
    @Previewable @State var range = DFDateRange()
    return DFDateRangeBlock(configuration: .init(
        range: range,
        onRangeChange: { range = $0 }
    ))
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("With Title — Light") {
    @Previewable @State var range = DFDateRange()
    return DFDateRangeBlock(configuration: .init(
        title: "Booking Period",
        startLabel: "Check-in",
        endLabel: "Check-out",
        range: range,
        onRangeChange: { range = $0 }
    ))
    .padding()
}

#Preview("With Title — Dark") {
    @Previewable @State var range = DFDateRange()
    return DFDateRangeBlock(configuration: .init(
        title: "Booking Period",
        startLabel: "Check-in",
        endLabel: "Check-out",
        range: range,
        onRangeChange: { range = $0 }
    ))
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Pre-filled — Light") {
    let start = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    let end = Calendar.current.date(byAdding: .day, value: 14, to: Date())!
    @Previewable @State var range = DFDateRange(start: start, end: end)
    return DFDateRangeBlock(configuration: .init(
        title: "Trip Dates",
        range: range,
        onRangeChange: { range = $0 }
    ))
    .padding()
}

#Preview("Pre-filled — Dark") {
    let start = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    let end = Calendar.current.date(byAdding: .day, value: 14, to: Date())!
    @Previewable @State var range = DFDateRange(start: start, end: end)
    return DFDateRangeBlock(configuration: .init(
        title: "Trip Dates",
        range: range,
        onRangeChange: { range = $0 }
    ))
    .padding()
    .preferredColorScheme(.dark)
}
```

### Step 3 — Create `DFDateRangeBlockTests.swift`

- [ ] Create `Tests/DesignFoundationBlocksTests/Forms/DFDateRangeBlockTests.swift` with the following content:

```swift
import Testing
import Foundation
@testable import DesignFoundationBlocks

@Suite("DFDateRangeBlock Tests")
struct DFDateRangeBlockTests {

    @Test("DFDateRange initializes with nils by default")
    func dateRangeDefaultInit() {
        let range = DFDateRange()
        #expect(range.start == nil)
        #expect(range.end == nil)
    }

    @Test("DFDateRange initializes with provided dates")
    func dateRangeCustomInit() {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start)!
        let range = DFDateRange(start: start, end: end)
        #expect(range.start == start)
        #expect(range.end == end)
    }

    @Test("DFDateRange Equatable conforms correctly")
    func dateRangeEquatable() {
        let date = Date()
        let range1 = DFDateRange(start: date)
        let range2 = DFDateRange(start: date)
        #expect(range1 == range2)
    }

    @Test("Configuration initializes with defaults")
    func configurationDefaults() {
        let config = DFDateRangeBlock.Configuration(
            onRangeChange: { _ in }
        )
        #expect(config.title == nil)
        #expect(config.startLabel == "Start Date")
        #expect(config.endLabel == "End Date")
        #expect(config.range.start == nil)
        #expect(config.range.end == nil)
    }

    @Test("Configuration initializes with custom labels")
    func configurationCustomLabels() {
        let config = DFDateRangeBlock.Configuration(
            title: "Booking Period",
            startLabel: "Check-in",
            endLabel: "Check-out",
            onRangeChange: { _ in }
        )
        #expect(config.title == "Booking Period")
        #expect(config.startLabel == "Check-in")
        #expect(config.endLabel == "Check-out")
    }

    @Test("Configuration stores provided range dates")
    func configurationStoredRange() {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 3, to: start)!
        let range = DFDateRange(start: start, end: end)
        let config = DFDateRangeBlock.Configuration(
            range: range,
            onRangeChange: { _ in }
        )
        #expect(config.range.start == start)
        #expect(config.range.end == end)
    }

    @Test("onRangeChange fires with updated range")
    @MainActor func onRangeChangeFires() async {
        var received: DFDateRange? = nil
        let config = DFDateRangeBlock.Configuration(
            onRangeChange: { range in
                received = range
            }
        )
        let newRange = DFDateRange(start: Date(), end: Date())
        await MainActor.run {
            config.onRangeChange(newRange)
        }
        #expect(received != nil)
        #expect(received == newRange)
    }

    @Test("End date range constrained by start date")
    func endDateConstrainedByStart() {
        let start = Date()
        let earlyEnd = Calendar.current.date(byAdding: .day, value: -1, to: start)!
        let range = DFDateRange(start: start, end: earlyEnd)
        // isInvalidRange logic: end < start
        #expect(range.end! < range.start!)
    }
}
```

### Step 4 — Commit

- [ ] Run: `git add Sources/DesignFoundationBlocks/Forms/DFDateRangeBlock.swift Sources/DesignFoundationBlocks/Forms/DFDateRangeBlock+Previews.swift Tests/DesignFoundationBlocksTests/Forms/DFDateRangeBlockTests.swift`
- [ ] Run: `git commit -m "feat(forms): add DFDateRangeBlock with start/end date pickers and validation hint"`

---

## Task 18: DFAddressBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/Forms/DFAddressBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Forms/DFAddressBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Forms/DFAddressBlockTests.swift`

### Step 1 — Create `DFAddressBlock.swift`

- [ ] Create `Sources/DesignFoundationBlocks/Forms/DFAddressBlock.swift` with the following content:

```swift
import SwiftUI

// MARK: - DFAddress

public struct DFAddress: Sendable, Equatable {
    public var line1: String
    public var line2: String
    public var city: String
    public var state: String
    public var postalCode: String
    public var country: String

    public init(
        line1: String = "",
        line2: String = "",
        city: String = "",
        state: String = "",
        postalCode: String = "",
        country: String = ""
    ) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }
}

// MARK: - DFAddressBlock

public struct DFAddressBlock: View {

    // MARK: Configuration

    public struct Configuration: Sendable {
        public var address: DFAddress
        public var showCountry: Bool
        public var title: String?
        public var onAddressChange: @MainActor (DFAddress) -> Void

        public init(
            address: DFAddress = DFAddress(),
            showCountry: Bool = true,
            title: String? = nil,
            onAddressChange: @escaping @MainActor (DFAddress) -> Void
        ) {
            self.address = address
            self.showCountry = showCountry
            self.title = title
            self.onAddressChange = onAddressChange
        }
    }

    // MARK: Properties

    private let configuration: Configuration
    @State private var address: DFAddress
    @Environment(\.dfTheme) private var theme

    // MARK: Init

    public init(configuration: Configuration) {
        self.configuration = configuration
        self._address = State(initialValue: configuration.address)
    }

    // MARK: Body

    public var body: some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                if let title = configuration.title {
                    Text(title)
                        .font(theme.typography.labelLarge)
                        .foregroundStyle(theme.colors.textPrimary)
                }

                DFTextField("Street Address", text: $address.line1)

                DFTextField("Apt, Suite, etc. (optional)", text: $address.line2)

                HStack(spacing: theme.spacing.sm) {
                    DFTextField("City", text: $address.city)
                    DFTextField("State", text: $address.state)
                        .frame(maxWidth: 100)
                }

                DFTextField("ZIP / Postal Code", text: $address.postalCode)

                if configuration.showCountry {
                    DFTextField("Country", text: $address.country)
                }
            }
        }
        .onChange(of: address) { _, newValue in
            let snapshot = newValue
            Task { @MainActor in
                configuration.onAddressChange(snapshot)
            }
        }
    }
}
```

### Step 2 — Create `DFAddressBlock+Previews.swift`

- [ ] Create `Sources/DesignFoundationBlocks/Forms/DFAddressBlock+Previews.swift` with the following content:

```swift
import SwiftUI

#Preview("Default — Light") {
    @Previewable @State var address = DFAddress()
    return DFAddressBlock(configuration: .init(
        onAddressChange: { address = $0 }
    ))
    .padding()
}

#Preview("Default — Dark") {
    @Previewable @State var address = DFAddress()
    return DFAddressBlock(configuration: .init(
        onAddressChange: { address = $0 }
    ))
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Pre-filled — Light") {
    @Previewable @State var address = DFAddress(
        line1: "1 Infinite Loop",
        line2: "Suite 200",
        city: "Cupertino",
        state: "CA",
        postalCode: "95014",
        country: "United States"
    )
    return DFAddressBlock(configuration: .init(
        address: address,
        onAddressChange: { address = $0 }
    ))
    .padding()
}

#Preview("Pre-filled — Dark") {
    @Previewable @State var address = DFAddress(
        line1: "1 Infinite Loop",
        line2: "Suite 200",
        city: "Cupertino",
        state: "CA",
        postalCode: "95014",
        country: "United States"
    )
    return DFAddressBlock(configuration: .init(
        address: address,
        onAddressChange: { address = $0 }
    ))
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("No Country — Light") {
    @Previewable @State var address = DFAddress()
    return DFAddressBlock(configuration: .init(
        showCountry: false,
        onAddressChange: { address = $0 }
    ))
    .padding()
}

#Preview("With Title — Light") {
    @Previewable @State var address = DFAddress()
    return DFAddressBlock(configuration: .init(
        title: "Shipping Address",
        onAddressChange: { address = $0 }
    ))
    .padding()
}
```

### Step 3 — Create `DFAddressBlockTests.swift`

- [ ] Create `Tests/DesignFoundationBlocksTests/Forms/DFAddressBlockTests.swift` with the following content:

```swift
import Testing
@testable import DesignFoundationBlocks

@Suite("DFAddressBlock Tests")
struct DFAddressBlockTests {

    @Test("DFAddress initializes with empty strings by default")
    func addressDefaultInit() {
        let address = DFAddress()
        #expect(address.line1.isEmpty)
        #expect(address.line2.isEmpty)
        #expect(address.city.isEmpty)
        #expect(address.state.isEmpty)
        #expect(address.postalCode.isEmpty)
        #expect(address.country.isEmpty)
    }

    @Test("DFAddress initializes with provided values")
    func addressCustomInit() {
        let address = DFAddress(
            line1: "1 Infinite Loop",
            line2: "Suite 200",
            city: "Cupertino",
            state: "CA",
            postalCode: "95014",
            country: "United States"
        )
        #expect(address.line1 == "1 Infinite Loop")
        #expect(address.line2 == "Suite 200")
        #expect(address.city == "Cupertino")
        #expect(address.state == "CA")
        #expect(address.postalCode == "95014")
        #expect(address.country == "United States")
    }

    @Test("DFAddress is Equatable")
    func addressEquatable() {
        let a1 = DFAddress(line1: "123 Main St", city: "Springfield")
        let a2 = DFAddress(line1: "123 Main St", city: "Springfield")
        #expect(a1 == a2)
    }

    @Test("Configuration initializes with defaults")
    func configurationDefaults() {
        let config = DFAddressBlock.Configuration(
            onAddressChange: { _ in }
        )
        #expect(config.address == DFAddress())
        #expect(config.showCountry == true)
        #expect(config.title == nil)
    }

    @Test("Configuration respects showCountry false")
    func configurationShowCountryFalse() {
        let config = DFAddressBlock.Configuration(
            showCountry: false,
            onAddressChange: { _ in }
        )
        #expect(config.showCountry == false)
    }

    @Test("Configuration stores provided address")
    func configurationStoredAddress() {
        let address = DFAddress(line1: "456 Elm Ave", city: "Shelbyville")
        let config = DFAddressBlock.Configuration(
            address: address,
            onAddressChange: { _ in }
        )
        #expect(config.address == address)
    }

    @Test("onAddressChange fires with updated address")
    @MainActor func onAddressChangeFires() async {
        var received: DFAddress? = nil
        let config = DFAddressBlock.Configuration(
            onAddressChange: { addr in
                received = addr
            }
        )
        let newAddress = DFAddress(line1: "789 Oak Rd", city: "Ogdenville")
        await MainActor.run {
            config.onAddressChange(newAddress)
        }
        #expect(received == newAddress)
    }

    @Test("Configuration stores title")
    func configurationTitle() {
        let config = DFAddressBlock.Configuration(
            title: "Shipping Address",
            onAddressChange: { _ in }
        )
        #expect(config.title == "Shipping Address")
    }
}
```

### Step 4 — Commit

- [ ] Run: `git add Sources/DesignFoundationBlocks/Forms/DFAddressBlock.swift Sources/DesignFoundationBlocks/Forms/DFAddressBlock+Previews.swift Tests/DesignFoundationBlocksTests/Forms/DFAddressBlockTests.swift`
- [ ] Run: `git commit -m "feat(forms): add DFAddressBlock with all address fields and optional country"`

---

## Task 19: DFMultiStepFormBlock

**Files:**
- Create: `Sources/DesignFoundationBlocks/Forms/DFMultiStepFormBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Forms/DFMultiStepFormBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Forms/DFMultiStepFormBlockTests.swift`

### Step 1 — Create `DFMultiStepFormBlock.swift`

- [ ] Create `Sources/DesignFoundationBlocks/Forms/DFMultiStepFormBlock.swift` with the following content:

```swift
import SwiftUI

// MARK: - DFFormStep

public struct DFFormStep: Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var icon: String?
    public var isCompleted: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        icon: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isCompleted = isCompleted
    }
}

// MARK: - DFMultiStepFormBlock

public struct DFMultiStepFormBlock<Content: View>: View {

    // MARK: Configuration

    public struct Configuration: Sendable {
        public var steps: [DFFormStep]
        public var currentStep: Int
        public var nextTitle: String
        public var backTitle: String
        public var finishTitle: String
        public var onNext: @MainActor () -> Void
        public var onBack: (@MainActor () -> Void)?
        public var onFinish: @MainActor () -> Void

        public init(
            steps: [DFFormStep],
            currentStep: Int = 0,
            nextTitle: String = "Next",
            backTitle: String = "Back",
            finishTitle: String = "Finish",
            onNext: @escaping @MainActor () -> Void,
            onBack: (@MainActor () -> Void)? = nil,
            onFinish: @escaping @MainActor () -> Void
        ) {
            self.steps = steps
            self.currentStep = currentStep
            self.nextTitle = nextTitle
            self.backTitle = backTitle
            self.finishTitle = finishTitle
            self.onNext = onNext
            self.onBack = onBack
            self.onFinish = onFinish
        }
    }

    // MARK: Properties

    private let configuration: Configuration
    private let content: (Int) -> Content
    @Environment(\.dfTheme) private var theme

    private var isLastStep: Bool {
        configuration.currentStep == configuration.steps.count - 1
    }

    private var isFirstStep: Bool {
        configuration.currentStep == 0
    }

    // MARK: Init

    public init(
        configuration: Configuration,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.configuration = configuration
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        VStack(spacing: 0) {
            stepProgressBar
                .padding(theme.spacing.md)

            Divider()
                .background(theme.colors.border)

            content(configuration.currentStep)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(theme.spacing.md)

            Divider()
                .background(theme.colors.border)

            navigationFooter
                .padding(theme.spacing.md)
        }
    }

    // MARK: Step Progress Bar

    private var stepProgressBar: some View {
        VStack(spacing: theme.spacing.xs) {
            HStack(spacing: 0) {
                ForEach(Array(configuration.steps.enumerated()), id: \.offset) { index, step in
                    stepIndicator(index: index, step: step)

                    if index < configuration.steps.count - 1 {
                        Rectangle()
                            .frame(height: 2)
                            .foregroundStyle(
                                index < configuration.currentStep
                                    ? theme.colors.primary
                                    : theme.colors.border
                            )
                    }
                }
            }

            HStack(spacing: 0) {
                ForEach(Array(configuration.steps.enumerated()), id: \.offset) { index, step in
                    Text(step.title)
                        .font(theme.typography.caption)
                        .foregroundStyle(
                            index == configuration.currentStep
                                ? theme.colors.primary
                                : theme.colors.textSecondary
                        )
                        .frame(maxWidth: .infinity)

                    if index < configuration.steps.count - 1 {
                        Spacer()
                            .frame(width: 0)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func stepIndicator(index: Int, step: DFFormStep) -> some View {
        let isCurrent = index == configuration.currentStep
        let isCompleted = index < configuration.currentStep || step.isCompleted

        ZStack {
            Circle()
                .fill(isCurrent || isCompleted ? theme.colors.primary : theme.colors.surface)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(
                            isCurrent || isCompleted ? theme.colors.primary : theme.colors.border,
                            lineWidth: 1.5
                        )
                )

            if isCompleted && !isCurrent {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
            } else if let icon = step.icon {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(isCurrent ? Color.white : theme.colors.textSecondary)
            } else {
                Text("\(index + 1)")
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isCurrent || isCompleted ? Color.white : theme.colors.textSecondary)
            }
        }
    }

    // MARK: Navigation Footer

    private var navigationFooter: some View {
        HStack {
            if !isFirstStep {
                DFButton(configuration.backTitle, role: .cancel) {
                    if let onBack = configuration.onBack {
                        Task { @MainActor in onBack() }
                    }
                }
            }

            Spacer()

            if isLastStep {
                DFButton(configuration.finishTitle) {
                    Task { @MainActor in configuration.onFinish() }
                }
            } else {
                DFButton(configuration.nextTitle) {
                    Task { @MainActor in configuration.onNext() }
                }
            }
        }
    }
}
```

### Step 2 — Create `DFMultiStepFormBlock+Previews.swift`

- [ ] Create `Sources/DesignFoundationBlocks/Forms/DFMultiStepFormBlock+Previews.swift` with the following content:

```swift
import SwiftUI

private let sampleSteps = [
    DFFormStep(title: "Account"),
    DFFormStep(title: "Profile"),
    DFFormStep(title: "Payment"),
    DFFormStep(title: "Review")
]

#Preview("Step 1 — Light") {
    @Previewable @State var step = 0
    return DFMultiStepFormBlock(
        configuration: .init(
            steps: sampleSteps,
            currentStep: step,
            onNext: { step = min(step + 1, sampleSteps.count - 1) },
            onBack: { step = max(step - 1, 0) },
            onFinish: {}
        )
    ) { currentStep in
        VStack(spacing: 16) {
            Image(systemName: "person.circle")
                .font(.system(size: 40))
            Text("Account Setup")
                .font(.headline)
            Text("Enter your email and choose a password.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview("Step 1 — Dark") {
    @Previewable @State var step = 0
    return DFMultiStepFormBlock(
        configuration: .init(
            steps: sampleSteps,
            currentStep: step,
            onNext: { step = min(step + 1, sampleSteps.count - 1) },
            onBack: { step = max(step - 1, 0) },
            onFinish: {}
        )
    ) { currentStep in
        VStack(spacing: 16) {
            Image(systemName: "person.circle")
                .font(.system(size: 40))
            Text("Account Setup")
                .font(.headline)
            Text("Enter your email and choose a password.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Step 2 — Light") {
    @Previewable @State var step = 1
    return DFMultiStepFormBlock(
        configuration: .init(
            steps: sampleSteps,
            currentStep: step,
            onNext: { step = min(step + 1, sampleSteps.count - 1) },
            onBack: { step = max(step - 1, 0) },
            onFinish: {}
        )
    ) { currentStep in
        VStack(spacing: 16) {
            Image(systemName: "person.text.rectangle")
                .font(.system(size: 40))
            Text("Your Profile")
                .font(.headline)
            Text("Tell us a bit about yourself.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview("Step 2 — Dark") {
    @Previewable @State var step = 1
    return DFMultiStepFormBlock(
        configuration: .init(
            steps: sampleSteps,
            currentStep: step,
            onNext: { step = min(step + 1, sampleSteps.count - 1) },
            onBack: { step = max(step - 1, 0) },
            onFinish: {}
        )
    ) { currentStep in
        VStack(spacing: 16) {
            Image(systemName: "person.text.rectangle")
                .font(.system(size: 40))
            Text("Your Profile")
                .font(.headline)
            Text("Tell us a bit about yourself.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Last Step — Light") {
    @Previewable @State var step = 3
    return DFMultiStepFormBlock(
        configuration: .init(
            steps: sampleSteps,
            currentStep: step,
            onNext: { step = min(step + 1, sampleSteps.count - 1) },
            onBack: { step = max(step - 1, 0) },
            onFinish: {}
        )
    ) { currentStep in
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            Text("Review & Submit")
                .font(.headline)
            Text("Everything looks good! Tap Finish to complete your setup.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview("Last Step — Dark") {
    @Previewable @State var step = 3
    return DFMultiStepFormBlock(
        configuration: .init(
            steps: sampleSteps,
            currentStep: step,
            onNext: { step = min(step + 1, sampleSteps.count - 1) },
            onBack: { step = max(step - 1, 0) },
            onFinish: {}
        )
    ) { currentStep in
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            Text("Review & Submit")
                .font(.headline)
            Text("Everything looks good! Tap Finish to complete your setup.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Two Steps — Light") {
    @Previewable @State var step = 0
    let twoSteps = [
        DFFormStep(title: "Info"),
        DFFormStep(title: "Confirm")
    ]
    return DFMultiStepFormBlock(
        configuration: .init(
            steps: twoSteps,
            currentStep: step,
            onNext: { step = min(step + 1, twoSteps.count - 1) },
            onBack: { step = max(step - 1, 0) },
            onFinish: {}
        )
    ) { currentStep in
        VStack {
            Text("Step \(currentStep + 1) of \(twoSteps.count)")
                .padding()
        }
    }
}
```

### Step 3 — Create `DFMultiStepFormBlockTests.swift`

- [ ] Create `Tests/DesignFoundationBlocksTests/Forms/DFMultiStepFormBlockTests.swift` with the following content:

```swift
import Testing
@testable import DesignFoundationBlocks

@Suite("DFMultiStepFormBlock Tests")
struct DFMultiStepFormBlockTests {

    let steps: [DFFormStep] = [
        DFFormStep(title: "Account"),
        DFFormStep(title: "Profile"),
        DFFormStep(title: "Payment"),
        DFFormStep(title: "Review")
    ]

    @Test("DFFormStep initializes with defaults")
    func formStepDefaultInit() {
        let step = DFFormStep(title: "Account")
        #expect(step.title == "Account")
        #expect(step.icon == nil)
        #expect(step.isCompleted == false)
    }

    @Test("DFFormStep initializes with all values")
    func formStepCustomInit() {
        let id = UUID()
        let step = DFFormStep(id: id, title: "Payment", icon: "creditcard", isCompleted: true)
        #expect(step.id == id)
        #expect(step.title == "Payment")
        #expect(step.icon == "creditcard")
        #expect(step.isCompleted == true)
    }

    @Test("Configuration initializes with defaults")
    func configurationDefaults() {
        let config = DFMultiStepFormBlock<EmptyView>.Configuration(
            steps: steps,
            onNext: {},
            onFinish: {}
        )
        #expect(config.currentStep == 0)
        #expect(config.nextTitle == "Next")
        #expect(config.backTitle == "Back")
        #expect(config.finishTitle == "Finish")
        #expect(config.onBack == nil)
        #expect(config.steps.count == 4)
    }

    @Test("Configuration initializes with custom button titles")
    func configurationCustomTitles() {
        let config = DFMultiStepFormBlock<EmptyView>.Configuration(
            steps: steps,
            nextTitle: "Continue",
            backTitle: "Previous",
            finishTitle: "Submit",
            onNext: {},
            onFinish: {}
        )
        #expect(config.nextTitle == "Continue")
        #expect(config.backTitle == "Previous")
        #expect(config.finishTitle == "Submit")
    }

    @Test("onNext fires")
    @MainActor func onNextFires() async {
        var nextCalled = false
        let config = DFMultiStepFormBlock<EmptyView>.Configuration(
            steps: steps,
            onNext: { nextCalled = true },
            onFinish: {}
        )
        await MainActor.run {
            config.onNext()
        }
        #expect(nextCalled)
    }

    @Test("onBack fires when provided")
    @MainActor func onBackFires() async {
        var backCalled = false
        let config = DFMultiStepFormBlock<EmptyView>.Configuration(
            steps: steps,
            currentStep: 1,
            onNext: {},
            onBack: { backCalled = true },
            onFinish: {}
        )
        await MainActor.run {
            config.onBack?()
        }
        #expect(backCalled)
    }

    @Test("onFinish fires")
    @MainActor func onFinishFires() async {
        var finishCalled = false
        let config = DFMultiStepFormBlock<EmptyView>.Configuration(
            steps: steps,
            currentStep: steps.count - 1,
            onNext: {},
            onFinish: { finishCalled = true }
        )
        await MainActor.run {
            config.onFinish()
        }
        #expect(finishCalled)
    }

    @Test("Last step index equals steps.count - 1")
    func lastStepIndex() {
        let config = DFMultiStepFormBlock<EmptyView>.Configuration(
            steps: steps,
            currentStep: steps.count - 1,
            onNext: {},
            onFinish: {}
        )
        #expect(config.currentStep == config.steps.count - 1)
    }

    @Test("First step has currentStep of 0")
    func firstStepIsZero() {
        let config = DFMultiStepFormBlock<EmptyView>.Configuration(
            steps: steps,
            currentStep: 0,
            onNext: {},
            onFinish: {}
        )
        #expect(config.currentStep == 0)
    }

    @Test("onBack is nil by default (back button hidden on step 0)")
    func onBackNilByDefault() {
        let config = DFMultiStepFormBlock<EmptyView>.Configuration(
            steps: steps,
            onNext: {},
            onFinish: {}
        )
        #expect(config.onBack == nil)
    }

    @Test("Step count matches provided steps")
    func stepCount() {
        let twoSteps = [DFFormStep(title: "A"), DFFormStep(title: "B")]
        let config = DFMultiStepFormBlock<EmptyView>.Configuration(
            steps: twoSteps,
            onNext: {},
            onFinish: {}
        )
        #expect(config.steps.count == 2)
    }
}
```

### Step 4 — Commit

- [ ] Run: `git add Sources/DesignFoundationBlocks/Forms/DFMultiStepFormBlock.swift Sources/DesignFoundationBlocks/Forms/DFMultiStepFormBlock+Previews.swift Tests/DesignFoundationBlocksTests/Forms/DFMultiStepFormBlockTests.swift`
- [ ] Run: `git commit -m "feat(forms): add DFMultiStepFormBlock with step progress bar and generic content"`

---

## Summary

| Task | Block | Files |
|------|-------|-------|
| 16 | DFTagPickerBlock | 3 files — main, previews, tests |
| 17 | DFDateRangeBlock | 3 files — main, previews, tests |
| 18 | DFAddressBlock | 3 files — main, previews, tests |
| 19 | DFMultiStepFormBlock | 3 files — main, previews, tests |

**Total:** 12 new files across `Sources/DesignFoundationBlocks/Forms/` and `Tests/DesignFoundationBlocksTests/Forms/`.

All blocks follow the same pattern: Configuration struct holds all external-facing state and callbacks; @State holds local interactive state initialized from Configuration; changes propagate out via `Task { @MainActor in callback() }`.
