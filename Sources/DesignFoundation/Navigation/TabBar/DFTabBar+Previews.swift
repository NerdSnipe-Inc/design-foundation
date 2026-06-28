import SwiftUI

#Preview("DFTabBar — Standard") {
    @Previewable @State var selection = "home"
    let items = [
        DFTabItem(id: "home", icon: "house", label: "Home"),
        DFTabItem(id: "search", icon: "magnifyingglass", label: "Search"),
        DFTabItem(id: "inbox", icon: "tray", label: "Inbox", badgeCount: 3),
        DFTabItem(id: "profile", icon: "person", label: "Profile"),
    ]
    DFTabBar(selection: $selection, items: items) { id in
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            Text("Tab: \(id)").font(.largeTitle)
        }
    }
    .dfTheme(.default)
}

#Preview("DFTabBar — Minimal") {
    @Previewable @State var selection = "home"
    let items = [
        DFTabItem(id: "home", icon: "house", label: "Home"),
        DFTabItem(id: "search", icon: "magnifyingglass", label: "Search"),
        DFTabItem(id: "profile", icon: "person", label: "Profile"),
    ]
    DFTabBar(selection: $selection, items: items) { id in
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            Text("Tab: \(id)").font(.largeTitle)
        }
    }
    .dfTabBarStyle(.minimal)
    .dfTheme(.default)
}

#Preview("DFTabBar — Glass (iOS 26+)") {
    @Previewable @State var selection = "home"
    if #available(iOS 26, macOS 26, *) {
        let items = [
            DFTabItem(id: "home", icon: "house", label: "Home"),
            DFTabItem(id: "search", icon: "magnifyingglass", label: "Search"),
            DFTabItem(id: "profile", icon: "person", label: "Profile"),
        ]
        DFTabBar(selection: $selection, items: items) { id in
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                Text("Tab: \(id)").font(.largeTitle)
            }
        }
        .dfTabBarStyle(.glass)
        .dfTheme(.default)
    }
}
