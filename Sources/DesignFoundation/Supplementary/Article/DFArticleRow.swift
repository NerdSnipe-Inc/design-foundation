import SwiftUI

/// Title + author + relative time + tags row, for feeds/news/docs lists.
public struct DFArticleRow: View {
    private enum AuthorSource {
        case initials(String)
        case image(Image)
    }

    public let title: String
    private let authorName: String
    private let authorSource: AuthorSource
    private let date: Date
    public let tags: [String]

    @Environment(\.dfTheme) private var theme

    public init(
        title: String,
        authorName: String,
        authorInitials: String,
        date: Date,
        tags: [String] = []
    ) {
        self.title = title
        self.authorName = authorName
        self.authorSource = .initials(authorInitials)
        self.date = date
        self.tags = tags
    }

    public init(
        title: String,
        authorName: String,
        authorImage: Image,
        date: Date,
        tags: [String] = []
    ) {
        self.title = title
        self.authorName = authorName
        self.authorSource = .image(authorImage)
        self.date = date
        self.tags = tags
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.headline.font)
                .lineLimit(theme.components.articleRow.titleLines ?? 2)

            HStack(spacing: theme.spacing.xs) {
                author
                DFRelativeTimeTag(date: date)
            }

            if !tags.isEmpty {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(tags, id: \.self) { tag in
                        DFInlineTagView(tag)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var author: some View {
        switch authorSource {
        case .initials(let initials):
            DFAuthorView(initials: initials, name: authorName)
        case .image(let image):
            DFAuthorView(image: image, name: authorName)
        }
    }
}
