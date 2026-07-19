import SwiftUI

/// The grid/card-context sibling of `DFEntityRow` — vertical layout (media on top, text below)
/// wrapped in `DFCard`, for product grids, article grids, and similar tile layouts.
public struct DFEntityCard: View {
    private let media: DFEntityMedia?
    private let title: String
    private let subtitle: String?
    private let trailing: DFEntityTrailing?
    private let onTap: (() -> Void)?

    @Environment(\.dfTheme) private var theme

    public init(
        media: DFEntityMedia? = nil,
        title: String,
        subtitle: String? = nil,
        trailing: DFEntityTrailing? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.media = media
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
        self.onTap = onTap
    }

    public var body: some View {
        DFCard(action: onTap) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                if let media {
                    mediaView(media)
                }
                Text(title)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                }
                if let trailing {
                    trailingView(trailing)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func mediaView(_ media: DFEntityMedia) -> some View {
        let mediaHeight = theme.components.entityCard.mediaHeight ?? 120

        switch media {
        case .systemImage(let name):
            RoundedRectangle(cornerRadius: theme.radius.sm)
                .fill(theme.colors.primary.opacity(0.12))
                .frame(height: mediaHeight)
                .overlay(
                    Image(systemName: name)
                        .font(.system(size: mediaHeight * 0.3))
                        .foregroundStyle(theme.colors.primary)
                )
        case .avatarInitials(let initials):
            DFAvatar(initials)
                .frame(width: mediaHeight * 0.5, height: mediaHeight * 0.5)
                .frame(maxWidth: .infinity, minHeight: mediaHeight)
        }
    }

    @ViewBuilder
    private func trailingView(_ trailing: DFEntityTrailing) -> some View {
        switch trailing {
        case .text(let text):
            Text(text)
                .font(theme.typography.caption.font)
                .foregroundStyle(theme.colors.textSecondary)
        case .badge(let text):
            DFBadge(text: text)
        case .chevron:
            EmptyView()
        }
    }
}
