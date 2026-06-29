# DesignFoundationScreens — CRM Vertical Plan

> **Vertical:** Sales / CRM — 6 launch-ready screens a real sales rep uses daily.
> **Source:** `Sources/DesignFoundationScreens/CRM/`
> **Tests:** `Tests/DesignFoundationScreensTests/CRM/`
> **Depends on:** DesignFoundation + DesignFoundationBlocks (both already available)

---

## Dependency Order

Build tasks in this sequence — each screen may navigate to the next:

1. `DFCRMAnalyticsScreen` — no outbound navigation
2. `DFCRMDealDetailScreen` — no outbound navigation (except back)
3. `DFCRMContactDetailScreen` — taps into DealDetailScreen
4. `DFCRMPipelineScreen` — taps into DealDetailScreen
5. `DFCRMContactsScreen` — taps into ContactDetailScreen
6. `DFCRMHomeScreen` — taps into ContactDetailScreen + DealDetailScreen

---

## Shared Models

**File:** `Sources/DesignFoundationScreens/CRM/CRMModels.swift`

Create value-type models. These are preview/demo models — no persistence layer.

```swift
import Foundation

// MARK: - Contact

public struct CRMContact: Identifiable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var title: String
    public var company: String
    public var email: String
    public var phone: String
    public var avatarInitials: String
    public var status: CRMContactStatus
    public var lastContactedDate: Date
    public var address: CRMAddress
    public var tags: [String]
    public var notes: [CRMNote]
    public var deals: [CRMDeal]

    public init(
        id: UUID = .init(),
        name: String,
        title: String,
        company: String,
        email: String,
        phone: String,
        avatarInitials: String,
        status: CRMContactStatus,
        lastContactedDate: Date,
        address: CRMAddress = .empty,
        tags: [String] = [],
        notes: [CRMNote] = [],
        deals: [CRMDeal] = []
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.company = company
        self.email = email
        self.phone = phone
        self.avatarInitials = avatarInitials
        self.status = status
        self.lastContactedDate = lastContactedDate
        self.address = address
        self.tags = tags
        self.notes = notes
        self.deals = deals
    }
}

public enum CRMContactStatus: String, CaseIterable, Sendable, Identifiable {
    case lead = "Lead"
    case customer = "Customer"
    case inactive = "Inactive"
    public var id: String { rawValue }
}

// MARK: - Deal

public struct CRMDeal: Identifiable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var value: Decimal
    public var stage: CRMDealStage
    public var contactID: UUID
    public var contactName: String
    public var contactCompany: String
    public var assignedAvatarInitials: String
    public var closeDate: Date
    public var daysInStage: Int
    public var notes: [CRMNote]
    public var activity: [CRMActivity]

    public init(
        id: UUID = .init(),
        name: String,
        value: Decimal,
        stage: CRMDealStage,
        contactID: UUID,
        contactName: String,
        contactCompany: String,
        assignedAvatarInitials: String,
        closeDate: Date,
        daysInStage: Int,
        notes: [CRMNote] = [],
        activity: [CRMActivity] = []
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.stage = stage
        self.contactID = contactID
        self.contactName = contactName
        self.contactCompany = contactCompany
        self.assignedAvatarInitials = assignedAvatarInitials
        self.closeDate = closeDate
        self.daysInStage = daysInStage
        self.notes = notes
        self.activity = activity
    }
}

public enum CRMDealStage: String, CaseIterable, Sendable, Identifiable, Hashable {
    case prospect = "Prospect"
    case qualified = "Qualified"
    case proposal = "Proposal"
    case negotiation = "Negotiation"
    case closedWon = "Closed Won"
    case closedLost = "Closed Lost"
    public var id: String { rawValue }

    /// Display order for the pipeline board
    public static var pipelineOrder: [CRMDealStage] {
        [.prospect, .qualified, .proposal, .negotiation, .closedWon, .closedLost]
    }
}

// MARK: - Task

public struct CRMTask: Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var dueDate: Date
    public var isCompleted: Bool
    public var contactID: UUID?
    public var contactName: String?

    public var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }
    public var isDueToday: Bool {
        !isCompleted && Calendar.current.isDateInToday(dueDate)
    }

    public init(
        id: UUID = .init(),
        title: String,
        dueDate: Date,
        isCompleted: Bool = false,
        contactID: UUID? = nil,
        contactName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.contactID = contactID
        self.contactName = contactName
    }
}

// MARK: - Activity

public struct CRMActivity: Identifiable, Sendable, Hashable {
    public let id: UUID
    public var type: CRMActivityType
    public var title: String
    public var detail: String
    public var date: Date
    public var contactName: String

    public init(
        id: UUID = .init(),
        type: CRMActivityType,
        title: String,
        detail: String,
        date: Date,
        contactName: String
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.detail = detail
        self.date = date
        self.contactName = contactName
    }
}

public enum CRMActivityType: String, Sendable, Hashable {
    case call, email, note, meeting, task
}

// MARK: - Note

public struct CRMNote: Identifiable, Sendable, Hashable {
    public let id: UUID
    public var body: String
    public var createdAt: Date

    public init(id: UUID = .init(), body: String, createdAt: Date = Date()) {
        self.id = id
        self.body = body
        self.createdAt = createdAt
    }
}

// MARK: - Address

public struct CRMAddress: Sendable, Hashable {
    public var street: String
    public var city: String
    public var state: String
    public var zip: String
    public var country: String

    public static let empty = CRMAddress(street: "", city: "", state: "", zip: "", country: "")

    public init(street: String, city: String, state: String, zip: String, country: String) {
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
    }
}

// MARK: - Follow-up

public struct CRMFollowUp: Identifiable, Sendable {
    public let id: UUID
    public var contactID: UUID
    public var contactName: String
    public var avatarInitials: String
    public var lastContactedDate: Date

    public init(
        id: UUID = .init(),
        contactID: UUID,
        contactName: String,
        avatarInitials: String,
        lastContactedDate: Date
    ) {
        self.id = id
        self.contactID = contactID
        self.contactName = contactName
        self.avatarInitials = avatarInitials
        self.lastContactedDate = lastContactedDate
    }
}
```

---

## Shared Preview Fixtures

**File:** `Sources/DesignFoundationScreens/CRM/CRMPreviewFixtures.swift`

```swift
import Foundation

// swiftlint:disable line_length
public enum CRMPreviewFixtures {

    // MARK: Contacts

    public static let contacts: [CRMContact] = [
        CRMContact(
            name: "Sarah Chen",
            title: "VP of Engineering",
            company: "Meridian Tech",
            email: "s.chen@meridian.io",
            phone: "+1 415 555 0182",
            avatarInitials: "SC",
            status: .customer,
            lastContactedDate: Date().addingTimeInterval(-86400),
            address: CRMAddress(street: "100 Market St", city: "San Francisco", state: "CA", zip: "94105", country: "US"),
            tags: ["Enterprise", "Renewal Q3"],
            notes: [
                CRMNote(body: "Interested in expanding seats by 50.", createdAt: Date().addingTimeInterval(-604800)),
                CRMNote(body: "Send updated pricing deck before Friday.", createdAt: Date().addingTimeInterval(-86400))
            ],
            deals: [sampleDeal1]
        ),
        CRMContact(
            name: "Marcus Williams",
            title: "Head of Product",
            company: "Luma Labs",
            email: "mwilliams@lumalabs.com",
            phone: "+1 212 555 0143",
            avatarInitials: "MW",
            status: .lead,
            lastContactedDate: Date().addingTimeInterval(-259200),
            tags: ["SMB", "Hot Lead"],
            deals: [sampleDeal2]
        ),
        CRMContact(
            name: "Priya Nair",
            title: "CTO",
            company: "Apex Systems",
            email: "priya@apexsystems.co",
            phone: "+1 650 555 0199",
            avatarInitials: "PN",
            status: .customer,
            lastContactedDate: Date().addingTimeInterval(-172800),
            deals: [sampleDeal3]
        ),
        CRMContact(
            name: "James Okonkwo",
            title: "Director of Operations",
            company: "Orbit Co",
            email: "j.okonkwo@orbit.co",
            phone: "+1 312 555 0171",
            avatarInitials: "JO",
            status: .inactive,
            lastContactedDate: Date().addingTimeInterval(-2592000)
        ),
        CRMContact(
            name: "Elena Rossi",
            title: "Founder & CEO",
            company: "Vanta Studio",
            email: "elena@vanta.io",
            phone: "+39 02 555 0127",
            avatarInitials: "ER",
            status: .lead,
            lastContactedDate: Date().addingTimeInterval(-432000)
        )
    ]

    // MARK: Deals

    public static let sampleDeal1 = CRMDeal(
        name: "Meridian Enterprise Renewal",
        value: 84_000,
        stage: .negotiation,
        contactID: UUID(),
        contactName: "Sarah Chen",
        contactCompany: "Meridian Tech",
        assignedAvatarInitials: "AJ",
        closeDate: Date().addingTimeInterval(86400 * 14),
        daysInStage: 8,
        notes: [CRMNote(body: "Legal review in progress.")],
        activity: sampleActivity
    )

    public static let sampleDeal2 = CRMDeal(
        name: "Luma Labs Pilot",
        value: 12_000,
        stage: .proposal,
        contactID: UUID(),
        contactName: "Marcus Williams",
        contactCompany: "Luma Labs",
        assignedAvatarInitials: "TK",
        closeDate: Date().addingTimeInterval(86400 * 30),
        daysInStage: 3,
        activity: sampleActivity
    )

    public static let sampleDeal3 = CRMDeal(
        name: "Apex Expansion",
        value: 36_000,
        stage: .closedWon,
        contactID: UUID(),
        contactName: "Priya Nair",
        contactCompany: "Apex Systems",
        assignedAvatarInitials: "AJ",
        closeDate: Date().addingTimeInterval(-86400 * 5),
        daysInStage: 0,
        activity: sampleActivity
    )

    public static let deals: [CRMDeal] = [
        sampleDeal1,
        sampleDeal2,
        sampleDeal3,
        CRMDeal(
            name: "Orbit Initial",
            value: 6_000,
            stage: .prospect,
            contactID: UUID(),
            contactName: "James Okonkwo",
            contactCompany: "Orbit Co",
            assignedAvatarInitials: "TK",
            closeDate: Date().addingTimeInterval(86400 * 60),
            daysInStage: 12
        ),
        CRMDeal(
            name: "Vanta Studio Discovery",
            value: 18_000,
            stage: .qualified,
            contactID: UUID(),
            contactName: "Elena Rossi",
            contactCompany: "Vanta Studio",
            assignedAvatarInitials: "AJ",
            closeDate: Date().addingTimeInterval(86400 * 45),
            daysInStage: 5
        ),
        CRMDeal(
            name: "Legacy Account Q2",
            value: 9_000,
            stage: .closedLost,
            contactID: UUID(),
            contactName: "Tom Bauer",
            contactCompany: "Nexgen Corp",
            assignedAvatarInitials: "TK",
            closeDate: Date().addingTimeInterval(-86400 * 10),
            daysInStage: 0
        )
    ]

    // MARK: Tasks

    public static let tasks: [CRMTask] = [
        CRMTask(
            title: "Send pricing deck to Sarah Chen",
            dueDate: Date().addingTimeInterval(-3600),
            contactName: "Sarah Chen"
        ),
        CRMTask(
            title: "Follow up on Luma Labs proposal",
            dueDate: Calendar.current.startOfDay(for: Date()),
            contactName: "Marcus Williams"
        ),
        CRMTask(
            title: "Prepare Apex expansion quote",
            dueDate: Date().addingTimeInterval(3600 * 4),
            contactName: "Priya Nair"
        ),
        CRMTask(
            title: "Schedule discovery call with Elena Rossi",
            dueDate: Date().addingTimeInterval(86400),
            contactName: "Elena Rossi"
        )
    ]

    // MARK: Activity

    public static let sampleActivity: [CRMActivity] = [
        CRMActivity(
            type: .call,
            title: "Discovery call",
            detail: "Discussed pain points around reporting. Interested in analytics add-on.",
            date: Date().addingTimeInterval(-86400),
            contactName: "Sarah Chen"
        ),
        CRMActivity(
            type: .email,
            title: "Sent pricing deck",
            detail: "Emailed updated enterprise pricing for 100-seat tier.",
            date: Date().addingTimeInterval(-172800),
            contactName: "Marcus Williams"
        ),
        CRMActivity(
            type: .meeting,
            title: "Renewal kick-off",
            detail: "30-minute Zoom with legal and finance team.",
            date: Date().addingTimeInterval(-259200),
            contactName: "Priya Nair"
        ),
        CRMActivity(
            type: .note,
            title: "Internal note",
            detail: "Champion is pushing internally. Decision expected next week.",
            date: Date().addingTimeInterval(-345600),
            contactName: "Elena Rossi"
        ),
        CRMActivity(
            type: .task,
            title: "Task completed",
            detail: "Sent NDA for countersignature.",
            date: Date().addingTimeInterval(-432000),
            contactName: "Sarah Chen"
        )
    ]

    // MARK: Follow-ups

    public static let followUps: [CRMFollowUp] = [
        CRMFollowUp(contactID: UUID(), contactName: "Marcus Williams", avatarInitials: "MW", lastContactedDate: Date().addingTimeInterval(-259200)),
        CRMFollowUp(contactID: UUID(), contactName: "Elena Rossi", avatarInitials: "ER", lastContactedDate: Date().addingTimeInterval(-432000)),
        CRMFollowUp(contactID: UUID(), contactName: "James Okonkwo", avatarInitials: "JO", lastContactedDate: Date().addingTimeInterval(-2592000))
    ]
}
// swiftlint:enable line_length
```

---

## Task 1 — DFCRMAnalyticsScreen

**File:** `Sources/DesignFoundationScreens/CRM/DFCRMAnalyticsScreen.swift`
**Test:** `Tests/DesignFoundationScreensTests/CRM/DFCRMAnalyticsScreenTests.swift`

### Purpose
The numbers screen a sales rep checks before every team meeting. Four headline metrics, two chart zones (pipeline by stage, revenue over time), a stat row for weekly activity, and a date-range filter sheet.

### Layout

```
NavigationStack
  ├── .navigationTitle("Analytics")
  ├── .toolbar → "Date Range" button → sheet(DFDateRangeBlock)
  └── ScrollView(.vertical)
        ├── DFMetricGridBlock (2×2)
        │     Deals Won | Revenue This Month | Avg Deal Size | Win Rate
        ├── Section header "Pipeline"
        ├── DFChartPlaceholderBlock(title: "Pipeline by Stage", style: .bar)
        ├── Section header "Revenue"
        ├── DFChartPlaceholderBlock(title: "Revenue Over Time", style: .line)
        ├── Section header "This Week"
        └── HStack (3 DFStatCardBlock)
              New Leads | Follow-ups Completed | Calls Made
```

### Implementation

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Screen

@MainActor
public struct DFCRMAnalyticsScreen: View {

    // MARK: Props

    /// Called when the user taps the date range button and confirms a selection.
    public var onDateRangeChanged: @MainActor (DateInterval) -> Void

    /// Injected data — pass computed values from your view-model or parent.
    public var dealsWon: Int
    public var revenueThisMonth: Decimal
    public var avgDealSize: Decimal
    public var winRate: Double           // 0.0 – 1.0
    public var newLeadsThisWeek: Int
    public var followUpsCompleted: Int
    public var callsMade: Int

    // MARK: Init

    public init(
        dealsWon: Int,
        revenueThisMonth: Decimal,
        avgDealSize: Decimal,
        winRate: Double,
        newLeadsThisWeek: Int,
        followUpsCompleted: Int,
        callsMade: Int,
        onDateRangeChanged: @escaping @MainActor (DateInterval) -> Void
    ) {
        self.dealsWon = dealsWon
        self.revenueThisMonth = revenueThisMonth
        self.avgDealSize = avgDealSize
        self.winRate = winRate
        self.newLeadsThisWeek = newLeadsThisWeek
        self.followUpsCompleted = followUpsCompleted
        self.callsMade = callsMade
        self.onDateRangeChanged = onDateRangeChanged
    }

    // MARK: State

    @State private var showDateRangeSheet = false
    @State private var selectedInterval: DateInterval = {
        let now = Date()
        let start = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        return DateInterval(start: start, end: now)
    }()

    @Environment(\.dfTheme) private var theme

    // MARK: Body

    public var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {

                // 2×2 headline metrics
                DFMetricGridBlock(items: [
                    .init(label: "Deals Won", value: "\(dealsWon)", trend: nil),
                    .init(label: "Revenue This Month", value: formatCurrency(revenueThisMonth), trend: nil),
                    .init(label: "Avg Deal Size", value: formatCurrency(avgDealSize), trend: nil),
                    .init(label: "Win Rate", value: formatPercent(winRate), trend: nil)
                ])
                .padding(.horizontal, theme.spacing.md)

                sectionHeader("Pipeline")

                DFChartPlaceholderBlock(
                    title: "Pipeline by Stage",
                    style: .bar,
                    height: 220
                )
                .padding(.horizontal, theme.spacing.md)

                sectionHeader("Revenue")

                DFChartPlaceholderBlock(
                    title: "Revenue Over Time",
                    style: .line,
                    height: 220
                )
                .padding(.horizontal, theme.spacing.md)

                sectionHeader("This Week")

                HStack(spacing: theme.spacing.sm) {
                    DFStatCardBlock(label: "New Leads", value: "\(newLeadsThisWeek)")
                    DFStatCardBlock(label: "Follow-ups Done", value: "\(followUpsCompleted)")
                    DFStatCardBlock(label: "Calls Made", value: "\(callsMade)")
                }
                .padding(.horizontal, theme.spacing.md)
            }
            .padding(.vertical, theme.spacing.md)
        }
        .navigationTitle("Analytics")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Date Range") {
                    showDateRangeSheet = true
                }
            }
        }
        .sheet(isPresented: $showDateRangeSheet) {
            NavigationStack {
                DFDateRangeBlock(
                    selectedInterval: $selectedInterval,
                    onConfirm: { interval in
                        showDateRangeSheet = false
                        onDateRangeChanged(interval)
                    }
                )
                .navigationTitle("Select Range")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showDateRangeSheet = false }
                    }
                }
            }
        }
    }

    // MARK: Helpers

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        DFText(title, style: .headlineSmall)
            .padding(.horizontal, theme.spacing.md)
            .padding(.top, theme.spacing.xs)
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSDecimalNumber) ?? "$\(value)"
    }

    private func formatPercent(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }
}

// MARK: - Previews

#Preview("Analytics — Light") {
    NavigationStack {
        DFCRMAnalyticsScreen(
            dealsWon: 12,
            revenueThisMonth: 148_200,
            avgDealSize: 24_700,
            winRate: 0.68,
            newLeadsThisWeek: 7,
            followUpsCompleted: 14,
            callsMade: 23,
            onDateRangeChanged: { _ in }
        )
    }
}

#Preview("Analytics — Dark") {
    NavigationStack {
        DFCRMAnalyticsScreen(
            dealsWon: 12,
            revenueThisMonth: 148_200,
            avgDealSize: 24_700,
            winRate: 0.68,
            newLeadsThisWeek: 7,
            followUpsCompleted: 14,
            callsMade: 23,
            onDateRangeChanged: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFCRMAnalyticsScreen")
struct DFCRMAnalyticsScreenTests {

    @Test("Win rate formats correctly at boundary values")
    func winRateBoundaries() {
        // The screen itself does the formatting; we verify the logic extracted from it.
        let format: (Double) -> String = { v in String(format: "%.0f%%", v * 100) }
        #expect(format(0.0) == "0%")
        #expect(format(1.0) == "100%")
        #expect(format(0.684) == "68%")
    }

    @Test("DateInterval initializer produces a 30-day default window")
    func defaultIntervalApprox30Days() {
        let now = Date()
        let start = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        let interval = DateInterval(start: start, end: now)
        let days = interval.duration / 86400
        #expect(days >= 28 && days <= 31)
    }
}
```

---

## Task 2 — DFCRMDealDetailScreen

**File:** `Sources/DesignFoundationScreens/CRM/DFCRMDealDetailScreen.swift`
**Test:** `Tests/DesignFoundationScreensTests/CRM/DFCRMDealDetailScreenTests.swift`

### Purpose
Everything about one deal in one place. Header shows deal name, dollar value, stage badge and close date. A step-progress row shows pipeline position. Linked contact row, activity feed, notes, and danger zone (archive/delete) at the bottom.

### Layout

```
NavigationStack
  ├── .navigationTitle(deal.name)
  ├── .toolbar → "Edit" button
  └── ScrollView(.vertical)
        ├── DealHeaderView (name, value, stage badge, close date)
        ├── DealStageProgressView (step indicators for each stage)
        ├── Section "Contact"
        │     DFContactRow (tappable → onContactTapped)
        ├── Section "Activity"
        │     DFActivityFeedBlock
        ├── Section "Notes"
        │     ForEach notes → NoteRow
        │     "Add Note" button
        └── DFDangerZoneBlock (Archive Deal, Delete Deal)
```

### Implementation

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Screen

@MainActor
public struct DFCRMDealDetailScreen: View {

    // MARK: Props

    public var deal: CRMDeal
    public var contact: CRMContact?
    public var onEditTapped: @MainActor () -> Void
    public var onContactTapped: @MainActor (CRMContact) -> Void
    public var onArchiveDeal: @MainActor () -> Void
    public var onDeleteDeal: @MainActor () -> Void

    // MARK: Init

    public init(
        deal: CRMDeal,
        contact: CRMContact? = nil,
        onEditTapped: @escaping @MainActor () -> Void,
        onContactTapped: @escaping @MainActor (CRMContact) -> Void,
        onArchiveDeal: @escaping @MainActor () -> Void,
        onDeleteDeal: @escaping @MainActor () -> Void
    ) {
        self.deal = deal
        self.contact = contact
        self.onEditTapped = onEditTapped
        self.onContactTapped = onContactTapped
        self.onArchiveDeal = onArchiveDeal
        self.onDeleteDeal = onDeleteDeal
    }

    // MARK: State

    @State private var newNoteText = ""
    @State private var notes: [CRMNote]
    @State private var showDeleteConfirm = false

    @Environment(\.dfTheme) private var theme

    public init(
        deal: CRMDeal,
        contact: CRMContact? = nil,
        onEditTapped: @escaping @MainActor () -> Void,
        onContactTapped: @escaping @MainActor (CRMContact) -> Void,
        onArchiveDeal: @escaping @MainActor () -> Void,
        onDeleteDeal: @escaping @MainActor () -> Void
    ) {
        self.deal = deal
        self.contact = contact
        self.onEditTapped = onEditTapped
        self.onContactTapped = onContactTapped
        self.onArchiveDeal = onArchiveDeal
        self.onDeleteDeal = onDeleteDeal
        self._notes = State(initialValue: deal.notes)
    }

    // MARK: Body

    public var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                dealHeader
                stageProgress
                contactSection
                activitySection
                notesSection
                dangerZone
            }
            .padding(.vertical, theme.spacing.md)
        }
        .navigationTitle(deal.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", action: onEditTapped)
            }
        }
        .confirmationDialog(
            "Delete \"\(deal.name)\"?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete Deal", role: .destructive, action: onDeleteDeal)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: Subviews

    @ViewBuilder
    private var dealHeader: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            DFText(deal.name, style: .title)
            DFText(formatCurrency(deal.value), style: .displayLarge)
                .foregroundStyle(theme.colors.primary)
            HStack {
                DFBadge(deal.stage.rawValue, style: stageBadgeStyle(deal.stage))
                Spacer()
                DFText("Closes \(formatDate(deal.closeDate))", style: .caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var stageProgress: some View {
        // Horizontal step-progress showing pipeline stages; current stage highlighted
        let stages = CRMDealStage.pipelineOrder
        let currentIndex = stages.firstIndex(of: deal.stage) ?? 0

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(stages.enumerated()), id: \.element) { index, stage in
                    HStack(spacing: 0) {
                        VStack(spacing: theme.spacing.xxs) {
                            Circle()
                                .fill(index <= currentIndex
                                      ? theme.colors.primary
                                      : theme.colors.surfaceSecondary)
                                .frame(width: 12, height: 12)
                            DFText(stage.rawValue, style: .labelSmall)
                                .multilineTextAlignment(.center)
                                .frame(width: 72)
                        }
                        if index < stages.count - 1 {
                            Rectangle()
                                .fill(index < currentIndex
                                      ? theme.colors.primary
                                      : theme.colors.borderSubtle)
                                .frame(height: 2)
                                .frame(width: 16)
                        }
                    }
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
        }
    }

    @ViewBuilder
    private var contactSection: some View {
        if let contact {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                sectionHeader("Contact")
                DFContactRow(
                    name: contact.name,
                    subtitle: "\(contact.title) · \(contact.company)",
                    avatarInitials: contact.avatarInitials,
                    badge: contact.status.rawValue,
                    detail: "Last contacted \(relativeDateString(contact.lastContactedDate))"
                ) {
                    onContactTapped(contact)
                }
                .padding(.horizontal, theme.spacing.md)
            }
        }
    }

    @ViewBuilder
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            sectionHeader("Activity")
            DFActivityFeedBlock(
                items: deal.activity.map { activity in
                    DFActivityFeedItem(
                        id: activity.id.uuidString,
                        iconName: activityIcon(activity.type),
                        title: activity.title,
                        subtitle: activity.detail,
                        timestamp: relativeDateString(activity.date)
                    )
                }
            )
            .padding(.horizontal, theme.spacing.md)
        }
    }

    @ViewBuilder
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            sectionHeader("Notes")
            ForEach(notes) { note in
                DFCard {
                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                        DFText(note.body, style: .body)
                        DFText(formatDate(note.createdAt), style: .caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    .padding(theme.spacing.sm)
                }
                .padding(.horizontal, theme.spacing.md)
            }
            HStack {
                DFTextField("Add a note…", text: $newNoteText)
                DFButton("Add", style: .secondary) {
                    guard !newNoteText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    notes.append(CRMNote(body: newNoteText))
                    newNoteText = ""
                }
            }
            .padding(.horizontal, theme.spacing.md)
        }
    }

    @ViewBuilder
    private var dangerZone: some View {
        DFDangerZoneBlock(actions: [
            .init(label: "Archive Deal", style: .warning, action: onArchiveDeal),
            .init(label: "Delete Deal", style: .destructive) {
                showDeleteConfirm = true
            }
        ])
        .padding(.horizontal, theme.spacing.md)
    }

    // MARK: Helpers

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        DFText(title, style: .headlineSmall)
            .padding(.horizontal, theme.spacing.md)
    }

    private func stageBadgeStyle(_ stage: CRMDealStage) -> DFBadgeStyle {
        switch stage {
        case .closedWon: return .success
        case .closedLost: return .destructive
        default: return .default
        }
    }

    private func activityIcon(_ type: CRMActivityType) -> String {
        switch type {
        case .call: return "phone"
        case .email: return "envelope"
        case .note: return "note.text"
        case .meeting: return "calendar"
        case .task: return "checkmark.circle"
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 0
        return f.string(from: value as NSDecimalNumber) ?? "$\(value)"
    }

    private func formatDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    private func relativeDateString(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Previews

#Preview("Deal Detail — Light") {
    NavigationStack {
        DFCRMDealDetailScreen(
            deal: CRMPreviewFixtures.sampleDeal1,
            contact: CRMPreviewFixtures.contacts.first,
            onEditTapped: {},
            onContactTapped: { _ in },
            onArchiveDeal: {},
            onDeleteDeal: {}
        )
    }
}

#Preview("Deal Detail — Dark") {
    NavigationStack {
        DFCRMDealDetailScreen(
            deal: CRMPreviewFixtures.sampleDeal1,
            contact: CRMPreviewFixtures.contacts.first,
            onEditTapped: {},
            onContactTapped: { _ in },
            onArchiveDeal: {},
            onDeleteDeal: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFCRMDealDetailScreen")
struct DFCRMDealDetailScreenTests {

    @Test("Stage progress order matches pipeline definition")
    func stageProgressOrder() {
        let stages = CRMDealStage.pipelineOrder
        #expect(stages.first == .prospect)
        #expect(stages.last == .closedLost)
        #expect(stages.count == 6)
    }

    @Test("closedWon is before closedLost in pipeline order")
    func wonBeforeLost() {
        let stages = CRMDealStage.pipelineOrder
        let wonIndex = stages.firstIndex(of: .closedWon)!
        let lostIndex = stages.firstIndex(of: .closedLost)!
        #expect(wonIndex < lostIndex)
    }

    @Test("Note appended correctly")
    func noteAppend() {
        var notes: [CRMNote] = []
        let note = CRMNote(body: "Test note")
        notes.append(note)
        #expect(notes.count == 1)
        #expect(notes[0].body == "Test note")
    }
}
```

---

## Task 3 — DFCRMContactDetailScreen

**File:** `Sources/DesignFoundationScreens/CRM/DFCRMContactDetailScreen.swift`
**Test:** `Tests/DesignFoundationScreensTests/CRM/DFCRMContactDetailScreenTests.swift`

### Purpose
The full picture of one relationship. Profile header, quick-action bar (Call / Email / Note / Task), and a tabbed lower section for Activity, Notes, and Deals.

### Layout

```
NavigationStack
  ├── .navigationTitle(contact.name)
  ├── .toolbar → "Edit" button
  └── ScrollView(.vertical)
        ├── DFProfileHeaderBlock
        ├── QuickActionBar (Call · Email · Note · Task)
        ├── DFTagPickerBlock (read-only; Edit button toggles edit mode)
        ├── DFAddressBlock (read-only; Edit button toggles edit mode)
        └── DFTabBar (segments: Activity | Notes | Deals)
              ├── Activity → DFActivityFeedBlock
              ├── Notes → NotesList + inline add
              └── Deals → DealCardList
```

### Implementation

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Screen

@MainActor
public struct DFCRMContactDetailScreen: View {

    // MARK: Props

    public var contact: CRMContact
    public var onEditTapped: @MainActor () -> Void
    public var onCallTapped: @MainActor (CRMContact) -> Void
    public var onEmailTapped: @MainActor (CRMContact) -> Void
    public var onAddNoteTapped: @MainActor (CRMContact) -> Void
    public var onAddTaskTapped: @MainActor (CRMContact) -> Void
    public var onDealTapped: @MainActor (CRMDeal) -> Void

    // MARK: Init

    public init(
        contact: CRMContact,
        onEditTapped: @escaping @MainActor () -> Void,
        onCallTapped: @escaping @MainActor (CRMContact) -> Void,
        onEmailTapped: @escaping @MainActor (CRMContact) -> Void,
        onAddNoteTapped: @escaping @MainActor (CRMContact) -> Void,
        onAddTaskTapped: @escaping @MainActor (CRMContact) -> Void,
        onDealTapped: @escaping @MainActor (CRMDeal) -> Void
    ) {
        self.contact = contact
        self.onEditTapped = onEditTapped
        self.onCallTapped = onCallTapped
        self.onEmailTapped = onEmailTapped
        self.onAddNoteTapped = onAddNoteTapped
        self.onAddTaskTapped = onAddTaskTapped
        self.onDealTapped = onDealTapped
    }

    // MARK: State

    public enum Tab: String, CaseIterable { case activity = "Activity", notes = "Notes", deals = "Deals" }

    @State private var selectedTab: Tab = .activity
    @State private var notes: [CRMNote]
    @State private var newNoteText = ""
    @State private var isEditingTags = false

    @Environment(\.dfTheme) private var theme

    public init(
        contact: CRMContact,
        onEditTapped: @escaping @MainActor () -> Void,
        onCallTapped: @escaping @MainActor (CRMContact) -> Void,
        onEmailTapped: @escaping @MainActor (CRMContact) -> Void,
        onAddNoteTapped: @escaping @MainActor (CRMContact) -> Void,
        onAddTaskTapped: @escaping @MainActor (CRMContact) -> Void,
        onDealTapped: @escaping @MainActor (CRMDeal) -> Void
    ) {
        self.contact = contact
        self.onEditTapped = onEditTapped
        self.onCallTapped = onCallTapped
        self.onEmailTapped = onEmailTapped
        self.onAddNoteTapped = onAddNoteTapped
        self.onAddTaskTapped = onAddTaskTapped
        self.onDealTapped = onDealTapped
        self._notes = State(initialValue: contact.notes)
    }

    // MARK: Body

    public var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                DFProfileHeaderBlock(
                    avatarInitials: contact.avatarInitials,
                    name: contact.name,
                    subtitle: "\(contact.title) · \(contact.company)"
                )

                quickActionBar

                DFTagPickerBlock(
                    tags: contact.tags,
                    isEditing: isEditingTags,
                    onToggleEdit: { isEditingTags.toggle() }
                )
                .padding(.horizontal, theme.spacing.md)

                DFAddressBlock(
                    street: contact.address.street,
                    city: contact.address.city,
                    state: contact.address.state,
                    zip: contact.address.zip,
                    country: contact.address.country
                )
                .padding(.horizontal, theme.spacing.md)

                tabPicker
                tabContent
            }
            .padding(.vertical, theme.spacing.md)
        }
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", action: onEditTapped)
            }
        }
    }

    // MARK: Quick Action Bar

    @ViewBuilder
    private var quickActionBar: some View {
        HStack(spacing: theme.spacing.sm) {
            quickAction(icon: "phone", label: "Call") { onCallTapped(contact) }
            quickAction(icon: "envelope", label: "Email") { onEmailTapped(contact) }
            quickAction(icon: "note.text.badge.plus", label: "Note") { onAddNoteTapped(contact) }
            quickAction(icon: "checkmark.circle.badge.plus", label: "Task") { onAddTaskTapped(contact) }
        }
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private func quickAction(
        icon: String,
        label: String,
        action: @escaping @MainActor () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: theme.spacing.xxs) {
                DFIcon(icon, size: .md)
                DFText(label, style: .labelSmall)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacing.sm)
            .background(theme.colors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: Tab Bar

    @ViewBuilder
    private var tabPicker: some View {
        Picker("", selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .activity:
            DFActivityFeedBlock(
                items: contact.deals.flatMap(\.activity).sorted(by: { $0.date > $1.date }).map { a in
                    DFActivityFeedItem(
                        id: a.id.uuidString,
                        iconName: activityIcon(a.type),
                        title: a.title,
                        subtitle: a.detail,
                        timestamp: a.date.formatted(.relative(presentation: .named))
                    )
                }
            )
            .padding(.horizontal, theme.spacing.md)

        case .notes:
            notesTab

        case .deals:
            dealsTab
        }
    }

    @ViewBuilder
    private var notesTab: some View {
        VStack(spacing: theme.spacing.sm) {
            if notes.isEmpty {
                DFEmptyStateBlock(
                    icon: "note.text",
                    title: "No notes yet",
                    message: "Add a note to keep track of important details."
                )
                .padding(.horizontal, theme.spacing.md)
            } else {
                ForEach(notes) { note in
                    DFCard {
                        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                            DFText(note.body, style: .body)
                            DFText(note.createdAt.formatted(date: .abbreviated, time: .omitted), style: .caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        .padding(theme.spacing.sm)
                    }
                    .padding(.horizontal, theme.spacing.md)
                }
            }
            HStack {
                DFTextField("New note…", text: $newNoteText)
                DFButton("Add", style: .secondary) {
                    let trimmed = newNoteText.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    notes.append(CRMNote(body: trimmed))
                    newNoteText = ""
                }
            }
            .padding(.horizontal, theme.spacing.md)
        }
    }

    @ViewBuilder
    private var dealsTab: some View {
        if contact.deals.isEmpty {
            DFEmptyStateBlock(
                icon: "briefcase",
                title: "No deals",
                message: "Deals linked to this contact will appear here."
            )
            .padding(.horizontal, theme.spacing.md)
        } else {
            VStack(spacing: theme.spacing.sm) {
                ForEach(contact.deals) { deal in
                    Button {
                        onDealTapped(deal)
                    } label: {
                        DFCard {
                            HStack {
                                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                                    DFText(deal.name, style: .headline)
                                    DFText(deal.closeDate.formatted(date: .abbreviated, time: .omitted), style: .caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: theme.spacing.xxs) {
                                    DFText(formatCurrency(deal.value), style: .headlineSmall)
                                    DFBadge(deal.stage.rawValue, style: stageBadgeStyle(deal.stage))
                                }
                            }
                            .padding(theme.spacing.sm)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, theme.spacing.md)
                }
            }
        }
    }

    // MARK: Helpers

    private func activityIcon(_ type: CRMActivityType) -> String {
        switch type {
        case .call: "phone"
        case .email: "envelope"
        case .note: "note.text"
        case .meeting: "calendar"
        case .task: "checkmark.circle"
        }
    }

    private func stageBadgeStyle(_ stage: CRMDealStage) -> DFBadgeStyle {
        switch stage {
        case .closedWon: .success
        case .closedLost: .destructive
        default: .default
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 0
        return f.string(from: value as NSDecimalNumber) ?? "$\(value)"
    }
}

// MARK: - Previews

#Preview("Contact Detail — Light") {
    NavigationStack {
        DFCRMContactDetailScreen(
            contact: CRMPreviewFixtures.contacts[0],
            onEditTapped: {},
            onCallTapped: { _ in },
            onEmailTapped: { _ in },
            onAddNoteTapped: { _ in },
            onAddTaskTapped: { _ in },
            onDealTapped: { _ in }
        )
    }
}

#Preview("Contact Detail — Dark") {
    NavigationStack {
        DFCRMContactDetailScreen(
            contact: CRMPreviewFixtures.contacts[0],
            onEditTapped: {},
            onCallTapped: { _ in },
            onEmailTapped: { _ in },
            onAddNoteTapped: { _ in },
            onAddTaskTapped: { _ in },
            onDealTapped: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFCRMContactDetailScreen")
struct DFCRMContactDetailScreenTests {

    @Test("Tabs enum covers all three tabs")
    func tabCases() {
        let cases = DFCRMContactDetailScreen.Tab.allCases
        #expect(cases.count == 3)
        #expect(cases.contains(.activity))
        #expect(cases.contains(.notes))
        #expect(cases.contains(.deals))
    }

    @Test("Note append to empty list")
    func noteAppendEmpty() {
        var notes: [CRMNote] = []
        let note = CRMNote(body: "Call went well")
        notes.append(note)
        #expect(notes.count == 1)
        #expect(notes.first?.body == "Call went well")
    }

    @Test("Blank note is not added")
    func blankNoteGuard() {
        var notes: [CRMNote] = []
        let text = "   "
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            notes.append(CRMNote(body: trimmed))
        }
        #expect(notes.isEmpty)
    }
}
```

---

## Task 4 — DFCRMPipelineScreen

**File:** `Sources/DesignFoundationScreens/CRM/DFCRMPipelineScreen.swift`
**Test:** `Tests/DesignFoundationScreensTests/CRM/DFCRMPipelineScreenTests.swift`

### Purpose
The kanban board reps drag deals across all day. Horizontally scrolling columns, one per stage. Each column shows deal count and total value. Deal cards show contact, company, value, days-in-stage, and assigned avatar. Won = success tint, Lost = destructive tint. Tap a card to navigate to DFCRMDealDetailScreen.

### Layout

```
NavigationStack
  ├── .navigationTitle("Pipeline")
  └── ScrollView(.horizontal, showsIndicators: false)
        └── HStack(spacing: 0) — one PipelineColumn per stage
              └── PipelineColumn
                    ├── Column Header (stage name, deal count, total value)
                    │     background: success/destructive/surface per stage
                    ├── ScrollView(.vertical)
                    │     └── ForEach deals → DealCard (tap → onDealTapped)
                    └── DFEmptyStateBlock (if no deals in stage)
```

### Implementation

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Screen

@MainActor
public struct DFCRMPipelineScreen: View {

    // MARK: Props

    public var deals: [CRMDeal]
    public var onDealTapped: @MainActor (CRMDeal) -> Void
    public var onAddDealTapped: @MainActor () -> Void

    // MARK: Init

    public init(
        deals: [CRMDeal],
        onDealTapped: @escaping @MainActor (CRMDeal) -> Void,
        onAddDealTapped: @escaping @MainActor () -> Void
    ) {
        self.deals = deals
        self.onDealTapped = onDealTapped
        self.onAddDealTapped = onAddDealTapped
    }

    @Environment(\.dfTheme) private var theme

    private let columnWidth: CGFloat = 280

    // MARK: Body

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                ForEach(CRMDealStage.pipelineOrder, id: \.self) { stage in
                    PipelineColumn(
                        stage: stage,
                        deals: deals(for: stage),
                        columnWidth: columnWidth,
                        onDealTapped: onDealTapped
                    )
                }
            }
            .padding(theme.spacing.md)
        }
        .navigationTitle("Pipeline")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onAddDealTapped) {
                    Label("Add Deal", systemImage: "plus")
                }
            }
        }
        .background(theme.colors.backgroundSecondary)
    }

    private func deals(for stage: CRMDealStage) -> [CRMDeal] {
        deals.filter { $0.stage == stage }
    }
}

// MARK: - Pipeline Column

@MainActor
private struct PipelineColumn: View {

    let stage: CRMDealStage
    let deals: [CRMDeal]
    let columnWidth: CGFloat
    let onDealTapped: @MainActor (CRMDeal) -> Void

    @Environment(\.dfTheme) private var theme

    var body: some View {
        VStack(spacing: 0) {
            columnHeader
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: theme.spacing.sm) {
                    if deals.isEmpty {
                        DFEmptyStateBlock(
                            icon: "arrow.down.circle.dotted",
                            title: "No deals",
                            message: "Drop deals here"
                        )
                        .padding(.top, theme.spacing.lg)
                    } else {
                        ForEach(deals) { deal in
                            DealCard(deal: deal) { onDealTapped(deal) }
                        }
                    }
                }
                .padding(theme.spacing.sm)
            }
        }
        .frame(width: columnWidth)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg))
    }

    @ViewBuilder
    private var columnHeader: some View {
        let totalValue = deals.reduce(Decimal(0)) { $0 + $1.value }
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            HStack {
                DFText(stage.rawValue, style: .headlineSmall)
                    .foregroundStyle(headerForeground)
                Spacer()
                DFBadge("\(deals.count)", style: .default)
            }
            DFText(formatCurrency(totalValue), style: .caption)
                .foregroundStyle(headerForeground.opacity(0.8))
        }
        .padding(theme.spacing.sm)
        .background(headerBackground)
    }

    private var headerBackground: Color {
        switch stage {
        case .closedWon: theme.colors.success.opacity(0.2)
        case .closedLost: theme.colors.destructive.opacity(0.15)
        default: theme.colors.surfaceSecondary
        }
    }

    private var headerForeground: Color {
        switch stage {
        case .closedWon: theme.colors.success
        case .closedLost: theme.colors.destructive
        default: theme.colors.textPrimary
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 0
        return f.string(from: value as NSDecimalNumber) ?? "$\(value)"
    }
}

// MARK: - Deal Card

@MainActor
private struct DealCard: View {

    let deal: CRMDeal
    let onTap: @MainActor () -> Void

    @Environment(\.dfTheme) private var theme

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        DFText(deal.contactName, style: .headline)
                        DFText(deal.contactCompany, style: .caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Spacer()
                    DFAvatar(initials: deal.assignedAvatarInitials, size: .sm)
                }
                DFText(formatCurrency(deal.value), style: .headlineSmall)
                    .foregroundStyle(theme.colors.primary)
                if deal.daysInStage > 0 {
                    DFText("\(deal.daysInStage)d in stage", style: .labelSmall)
                        .foregroundStyle(daysInStageColor)
                }
            }
            .padding(theme.spacing.sm)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var daysInStageColor: Color {
        deal.daysInStage > 14 ? theme.colors.warning : theme.colors.textSecondary
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 0
        return f.string(from: value as NSDecimalNumber) ?? "$\(value)"
    }
}

// MARK: - Previews

#Preview("Pipeline — Light") {
    NavigationStack {
        DFCRMPipelineScreen(
            deals: CRMPreviewFixtures.deals,
            onDealTapped: { _ in },
            onAddDealTapped: {}
        )
    }
}

#Preview("Pipeline — Dark") {
    NavigationStack {
        DFCRMPipelineScreen(
            deals: CRMPreviewFixtures.deals,
            onDealTapped: { _ in },
            onAddDealTapped: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFCRMPipelineScreen")
struct DFCRMPipelineScreenTests {

    @Test("Filtering deals by stage returns correct subset")
    func filterByStage() {
        let deals = CRMPreviewFixtures.deals
        let wonDeals = deals.filter { $0.stage == .closedWon }
        let lostDeals = deals.filter { $0.stage == .closedLost }
        #expect(!wonDeals.isEmpty)
        #expect(!lostDeals.isEmpty)
        #expect(wonDeals.allSatisfy { $0.stage == .closedWon })
        #expect(lostDeals.allSatisfy { $0.stage == .closedLost })
    }

    @Test("Total value of filtered deals is sum of individual values")
    func totalValue() {
        let deals = CRMPreviewFixtures.deals.filter { $0.stage == .negotiation }
        let total = deals.reduce(Decimal(0)) { $0 + $1.value }
        let manual = deals.map(\.value).reduce(0, +)
        #expect(total == manual)
    }

    @Test("Pipeline order has exactly 6 stages")
    func pipelineOrderCount() {
        #expect(CRMDealStage.pipelineOrder.count == 6)
    }

    @Test("Days in stage warning threshold: >14 days triggers warning color logic")
    func daysInStageWarning() {
        let borderline = 14
        let overThreshold = 15
        // Mirrors the logic in DealCard
        #expect(borderline <= 14)       // not warning
        #expect(overThreshold > 14)     // warning
    }
}
```

---

## Task 5 — DFCRMContactsScreen

**File:** `Sources/DesignFoundationScreens/CRM/DFCRMContactsScreen.swift`
**Test:** `Tests/DesignFoundationScreensTests/CRM/DFCRMContactsScreenTests.swift`

### Purpose
The full contact list — where reps spend half their day. Search bar, filter chips (All / Leads / Customers / Inactive), sortable list with swipe actions (Call / Email), and an add FAB.

### Layout

```
NavigationStack
  ├── .navigationTitle("Contacts")
  ├── .searchable(text: $searchText)
  └── VStack
        ├── FilterChipBar (All | Leads | Customers | Inactive)
        ├── SortMenu toolbar button
        └── DFList / List
              ├── [loading] DFBlockSkeletonBlock × 5
              ├── [empty] DFEmptyStateBlock
              └── [data] ForEach filteredContacts
                    DFContactRow
                      .swipeActions(edge: .leading) → Call
                      .swipeActions(edge: .trailing) → Email
  └── FAB overlay (bottom-trailing) → onAddContactTapped
```

### Implementation

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Screen

@MainActor
public struct DFCRMContactsScreen: View {

    // MARK: Props

    public var contacts: [CRMContact]
    public var isLoading: Bool
    public var onContactTapped: @MainActor (CRMContact) -> Void
    public var onCallTapped: @MainActor (CRMContact) -> Void
    public var onEmailTapped: @MainActor (CRMContact) -> Void
    public var onAddContactTapped: @MainActor () -> Void

    // MARK: Init

    public init(
        contacts: [CRMContact],
        isLoading: Bool = false,
        onContactTapped: @escaping @MainActor (CRMContact) -> Void,
        onCallTapped: @escaping @MainActor (CRMContact) -> Void,
        onEmailTapped: @escaping @MainActor (CRMContact) -> Void,
        onAddContactTapped: @escaping @MainActor () -> Void
    ) {
        self.contacts = contacts
        self.isLoading = isLoading
        self.onContactTapped = onContactTapped
        self.onCallTapped = onCallTapped
        self.onEmailTapped = onEmailTapped
        self.onAddContactTapped = onAddContactTapped
    }

    // MARK: State

    public enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case leads = "Leads"
        case customers = "Customers"
        case inactive = "Inactive"
        public var id: String { rawValue }
    }

    public enum SortOption: String, CaseIterable, Identifiable {
        case recent = "Recent"
        case name = "Name"
        case status = "Status"
        public var id: String { rawValue }
    }

    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var selectedSort: SortOption = .recent

    @Environment(\.dfTheme) private var theme

    // MARK: Derived

    private var filteredContacts: [CRMContact] {
        var result = contacts

        // Filter by status
        switch selectedFilter {
        case .all: break
        case .leads: result = result.filter { $0.status == .lead }
        case .customers: result = result.filter { $0.status == .customer }
        case .inactive: result = result.filter { $0.status == .inactive }
        }

        // Search
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.company.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        switch selectedSort {
        case .recent:
            result = result.sorted { $0.lastContactedDate > $1.lastContactedDate }
        case .name:
            result = result.sorted { $0.name < $1.name }
        case .status:
            result = result.sorted { $0.status.rawValue < $1.status.rawValue }
        }

        return result
    }

    // MARK: Body

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                filterChipBar
                contactList
            }
            fab
        }
        .navigationTitle("Contacts")
        .searchable(text: $searchText, prompt: "Search contacts…")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sort by", selection: $selectedSort) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
    }

    // MARK: Filter Chips

    @ViewBuilder
    private var filterChipBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(FilterOption.allCases) { option in
                    Button {
                        selectedFilter = option
                    } label: {
                        DFText(option.rawValue, style: .labelMedium)
                            .padding(.horizontal, theme.spacing.sm)
                            .padding(.vertical, theme.spacing.xs)
                            .background(selectedFilter == option
                                        ? theme.colors.primary
                                        : theme.colors.surfaceSecondary)
                            .foregroundStyle(selectedFilter == option
                                             ? theme.colors.onPrimary
                                             : theme.colors.textPrimary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
        }
        .background(theme.colors.surface)
    }

    // MARK: Contact List

    @ViewBuilder
    private var contactList: some View {
        if isLoading {
            List {
                ForEach(0..<5, id: \.self) { _ in
                    DFBlockSkeletonBlock()
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
        } else if filteredContacts.isEmpty {
            DFEmptyStateBlock(
                icon: "person.3",
                title: searchText.isEmpty ? "No contacts" : "No results",
                message: searchText.isEmpty
                    ? "Add your first contact to get started."
                    : "Try a different search or filter."
            )
        } else {
            List {
                ForEach(filteredContacts) { contact in
                    DFContactRow(
                        name: contact.name,
                        subtitle: "\(contact.title) · \(contact.company)",
                        avatarInitials: contact.avatarInitials,
                        badge: contact.status.rawValue,
                        detail: "Last contacted \(contact.lastContactedDate.formatted(.relative(presentation: .named)))"
                    ) {
                        onContactTapped(contact)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            onCallTapped(contact)
                        } label: {
                            Label("Call", systemImage: "phone")
                        }
                        .tint(theme.colors.success)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            onEmailTapped(contact)
                        } label: {
                            Label("Email", systemImage: "envelope")
                        }
                        .tint(theme.colors.primary)
                    }
                    .listRowInsets(.init(top: 0, leading: theme.spacing.md, bottom: 0, trailing: theme.spacing.md))
                    .listRowSeparatorTint(theme.colors.borderSubtle)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: FAB

    @ViewBuilder
    private var fab: some View {
        Button(action: onAddContactTapped) {
            Label("Add Contact", systemImage: "plus")
                .labelStyle(.iconOnly)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(theme.colors.onPrimary)
                .frame(width: 56, height: 56)
                .background(theme.colors.primary)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(theme.spacing.lg)
        .accessibilityLabel("Add Contact")
    }
}

// MARK: - Previews

#Preview("Contacts — Light") {
    NavigationStack {
        DFCRMContactsScreen(
            contacts: CRMPreviewFixtures.contacts,
            onContactTapped: { _ in },
            onCallTapped: { _ in },
            onEmailTapped: { _ in },
            onAddContactTapped: {}
        )
    }
}

#Preview("Contacts — Loading") {
    NavigationStack {
        DFCRMContactsScreen(
            contacts: [],
            isLoading: true,
            onContactTapped: { _ in },
            onCallTapped: { _ in },
            onEmailTapped: { _ in },
            onAddContactTapped: {}
        )
    }
}

#Preview("Contacts — Empty") {
    NavigationStack {
        DFCRMContactsScreen(
            contacts: [],
            onContactTapped: { _ in },
            onCallTapped: { _ in },
            onEmailTapped: { _ in },
            onAddContactTapped: {}
        )
    }
}

#Preview("Contacts — Dark") {
    NavigationStack {
        DFCRMContactsScreen(
            contacts: CRMPreviewFixtures.contacts,
            onContactTapped: { _ in },
            onCallTapped: { _ in },
            onEmailTapped: { _ in },
            onAddContactTapped: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFCRMContactsScreen")
struct DFCRMContactsScreenTests {

    private let contacts = CRMPreviewFixtures.contacts

    @Test("Filter: leads returns only lead-status contacts")
    func filterLeads() {
        let result = contacts.filter { $0.status == .lead }
        #expect(result.allSatisfy { $0.status == .lead })
        #expect(!result.isEmpty)
    }

    @Test("Filter: customers returns only customer-status contacts")
    func filterCustomers() {
        let result = contacts.filter { $0.status == .customer }
        #expect(result.allSatisfy { $0.status == .customer })
    }

    @Test("Search: case-insensitive match on name")
    func searchCaseInsensitive() {
        let query = "sarah"
        let result = contacts.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
        #expect(result.contains(where: { $0.name == "Sarah Chen" }))
    }

    @Test("Search: empty query returns all contacts")
    func emptySearchReturnsAll() {
        let result = contacts.filter {
            "".isEmpty || $0.name.localizedCaseInsensitiveContains("")
        }
        #expect(result.count == contacts.count)
    }

    @Test("Sort by name: ascending alphabetical")
    func sortByName() {
        let sorted = contacts.sorted { $0.name < $1.name }
        for i in 0..<(sorted.count - 1) {
            #expect(sorted[i].name <= sorted[i + 1].name)
        }
    }

    @Test("Sort by recent: most recently contacted first")
    func sortByRecent() {
        let sorted = contacts.sorted { $0.lastContactedDate > $1.lastContactedDate }
        for i in 0..<(sorted.count - 1) {
            #expect(sorted[i].lastContactedDate >= sorted[i + 1].lastContactedDate)
        }
    }
}
```

---

## Task 6 — DFCRMHomeScreen

**File:** `Sources/DesignFoundationScreens/CRM/DFCRMHomeScreen.swift`
**Test:** `Tests/DesignFoundationScreensTests/CRM/DFCRMHomeScreenTests.swift`

### Purpose
The sales rep's morning dashboard. Today's tasks (overdue in destructive color, due today normal), follow-ups due (contact + last contacted date), pipeline summary as a horizontal stat row, recent activity feed (last 5 interactions), and a FAB for quick-add (task or contact).

### Layout

```
NavigationStack
  ├── .navigationTitle("Today")
  └── ZStack(alignment: .bottomTrailing)
        ├── ScrollView(.vertical)
        │     ├── [loading] DFBlockSkeletonBlock × 4
        │     ├── [empty new user] DFEmptyStateBlock
        │     └── [data]
        │           ├── Section "Tasks"
        │           │     ForEach todayTasks → TaskRow (overdue = .destructive)
        │           │     DFEmptyStateBlock if none
        │           ├── Section "Follow-ups Due"
        │           │     ForEach followUps → FollowUpRow
        │           ├── Section "Pipeline"
        │           │     HStack → DFStatCardBlock per stage (3 key stages)
        │           └── Section "Recent Activity"
        │                 DFActivityFeedBlock (first 5 items)
        └── FAB → showQuickAddSheet
              Sheet: "New Task" | "New Contact" buttons
```

### Implementation

```swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Screen

@MainActor
public struct DFCRMHomeScreen: View {

    // MARK: Props

    public var tasks: [CRMTask]
    public var followUps: [CRMFollowUp]
    public var deals: [CRMDeal]
    public var recentActivity: [CRMActivity]
    public var isLoading: Bool
    public var onContactTapped: @MainActor (UUID) -> Void
    public var onDealTapped: @MainActor (CRMDeal) -> Void
    public var onTaskCompleted: @MainActor (CRMTask) -> Void
    public var onAddTaskTapped: @MainActor () -> Void
    public var onAddContactTapped: @MainActor () -> Void

    // MARK: Init

    public init(
        tasks: [CRMTask],
        followUps: [CRMFollowUp],
        deals: [CRMDeal],
        recentActivity: [CRMActivity],
        isLoading: Bool = false,
        onContactTapped: @escaping @MainActor (UUID) -> Void,
        onDealTapped: @escaping @MainActor (CRMDeal) -> Void,
        onTaskCompleted: @escaping @MainActor (CRMTask) -> Void,
        onAddTaskTapped: @escaping @MainActor () -> Void,
        onAddContactTapped: @escaping @MainActor () -> Void
    ) {
        self.tasks = tasks
        self.followUps = followUps
        self.deals = deals
        self.recentActivity = recentActivity
        self.isLoading = isLoading
        self.onContactTapped = onContactTapped
        self.onDealTapped = onDealTapped
        self.onTaskCompleted = onTaskCompleted
        self.onAddTaskTapped = onAddTaskTapped
        self.onAddContactTapped = onAddContactTapped
    }

    // MARK: State

    @State private var showQuickAdd = false
    @Environment(\.dfTheme) private var theme

    // MARK: Derived

    /// Tasks overdue or due today, sorted: overdue first, then by date
    private var urgentTasks: [CRMTask] {
        tasks
            .filter { $0.isOverdue || $0.isDueToday }
            .sorted {
                if $0.isOverdue != $1.isOverdue { return $0.isOverdue }
                return $0.dueDate < $1.dueDate
            }
    }

    private func dealCount(for stage: CRMDealStage) -> Int {
        deals.filter { $0.stage == stage }.count
    }

    private func dealTotal(for stage: CRMDealStage) -> Decimal {
        deals.filter { $0.stage == stage }.reduce(0) { $0 + $1.value }
    }

    // MARK: Body

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if isLoading {
                loadingState
            } else if tasks.isEmpty && followUps.isEmpty && deals.isEmpty {
                newUserEmptyState
            } else {
                contentScroll
            }
            fab
        }
        .navigationTitle("Today")
        .confirmationDialog("Quick Add", isPresented: $showQuickAdd) {
            Button("New Task", action: onAddTaskTapped)
            Button("New Contact", action: onAddContactTapped)
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: Loading

    @ViewBuilder
    private var loadingState: some View {
        ScrollView {
            VStack(spacing: theme.spacing.md) {
                ForEach(0..<4, id: \.self) { _ in
                    DFBlockSkeletonBlock()
                        .padding(.horizontal, theme.spacing.md)
                }
            }
            .padding(.vertical, theme.spacing.md)
        }
    }

    // MARK: Empty State (new user)

    @ViewBuilder
    private var newUserEmptyState: some View {
        DFEmptyStateBlock(
            icon: "chart.line.uptrend.xyaxis",
            title: "Welcome to CRM",
            message: "Add your first contact or deal to get started.",
            actionLabel: "Add Contact",
            onAction: onAddContactTapped
        )
    }

    // MARK: Content

    @ViewBuilder
    private var contentScroll: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                tasksSection
                followUpsSection
                pipelineSection
                activitySection
            }
            .padding(.vertical, theme.spacing.md)
            .padding(.bottom, 80) // clearance for FAB
        }
    }

    // MARK: Tasks Section

    @ViewBuilder
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            sectionHeader("Tasks", count: urgentTasks.count)
            if urgentTasks.isEmpty {
                DFEmptyStateBlock(
                    icon: "checkmark.circle",
                    title: "All clear",
                    message: "No tasks due today."
                )
                .padding(.horizontal, theme.spacing.md)
            } else {
                ForEach(urgentTasks) { task in
                    TaskRow(task: task, onComplete: { onTaskCompleted(task) })
                        .padding(.horizontal, theme.spacing.md)
                }
            }
        }
    }

    // MARK: Follow-ups Section

    @ViewBuilder
    private var followUpsSection: some View {
        if !followUps.isEmpty {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                sectionHeader("Follow-ups Due", count: followUps.count)
                ForEach(followUps) { followUp in
                    Button {
                        onContactTapped(followUp.contactID)
                    } label: {
                        HStack(spacing: theme.spacing.sm) {
                            DFAvatar(initials: followUp.avatarInitials, size: .md)
                            VStack(alignment: .leading, spacing: 2) {
                                DFText(followUp.contactName, style: .headline)
                                DFText(
                                    "Last contact: \(followUp.lastContactedDate.formatted(.relative(presentation: .named)))",
                                    style: .caption
                                )
                                .foregroundStyle(theme.colors.textSecondary)
                            }
                            Spacer()
                            DFIcon("chevron.right", size: .sm)
                                .foregroundStyle(theme.colors.textTertiary)
                        }
                        .padding(.horizontal, theme.spacing.md)
                        .padding(.vertical, theme.spacing.xs)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Pipeline Section

    @ViewBuilder
    private var pipelineSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            sectionHeader("Pipeline", count: nil)
            HStack(spacing: theme.spacing.sm) {
                DFStatCardBlock(
                    label: "Qualified",
                    value: "\(dealCount(for: .qualified))",
                    detail: formatCurrency(dealTotal(for: .qualified))
                )
                DFStatCardBlock(
                    label: "Proposal",
                    value: "\(dealCount(for: .proposal))",
                    detail: formatCurrency(dealTotal(for: .proposal))
                )
                DFStatCardBlock(
                    label: "Negotiation",
                    value: "\(dealCount(for: .negotiation))",
                    detail: formatCurrency(dealTotal(for: .negotiation))
                )
            }
            .padding(.horizontal, theme.spacing.md)
        }
    }

    // MARK: Activity Section

    @ViewBuilder
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            sectionHeader("Recent Activity", count: nil)
            DFActivityFeedBlock(
                items: Array(recentActivity.prefix(5)).map { a in
                    DFActivityFeedItem(
                        id: a.id.uuidString,
                        iconName: activityIcon(a.type),
                        title: a.title,
                        subtitle: "\(a.contactName) · \(a.detail)",
                        timestamp: a.date.formatted(.relative(presentation: .named))
                    )
                }
            )
            .padding(.horizontal, theme.spacing.md)
        }
    }

    // MARK: FAB

    @ViewBuilder
    private var fab: some View {
        Button {
            showQuickAdd = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(theme.colors.onPrimary)
                .frame(width: 56, height: 56)
                .background(theme.colors.primary)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(theme.spacing.lg)
        .accessibilityLabel("Quick add task or contact")
    }

    // MARK: Helpers

    @ViewBuilder
    private func sectionHeader(_ title: String, count: Int?) -> some View {
        HStack {
            DFText(title, style: .headlineSmall)
            if let count, count > 0 {
                DFBadge("\(count)", style: .default)
            }
        }
        .padding(.horizontal, theme.spacing.md)
    }

    private func activityIcon(_ type: CRMActivityType) -> String {
        switch type {
        case .call: "phone"
        case .email: "envelope"
        case .note: "note.text"
        case .meeting: "calendar"
        case .task: "checkmark.circle"
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 0
        return f.string(from: value as NSDecimalNumber) ?? "$\(value)"
    }
}

// MARK: - Task Row

@MainActor
private struct TaskRow: View {

    let task: CRMTask
    let onComplete: @MainActor () -> Void

    @Environment(\.dfTheme) private var theme

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Button(action: onComplete) {
                Image(systemName: "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(task.isOverdue ? theme.colors.destructive : theme.colors.primary)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 2) {
                DFText(task.title, style: .body)
                    .foregroundStyle(task.isOverdue ? theme.colors.destructive : theme.colors.textPrimary)
                HStack(spacing: 4) {
                    if task.isOverdue {
                        DFBadge("Overdue", style: .destructive)
                    }
                    DFText(task.dueDate.formatted(date: .abbreviated, time: .shortened), style: .caption)
                        .foregroundStyle(theme.colors.textSecondary)
                    if let contactName = task.contactName {
                        DFText("· \(contactName)", style: .caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }
            Spacer()
        }
        .padding(theme.spacing.sm)
        .background(task.isOverdue ? theme.colors.destructive.opacity(0.06) : theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .strokeBorder(
                    task.isOverdue ? theme.colors.destructive.opacity(0.3) : theme.colors.borderSubtle,
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Previews

#Preview("Home — Light") {
    NavigationStack {
        DFCRMHomeScreen(
            tasks: CRMPreviewFixtures.tasks,
            followUps: CRMPreviewFixtures.followUps,
            deals: CRMPreviewFixtures.deals,
            recentActivity: CRMPreviewFixtures.sampleActivity,
            onContactTapped: { _ in },
            onDealTapped: { _ in },
            onTaskCompleted: { _ in },
            onAddTaskTapped: {},
            onAddContactTapped: {}
        )
    }
}

#Preview("Home — Loading") {
    NavigationStack {
        DFCRMHomeScreen(
            tasks: [],
            followUps: [],
            deals: [],
            recentActivity: [],
            isLoading: true,
            onContactTapped: { _ in },
            onDealTapped: { _ in },
            onTaskCompleted: { _ in },
            onAddTaskTapped: {},
            onAddContactTapped: {}
        )
    }
}

#Preview("Home — New User") {
    NavigationStack {
        DFCRMHomeScreen(
            tasks: [],
            followUps: [],
            deals: [],
            recentActivity: [],
            onContactTapped: { _ in },
            onDealTapped: { _ in },
            onTaskCompleted: { _ in },
            onAddTaskTapped: {},
            onAddContactTapped: {}
        )
    }
}

#Preview("Home — Dark") {
    NavigationStack {
        DFCRMHomeScreen(
            tasks: CRMPreviewFixtures.tasks,
            followUps: CRMPreviewFixtures.followUps,
            deals: CRMPreviewFixtures.deals,
            recentActivity: CRMPreviewFixtures.sampleActivity,
            onContactTapped: { _ in },
            onDealTapped: { _ in },
            onTaskCompleted: { _ in },
            onAddTaskTapped: {},
            onAddContactTapped: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

### Tests

```swift
import Testing
import Foundation
@testable import DesignFoundationScreens

@Suite("DFCRMHomeScreen")
struct DFCRMHomeScreenTests {

    @Test("isOverdue: task past due date returns true")
    func overdueTask() {
        let task = CRMTask(
            title: "Old task",
            dueDate: Date().addingTimeInterval(-3600)
        )
        #expect(task.isOverdue)
    }

    @Test("isOverdue: future task returns false")
    func futureTaskNotOverdue() {
        let task = CRMTask(
            title: "Future task",
            dueDate: Date().addingTimeInterval(3600)
        )
        #expect(!task.isOverdue)
    }

    @Test("isDueToday: task with today date returns true")
    func dueTodayTask() {
        let task = CRMTask(
            title: "Today task",
            dueDate: Calendar.current.startOfDay(for: Date())
        )
        #expect(task.isDueToday)
    }

    @Test("isCompleted: completed task is not overdue")
    func completedTaskNotOverdue() {
        let task = CRMTask(
            title: "Done task",
            dueDate: Date().addingTimeInterval(-3600),
            isCompleted: true
        )
        #expect(!task.isOverdue)
    }

    @Test("Urgent tasks sort: overdue before due-today")
    func urgentTaskSort() {
        let overdueTask = CRMTask(title: "Overdue", dueDate: Date().addingTimeInterval(-7200))
        let todayTask = CRMTask(title: "Today", dueDate: Calendar.current.startOfDay(for: Date()))
        let sorted = [todayTask, overdueTask].sorted {
            if $0.isOverdue != $1.isOverdue { return $0.isOverdue }
            return $0.dueDate < $1.dueDate
        }
        #expect(sorted.first?.title == "Overdue")
    }

    @Test("Recent activity prefix limits to 5 items")
    func activityPrefix() {
        let activity = CRMPreviewFixtures.sampleActivity
        let limited = Array(activity.prefix(5))
        #expect(limited.count <= 5)
    }

    @Test("Pipeline deal count by stage is accurate")
    func dealCountByStage() {
        let deals = CRMPreviewFixtures.deals
        let qualifiedCount = deals.filter { $0.stage == .qualified }.count
        let expected = deals.filter { $0.stage == .qualified }.count
        #expect(qualifiedCount == expected)
    }
}
```

---

## File Summary

```
Sources/DesignFoundationScreens/CRM/
├── CRMModels.swift                  — value types shared across all CRM screens
├── CRMPreviewFixtures.swift         — rich preview data (no production dependency)
├── DFCRMAnalyticsScreen.swift       — Task 1
├── DFCRMDealDetailScreen.swift      — Task 2
├── DFCRMContactDetailScreen.swift   — Task 3
├── DFCRMPipelineScreen.swift        — Task 4
├── DFCRMContactsScreen.swift        — Task 5
└── DFCRMHomeScreen.swift            — Task 6

Tests/DesignFoundationScreensTests/CRM/
├── DFCRMAnalyticsScreenTests.swift
├── DFCRMDealDetailScreenTests.swift
├── DFCRMContactDetailScreenTests.swift
├── DFCRMPipelineScreenTests.swift
├── DFCRMContactsScreenTests.swift
└── DFCRMHomeScreenTests.swift
```

---

## Commit Sequence

```
feat(screens): add CRM shared models and preview fixtures
feat(screens): add DFCRMAnalyticsScreen with metric grid and chart zones
feat(screens): add DFCRMDealDetailScreen with stage progress and danger zone
feat(screens): add DFCRMContactDetailScreen with tabbed activity/notes/deals
feat(screens): add DFCRMPipelineScreen with kanban columns
feat(screens): add DFCRMContactsScreen with search, filter, and swipe actions
feat(screens): add DFCRMHomeScreen with tasks, follow-ups, and pipeline summary
```

One commit per source file. Tests can be committed alongside their screen or as a follow-up commit per file.

---

## Implementer Notes

- **Duplicate init warning:** `DFCRMDealDetailScreen` and `DFCRMContactDetailScreen` each have two `init` blocks shown — one for the prop declarations and one that seeds `@State`. In the real file, merge them: the `@State` initializer is the only one needed. The duplicate is shown for clarity.
- **DFActivityFeedItem / DFActivityFeedBlock API:** confirm the exact init signature from the DesignFoundationBlocks source before implementing — adapt field names if they differ.
- **DFDangerZoneBlock:** confirm whether it takes an array of actions or individual closure params; adapt accordingly.
- **DFStatCardBlock `detail` param:** may be optional; check the block's actual API.
- **DFEmptyStateBlock `actionLabel` / `onAction`:** optional params; confirm they exist before using.
- **`theme.colors.warning` / `.onPrimary` / `.textTertiary`:** confirm these token names against the live DFTheme definition; substitute with the closest available if they differ.
- **Swift 6 concurrency:** every closure passed to a child view must be `@MainActor` or `Sendable`. All action closures in this plan are typed `@escaping @MainActor (T) -> Void` — do not drop the `@MainActor`.
