import SwiftUI

public struct DFListRow: View {
    private let title: String
    private let subtitle: String?
    private let leading: AnyView?
    private let trailing: AnyView?
    private let showDisclosure: Bool

    @Environment(\.dfTheme) private var theme

    public init(title: String, subtitle: String? = nil, showDisclosure: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.leading = nil
        self.trailing = nil
        self.showDisclosure = showDisclosure
    }

    public init<Leading: View>(
        title: String,
        subtitle: String? = nil,
        showDisclosure: Bool = false,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = AnyView(leading())
        self.trailing = nil
        self.showDisclosure = showDisclosure
    }

    public init<Trailing: View>(
        title: String,
        subtitle: String? = nil,
        showDisclosure: Bool = false,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = nil
        self.trailing = AnyView(trailing())
        self.showDisclosure = showDisclosure
    }

    public init<Leading: View, Trailing: View>(
        title: String,
        subtitle: String? = nil,
        showDisclosure: Bool = false,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = AnyView(leading())
        self.trailing = AnyView(trailing())
        self.showDisclosure = showDisclosure
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            if let leading {
                leading
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
                trailing
            }
            if showDisclosure {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .accessibilityElement(children: .combine)
    }
}
