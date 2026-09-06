import SwiftUI

public struct DFMetadataItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let systemImage: String
    public let label: String

    public init(id: String = UUID().uuidString, systemImage: String, label: String) {
        self.id = id
        self.systemImage = systemImage
        self.label = label
    }
}

/// A horizontal row of small icon+label metadata items (read time, view count, etc).
public struct DFMetadataRow: View {
    public let items: [DFMetadataItem]

    @Environment(\.dfTheme) private var theme

    public init(items: [DFMetadataItem]) {
        self.items = items
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(items) { item in
                Label(item.label, systemImage: item.systemImage)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
