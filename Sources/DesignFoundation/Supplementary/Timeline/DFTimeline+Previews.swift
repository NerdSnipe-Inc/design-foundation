import SwiftUI

private let previewItems: [DFTimelineItem] = [
    DFTimelineItem(
        id: "placed", title: "Order placed", detail: "We received your order.",
        timestamp: "Oct 3, 9:12 AM", systemImage: "bag", state: .complete
    ),
    DFTimelineItem(
        id: "packed", title: "Packed", detail: "Leaving the warehouse today.",
        timestamp: "Oct 4, 2:30 PM", systemImage: "shippingbox", state: .complete, trailing: .badge("Priority")
    ),
    DFTimelineItem(
        id: "transit", title: "In transit", detail: "Arriving Thursday.",
        timestamp: "Oct 5, 8:05 AM", systemImage: "truck.box", state: .current, trailing: .chevron
    ),
    DFTimelineItem(id: "delivered", title: "Delivered", systemImage: "house", state: .upcoming),
]

#Preview("DFTimeline — Standard") {
    DFTimeline(items: previewItems)
        .padding()
}

#Preview("DFTimeline — Compact") {
    DFTimeline(items: previewItems)
        .dfTimelineStyle(.compact)
        .padding()
}

#Preview("DFTimeline — Error") {
    DFTimeline(items: [
        DFTimelineItem(title: "Payment authorised", timestamp: "9:12 AM", state: .complete),
        DFTimelineItem(title: "Delivery failed", detail: "No one was home.", timestamp: "4:40 PM", state: .error, trailing: .text("Retry")),
        DFTimelineItem(title: "Delivered", state: .upcoming),
    ])
    .padding()
}
