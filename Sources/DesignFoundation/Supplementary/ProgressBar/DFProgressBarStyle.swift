import SwiftUI

// MARK: - Variant

public enum DFProgressBarVariant: Sendable, Equatable {
    case linear
    case circular
    case indeterminate
}

// MARK: - Configuration
// IS Sendable: holds DFProgressBarVariant (Sendable), Double, optional String, DFTheme (Sendable).

public struct DFProgressBarStyleConfiguration: Sendable {
    public let variant: DFProgressBarVariant
    public let value: Double
    public let label: String?
    public let theme: DFTheme

    public init(variant: DFProgressBarVariant, value: Double, label: String?, theme: DFTheme) {
        self.variant = variant
        self.value = value
        self.label = label
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFProgressBarStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFProgressBarStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFProgressBarStyle: DFProgressBarStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: (DFProgressBarStyleConfiguration) -> AnyView

    public init<S: DFProgressBarStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFProgressBarStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFProgressBarStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFProgressBarStyle = AnyDFProgressBarStyle(DFDefaultProgressBarStyle())
}

public extension EnvironmentValues {
    var dfProgressBarStyle: AnyDFProgressBarStyle {
        get { self[DFProgressBarStyleKey.self] }
        set { self[DFProgressBarStyleKey.self] = newValue }
    }
}

public extension View {
    func dfProgressBarStyle<S: DFProgressBarStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfProgressBarStyle, AnyDFProgressBarStyle(style))
    }
}

// MARK: - Convenience static var

public extension DFProgressBarStyle where Self == DFDefaultProgressBarStyle {
    static var `default`: DFDefaultProgressBarStyle { DFDefaultProgressBarStyle() }
}

// MARK: - Built-in: Default

public struct DFDefaultProgressBarStyle: DFProgressBarStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFProgressBarStyleConfiguration) -> some View {
        let theme = configuration.theme
        let clamped = max(0, min(1, configuration.value))

        switch configuration.variant {
        case .linear:
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                if let label = configuration.label {
                    Text(label)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(theme.colors.border)
                            .frame(height: 6)
                        Capsule()
                            .fill(theme.colors.primary)
                            .frame(width: geo.size.width * clamped, height: 6)
                    }
                }
                .frame(height: 6)
            }

        case .circular:
            ZStack {
                Circle()
                    .stroke(theme.colors.border, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: clamped)
                    .stroke(theme.colors.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                if let label = configuration.label {
                    Text(label)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 52, height: 52)

        case .indeterminate:
            VStack(spacing: theme.spacing.xs) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(theme.colors.primary)
                if let label = configuration.label {
                    Text(label)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
        }
    }
}
