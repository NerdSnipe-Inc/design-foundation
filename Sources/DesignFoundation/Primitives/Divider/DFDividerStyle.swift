import SwiftUI

// MARK: - Orientation

public enum DFDividerOrientation: String, Sendable, CaseIterable {
    case horizontal
    case vertical
}

// MARK: - Configuration

public struct DFDividerStyleConfiguration: Sendable {
    public let orientation: DFDividerOrientation
    public let label: String?
    public let theme: DFTheme

    public init(orientation: DFDividerOrientation, label: String?, theme: DFTheme) {
        self.orientation = orientation
        self.label = label
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFDividerStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFDividerStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFDividerStyle: DFDividerStyle, @unchecked Sendable {
    private let _makeBody: (DFDividerStyleConfiguration) -> AnyView

    public init<S: DFDividerStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFDividerStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFDividerStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFDividerStyle(DFStandardDividerStyle())
}

public extension EnvironmentValues {
    var dfDividerStyle: AnyDFDividerStyle {
        get { self[DFDividerStyleKey.self] }
        set { self[DFDividerStyleKey.self] = newValue }
    }
}

public extension View {
    func dfDividerStyle<S: DFDividerStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfDividerStyle, AnyDFDividerStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFDividerStyle where Self == DFStandardDividerStyle {
    static var standard: DFStandardDividerStyle { DFStandardDividerStyle() }
}
public extension DFDividerStyle where Self == DFThickDividerStyle {
    static var thick: DFThickDividerStyle { DFThickDividerStyle() }
}
public extension DFDividerStyle where Self == DFSubtleDividerStyle {
    static var subtle: DFSubtleDividerStyle { DFSubtleDividerStyle() }
}

// MARK: - Helper: line with optional label

private func dividerLine(color: Color, lineWidth: CGFloat, orientation: DFDividerOrientation) -> some View {
    Group {
        if orientation == .horizontal {
            Rectangle().fill(color).frame(height: lineWidth)
        } else {
            Rectangle().fill(color).frame(width: lineWidth)
        }
    }
}

// MARK: - Built-in: Standard

public struct DFStandardDividerStyle: DFDividerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFDividerStyleConfiguration) -> some View {
        let color = configuration.theme.colors.border
        if let label = configuration.label, configuration.orientation == .horizontal {
            HStack {
                dividerLine(color: color, lineWidth: 1, orientation: .horizontal)
                Text(label)
                    .font(configuration.theme.typography.caption.font)
                    .foregroundStyle(configuration.theme.colors.textSecondary)
                    .fixedSize()
                dividerLine(color: color, lineWidth: 1, orientation: .horizontal)
            }
        } else {
            dividerLine(color: color, lineWidth: 1, orientation: configuration.orientation)
        }
    }
}

// MARK: - Built-in: Thick

public struct DFThickDividerStyle: DFDividerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFDividerStyleConfiguration) -> some View {
        dividerLine(
            color: configuration.theme.colors.border,
            lineWidth: 2,
            orientation: configuration.orientation
        )
    }
}

// MARK: - Built-in: Subtle

public struct DFSubtleDividerStyle: DFDividerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFDividerStyleConfiguration) -> some View {
        dividerLine(
            color: configuration.theme.colors.border.opacity(0.4),
            lineWidth: 1,
            orientation: configuration.orientation
        )
    }
}
