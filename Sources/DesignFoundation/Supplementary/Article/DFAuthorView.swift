import SwiftUI

/// Avatar + name (+ optional subtitle), an inline unit reusable standalone
/// (e.g. article bylines) or inside `DFArticleRow`.
public struct DFAuthorView: View {
    private enum Source {
        case initials(String)
        case image(Image)
    }

    private let source: Source
    public let name: String
    public let subtitle: String?

    @Environment(\.dfTheme) private var theme

    public init(initials: String, name: String, subtitle: String? = nil) {
        self.source = .initials(initials)
        self.name = name
        self.subtitle = subtitle
    }

    public init(image: Image, name: String, subtitle: String? = nil) {
        self.source = .image(image)
        self.name = name
        self.subtitle = subtitle
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            avatar
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .font(theme.typography.label.font)
                    .foregroundStyle(theme.colors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var avatar: some View {
        switch source {
        case .initials(let initials):
            DFAvatar(initials, size: 32, accessibilityName: name)
        case .image(let image):
            DFAvatar(image: image, size: 32, accessibilityName: name)
        }
    }
}
