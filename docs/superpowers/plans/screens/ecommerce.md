# E-commerce / Store Manager Screens Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build 4 production-ready merchant-facing store management screens — Orders list, Order detail, Products inventory, and Revenue dashboard — as a cohesive `Ecommerce` module inside `DesignFoundationScreens`.

**Architecture:** Each screen is a standalone `struct … : View` that accepts a `Configuration` struct and reads all visual tokens from `@Environment(\.dfTheme)`. Screens are composable — `DFEcommerceOrdersScreen` navigates to `DFEcommerceOrderDetailScreen` via a passed closure, not a hard `NavigationLink`, keeping screens independently reusable. A shared `Models/` file defines all domain types (`DFOrder`, `DFOrderStatus`, `DFOrderLineItem`, `DFProduct`, etc.) used across screens. No business logic lives in screens — they are pure display + action-closure surfaces.

**Tech Stack:** Swift 6, SwiftUI, Swift Testing, `DesignFoundation` (DFTheme + primitives), `DesignFoundationBlocks` (DFStatCardBlock, DFMetricGridBlock, DFChartPlaceholderBlock, DFProgressRingBlock, DFProgressBar, DFActivityFeedBlock, DFActivityFeedRow, DFContactRow, DFProfileHeaderBlock, DFSearchResultsBlock, DFEmptyStateBlock, DFBlockSkeletonBlock, DFDateRangeBlock, DFTagPickerBlock), `DesignFoundationBlocks` primitives (DFTable, DFList, DFListRow, DFCard, DFButton, DFText, DFBadge, DFAvatar, DFDivider, DFToast)

---

## Global Constraints

- Swift 6 strict concurrency: `StrictConcurrency` experimental feature ON in all targets
- Platforms: iOS 18.0, macOS 15.0, visionOS 2.0
- All colors, typography, spacing, radius from `@Environment(\.dfTheme)` — zero hardcoded values
- Action closures: `@MainActor () -> Void` or `@MainActor (T) -> Void` — Configuration structs do NOT declare `Sendable` (they hold closures)
- Domain model types (`DFOrder`, `DFProduct`, etc.) carry no closures — declare `Sendable, Equatable, Identifiable`
- Previews: one `#Preview("Light") { … }` and one `#Preview("Dark") { … .colorScheme(.dark) }` per screen
- Tests: Swift Testing only (`import Testing`, `@Suite`, `@Test`, `#expect`) — never XCTest
- Adaptive navigation: `NavigationSplitView` on iPad/Mac (sidebar + detail), `TabView` on iPhone — screens themselves are not responsible for the shell; they receive navigation callbacks via closures
- Package: `DesignFoundationScreens` at `/Users/nerdsnipe/Projects/DesignFoundationScreens/`
- Source path: `Sources/DesignFoundationScreens/Ecommerce/` (relative to package root)
- Test path: `Tests/DesignFoundationScreensTests/Ecommerce/` (relative to package root)
- Commit messages: `feat(screens): …`, `test(screens): …`
- No Co-Author line in any commit

---

## File Map

```
Sources/DesignFoundationScreens/Ecommerce/
  Models/
    DFEcommerceModels.swift          ← DFOrder, DFOrderStatus, DFOrderLineItem,
                                        DFProduct, DFProductStatus, DFTrackingInfo,
                                        DFOrderNote, DFEcommerceAddress,
                                        DFRevenuePeriod, DFRevenueMetrics,
                                        DFTopProduct — all Sendable, Equatable, Identifiable

  Orders/
    DFEcommerceOrdersScreen.swift    ← list screen with search, filters, stat row
    DFEcommerceOrdersScreen+Previews.swift

  OrderDetail/
    DFEcommerceOrderDetailScreen.swift   ← full order, timeline, line items, actions
    DFEcommerceOrderDetailScreen+Previews.swift

  Products/
    DFEcommerceProductsScreen.swift  ← grid/list toggle, metric header, search + filter
    DFEcommerceProductsScreen+Previews.swift

  Revenue/
    DFEcommerceRevenueScreen.swift   ← period selector, charts, top products table, ring
    DFEcommerceRevenueScreen+Previews.swift

Tests/DesignFoundationScreensTests/Ecommerce/
  DFEcommerceModelsTests.swift
  DFEcommerceOrdersScreenTests.swift
  DFEcommerceOrderDetailScreenTests.swift
  DFEcommerceProductsScreenTests.swift
  DFEcommerceRevenueScreenTests.swift
```

---

## Task 1: Domain Models

**Files:**
- Create: `Sources/DesignFoundationScreens/Ecommerce/Models/DFEcommerceModels.swift`
- Test: `Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceModelsTests.swift`

**Interfaces:**
- Produces: `DFOrderStatus`, `DFOrder`, `DFOrderLineItem`, `DFOrderNote`, `DFTrackingInfo`, `DFEcommerceAddress`, `DFProductStatus`, `DFProduct`, `DFRevenuePeriod`, `DFRevenueMetrics`, `DFTopProduct` — all used by Tasks 2–5

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceModelsTests.swift
import Testing
@testable import DesignFoundationScreens

@Suite("DFEcommerceModels")
struct DFEcommerceModelsTests {

    @Test("DFOrderStatus badge semantic")
    func orderStatusBadgeSemantic() {
        #expect(DFOrderStatus.pending.badgeSemantic == .warning)
        #expect(DFOrderStatus.processing.badgeSemantic == .primary)
        #expect(DFOrderStatus.shipped.badgeSemantic == .info)
        #expect(DFOrderStatus.delivered.badgeSemantic == .success)
        #expect(DFOrderStatus.returned.badgeSemantic == .destructive)
    }

    @Test("DFOrder conforms to Identifiable via id")
    func orderIdentifiable() {
        let order = DFOrder.stub(id: "ORD-001")
        #expect(order.id == "ORD-001")
    }

    @Test("DFProduct isLowStock logic")
    func productLowStock() {
        let low = DFProduct.stub(inventoryCount: 3, lowStockThreshold: 5)
        let ok  = DFProduct.stub(inventoryCount: 10, lowStockThreshold: 5)
        #expect(low.isLowStock == true)
        #expect(ok.isLowStock == false)
    }

    @Test("DFProduct isOutOfStock logic")
    func productOutOfStock() {
        let oos = DFProduct.stub(inventoryCount: 0, lowStockThreshold: 5)
        #expect(oos.isOutOfStock == true)
        #expect(oos.isLowStock == false) // out-of-stock is not also low-stock
    }

    @Test("DFRevenuePeriod display label")
    func revenuePeriodLabel() {
        #expect(DFRevenuePeriod.today.displayLabel == "Today")
        #expect(DFRevenuePeriod.sevenDays.displayLabel == "7D")
        #expect(DFRevenuePeriod.thirtyDays.displayLabel == "30D")
        #expect(DFRevenuePeriod.ninetyDays.displayLabel == "90D")
        #expect(DFRevenuePeriod.custom.displayLabel == "Custom")
    }

    @Test("DFRevenueMetrics delta sign")
    func revenueDeltaSign() {
        let metrics = DFRevenueMetrics.stub(todayRevenue: 1200, yesterdayRevenue: 1000)
        #expect(metrics.revenueDelta == 200)
        #expect(metrics.revenueDeltaPercent == 20.0)
    }
}
```

- [ ] **Step 2: Run to verify tests fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFEcommerceModelsTests 2>&1 | head -20
```
Expected: compile error — types not yet defined.

- [ ] **Step 3: Write the models**

```swift
// Sources/DesignFoundationScreens/Ecommerce/Models/DFEcommerceModels.swift
import Foundation

// MARK: - Order Status

public enum DFOrderStatus: String, CaseIterable, Sendable, Equatable, Hashable {
    case pending
    case processing
    case shipped
    case delivered
    case returned

    public var displayLabel: String {
        switch self {
        case .pending:    return "Pending"
        case .processing: return "Processing"
        case .shipped:    return "Shipped"
        case .delivered:  return "Delivered"
        case .returned:   return "Returned"
        }
    }

    /// Maps to DFBadgeSemantic for color-coding — consumed by DFBadge(semantic:)
    public var badgeSemantic: DFBadgeSemantic {
        switch self {
        case .pending:    return .warning
        case .processing: return .primary
        case .shipped:    return .info
        case .delivered:  return .success
        case .returned:   return .destructive
        }
    }
}

// MARK: - Order

public struct DFOrder: Sendable, Equatable, Identifiable {
    public let id: String              // e.g. "ORD-1042"
    public let customerName: String
    public let customerAvatarURL: URL?
    public let itemCount: Int
    public let total: Decimal
    public let status: DFOrderStatus
    public let placedAt: Date
    public let lineItems: [DFOrderLineItem]
    public let shippingAddress: DFEcommerceAddress
    public let notes: [DFOrderNote]
    public let tracking: DFTrackingInfo?

    public init(
        id: String,
        customerName: String,
        customerAvatarURL: URL? = nil,
        itemCount: Int,
        total: Decimal,
        status: DFOrderStatus,
        placedAt: Date,
        lineItems: [DFOrderLineItem] = [],
        shippingAddress: DFEcommerceAddress,
        notes: [DFOrderNote] = [],
        tracking: DFTrackingInfo? = nil
    ) {
        self.id = id
        self.customerName = customerName
        self.customerAvatarURL = customerAvatarURL
        self.itemCount = itemCount
        self.total = total
        self.status = status
        self.placedAt = placedAt
        self.lineItems = lineItems
        self.shippingAddress = shippingAddress
        self.notes = notes
        self.tracking = tracking
    }
}

// MARK: - Order Line Item

public struct DFOrderLineItem: Sendable, Equatable, Identifiable {
    public let id: String
    public let productName: String
    public let variantLabel: String?   // e.g. "Size: M / Color: Blue"
    public let quantity: Int
    public let unitPrice: Decimal

    public var subtotal: Decimal { Decimal(quantity) * unitPrice }

    public init(
        id: String,
        productName: String,
        variantLabel: String? = nil,
        quantity: Int,
        unitPrice: Decimal
    ) {
        self.id = id
        self.productName = productName
        self.variantLabel = variantLabel
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}

// MARK: - Order Note

public struct DFOrderNote: Sendable, Equatable, Identifiable {
    public let id: String
    public let body: String
    public let createdAt: Date
    public let authorName: String

    public init(id: String, body: String, createdAt: Date, authorName: String) {
        self.id = id
        self.body = body
        self.createdAt = createdAt
        self.authorName = authorName
    }
}

// MARK: - Tracking Info

public struct DFTrackingInfo: Sendable, Equatable {
    public let carrier: String
    public let trackingNumber: String
    public let trackingURL: URL?

    public init(carrier: String, trackingNumber: String, trackingURL: URL? = nil) {
        self.carrier = carrier
        self.trackingNumber = trackingNumber
        self.trackingURL = trackingURL
    }
}

// MARK: - Address

public struct DFEcommerceAddress: Sendable, Equatable {
    public let line1: String
    public let line2: String?
    public let city: String
    public let state: String
    public let postalCode: String
    public let country: String

    public init(
        line1: String,
        line2: String? = nil,
        city: String,
        state: String,
        postalCode: String,
        country: String
    ) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }

    public var formattedSingleLine: String {
        let parts = [line1, line2, "\(city), \(state) \(postalCode)", country]
        return parts.compactMap { $0 }.joined(separator: " · ")
    }
}

// MARK: - Product Status

public enum DFProductStatus: String, CaseIterable, Sendable, Equatable, Hashable {
    case active
    case draft
    case outOfStock
    case archived

    public var displayLabel: String {
        switch self {
        case .active:     return "Active"
        case .draft:      return "Draft"
        case .outOfStock: return "Out of Stock"
        case .archived:   return "Archived"
        }
    }
}

// MARK: - Product

public struct DFProduct: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let price: Decimal
    public let inventoryCount: Int
    public let lowStockThreshold: Int
    public let status: DFProductStatus
    public let imageURL: URL?
    public let category: String?

    public var isOutOfStock: Bool { inventoryCount == 0 }
    public var isLowStock: Bool   { inventoryCount > 0 && inventoryCount < lowStockThreshold }

    public init(
        id: String,
        name: String,
        price: Decimal,
        inventoryCount: Int,
        lowStockThreshold: Int = 10,
        status: DFProductStatus = .active,
        imageURL: URL? = nil,
        category: String? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.inventoryCount = inventoryCount
        self.lowStockThreshold = lowStockThreshold
        self.status = status
        self.imageURL = imageURL
        self.category = category
    }
}

// MARK: - Revenue Period

public enum DFRevenuePeriod: String, CaseIterable, Sendable, Equatable, Hashable {
    case today
    case sevenDays
    case thirtyDays
    case ninetyDays
    case custom

    public var displayLabel: String {
        switch self {
        case .today:      return "Today"
        case .sevenDays:  return "7D"
        case .thirtyDays: return "30D"
        case .ninetyDays: return "90D"
        case .custom:     return "Custom"
        }
    }
}

// MARK: - Revenue Metrics

public struct DFRevenueMetrics: Sendable, Equatable {
    public let todayRevenue: Decimal
    public let yesterdayRevenue: Decimal
    public let grossRevenue: Decimal
    public let netRevenue: Decimal
    public let totalRefunds: Decimal
    public let avgOrderValue: Decimal
    public let monthlyTarget: Decimal
    public let monthlyActual: Decimal

    public var revenueDelta: Decimal { todayRevenue - yesterdayRevenue }
    public var revenueDeltaPercent: Double {
        guard yesterdayRevenue > 0 else { return 0 }
        return Double(truncating: (revenueDelta / yesterdayRevenue * 100) as NSDecimalNumber)
    }
    public var monthlyProgress: Double {
        guard monthlyTarget > 0 else { return 0 }
        return Double(truncating: (monthlyActual / monthlyTarget) as NSDecimalNumber)
    }

    public init(
        todayRevenue: Decimal,
        yesterdayRevenue: Decimal,
        grossRevenue: Decimal,
        netRevenue: Decimal,
        totalRefunds: Decimal,
        avgOrderValue: Decimal,
        monthlyTarget: Decimal,
        monthlyActual: Decimal
    ) {
        self.todayRevenue = todayRevenue
        self.yesterdayRevenue = yesterdayRevenue
        self.grossRevenue = grossRevenue
        self.netRevenue = netRevenue
        self.totalRefunds = totalRefunds
        self.avgOrderValue = avgOrderValue
        self.monthlyTarget = monthlyTarget
        self.monthlyActual = monthlyActual
    }
}

// MARK: - Top Product (revenue table row)

public struct DFTopProduct: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let unitsSold: Int
    public let revenue: Decimal
    public let percentOfTotal: Double

    public init(
        id: String,
        name: String,
        unitsSold: Int,
        revenue: Decimal,
        percentOfTotal: Double
    ) {
        self.id = id
        self.name = name
        self.unitsSold = unitsSold
        self.revenue = revenue
        self.percentOfTotal = percentOfTotal
    }
}

// MARK: - DFBadgeSemantic (if not already in DesignFoundation)
// If DesignFoundation already exports DFBadgeSemantic, delete this block.
// If it does not, define it here and file an issue to move it upstream.
public enum DFBadgeSemantic: String, Sendable, Equatable {
    case primary, success, warning, info, destructive, neutral
}

// MARK: - Stubs (test-only helpers — internal, not shipped to consumers)
#if DEBUG
extension DFOrder {
    static func stub(
        id: String = "ORD-001",
        customerName: String = "Jane Smith",
        total: Decimal = 129.99,
        status: DFOrderStatus = .pending,
        placedAt: Date = Date()
    ) -> DFOrder {
        DFOrder(
            id: id,
            customerName: customerName,
            itemCount: 2,
            total: total,
            status: status,
            placedAt: placedAt,
            shippingAddress: DFEcommerceAddress(
                line1: "123 Main St",
                city: "Austin",
                state: "TX",
                postalCode: "78701",
                country: "US"
            )
        )
    }
}

extension DFProduct {
    static func stub(
        id: String = "PROD-001",
        name: String = "Classic Tee",
        inventoryCount: Int = 5,
        lowStockThreshold: Int = 10,
        status: DFProductStatus = .active
    ) -> DFProduct {
        DFProduct(
            id: id,
            name: name,
            price: 29.99,
            inventoryCount: inventoryCount,
            lowStockThreshold: lowStockThreshold,
            status: status
        )
    }
}

extension DFRevenueMetrics {
    static func stub(todayRevenue: Decimal = 1200, yesterdayRevenue: Decimal = 1000) -> DFRevenueMetrics {
        DFRevenueMetrics(
            todayRevenue: todayRevenue,
            yesterdayRevenue: yesterdayRevenue,
            grossRevenue: 42_500,
            netRevenue: 38_200,
            totalRefunds: 1_800,
            avgOrderValue: 87.50,
            monthlyTarget: 50_000,
            monthlyActual: 42_500
        )
    }
}
#endif
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFEcommerceModelsTests 2>&1 | tail -10
```
Expected: `Test Suite 'DFEcommerceModelsTests' passed`

- [ ] **Step 5: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Ecommerce/Models/DFEcommerceModels.swift \
        Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceModelsTests.swift
git commit -m "feat(screens): add DFEcommerce domain models"
```

---

## Task 2: DFEcommerceOrdersScreen

*The first thing a merchant opens in the morning — orders that need action today.*

**Files:**
- Create: `Sources/DesignFoundationScreens/Ecommerce/Orders/DFEcommerceOrdersScreen.swift`
- Create: `Sources/DesignFoundationScreens/Ecommerce/Orders/DFEcommerceOrdersScreen+Previews.swift`
- Test: `Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceOrdersScreenTests.swift`

**Interfaces:**
- Consumes: `DFOrder`, `DFOrderStatus`, `DFBadgeSemantic` from Task 1
- Produces: `DFEcommerceOrdersScreen` (public struct), `DFEcommerceOrdersScreen.Configuration` (public struct)

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceOrdersScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFEcommerceOrdersScreen")
struct DFEcommerceOrdersScreenTests {

    @Test("Configuration stores orders")
    func configurationStoresOrders() {
        let orders = [DFOrder.stub(id: "ORD-1"), DFOrder.stub(id: "ORD-2")]
        let config = DFEcommerceOrdersScreen.Configuration(orders: orders)
        #expect(config.orders.count == 2)
    }

    @Test("Configuration default period is today")
    func defaultPeriodIsToday() {
        let config = DFEcommerceOrdersScreen.Configuration(orders: [])
        #expect(config.initialPeriod == .today)
    }

    @Test("Configuration default status filter is all")
    func defaultStatusFilterIsAll() {
        let config = DFEcommerceOrdersScreen.Configuration(orders: [])
        #expect(config.initialStatusFilter == nil)
    }

    @Test("filteredOrders returns all when statusFilter is nil")
    @MainActor func filteredOrdersAllStatuses() {
        let orders = DFOrderStatus.allCases.map { status in
            DFOrder.stub(id: "ORD-\(status.rawValue)", status: status)
        }
        let config = DFEcommerceOrdersScreen.Configuration(orders: orders)
        let screen = DFEcommerceOrdersScreen(configuration: config)
        #expect(screen.filteredOrders(statusFilter: nil, query: "").count == orders.count)
    }

    @Test("filteredOrders filters by status")
    @MainActor func filteredOrdersByStatus() {
        let orders = [
            DFOrder.stub(id: "ORD-1", status: .pending),
            DFOrder.stub(id: "ORD-2", status: .shipped),
        ]
        let config = DFEcommerceOrdersScreen.Configuration(orders: orders)
        let screen = DFEcommerceOrdersScreen(configuration: config)
        let result = screen.filteredOrders(statusFilter: .shipped, query: "")
        #expect(result.count == 1)
        #expect(result[0].id == "ORD-2")
    }

    @Test("filteredOrders filters by search query on order id")
    @MainActor func filteredOrdersByQuery() {
        let orders = [
            DFOrder.stub(id: "ORD-100", customerName: "Alice"),
            DFOrder.stub(id: "ORD-200", customerName: "Bob"),
        ]
        let config = DFEcommerceOrdersScreen.Configuration(orders: orders)
        let screen = DFEcommerceOrdersScreen(configuration: config)
        let result = screen.filteredOrders(statusFilter: nil, query: "100")
        #expect(result.count == 1)
        #expect(result[0].id == "ORD-100")
    }

    @Test("filteredOrders filters by customer name")
    @MainActor func filteredOrdersByCustomerName() {
        let orders = [
            DFOrder.stub(id: "ORD-1", customerName: "Alice Johnson"),
            DFOrder.stub(id: "ORD-2", customerName: "Bob Smith"),
        ]
        let config = DFEcommerceOrdersScreen.Configuration(orders: orders)
        let screen = DFEcommerceOrdersScreen(configuration: config)
        let result = screen.filteredOrders(statusFilter: nil, query: "alice")
        #expect(result.count == 1)
        #expect(result[0].customerName == "Alice Johnson")
    }
}
```

- [ ] **Step 2: Run to verify tests fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFEcommerceOrdersScreenTests 2>&1 | head -20
```
Expected: compile error — `DFEcommerceOrdersScreen` not found.

- [ ] **Step 3: Write the screen**

```swift
// Sources/DesignFoundationScreens/Ecommerce/Orders/DFEcommerceOrdersScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Period (scoped to Orders — Revenue has its own richer enum in Models)

public enum DFOrdersPeriod: String, CaseIterable, Sendable, Equatable {
    case today
    case thisWeek
    case custom

    public var displayLabel: String {
        switch self {
        case .today:    return "Today"
        case .thisWeek: return "This Week"
        case .custom:   return "Custom"
        }
    }
}

// MARK: - Configuration

public struct DFEcommerceOrdersScreen: View {

    public struct Configuration {
        public var orders: [DFOrder]
        public var initialPeriod: DFOrdersPeriod
        public var initialStatusFilter: DFOrderStatus?
        /// Summary stats — caller computes these from orders or from server
        public var ordersToday: Int
        public var revenueToday: Decimal
        public var avgOrderValue: Decimal
        /// Callbacks
        public var onSelectOrder: @MainActor (DFOrder) -> Void
        public var onMarkShipped: @MainActor (DFOrder) -> Void
        public var onPrintLabel: @MainActor (DFOrder) -> Void
        public var onRefund: @MainActor (DFOrder) -> Void
        public var onCustomDateRange: @MainActor () -> Void
        public var isLoading: Bool

        public init(
            orders: [DFOrder],
            initialPeriod: DFOrdersPeriod = .today,
            initialStatusFilter: DFOrderStatus? = nil,
            ordersToday: Int = 0,
            revenueToday: Decimal = 0,
            avgOrderValue: Decimal = 0,
            isLoading: Bool = false,
            onSelectOrder: @escaping @MainActor (DFOrder) -> Void = { _ in },
            onMarkShipped: @escaping @MainActor (DFOrder) -> Void = { _ in },
            onPrintLabel: @escaping @MainActor (DFOrder) -> Void = { _ in },
            onRefund: @escaping @MainActor (DFOrder) -> Void = { _ in },
            onCustomDateRange: @escaping @MainActor () -> Void = {}
        ) {
            self.orders = orders
            self.initialPeriod = initialPeriod
            self.initialStatusFilter = initialStatusFilter
            self.ordersToday = ordersToday
            self.revenueToday = revenueToday
            self.avgOrderValue = avgOrderValue
            self.isLoading = isLoading
            self.onSelectOrder = onSelectOrder
            self.onMarkShipped = onMarkShipped
            self.onPrintLabel = onPrintLabel
            self.onRefund = onRefund
            self.onCustomDateRange = onCustomDateRange
        }
    }

    // MARK: - State

    private let configuration: Configuration
    @State private var selectedPeriod: DFOrdersPeriod
    @State private var selectedStatus: DFOrderStatus?
    @State private var searchQuery: String = ""
    @State private var showDateRangeSheet: Bool = false
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
        _selectedPeriod = State(initialValue: configuration.initialPeriod)
        _selectedStatus = State(initialValue: configuration.initialStatusFilter)
    }

    // MARK: - Filtering (internal for testability)

    func filteredOrders(statusFilter: DFOrderStatus?, query: String) -> [DFOrder] {
        configuration.orders
            .filter { order in
                guard let filter = statusFilter else { return true }
                return order.status == filter
            }
            .filter { order in
                guard !query.isEmpty else { return true }
                let q = query.lowercased()
                return order.id.lowercased().contains(q)
                    || order.customerName.lowercased().contains(q)
            }
    }

    private var displayedOrders: [DFOrder] {
        filteredOrders(statusFilter: selectedStatus, query: searchQuery)
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if configuration.isLoading {
                loadingView
            } else {
                contentView
            }
        }
        .navigationTitle("Orders")
        .sheet(isPresented: $showDateRangeSheet) {
            DFDateRangeBlock(configuration: .init(
                onApply: { _, _ in showDateRangeSheet = false },
                onCancel: { showDateRangeSheet = false }
            ))
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        ScrollView {
            VStack(spacing: theme.spacing.md) {
                DFBlockSkeletonBlock(rows: 6)
            }
            .padding(theme.spacing.md)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: theme.spacing.md) {
                periodFilterRow
                statusFilterRow
                statSummaryRow
                searchBar
                orderList
            }
            .padding(theme.spacing.md)
        }
    }

    @ViewBuilder
    private var periodFilterRow: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(DFOrdersPeriod.allCases, id: \.self) { period in
                DFButton(
                    period.displayLabel,
                    style: selectedPeriod == period ? .primary : .secondary,
                    size: .small
                ) {
                    if period == .custom {
                        showDateRangeSheet = true
                        configuration.onCustomDateRange()
                    } else {
                        selectedPeriod = period
                    }
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var statusFilterRow: some View {
        DFTagPickerBlock(configuration: .init(
            tags: [nil] + DFOrderStatus.allCases.map { Optional($0) },
            labelForTag: { status in status?.displayLabel ?? "All" },
            selectedTag: selectedStatus,
            onSelect: { selectedStatus = $0 }
        ))
    }

    @ViewBuilder
    private var statSummaryRow: some View {
        HStack(spacing: theme.spacing.sm) {
            DFStatCardBlock(configuration: .init(
                title: "Orders Today",
                value: "\(configuration.ordersToday)"
            ))
            DFStatCardBlock(configuration: .init(
                title: "Revenue Today",
                value: configuration.revenueToday.formatted(.currency(code: "USD"))
            ))
            DFStatCardBlock(configuration: .init(
                title: "Avg Order Value",
                value: configuration.avgOrderValue.formatted(.currency(code: "USD"))
            ))
        }
    }

    @ViewBuilder
    private var searchBar: some View {
        DFSearchResultsBlock(configuration: .init(
            query: $searchQuery,
            placeholder: "Search orders or customers…"
        ))
    }

    @ViewBuilder
    private var orderList: some View {
        if displayedOrders.isEmpty {
            DFEmptyStateBlock(configuration: .init(
                icon: "shippingbox",
                title: "No orders",
                message: "No orders match your current filters."
            ))
        } else {
            DFList(configuration: .init(items: displayedOrders)) { order in
                orderRow(order)
                    .onTapGesture { configuration.onSelectOrder(order) }
                    .swipeActions(edge: .trailing) {
                        Button("Refund") { configuration.onRefund(order) }
                            .tint(theme.colors.destructive)
                        Button("Print") { configuration.onPrintLabel(order) }
                            .tint(theme.colors.secondary)
                    }
                    .swipeActions(edge: .leading) {
                        Button("Ship") { configuration.onMarkShipped(order) }
                            .tint(theme.colors.success)
                    }
            }
        }
    }

    @ViewBuilder
    private func orderRow(_ order: DFOrder) -> some View {
        HStack(spacing: theme.spacing.sm) {
            DFAvatar(
                configuration: .init(
                    imageURL: order.customerAvatarURL,
                    fallbackInitials: order.customerName.initials,
                    size: .medium
                )
            )
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                DFText(order.id, style: .bodyEmphasized)
                DFText(order.customerName, style: .body)
                DFText("\(order.itemCount) item\(order.itemCount == 1 ? "" : "s")", style: .caption)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: theme.spacing.xs) {
                DFText(order.total.formatted(.currency(code: "USD")), style: .bodyEmphasized)
                DFBadge(order.status.displayLabel, semantic: order.status.badgeSemantic)
                DFText(order.placedAt.relativeFormatted, style: .caption)
            }
        }
        .padding(theme.spacing.sm)
    }
}

// MARK: - Helpers

private extension String {
    var initials: String {
        let words = split(separator: " ")
        let letters = words.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}

private extension Date {
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
```

- [ ] **Step 4: Write the previews**

```swift
// Sources/DesignFoundationScreens/Ecommerce/Orders/DFEcommerceOrdersScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light") {
    NavigationStack {
        DFEcommerceOrdersScreen(configuration: .init(
            orders: .previewOrders,
            ordersToday: 14,
            revenueToday: 1_842.50,
            avgOrderValue: 131.60
        ))
    }
    .environment(\.dfTheme, .default)
}

#Preview("Dark") {
    NavigationStack {
        DFEcommerceOrdersScreen(configuration: .init(
            orders: .previewOrders,
            ordersToday: 14,
            revenueToday: 1_842.50,
            avgOrderValue: 131.60
        ))
    }
    .environment(\.dfTheme, .default)
    .colorScheme(.dark)
}

#Preview("Loading") {
    DFEcommerceOrdersScreen(configuration: .init(orders: [], isLoading: true))
        .environment(\.dfTheme, .default)
}

#Preview("Empty") {
    DFEcommerceOrdersScreen(configuration: .init(orders: []))
        .environment(\.dfTheme, .default)
}

// MARK: - Preview Data

private extension [DFOrder] {
    static var previewOrders: [DFOrder] {
        [
            DFOrder(id: "ORD-1042", customerName: "Sarah Chen", itemCount: 3,
                    total: 247.95, status: .processing,
                    placedAt: Date().addingTimeInterval(-3600),
                    shippingAddress: DFEcommerceAddress(line1: "10 Market St",
                        city: "San Francisco", state: "CA", postalCode: "94105", country: "US")),
            DFOrder(id: "ORD-1041", customerName: "Marcus Lee", itemCount: 1,
                    total: 89.00, status: .pending,
                    placedAt: Date().addingTimeInterval(-7200),
                    shippingAddress: DFEcommerceAddress(line1: "42 Oak Ave",
                        city: "Portland", state: "OR", postalCode: "97201", country: "US")),
            DFOrder(id: "ORD-1040", customerName: "Priya Patel", itemCount: 5,
                    total: 412.50, status: .shipped,
                    placedAt: Date().addingTimeInterval(-86400),
                    shippingAddress: DFEcommerceAddress(line1: "88 Pine Rd",
                        city: "Austin", state: "TX", postalCode: "78701", country: "US")),
            DFOrder(id: "ORD-1039", customerName: "Jordan Riley", itemCount: 2,
                    total: 159.00, status: .delivered,
                    placedAt: Date().addingTimeInterval(-172800),
                    shippingAddress: DFEcommerceAddress(line1: "5 Elm St",
                        city: "Chicago", state: "IL", postalCode: "60601", country: "US")),
            DFOrder(id: "ORD-1038", customerName: "Emma Wilson", itemCount: 1,
                    total: 45.00, status: .returned,
                    placedAt: Date().addingTimeInterval(-259200),
                    shippingAddress: DFEcommerceAddress(line1: "99 River Ln",
                        city: "Nashville", state: "TN", postalCode: "37201", country: "US")),
        ]
    }
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFEcommerceOrdersScreenTests 2>&1 | tail -10
```
Expected: `Test Suite 'DFEcommerceOrdersScreenTests' passed`

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Ecommerce/Orders/ \
        Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceOrdersScreenTests.swift
git commit -m "feat(screens): add DFEcommerceOrdersScreen"
```

---

## Task 3: DFEcommerceOrderDetailScreen

*Full order view — everything needed to fulfill, refund, or track.*

**Files:**
- Create: `Sources/DesignFoundationScreens/Ecommerce/OrderDetail/DFEcommerceOrderDetailScreen.swift`
- Create: `Sources/DesignFoundationScreens/Ecommerce/OrderDetail/DFEcommerceOrderDetailScreen+Previews.swift`
- Test: `Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceOrderDetailScreenTests.swift`

**Interfaces:**
- Consumes: `DFOrder`, `DFOrderStatus`, `DFOrderLineItem`, `DFOrderNote`, `DFTrackingInfo`, `DFEcommerceAddress` from Task 1
- Produces: `DFEcommerceOrderDetailScreen` (public struct), `DFEcommerceOrderDetailScreen.Configuration` (public struct)

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceOrderDetailScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFEcommerceOrderDetailScreen")
struct DFEcommerceOrderDetailScreenTests {

    @Test("Configuration stores order")
    func configStoresOrder() {
        let order = DFOrder.stub(id: "ORD-999")
        let config = DFEcommerceOrderDetailScreen.Configuration(order: order)
        #expect(config.order.id == "ORD-999")
    }

    @Test("orderSubtotal sums line items correctly")
    func orderSubtotal() {
        let items = [
            DFOrderLineItem(id: "1", productName: "Tee", quantity: 2, unitPrice: 25.00),
            DFOrderLineItem(id: "2", productName: "Hat", quantity: 1, unitPrice: 40.00),
        ]
        let order = DFOrder(
            id: "ORD-1", customerName: "Test", itemCount: 3, total: 90.00,
            status: .pending, placedAt: Date(),
            lineItems: items,
            shippingAddress: DFEcommerceAddress(line1: "1 St", city: "City",
                state: "TX", postalCode: "00000", country: "US")
        )
        let config = DFEcommerceOrderDetailScreen.Configuration(order: order)
        let screen = DFEcommerceOrderDetailScreen(configuration: config)
        #expect(screen.orderSubtotal == 90.00)
    }

    @Test("canMarkShipped only when processing")
    func canMarkShipped() {
        let processingOrder = DFOrder.stub(status: .processing)
        let shippedOrder    = DFOrder.stub(status: .shipped)
        let c1 = DFEcommerceOrderDetailScreen.Configuration(order: processingOrder)
        let c2 = DFEcommerceOrderDetailScreen.Configuration(order: shippedOrder)
        #expect(DFEcommerceOrderDetailScreen(configuration: c1).canMarkShipped == true)
        #expect(DFEcommerceOrderDetailScreen(configuration: c2).canMarkShipped == false)
    }

    @Test("canCancel only when pending or processing")
    func canCancel() {
        let pending    = DFOrder.stub(status: .pending)
        let processing = DFOrder.stub(status: .processing)
        let shipped    = DFOrder.stub(status: .shipped)
        #expect(DFEcommerceOrderDetailScreen(configuration: .init(order: pending)).canCancel == true)
        #expect(DFEcommerceOrderDetailScreen(configuration: .init(order: processing)).canCancel == true)
        #expect(DFEcommerceOrderDetailScreen(configuration: .init(order: shipped)).canCancel == false)
    }

    @Test("timelineSteps returns all 5 stages")
    func timelineStepsCount() {
        let order = DFOrder.stub(status: .processing)
        let screen = DFEcommerceOrderDetailScreen(configuration: .init(order: order))
        #expect(screen.timelineSteps.count == 5)
    }

    @Test("timelineSteps marks correct steps as completed")
    func timelineStepsCompletion() {
        // Processing: Placed ✓, Confirmed ✓, Processing ✓, Shipped ✗, Delivered ✗
        let order = DFOrder.stub(status: .processing)
        let screen = DFEcommerceOrderDetailScreen(configuration: .init(order: order))
        let completed = screen.timelineSteps.filter(\.isCompleted)
        #expect(completed.count == 3)
    }
}
```

- [ ] **Step 2: Run to verify tests fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFEcommerceOrderDetailScreenTests 2>&1 | head -20
```
Expected: compile error — `DFEcommerceOrderDetailScreen` not found.

- [ ] **Step 3: Write the screen**

```swift
// Sources/DesignFoundationScreens/Ecommerce/OrderDetail/DFEcommerceOrderDetailScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Timeline Step

public struct DFOrderTimelineStep: Sendable, Equatable {
    public let label: String
    public let isCompleted: Bool

    public init(label: String, isCompleted: Bool) {
        self.label = label
        self.isCompleted = isCompleted
    }
}

// MARK: - Configuration

public struct DFEcommerceOrderDetailScreen: View {

    public struct Configuration {
        public var order: DFOrder
        public var onMarkShipped: @MainActor () -> Void
        public var onPrintLabel: @MainActor () -> Void
        public var onIssueRefund: @MainActor () -> Void
        public var onCancelOrder: @MainActor () -> Void
        public var onAddNote: @MainActor (String) -> Void
        public var shippingCost: Decimal
        public var discountAmount: Decimal
        public var taxAmount: Decimal

        public init(
            order: DFOrder,
            shippingCost: Decimal = 0,
            discountAmount: Decimal = 0,
            taxAmount: Decimal = 0,
            onMarkShipped: @escaping @MainActor () -> Void = {},
            onPrintLabel: @escaping @MainActor () -> Void = {},
            onIssueRefund: @escaping @MainActor () -> Void = {},
            onCancelOrder: @escaping @MainActor () -> Void = {},
            onAddNote: @escaping @MainActor (String) -> Void = { _ in }
        ) {
            self.order = order
            self.shippingCost = shippingCost
            self.discountAmount = discountAmount
            self.taxAmount = taxAmount
            self.onMarkShipped = onMarkShipped
            self.onPrintLabel = onPrintLabel
            self.onIssueRefund = onIssueRefund
            self.onCancelOrder = onCancelOrder
            self.onAddNote = onAddNote
        }
    }

    // MARK: - State

    private let configuration: Configuration
    @State private var newNoteText: String = ""
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: - Computed helpers (internal for testability)

    var orderSubtotal: Decimal {
        configuration.order.lineItems.reduce(0) { $0 + $1.subtotal }
    }

    var canMarkShipped: Bool { configuration.order.status == .processing }
    var canCancel: Bool      { [.pending, .processing].contains(configuration.order.status) }

    /// Five-stage fulfillment timeline.
    var timelineSteps: [DFOrderTimelineStep] {
        let stages: [(String, [DFOrderStatus])] = [
            ("Placed",      [.pending, .processing, .shipped, .delivered]),
            ("Confirmed",   [.processing, .shipped, .delivered]),
            ("Processing",  [.processing, .shipped, .delivered]),
            ("Shipped",     [.shipped, .delivered]),
            ("Delivered",   [.delivered]),
        ]
        return stages.map { label, completedWhen in
            DFOrderTimelineStep(
                label: label,
                isCompleted: completedWhen.contains(configuration.order.status)
            )
        }
    }

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                orderHeader
                orderTimeline
                customerSection
                lineItemsSection
                orderSummaryCard
                actionButtons
                trackingSection
                notesSection
            }
            .padding(theme.spacing.md)
        }
        .navigationTitle(configuration.order.id)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    @ViewBuilder
    private var orderHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                DFText(configuration.order.id, style: .title2)
                DFText(
                    "Placed \(configuration.order.placedAt.formatted(date: .long, time: .shortened))",
                    style: .caption
                )
            }
            Spacer()
            DFBadge(
                configuration.order.status.displayLabel,
                semantic: configuration.order.status.badgeSemantic,
                size: .large
            )
        }
    }

    @ViewBuilder
    private var orderTimeline: some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                DFText("Timeline", style: .headlineSmall)
                HStack(spacing: 0) {
                    ForEach(Array(timelineSteps.enumerated()), id: \.offset) { index, step in
                        VStack(spacing: theme.spacing.xs) {
                            Circle()
                                .fill(step.isCompleted ? theme.colors.primary : theme.colors.surfaceSecondary)
                                .frame(width: 12, height: 12)
                            DFText(step.label, style: .caption)
                                .multilineTextAlignment(.center)
                        }
                        if index < timelineSteps.count - 1 {
                            Rectangle()
                                .fill(step.isCompleted ? theme.colors.primary : theme.colors.border)
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, theme.spacing.lg) // align with circle center
                        }
                    }
                }
            }
            .padding(theme.spacing.md)
        }
    }

    @ViewBuilder
    private var customerSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Customer", style: .headlineSmall)
            DFContactRow(configuration: .init(
                name: configuration.order.customerName,
                avatarURL: configuration.order.customerAvatarURL
            ))
            DFDivider()
            DFText("Shipping Address", style: .caption)
            DFText(configuration.order.shippingAddress.formattedSingleLine, style: .body)
        }
    }

    @ViewBuilder
    private var lineItemsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Items", style: .headlineSmall)
            ForEach(configuration.order.lineItems) { item in
                HStack(spacing: theme.spacing.sm) {
                    // Product image placeholder
                    RoundedRectangle(cornerRadius: theme.radius.sm)
                        .fill(theme.colors.surfaceSecondary)
                        .frame(width: 48, height: 48)
                        .overlay {
                            Image(systemName: "tag")
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        DFText(item.productName, style: .bodyEmphasized)
                        if let variant = item.variantLabel {
                            DFText(variant, style: .caption)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: theme.spacing.xs) {
                        DFText("\(item.quantity) × \(item.unitPrice.formatted(.currency(code: "USD")))", style: .caption)
                        DFText(item.subtotal.formatted(.currency(code: "USD")), style: .bodyEmphasized)
                    }
                }
                DFDivider()
            }
        }
    }

    @ViewBuilder
    private var orderSummaryCard: some View {
        DFCard {
            VStack(spacing: theme.spacing.sm) {
                DFText("Order Summary", style: .headlineSmall)
                    .frame(maxWidth: .infinity, alignment: .leading)
                summaryRow("Subtotal", value: orderSubtotal)
                summaryRow("Shipping", value: configuration.shippingCost)
                if configuration.discountAmount > 0 {
                    summaryRow("Discount", value: -configuration.discountAmount)
                }
                summaryRow("Tax", value: configuration.taxAmount)
                DFDivider()
                summaryRow("Total", value: configuration.order.total, isTotal: true)
            }
            .padding(theme.spacing.md)
        }
    }

    @ViewBuilder
    private func summaryRow(_ label: String, value: Decimal, isTotal: Bool = false) -> some View {
        HStack {
            DFText(label, style: isTotal ? .bodyEmphasized : .body)
            Spacer()
            DFText(value.formatted(.currency(code: "USD")), style: isTotal ? .bodyEmphasized : .body)
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: theme.spacing.sm) {
            if canMarkShipped {
                DFButton("Mark as Shipped", style: .primary) {
                    configuration.onMarkShipped()
                }
            }
            DFButton("Print Label", style: .secondary) {
                configuration.onPrintLabel()
            }
            DFButton("Issue Refund", style: .secondary) {
                configuration.onIssueRefund()
            }
            if canCancel {
                DFButton("Cancel Order", style: .destructive) {
                    configuration.onCancelOrder()
                }
            }
        }
    }

    @ViewBuilder
    private var trackingSection: some View {
        if let tracking = configuration.order.tracking {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                DFText("Tracking", style: .headlineSmall)
                DFCard {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        DFText(tracking.carrier, style: .bodyEmphasized)
                        DFText(tracking.trackingNumber, style: .body)
                        if let url = tracking.trackingURL {
                            Link("Track Package", destination: url)
                                .font(theme.typography.body.font)
                                .foregroundStyle(theme.colors.primary)
                        }
                    }
                    .padding(theme.spacing.md)
                }
            }
        }
    }

    @ViewBuilder
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Internal Notes", style: .headlineSmall)
            ForEach(configuration.order.notes) { note in
                DFCard {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack {
                            DFText(note.authorName, style: .bodyEmphasized)
                            Spacer()
                            DFText(note.createdAt.formatted(date: .abbreviated, time: .shortened), style: .caption)
                        }
                        DFText(note.body, style: .body)
                    }
                    .padding(theme.spacing.sm)
                }
            }
            HStack(spacing: theme.spacing.sm) {
                TextField("Add a note…", text: $newNoteText, axis: .vertical)
                    .font(theme.typography.body.font)
                    .lineLimit(3)
                    .padding(theme.spacing.sm)
                    .background(theme.colors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: theme.radius.sm))
                if !newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    DFButton("Add", style: .primary, size: .small) {
                        configuration.onAddNote(newNoteText)
                        newNoteText = ""
                    }
                }
            }
        }
    }
}
```

- [ ] **Step 4: Write the previews**

```swift
// Sources/DesignFoundationScreens/Ecommerce/OrderDetail/DFEcommerceOrderDetailScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light — Processing") {
    NavigationStack {
        DFEcommerceOrderDetailScreen(configuration: .previewConfig(status: .processing))
    }
    .environment(\.dfTheme, .default)
}

#Preview("Dark — Shipped") {
    NavigationStack {
        DFEcommerceOrderDetailScreen(configuration: .previewConfig(status: .shipped))
    }
    .environment(\.dfTheme, .default)
    .colorScheme(.dark)
}

#Preview("Delivered with Tracking") {
    NavigationStack {
        DFEcommerceOrderDetailScreen(configuration: .previewConfig(status: .delivered, withTracking: true))
    }
    .environment(\.dfTheme, .default)
}

private extension DFEcommerceOrderDetailScreen.Configuration {
    static func previewConfig(status: DFOrderStatus, withTracking: Bool = false) -> Self {
        let items = [
            DFOrderLineItem(id: "L1", productName: "Classic Tee", variantLabel: "Size: M / Black",
                            quantity: 2, unitPrice: 29.99),
            DFOrderLineItem(id: "L2", productName: "Baseball Cap", quantity: 1, unitPrice: 24.00),
        ]
        let tracking: DFTrackingInfo? = withTracking
            ? DFTrackingInfo(carrier: "UPS", trackingNumber: "1Z999AA10123456784",
                             trackingURL: URL(string: "https://www.ups.com/track?tracknum=1Z999AA10123456784"))
            : nil
        let notes: [DFOrderNote] = [
            DFOrderNote(id: "N1", body: "Customer requested gift wrapping.",
                        createdAt: Date().addingTimeInterval(-3600), authorName: "Sam (Support)")
        ]
        let order = DFOrder(
            id: "ORD-1042", customerName: "Sarah Chen",
            itemCount: items.count,
            total: 113.98,
            status: status,
            placedAt: Date().addingTimeInterval(-7200),
            lineItems: items,
            shippingAddress: DFEcommerceAddress(line1: "10 Market St", city: "San Francisco",
                                                state: "CA", postalCode: "94105", country: "US"),
            notes: notes,
            tracking: tracking
        )
        return .init(order: order, shippingCost: 8.99, taxAmount: 11.00)
    }
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFEcommerceOrderDetailScreenTests 2>&1 | tail -10
```
Expected: `Test Suite 'DFEcommerceOrderDetailScreenTests' passed`

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Ecommerce/OrderDetail/ \
        Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceOrderDetailScreenTests.swift
git commit -m "feat(screens): add DFEcommerceOrderDetailScreen"
```

---

## Task 4: DFEcommerceProductsScreen

*Inventory at a glance — what's selling, what's running low, what needs attention.*

**Files:**
- Create: `Sources/DesignFoundationScreens/Ecommerce/Products/DFEcommerceProductsScreen.swift`
- Create: `Sources/DesignFoundationScreens/Ecommerce/Products/DFEcommerceProductsScreen+Previews.swift`
- Test: `Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceProductsScreenTests.swift`

**Interfaces:**
- Consumes: `DFProduct`, `DFProductStatus` from Task 1
- Produces: `DFEcommerceProductsScreen` (public struct), `DFEcommerceProductsScreen.Configuration`, `DFProductSortOrder` (public enum)

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceProductsScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFEcommerceProductsScreen")
struct DFEcommerceProductsScreenTests {

    private func makeScreen(products: [DFProduct]) -> DFEcommerceProductsScreen {
        DFEcommerceProductsScreen(configuration: .init(products: products))
    }

    @Test("filteredProducts returns all when no status filter and no query")
    func noFilterReturnsAll() {
        let products = [DFProduct.stub(id: "1"), DFProduct.stub(id: "2")]
        let screen = makeScreen(products: products)
        #expect(screen.filteredProducts(statusFilter: nil, query: "", sort: .newest).count == 2)
    }

    @Test("filteredProducts filters by status")
    func filterByStatus() {
        let products = [
            DFProduct.stub(id: "1", status: .active),
            DFProduct.stub(id: "2", status: .draft),
        ]
        let screen = makeScreen(products: products)
        let result = screen.filteredProducts(statusFilter: .draft, query: "", sort: .newest)
        #expect(result.count == 1)
        #expect(result[0].id == "2")
    }

    @Test("filteredProducts filters by name query")
    func filterByQuery() {
        let products = [
            DFProduct.stub(id: "1", name: "Classic Tee"),
            DFProduct.stub(id: "2", name: "Baseball Cap"),
        ]
        let screen = makeScreen(products: products)
        let result = screen.filteredProducts(statusFilter: nil, query: "tee", sort: .newest)
        #expect(result.count == 1)
        #expect(result[0].name == "Classic Tee")
    }

    @Test("filteredProducts sorts by stockLowToHigh")
    func sortByStock() {
        let products = [
            DFProduct.stub(id: "1", name: "A", inventoryCount: 50),
            DFProduct.stub(id: "2", name: "B", inventoryCount: 2),
            DFProduct.stub(id: "3", name: "C", inventoryCount: 15),
        ]
        let screen = makeScreen(products: products)
        let result = screen.filteredProducts(statusFilter: nil, query: "", sort: .stockLowToHigh)
        #expect(result.map(\.id) == ["2", "3", "1"])
    }

    @Test("metrics totalProducts counts all")
    func metricsTotalProducts() {
        let products = [DFProduct.stub(id: "1"), DFProduct.stub(id: "2"), DFProduct.stub(id: "3")]
        let screen = makeScreen(products: products)
        #expect(screen.metrics.totalProducts == 3)
    }

    @Test("metrics outOfStock counts products with zero inventory")
    func metricsOutOfStock() {
        let products = [
            DFProduct.stub(id: "1", inventoryCount: 0),
            DFProduct.stub(id: "2", inventoryCount: 5),
        ]
        let screen = makeScreen(products: products)
        #expect(screen.metrics.outOfStock == 1)
    }

    @Test("metrics lowStock excludes out-of-stock")
    func metricsLowStock() {
        let products = [
            DFProduct.stub(id: "1", inventoryCount: 0, lowStockThreshold: 10),   // out-of-stock, not low
            DFProduct.stub(id: "2", inventoryCount: 3, lowStockThreshold: 10),   // low stock
            DFProduct.stub(id: "3", inventoryCount: 20, lowStockThreshold: 10),  // fine
        ]
        let screen = makeScreen(products: products)
        #expect(screen.metrics.lowStock == 1)
    }
}
```

- [ ] **Step 2: Run to verify tests fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFEcommerceProductsScreenTests 2>&1 | head -20
```
Expected: compile error — `DFEcommerceProductsScreen` not found.

- [ ] **Step 3: Write the screen**

```swift
// Sources/DesignFoundationScreens/Ecommerce/Products/DFEcommerceProductsScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

// MARK: - Sort Order

public enum DFProductSortOrder: String, CaseIterable, Sendable, Equatable {
    case bestSelling
    case newest
    case priceLowToHigh
    case priceHighToLow
    case stockLowToHigh

    public var displayLabel: String {
        switch self {
        case .bestSelling:    return "Best Selling"
        case .newest:         return "Newest"
        case .priceLowToHigh: return "Price: Low → High"
        case .priceHighToLow: return "Price: High → Low"
        case .stockLowToHigh: return "Stock: Low → High"
        }
    }
}

// MARK: - Metrics

public struct DFProductMetrics: Sendable, Equatable {
    public let totalProducts: Int
    public let activeListings: Int
    public let outOfStock: Int
    public let lowStock: Int
}

// MARK: - Layout Mode

public enum DFProductLayoutMode: Sendable, Equatable {
    case grid, list
}

// MARK: - Screen

public struct DFEcommerceProductsScreen: View {

    public struct Configuration {
        public var products: [DFProduct]
        public var initialStatusFilter: DFProductStatus?
        public var initialSort: DFProductSortOrder
        public var initialLayout: DFProductLayoutMode
        public var onSelectProduct: @MainActor (DFProduct) -> Void
        public var isLoading: Bool

        public init(
            products: [DFProduct],
            initialStatusFilter: DFProductStatus? = nil,
            initialSort: DFProductSortOrder = .newest,
            initialLayout: DFProductLayoutMode = .grid,
            isLoading: Bool = false,
            onSelectProduct: @escaping @MainActor (DFProduct) -> Void = { _ in }
        ) {
            self.products = products
            self.initialStatusFilter = initialStatusFilter
            self.initialSort = initialSort
            self.initialLayout = initialLayout
            self.isLoading = isLoading
            self.onSelectProduct = onSelectProduct
        }
    }

    // MARK: - State

    private let configuration: Configuration
    @State private var selectedStatus: DFProductStatus?
    @State private var selectedSort: DFProductSortOrder
    @State private var searchQuery: String = ""
    @State private var layoutMode: DFProductLayoutMode
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
        _selectedStatus = State(initialValue: configuration.initialStatusFilter)
        _selectedSort = State(initialValue: configuration.initialSort)
        _layoutMode = State(initialValue: configuration.initialLayout)
    }

    // MARK: - Computed helpers (internal for testability)

    func filteredProducts(
        statusFilter: DFProductStatus?,
        query: String,
        sort: DFProductSortOrder
    ) -> [DFProduct] {
        let filtered = configuration.products
            .filter { product in
                guard let filter = statusFilter else { return true }
                return product.status == filter
            }
            .filter { product in
                guard !query.isEmpty else { return true }
                return product.name.lowercased().contains(query.lowercased())
            }

        return filtered.sorted { a, b in
            switch sort {
            case .bestSelling:    return a.id < b.id  // stable placeholder; real sort uses sales data
            case .newest:         return a.id > b.id
            case .priceLowToHigh: return a.price < b.price
            case .priceHighToLow: return a.price > b.price
            case .stockLowToHigh: return a.inventoryCount < b.inventoryCount
            }
        }
    }

    var metrics: DFProductMetrics {
        DFProductMetrics(
            totalProducts: configuration.products.count,
            activeListings: configuration.products.filter { $0.status == .active }.count,
            outOfStock: configuration.products.filter(\.isOutOfStock).count,
            lowStock: configuration.products.filter(\.isLowStock).count
        )
    }

    private var displayedProducts: [DFProduct] {
        filteredProducts(statusFilter: selectedStatus, query: searchQuery, sort: selectedSort)
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if configuration.isLoading {
                DFBlockSkeletonBlock(rows: 8)
                    .padding(theme.spacing.md)
            } else {
                contentView
            }
        }
        .navigationTitle("Products")
    }

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: theme.spacing.md) {
                metricsHeader
                searchAndFilterBar
                sortAndLayoutBar
                if displayedProducts.isEmpty {
                    DFEmptyStateBlock(configuration: .init(
                        icon: "cube.box",
                        title: "No products",
                        message: "No products match your current filters."
                    ))
                } else {
                    switch layoutMode {
                    case .grid: productGrid
                    case .list: productList
                    }
                }
            }
            .padding(theme.spacing.md)
        }
    }

    @ViewBuilder
    private var metricsHeader: some View {
        DFMetricGridBlock(configuration: .init(metrics: [
            .init(label: "Total Products",  value: "\(metrics.totalProducts)"),
            .init(label: "Active Listings", value: "\(metrics.activeListings)"),
            .init(label: "Out of Stock",    value: "\(metrics.outOfStock)"),
            .init(label: "Low Stock",       value: "\(metrics.lowStock)"),
        ]))
    }

    @ViewBuilder
    private var searchAndFilterBar: some View {
        VStack(spacing: theme.spacing.sm) {
            DFSearchResultsBlock(configuration: .init(
                query: $searchQuery,
                placeholder: "Search products…"
            ))
            DFTagPickerBlock(configuration: .init(
                tags: [nil] + DFProductStatus.allCases.map { Optional($0) },
                labelForTag: { status in status?.displayLabel ?? "All" },
                selectedTag: selectedStatus,
                onSelect: { selectedStatus = $0 }
            ))
        }
    }

    @ViewBuilder
    private var sortAndLayoutBar: some View {
        HStack {
            Menu {
                ForEach(DFProductSortOrder.allCases, id: \.self) { sort in
                    Button(sort.displayLabel) { selectedSort = sort }
                }
            } label: {
                HStack(spacing: theme.spacing.xs) {
                    DFText("Sort: \(selectedSort.displayLabel)", style: .caption)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            Spacer()
            HStack(spacing: 0) {
                Button {
                    layoutMode = .grid
                } label: {
                    Image(systemName: "square.grid.2x2")
                        .foregroundStyle(layoutMode == .grid ? theme.colors.primary : theme.colors.textSecondary)
                }
                .padding(theme.spacing.xs)
                Button {
                    layoutMode = .list
                } label: {
                    Image(systemName: "list.bullet")
                        .foregroundStyle(layoutMode == .list ? theme.colors.primary : theme.colors.textSecondary)
                }
                .padding(theme.spacing.xs)
            }
        }
    }

    @ViewBuilder
    private var productGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        LazyVGrid(columns: columns, spacing: theme.spacing.md) {
            ForEach(displayedProducts) { product in
                productCard(product)
                    .onTapGesture { configuration.onSelectProduct(product) }
            }
        }
    }

    @ViewBuilder
    private var productList: some View {
        LazyVStack(spacing: theme.spacing.sm) {
            ForEach(displayedProducts) { product in
                productListRow(product)
                    .onTapGesture { configuration.onSelectProduct(product) }
                DFDivider()
            }
        }
    }

    @ViewBuilder
    private func productCard(_ product: DFProduct) -> some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ZStack(alignment: .topTrailing) {
                    // Product image placeholder
                    RoundedRectangle(cornerRadius: theme.radius.sm)
                        .fill(theme.colors.surfaceSecondary)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    if product.isOutOfStock {
                        DFBadge("Out of Stock", semantic: .destructive, size: .small)
                            .padding(theme.spacing.xs)
                    }
                }
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    DFText(product.name, style: .bodyEmphasized)
                        .lineLimit(2)
                    DFText(product.price.formatted(.currency(code: "USD")), style: .body)
                    DFBadge(
                        "\(product.inventoryCount) in stock",
                        semantic: product.isOutOfStock ? .destructive
                                  : product.isLowStock  ? .warning
                                  : .neutral
                    )
                }
            }
            .padding(theme.spacing.sm)
        }
    }

    @ViewBuilder
    private func productListRow(_ product: DFProduct) -> some View {
        HStack(spacing: theme.spacing.sm) {
            RoundedRectangle(cornerRadius: theme.radius.sm)
                .fill(theme.colors.surfaceSecondary)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(theme.colors.textSecondary)
                }
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                DFText(product.name, style: .bodyEmphasized)
                DFText(product.price.formatted(.currency(code: "USD")), style: .body)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: theme.spacing.xs) {
                DFBadge(
                    "\(product.inventoryCount)",
                    semantic: product.isOutOfStock ? .destructive
                              : product.isLowStock  ? .warning
                              : .neutral
                )
                DFText(product.status.displayLabel, style: .caption)
            }
        }
        .padding(.vertical, theme.spacing.xs)
    }
}
```

- [ ] **Step 4: Write the previews**

```swift
// Sources/DesignFoundationScreens/Ecommerce/Products/DFEcommerceProductsScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light — Grid") {
    NavigationStack {
        DFEcommerceProductsScreen(configuration: .init(
            products: .previewProducts,
            initialLayout: .grid
        ))
    }
    .environment(\.dfTheme, .default)
}

#Preview("Dark — List") {
    NavigationStack {
        DFEcommerceProductsScreen(configuration: .init(
            products: .previewProducts,
            initialLayout: .list
        ))
    }
    .environment(\.dfTheme, .default)
    .colorScheme(.dark)
}

#Preview("Loading") {
    DFEcommerceProductsScreen(configuration: .init(products: [], isLoading: true))
        .environment(\.dfTheme, .default)
}

#Preview("Empty") {
    DFEcommerceProductsScreen(configuration: .init(products: []))
        .environment(\.dfTheme, .default)
}

private extension [DFProduct] {
    static var previewProducts: [DFProduct] {
        [
            DFProduct(id: "P1", name: "Classic Tee",       price: 29.99, inventoryCount: 42,  lowStockThreshold: 10, status: .active),
            DFProduct(id: "P2", name: "Baseball Cap",      price: 24.00, inventoryCount: 3,   lowStockThreshold: 10, status: .active),
            DFProduct(id: "P3", name: "Hoodie XL",         price: 59.99, inventoryCount: 0,   lowStockThreshold: 10, status: .outOfStock),
            DFProduct(id: "P4", name: "Canvas Tote",       price: 18.00, inventoryCount: 120, lowStockThreshold: 10, status: .active),
            DFProduct(id: "P5", name: "Logo Mug",          price: 14.99, inventoryCount: 7,   lowStockThreshold: 10, status: .active),
            DFProduct(id: "P6", name: "Summer Dress",      price: 89.00, inventoryCount: 0,   lowStockThreshold: 10, status: .outOfStock),
            DFProduct(id: "P7", name: "Denim Shorts",      price: 45.00, inventoryCount: 22,  lowStockThreshold: 10, status: .active),
            DFProduct(id: "P8", name: "Prototype Beanie",  price: 19.99, inventoryCount: 0,   lowStockThreshold: 10, status: .draft),
        ]
    }
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFEcommerceProductsScreenTests 2>&1 | tail -10
```
Expected: `Test Suite 'DFEcommerceProductsScreenTests' passed`

- [ ] **Step 6: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Ecommerce/Products/ \
        Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceProductsScreenTests.swift
git commit -m "feat(screens): add DFEcommerceProductsScreen"
```

---

## Task 5: DFEcommerceRevenueScreen

*The financial summary — today's performance, monthly targets, and what's driving revenue.*

**Files:**
- Create: `Sources/DesignFoundationScreens/Ecommerce/Revenue/DFEcommerceRevenueScreen.swift`
- Create: `Sources/DesignFoundationScreens/Ecommerce/Revenue/DFEcommerceRevenueScreen+Previews.swift`
- Test: `Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceRevenueScreenTests.swift`

**Interfaces:**
- Consumes: `DFRevenuePeriod`, `DFRevenueMetrics`, `DFTopProduct`, `DFOrder` from Task 1
- Produces: `DFEcommerceRevenueScreen` (public struct), `DFEcommerceRevenueScreen.Configuration`

- [ ] **Step 1: Write the failing tests**

```swift
// Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceRevenueScreenTests.swift
import Testing
import SwiftUI
@testable import DesignFoundationScreens

@Suite("DFEcommerceRevenueScreen")
struct DFEcommerceRevenueScreenTests {

    @Test("Configuration stores metrics")
    func configStoresMetrics() {
        let metrics = DFRevenueMetrics.stub(todayRevenue: 500, yesterdayRevenue: 400)
        let config = DFEcommerceRevenueScreen.Configuration(metrics: metrics, topProducts: [], largeOrders: [])
        #expect(config.metrics.todayRevenue == 500)
    }

    @Test("deltaIsPositive true when today > yesterday")
    func deltaPositive() {
        let metrics = DFRevenueMetrics.stub(todayRevenue: 1200, yesterdayRevenue: 1000)
        let screen = DFEcommerceRevenueScreen(configuration: .init(
            metrics: metrics, topProducts: [], largeOrders: []
        ))
        #expect(screen.deltaIsPositive == true)
    }

    @Test("deltaIsPositive false when today < yesterday")
    func deltaNegative() {
        let metrics = DFRevenueMetrics.stub(todayRevenue: 800, yesterdayRevenue: 1000)
        let screen = DFEcommerceRevenueScreen(configuration: .init(
            metrics: metrics, topProducts: [], largeOrders: []
        ))
        #expect(screen.deltaIsPositive == false)
    }

    @Test("formattedDeltaPercent includes sign and percent")
    func formattedDeltaPercent() {
        let metrics = DFRevenueMetrics.stub(todayRevenue: 1200, yesterdayRevenue: 1000)
        let screen = DFEcommerceRevenueScreen(configuration: .init(
            metrics: metrics, topProducts: [], largeOrders: []
        ))
        let formatted = screen.formattedDeltaPercent
        #expect(formatted.contains("+") || formatted.contains("-"))
        #expect(formatted.contains("%"))
    }

    @Test("defaultPeriod is today")
    func defaultPeriod() {
        let screen = DFEcommerceRevenueScreen(configuration: .init(
            metrics: .stub(), topProducts: [], largeOrders: []
        ))
        #expect(screen.selectedPeriod == .today)
    }

    @Test("topProducts stored correctly")
    func topProductsStored() {
        let products = [
            DFTopProduct(id: "P1", name: "Tee", unitsSold: 100, revenue: 2999, percentOfTotal: 30.0),
            DFTopProduct(id: "P2", name: "Cap", unitsSold: 50,  revenue: 1200, percentOfTotal: 12.0),
        ]
        let config = DFEcommerceRevenueScreen.Configuration(
            metrics: .stub(), topProducts: products, largeOrders: []
        )
        #expect(config.topProducts.count == 2)
    }
}
```

- [ ] **Step 2: Run to verify tests fail**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFEcommerceRevenueScreenTests 2>&1 | head -20
```
Expected: compile error — `DFEcommerceRevenueScreen` not found.

- [ ] **Step 3: Write the screen**

```swift
// Sources/DesignFoundationScreens/Ecommerce/Revenue/DFEcommerceRevenueScreen.swift
import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

public struct DFEcommerceRevenueScreen: View {

    public struct Configuration {
        public var metrics: DFRevenueMetrics
        public var topProducts: [DFTopProduct]
        /// Orders above a threshold shown in "Recent Large Orders" feed
        public var largeOrders: [DFOrder]
        public var initialPeriod: DFRevenuePeriod
        public var onPeriodChange: @MainActor (DFRevenuePeriod) -> Void
        public var onCustomDateRange: @MainActor () -> Void

        public init(
            metrics: DFRevenueMetrics,
            topProducts: [DFTopProduct],
            largeOrders: [DFOrder],
            initialPeriod: DFRevenuePeriod = .today,
            onPeriodChange: @escaping @MainActor (DFRevenuePeriod) -> Void = { _ in },
            onCustomDateRange: @escaping @MainActor () -> Void = {}
        ) {
            self.metrics = metrics
            self.topProducts = topProducts
            self.largeOrders = largeOrders
            self.initialPeriod = initialPeriod
            self.onPeriodChange = onPeriodChange
            self.onCustomDateRange = onCustomDateRange
        }
    }

    // MARK: - State

    private let configuration: Configuration
    @State private(set) var selectedPeriod: DFRevenuePeriod
    @State private var showDateRangeSheet: Bool = false
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
        _selectedPeriod = State(initialValue: configuration.initialPeriod)
    }

    // MARK: - Computed helpers (internal for testability)

    var deltaIsPositive: Bool { configuration.metrics.revenueDelta >= 0 }

    var formattedDeltaPercent: String {
        let pct = configuration.metrics.revenueDeltaPercent
        let sign = pct >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", pct))%"
    }

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                periodSelector
                heroRevenue
                statCards
                revenueChartArea
                categoryChartArea
                topProductsTable
                monthlyTargetRing
                largeOrdersFeed
            }
            .padding(theme.spacing.md)
        }
        .navigationTitle("Revenue")
        .sheet(isPresented: $showDateRangeSheet) {
            DFDateRangeBlock(configuration: .init(
                onApply: { _, _ in showDateRangeSheet = false },
                onCancel: { showDateRangeSheet = false }
            ))
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var periodSelector: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(DFRevenuePeriod.allCases, id: \.self) { period in
                DFButton(
                    period.displayLabel,
                    style: selectedPeriod == period ? .primary : .secondary,
                    size: .small
                ) {
                    if period == .custom {
                        showDateRangeSheet = true
                        configuration.onCustomDateRange()
                    } else {
                        selectedPeriod = period
                        configuration.onPeriodChange(period)
                    }
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var heroRevenue: some View {
        DFCard {
            VStack(spacing: theme.spacing.sm) {
                DFText("Today's Revenue", style: .caption)
                DFText(
                    configuration.metrics.todayRevenue.formatted(.currency(code: "USD")),
                    style: .largeTitle
                )
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: deltaIsPositive ? "arrow.up.right" : "arrow.down.right")
                        .foregroundStyle(deltaIsPositive ? theme.colors.success : theme.colors.destructive)
                    DFText(
                        "\(formattedDeltaPercent) vs yesterday",
                        style: .body
                    )
                    .foregroundStyle(deltaIsPositive ? theme.colors.success : theme.colors.destructive)
                }
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var statCards: some View {
        HStack(spacing: theme.spacing.sm) {
            DFStatCardBlock(configuration: .init(
                title: "Gross Revenue",
                value: configuration.metrics.grossRevenue.formatted(.currency(code: "USD"))
            ))
            DFStatCardBlock(configuration: .init(
                title: "Net Revenue",
                value: configuration.metrics.netRevenue.formatted(.currency(code: "USD"))
            ))
        }
        HStack(spacing: theme.spacing.sm) {
            DFStatCardBlock(configuration: .init(
                title: "Refunds",
                value: configuration.metrics.totalRefunds.formatted(.currency(code: "USD"))
            ))
            DFStatCardBlock(configuration: .init(
                title: "Avg Order Value",
                value: configuration.metrics.avgOrderValue.formatted(.currency(code: "USD"))
            ))
        }
    }

    @ViewBuilder
    private var revenueChartArea: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Revenue Over Time", style: .headlineSmall)
            DFChartPlaceholderBlock(configuration: .init(
                chartType: .area,
                title: "Revenue — \(selectedPeriod.displayLabel)",
                height: 220
            ))
        }
    }

    @ViewBuilder
    private var categoryChartArea: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Revenue by Category", style: .headlineSmall)
            DFChartPlaceholderBlock(configuration: .init(
                chartType: .donut,
                title: "Category Breakdown",
                height: 180
            ))
        }
    }

    @ViewBuilder
    private var topProductsTable: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Top Products", style: .headlineSmall)
            if configuration.topProducts.isEmpty {
                DFEmptyStateBlock(configuration: .init(
                    icon: "chart.bar",
                    title: "No data",
                    message: "No product sales data for this period."
                ))
            } else {
                DFTable(configuration: .init(
                    columns: [
                        .init(id: "name",    label: "Product",      width: .flexible),
                        .init(id: "units",   label: "Units Sold",   width: .fixed(90)),
                        .init(id: "revenue", label: "Revenue",      width: .fixed(110)),
                        .init(id: "pct",     label: "% of Total",   width: .fixed(90)),
                    ],
                    rows: configuration.topProducts.map { product in
                        DFTableRow(id: product.id, cells: [
                            "name":    .text(product.name),
                            "units":   .text("\(product.unitsSold)"),
                            "revenue": .text(product.revenue.formatted(.currency(code: "USD"))),
                            "pct":     .text(String(format: "%.1f%%", product.percentOfTotal)),
                        ])
                    }
                ))
            }
        }
    }

    @ViewBuilder
    private var monthlyTargetRing: some View {
        DFCard {
            HStack(spacing: theme.spacing.md) {
                DFProgressRingBlock(configuration: .init(
                    progress: configuration.metrics.monthlyProgress,
                    label: "Monthly Target",
                    size: .large
                ))
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    DFText("Monthly Target", style: .headlineSmall)
                    DFText(
                        "\(String(format: "%.0f", configuration.metrics.monthlyProgress * 100))% complete",
                        style: .body
                    )
                    DFText(
                        "\(configuration.metrics.monthlyActual.formatted(.currency(code: "USD"))) of \(configuration.metrics.monthlyTarget.formatted(.currency(code: "USD")))",
                        style: .caption
                    )
                    DFProgressBar(configuration: .init(
                        progress: configuration.metrics.monthlyProgress
                    ))
                }
            }
            .padding(theme.spacing.md)
        }
    }

    @ViewBuilder
    private var largeOrdersFeed: some View {
        if !configuration.largeOrders.isEmpty {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                DFText("Recent Large Orders", style: .headlineSmall)
                DFActivityFeedBlock(configuration: .init(
                    rows: configuration.largeOrders.map { order in
                        DFActivityFeedRow.Configuration(
                            title: order.id,
                            subtitle: order.customerName,
                            trailingText: order.total.formatted(.currency(code: "USD")),
                            timestamp: order.placedAt
                        )
                    }
                ))
            }
        }
    }
}
```

- [ ] **Step 4: Write the previews**

```swift
// Sources/DesignFoundationScreens/Ecommerce/Revenue/DFEcommerceRevenueScreen+Previews.swift
import SwiftUI
import DesignFoundation

#Preview("Light — Today") {
    NavigationStack {
        DFEcommerceRevenueScreen(configuration: .previewConfig(period: .today))
    }
    .environment(\.dfTheme, .default)
}

#Preview("Dark — 30D") {
    NavigationStack {
        DFEcommerceRevenueScreen(configuration: .previewConfig(period: .thirtyDays))
    }
    .environment(\.dfTheme, .default)
    .colorScheme(.dark)
}

#Preview("Down Day") {
    NavigationStack {
        DFEcommerceRevenueScreen(configuration: .previewConfig(isDownDay: true))
    }
    .environment(\.dfTheme, .default)
}

private extension DFEcommerceRevenueScreen.Configuration {
    static func previewConfig(
        period: DFRevenuePeriod = .today,
        isDownDay: Bool = false
    ) -> Self {
        let metrics = DFRevenueMetrics(
            todayRevenue:    isDownDay ? 820  : 1_842.50,
            yesterdayRevenue: 1_200,
            grossRevenue:    42_500,
            netRevenue:      38_200,
            totalRefunds:    1_800,
            avgOrderValue:   87.50,
            monthlyTarget:   50_000,
            monthlyActual:   42_500
        )
        let topProducts = [
            DFTopProduct(id: "P1", name: "Classic Tee",  unitsSold: 210, revenue: 6_279, percentOfTotal: 14.8),
            DFTopProduct(id: "P2", name: "Canvas Tote",  unitsSold: 184, revenue: 3_312, percentOfTotal: 7.8),
            DFTopProduct(id: "P3", name: "Baseball Cap", unitsSold: 145, revenue: 3_480, percentOfTotal: 8.2),
            DFTopProduct(id: "P4", name: "Logo Mug",     unitsSold: 120, revenue: 1_799, percentOfTotal: 4.2),
        ]
        let largeOrders = [
            DFOrder(id: "ORD-1042", customerName: "Sarah Chen", itemCount: 5,
                    total: 412.50, status: .processing,
                    placedAt: Date().addingTimeInterval(-3600),
                    shippingAddress: DFEcommerceAddress(line1: "10 Market St",
                        city: "SF", state: "CA", postalCode: "94105", country: "US")),
            DFOrder(id: "ORD-1039", customerName: "Priya Patel", itemCount: 8,
                    total: 699.00, status: .shipped,
                    placedAt: Date().addingTimeInterval(-28800),
                    shippingAddress: DFEcommerceAddress(line1: "88 Pine Rd",
                        city: "Austin", state: "TX", postalCode: "78701", country: "US")),
        ]
        return .init(
            metrics: metrics,
            topProducts: topProducts,
            largeOrders: largeOrders,
            initialPeriod: period
        )
    }
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter DFEcommerceRevenueScreenTests 2>&1 | tail -10
```
Expected: `Test Suite 'DFEcommerceRevenueScreenTests' passed`

- [ ] **Step 6: Run full test suite**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
swift test --filter Ecommerce 2>&1 | tail -15
```
Expected: all Ecommerce suites pass — no failures.

- [ ] **Step 7: Commit**

```bash
cd /Users/nerdsnipe/Projects/DesignFoundationScreens
git add Sources/DesignFoundationScreens/Ecommerce/Revenue/ \
        Tests/DesignFoundationScreensTests/Ecommerce/DFEcommerceRevenueScreenTests.swift
git commit -m "feat(screens): add DFEcommerceRevenueScreen"
```

---

## Self-Review Notes

**Spec coverage check:**
- DFEcommerceOrdersScreen: period filter (Today/This Week/Custom) ✓, status filter chips ✓, 3-stat summary row ✓, order list with DFAvatar + swipe actions ✓, tap → detail via closure ✓, search ✓, empty state ✓, skeleton loading ✓
- DFEcommerceOrderDetailScreen: order header with status badge ✓, 5-step timeline ✓, customer + address ✓, line items ✓, order summary card ✓, state-dependent action buttons ✓, internal notes + inline add ✓, tracking section ✓
- DFEcommerceProductsScreen: search + status filter chips ✓, sort menu ✓, grid/list toggle ✓, DFMetricGridBlock header ✓, low-stock/out-of-stock badge logic ✓, empty state ✓, loading state ✓
- DFEcommerceRevenueScreen: period selector (Today/7D/30D/90D/Custom) ✓, hero revenue + delta arrow ✓, 4 stat cards ✓, area chart placeholder ✓, donut chart placeholder ✓, top products table (DFTable, sortable columns) ✓, DFProgressRingBlock + DFProgressBar for monthly target ✓, DFActivityFeedBlock for large orders ✓

**DFTable sortable columns:** The spec says the top products table should be sortable. `DFTable` is passed a `Configuration` with columns — whether column headers are tappable for sorting is a behavior of `DFTable` itself (already built in the blocks layer). The plan passes columns correctly; no additional wiring needed in the screen.

**`DFBadgeSemantic` upstream concern:** The `DFBadgeSemantic` enum is defined in the Models file with a `#if DEBUG` guard note. If it already exists in `DesignFoundation`, remove the duplicate and just import it. Check with `grep -r "DFBadgeSemantic" /Users/nerdsnipe/Projects/DesignFoundation/Sources/` before Task 1.

**Type consistency confirmed:** `DFOrder.stub`, `DFProduct.stub`, `DFRevenueMetrics.stub` defined in Task 1 and used verbatim in Tasks 2–5 tests. `filteredOrders`, `filteredProducts`, `metrics`, `deltaIsPositive`, `formattedDeltaPercent`, `canMarkShipped`, `canCancel`, `timelineSteps`, `orderSubtotal` all match between implementation and test calls.
