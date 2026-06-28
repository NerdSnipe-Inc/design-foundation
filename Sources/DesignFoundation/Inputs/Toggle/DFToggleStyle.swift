import SwiftUI

// MARK: - Configuration

/// Sendable: Binding<Bool>: Sendable on iOS 18+, all other fields Sendable.
public struct DFToggleStyleConfiguration: Sendable {
    public let label: String
    /// Styles read and write this binding to drive interaction.
    public let isOn: Binding<Bool>
    public let isDisabled: Bool
    public let theme: DFTheme

    public init(label: String, isOn: Binding<Bool>, isDisabled: Bool, theme: DFTheme) {
        self.label = label
        self.isOn = isOn
        self.isDisabled = isDisabled
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFToggleStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFToggleStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFToggleStyle: DFToggleStyle, @unchecked Sendable {
    private let _makeBody: (DFToggleStyleConfiguration) -> AnyView

    public init<S: DFToggleStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFToggleStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFToggleStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFToggleStyle = AnyDFToggleStyle(DFSwitchToggleStyle())
}

public extension EnvironmentValues {
    var dfToggleStyle: AnyDFToggleStyle {
        get { self[DFToggleStyleKey.self] }
        set { self[DFToggleStyleKey.self] = newValue }
    }
}

public extension View {
    func dfToggleStyle<S: DFToggleStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfToggleStyle, AnyDFToggleStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFToggleStyle where Self == DFSwitchToggleStyle {
    static var `switch`: DFSwitchToggleStyle { DFSwitchToggleStyle() }
}
public extension DFToggleStyle where Self == DFCheckboxToggleStyle {
    static var checkbox: DFCheckboxToggleStyle { DFCheckboxToggleStyle() }
}

// MARK: - Built-in: Switch (default) — wraps native Toggle

public struct DFSwitchToggleStyle: DFToggleStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFToggleStyleConfiguration) -> some View {
        let theme = configuration.theme
        Toggle(isOn: configuration.isOn) {
            Text(configuration.label)
                .font(theme.typography.body.font)
                .foregroundStyle(
                    configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary
                )
        }
        .toggleStyle(.switch)
        .tint(theme.colors.primary)
        .disabled(configuration.isDisabled)
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Checkbox

public struct DFCheckboxToggleStyle: DFToggleStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFToggleStyleConfiguration) -> some View {
        let theme = configuration.theme
        Button {
            if !configuration.isDisabled {
                configuration.isOn.wrappedValue.toggle()
            }
        } label: {
            HStack(spacing: theme.spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: theme.radius.sm)
                        .fill(
                            configuration.isOn.wrappedValue
                                ? (configuration.isDisabled ? theme.colors.interactiveDisabled : theme.colors.primary)
                                : Color.clear
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radius.sm)
                                .stroke(
                                    configuration.isDisabled ? theme.colors.border : theme.colors.primary,
                                    lineWidth: 1.5
                                )
                        )
                        .frame(width: 20, height: 20)
                    if configuration.isOn.wrappedValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                Text(configuration.label)
                    .font(theme.typography.body.font)
                    .foregroundStyle(
                        configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(configuration.isDisabled)
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
        .animation(theme.animation.fast, value: configuration.isOn.wrappedValue)
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFToggleStyle where Self == DFGlassToggleStyle {
    static var glass: DFGlassToggleStyle { DFGlassToggleStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)
// Note: switch variant uses native Toggle which automatically receives Liquid Glass treatment
// on iOS 26; this style adds glass background to a custom checkbox rendering.

@available(iOS 26, macOS 26, *)
public struct DFGlassToggleStyle: DFToggleStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFToggleStyleConfiguration) -> some View {
        let theme = configuration.theme
        Button {
            if !configuration.isDisabled {
                configuration.isOn.wrappedValue.toggle()
            }
        } label: {
            HStack(spacing: theme.spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: theme.radius.sm)
                        .fill(.regularMaterial)
                        .frame(width: 22, height: 22)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radius.sm)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                    if configuration.isOn.wrappedValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                Text(configuration.label)
                    .font(theme.typography.body.font)
                    .foregroundStyle(configuration.isDisabled ? .white.opacity(0.4) : .white)
            }
        }
        .buttonStyle(.plain)
        .disabled(configuration.isDisabled)
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
        .animation(theme.animation.fast, value: configuration.isOn.wrappedValue)
    }
}
