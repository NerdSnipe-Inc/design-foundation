import SwiftUI

public struct DFDivider: View {
    private let orientation: DFDividerOrientation
    private let label: String?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfDividerStyle) private var style

    public init(orientation: DFDividerOrientation = .horizontal, label: String? = nil) {
        self.orientation = orientation
        self.label = label
    }

    public var body: some View {
        let config = DFDividerStyleConfiguration(
            orientation: orientation,
            label: label,
            theme: theme
        )
        style.makeBody(configuration: config)
            .accessibilityHidden(true)
    }
}
