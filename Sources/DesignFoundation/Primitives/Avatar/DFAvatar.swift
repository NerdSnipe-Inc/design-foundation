import SwiftUI

public struct DFAvatar: View {
    private let source: DFAvatarSource
    private let size: CGFloat
    private let presence: DFAvatarPresence
    private let accessibilityName: String?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfAvatarStyle) private var style

    public init(
        _ initials: String,
        size: CGFloat = 40,
        presence: DFAvatarPresence = .none,
        accessibilityName: String? = nil
    ) {
        self.source = .initials(initials)
        self.size = size
        self.presence = presence
        self.accessibilityName = accessibilityName
    }

    public init(
        image: Image,
        size: CGFloat = 40,
        presence: DFAvatarPresence = .none,
        accessibilityName: String? = nil
    ) {
        self.source = .image(image)
        self.size = size
        self.presence = presence
        self.accessibilityName = accessibilityName
    }

    public var body: some View {
        let config = DFAvatarStyleConfiguration(
            source: source,
            size: size,
            presence: presence,
            theme: theme
        )
        AnyView(style.makeBody(configuration: config))
            .accessibilityElement()
            .accessibilityLabel(accessibilityName ?? "Avatar")
            .accessibilityAddTraits(.isImage)
    }
}
