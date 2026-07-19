import SwiftUI

#if DEBUG

#Preview("Card grid") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        DFEntityCard(
            media: .systemImage("shippingbox.fill"),
            title: "Wireless Headphones",
            subtitle: "$129.99",
            trailing: .badge("New")
        )
        DFEntityCard(
            media: .systemImage("laptopcomputer"),
            title: "Laptop Stand",
            subtitle: "$49.99"
        )
    }
    .padding()
}

#Preview("Tappable card") {
    DFEntityCard(
        media: .avatarInitials("JL"),
        title: "Jordan Lee",
        subtitle: "Design",
        onTap: {}
    )
    .padding()
    .frame(width: 180)
}

#Preview("Dark mode") {
    DFEntityCard(
        media: .systemImage("cart.fill"),
        title: "Product name",
        subtitle: "$19.99"
    )
    .padding()
    .frame(width: 180)
    .preferredColorScheme(.dark)
}

#endif
