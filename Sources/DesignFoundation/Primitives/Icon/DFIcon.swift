import SwiftUI

public struct DFIcon: View {
    private let source: DFIconSource
    private let size: CGFloat?

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfIconStyle) private var style

    /// SF Symbol initialiser
    public init(_ symbolName: String, size: CGFloat? = nil) {
        self.source = .symbol(symbolName)
        self.size = size
    }

    /// Custom image initialiser
    public init(image: Image, size: CGFloat? = nil) {
        self.source = .image(image)
        self.size = size
    }

    public var body: some View {
        let resolvedSize = size ?? theme.components.icon.defaultSize ?? 24
        let config = DFIconStyleConfiguration(
            source: source,
            size: resolvedSize,
            isDisabled: !isEnabled,
            theme: theme
        )
        style.makeBody(configuration: config)
            .accessibilityHidden(true) // Icons are decorative by default; callers add label if needed
    }
}
