import SwiftUI

#if DEBUG

#Preview("Rows — various media/trailing combinations") {
    VStack(spacing: 0) {
        DFEntityRow(
            media: .avatarInitials("JL"),
            title: "Jordan Lee",
            subtitle: "jordan@acme.com",
            trailing: .chevron
        )
        DFDivider()
        DFEntityRow(
            media: .systemImage("shippingbox.fill"),
            title: "Order #1042",
            subtitle: "3 items",
            trailing: .badge("Shipped")
        )
        DFDivider()
        DFEntityRow(
            title: "No media row",
            trailing: .text("2h ago")
        )
    }
    .padding()
}

#Preview("Tappable row") {
    DFEntityRow(
        media: .avatarInitials("AR"),
        title: "Alex Rivera",
        subtitle: "Product Manager",
        trailing: .chevron,
        onTap: {}
    )
    .padding()
}

#Preview("Dark mode") {
    DFEntityRow(
        media: .systemImage("cart.fill"),
        title: "Cart item",
        subtitle: "$34.99",
        trailing: .chevron
    )
    .padding()
    .preferredColorScheme(.dark)
}

#endif
