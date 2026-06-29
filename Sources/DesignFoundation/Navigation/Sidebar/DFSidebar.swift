import SwiftUI

// MARK: - Data model

public struct DFSidebarItem: Identifiable, Sendable {
    public let id: String
    public let icon: String?
    public let label: String
    public let isEnabled: Bool

    public init(id: String, icon: String? = nil, label: String, isEnabled: Bool = true) {
        self.id = id
        self.icon = icon
        self.label = label
        self.isEnabled = isEnabled
    }
}

public struct DFSidebarSection: Identifiable, Sendable {
    public let id: String
    public let title: String?
    public let items: [DFSidebarItem]
    public let isCollapsible: Bool

    public init(
        id: String,
        title: String? = nil,
        items: [DFSidebarItem],
        isCollapsible: Bool = false
    ) {
        self.id = id
        self.title = title
        self.items = items
        self.isCollapsible = isCollapsible
    }
}

// MARK: - DFSidebar

public struct DFSidebar: View {
    @Binding private var selection: String?
    private let sections: [DFSidebarSection]

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfSidebarStyle) private var style
    @State private var collapsedSections: Set<String> = []

    public init(selection: Binding<String?>, sections: [DFSidebarSection]) {
        self._selection = selection
        self.sections = sections
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(sections) { section in
                    sectionView(section)
                }
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
        }
        .background(style.sidebarBackground(theme: theme))
    }

    @ViewBuilder
    private func sectionView(_ section: DFSidebarSection) -> some View {
        if let title = section.title {
            Button {
                guard section.isCollapsible else { return }
                if collapsedSections.contains(section.id) {
                    collapsedSections.remove(section.id)
                } else {
                    collapsedSections.insert(section.id)
                }
            } label: {
                HStack {
                    Text(title)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Spacer()
                    if section.isCollapsible {
                        Image(
                            systemName: collapsedSections.contains(section.id)
                                ? "chevron.right"
                                : "chevron.down"
                        )
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.top, theme.spacing.md)
                .padding(.bottom, theme.spacing.xs)
            }
            .buttonStyle(.plain)
        }

        if !collapsedSections.contains(section.id) {
            ForEach(section.items) { item in
                Button {
                    guard item.isEnabled else { return }
                    selection = item.id
                } label: {
                    style.makeItemBody(configuration: DFSidebarItemStyleConfiguration(
                        item: item,
                        isSelected: selection == item.id,
                        isEnabled: item.isEnabled,
                        theme: theme
                    ))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.label)
                .accessibilityAddTraits(selection == item.id ? [.isSelected] : [])
            }
        }
    }
}
