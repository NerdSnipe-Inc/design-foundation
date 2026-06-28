import SwiftUI

#Preview("DFSidebar — Standard") {
    @Previewable @State var selection: String? = "home"
    let sections: [DFSidebarSection] = [
        DFSidebarSection(id: "main", items: [
            DFSidebarItem(id: "home", icon: "house", label: "Home"),
            DFSidebarItem(id: "search", icon: "magnifyingglass", label: "Search"),
            DFSidebarItem(id: "favorites", icon: "heart", label: "Favorites"),
        ]),
        DFSidebarSection(id: "settings", title: "Settings", items: [
            DFSidebarItem(id: "account", icon: "person", label: "Account"),
            DFSidebarItem(id: "notifications", icon: "bell", label: "Notifications"),
            DFSidebarItem(id: "disabled", icon: "lock", label: "Locked", isEnabled: false),
        ], isCollapsible: true),
    ]
    DFSidebar(selection: $selection, sections: sections)
        .frame(width: 260)
        .dfTheme(.default)
}

#Preview("DFSidebar — Plain Style") {
    @Previewable @State var selection: String? = "home"
    let sections: [DFSidebarSection] = [
        DFSidebarSection(id: "nav", title: "Navigation", items: [
            DFSidebarItem(id: "home", icon: "house", label: "Home"),
            DFSidebarItem(id: "library", icon: "books.vertical", label: "Library"),
            DFSidebarItem(id: "profile", icon: "person.circle", label: "Profile"),
        ]),
    ]
    DFSidebar(selection: $selection, sections: sections)
        .dfSidebarStyle(.plain)
        .frame(width: 260)
        .dfTheme(.default)
}

#Preview("DFSidebar — Glass (iOS 26+)") {
    @Previewable @State var selection: String? = "home"
    if #available(iOS 26, macOS 26, *) {
        let sections: [DFSidebarSection] = [
            DFSidebarSection(id: "nav", title: "Navigation", items: [
                DFSidebarItem(id: "home", icon: "house", label: "Home"),
                DFSidebarItem(id: "library", icon: "books.vertical", label: "Library"),
                DFSidebarItem(id: "profile", icon: "person.circle", label: "Profile"),
            ]),
        ]
        ZStack {
            LinearGradient(
                colors: [.indigo.opacity(0.3), .blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            DFSidebar(selection: $selection, sections: sections)
                .dfSidebarStyle(.glass)
                .frame(width: 260)
        }
        .dfTheme(.default)
    }
}
