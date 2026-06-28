import SwiftUI

// MARK: - Configuration

// IS Sendable: holds only Bool and DFTheme (Sendable); no closures.

public struct DFCheckboxStyleConfiguration: Sendable {
    public let isChecked: Bool
    public let isEnabled: Bool
    public let theme: DFTheme

    public init(isChecked: Bool, isEnabled: Bool, theme: DFTheme) {
        self.isChecked = isChecked
        self.isEnabled = isEnabled
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFCheckboxStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFCheckboxStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFCheckboxStyle: DFCheckboxStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: (DFCheckboxStyleConfiguration) -> AnyView

    public init<S: DFCheckboxStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFCheckboxStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFCheckboxStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFCheckboxStyle = AnyDFCheckboxStyle(DFDefaultCheckboxStyle())
}

public extension EnvironmentValues {
    var dfCheckboxStyle: AnyDFCheckboxStyle {
        get { self[DFCheckboxStyleKey.self] }
        set { self[DFCheckboxStyleKey.self] = newValue }
    }
}

public extension View {
    func dfCheckboxStyle<S: DFCheckboxStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfCheckboxStyle, AnyDFCheckboxStyle(style))
    }
}

// MARK: - Convenience static var

public extension DFCheckboxStyle where Self == DFDefaultCheckboxStyle {
    static var `default`: DFDefaultCheckboxStyle { DFDefaultCheckboxStyle() }
}

// MARK: - Built-in: Default

public struct DFDefaultCheckboxStyle: DFCheckboxStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFCheckboxStyleConfiguration) -> some View {
        let theme = configuration.theme
        ZStack {
            RoundedRectangle(cornerRadius: theme.radius.sm)
                .strokeBorder(
                    configuration.isChecked ? theme.colors.primary : theme.colors.border,
                    lineWidth: 1.5
                )
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.sm)
                        .fill(configuration.isChecked ? theme.colors.primary : Color.clear)
                )
                .frame(width: 20, height: 20)
            if configuration.isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .opacity(configuration.isEnabled ? 1.0 : 0.4)
    }
}
