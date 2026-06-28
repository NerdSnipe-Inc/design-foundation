import SwiftUI

public struct DFToggle: View {
    private let label: String
    @Binding private var isOn: Bool

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfToggleStyle) private var style

    public init(_ label: String, isOn: Binding<Bool>) {
        self.label = label
        self._isOn = isOn
    }

    public var body: some View {
        let config = DFToggleStyleConfiguration(
            label: label,
            isOn: $isOn,
            isDisabled: !isEnabled,
            theme: theme
        )
        style.makeBody(configuration: config)
            .accessibilityLabel(label)
            .accessibilityValue(isOn ? "On" : "Off")
    }
}
