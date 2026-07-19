import SwiftUI

/// A themed, content-rich entity summary row — media + title/subtitle + trailing metadata.
/// For a plain structural row with arbitrary leading/trailing views, use `DFListRow` instead;
/// `DFEntityRow` trades that flexibility for a consistent, quick-to-compose summary shape
/// (contact rows, order rows, search results). See `DFEntityCard` for the grid/card sibling.
public struct DFEntityRow: View {
    private let media: DFEntityMedia?
    private let title: String
    private let subtitle: String?
    private let trailing: DFEntityTrailing?
    private let onTap: (@MainActor @Sendable () -> Void)?

    @Environment(\.dfTheme) private var theme

    public init(
        media: DFEntityMedia? = nil,
        title: String,
        subtitle: String? = nil,
        trailing: DFEntityTrailing? = nil,
        onTap: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.media = media
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
        self.onTap = onTap
    }

    @MainActor
    public var body: some View {
        if let onTap {
            Button(action: onTap) { rowContent }
                .buttonStyle(.plain)
        } else {
            rowContent
        }
    }

    @ViewBuilder
    private var rowContent: some View {
        let mediaSize = theme.components.entityRow.mediaSize ?? 40

        HStack(spacing: theme.spacing.sm) {
            if let media {
                mediaView(media, size: mediaSize)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let trailing {
                trailingView(trailing)
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func mediaView(_ media: DFEntityMedia, size: CGFloat) -> some View {
        switch media {
        case .systemImage(let name):
            Image(systemName: name)
                .font(.system(size: size * 0.5))
                .foregroundStyle(theme.colors.primary)
                .frame(width: size, height: size)
                .background(Circle().fill(theme.colors.primary.opacity(0.12)))
        case .avatarInitials(let initials):
            DFAvatar(initials)
                .frame(width: size, height: size)
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
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}
