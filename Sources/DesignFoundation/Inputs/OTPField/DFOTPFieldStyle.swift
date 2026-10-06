import SwiftUI

// MARK: - Configuration

/// Passed to every DFOTPFieldStyle.makeBody.
/// Not Sendable: holds AnyView values.
public struct DFOTPFieldStyleConfiguration {
    public let label: String
    /// The real (visually hidden) text input. Overlay it on the row of cells so taps focus it, e.g.
    /// `HStack { ...cells... }.overlay { configuration.fieldContent }`. It already carries the label for VoiceOver.
    public let fieldContent: AnyView
    /// One entry per visual cell, with the character to show and whether it is the active one.
    public let cells: [DFOTPCode.Cell]
    public let isFocused: Bool
    public let isDisabled: Bool
    public let validationState: DFValidationState
    public let theme: DFTheme

    public init(
        label: String,
        fieldContent: AnyView,
        cells: [DFOTPCode.Cell],
        isFocused: Bool,
        isDisabled: Bool,
        validationState: DFValidationState,
        theme: DFTheme
    ) {
        self.label = label
        self.fieldContent = fieldContent
        self.cells = cells
        self.isFocused = isFocused
        self.isDisabled = isDisabled
        self.validationState = validationState
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFOTPFieldStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFOTPFieldStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFOTPFieldStyle: DFOTPFieldStyle, @unchecked Sendable {
    private let _makeBody: @MainActor (DFOTPFieldStyleConfiguration) -> AnyView

    public init<S: DFOTPFieldStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFOTPFieldStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFOTPFieldStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFOTPFieldStyle = AnyDFOTPFieldStyle(DFOutlinedOTPFieldStyle())
}

public extension EnvironmentValues {
    var dfOTPFieldStyle: AnyDFOTPFieldStyle {
        get { self[DFOTPFieldStyleKey.self] }
        set { self[DFOTPFieldStyleKey.self] = newValue }
    }
}

public extension View {
    func dfOTPFieldStyle<S: DFOTPFieldStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfOTPFieldStyle, AnyDFOTPFieldStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFOTPFieldStyle where Self == DFOutlinedOTPFieldStyle {
    static var outlined: DFOutlinedOTPFieldStyle { DFOutlinedOTPFieldStyle() }
}
public extension DFOTPFieldStyle where Self == DFFilledOTPFieldStyle {
    static var filled: DFFilledOTPFieldStyle { DFFilledOTPFieldStyle() }
}
public extension DFOTPFieldStyle where Self == DFUnderlinedOTPFieldStyle {
    static var underlined: DFUnderlinedOTPFieldStyle { DFUnderlinedOTPFieldStyle() }
}

// MARK: - Shared building blocks (internal)

extension DFOTPFieldStyleConfiguration {
    /// Stroke color for a cell: validation wins over focus, focus wins over `idle`.
    func cellStrokeColor(for cell: DFOTPCode.Cell, idle: Color) -> Color {
        if isDisabled { return idle }
        switch validationState {
        case .error: return theme.colors.destructive
        case .valid: return theme.colors.success
        case .none: return cell.isActive ? theme.colors.primary : idle
        }
    }

    var cellTextColor: Color {
        isDisabled ? theme.colors.textDisabled : theme.colors.textPrimary
    }
}

enum DFOTPMetrics {
    /// Comfortably above the 44pt iOS touch target.
    static let cellMinHeight: CGFloat = 52
    static let cellMaxWidth: CGFloat = 56
}

/// Character (or caret, while the active cell is empty) drawn inside one cell. The row hides it from VoiceOver;
/// the real input announces the value.
struct DFOTPCellContent: View {
    let cell: DFOTPCode.Cell
    let configuration: DFOTPFieldStyleConfiguration

    var body: some View {
        let theme = configuration.theme
        ZStack {
            if let character = cell.character {
                Text(String(character))
                    .font(theme.typography.title.font.monospacedDigit())
                    .foregroundStyle(configuration.cellTextColor)
            } else if cell.isActive {
                Capsule()
                    .fill(theme.colors.primary)
                    .frame(width: 2, height: 24)
            }
        }
        .frame(maxWidth: .infinity, minHeight: DFOTPMetrics.cellMinHeight)
        .dfMinimumTouchHeight()
    }
}

/// Lays the cells out in a row, hides them from accessibility and overlays the real input on top.
struct DFOTPCellRow<Cell: View>: View {
    let configuration: DFOTPFieldStyleConfiguration
    let cell: (DFOTPCode.Cell) -> Cell

    init(
        configuration: DFOTPFieldStyleConfiguration,
        @ViewBuilder cell: @escaping (DFOTPCode.Cell) -> Cell
    ) {
        self.configuration = configuration
        self.cell = cell
    }

    var body: some View {
        let spacing = configuration.theme.spacing.sm
        let count = CGFloat(configuration.cells.count)
        HStack(spacing: spacing) {
            ForEach(configuration.cells) { item in
                cell(item)
            }
        }
        .accessibilityHidden(true)
        .overlay { configuration.fieldContent }
        .frame(
            maxWidth: count * DFOTPMetrics.cellMaxWidth + max(0, count - 1) * spacing,
            alignment: .leading
        )
    }
}

/// Label above, row of cells, validation message below. The message is its own accessibility element.
struct DFOTPFieldFrame<Row: View>: View {
    let configuration: DFOTPFieldStyleConfiguration
    let labelColor: Color
    let row: Row

    init(configuration: DFOTPFieldStyleConfiguration, labelColor: Color, @ViewBuilder row: () -> Row) {
        self.configuration = configuration
        self.labelColor = labelColor
        self.row = row()
    }

    var body: some View {
        let theme = configuration.theme
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if !configuration.label.isEmpty {
                Text(configuration.label)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(labelColor)
            }
            row
            if case .error(let message) = configuration.validationState {
                Text(message)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.destructive)
            }
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
        .animation(theme.animation.fast, value: configuration.isFocused)
    }
}

// MARK: - Built-in: Outlined (default)

/// Boxed cells with a border; the active cell gets a 2pt primary border.
public struct DFOutlinedOTPFieldStyle: DFOTPFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFOTPFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        DFOTPFieldFrame(
            configuration: configuration,
            labelColor: configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textSecondary
        ) {
            DFOTPCellRow(configuration: configuration) { cell in
                DFOTPCellContent(cell: cell, configuration: configuration)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.md)
                            .fill(theme.colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.md)
                                    .stroke(
                                        configuration.cellStrokeColor(for: cell, idle: theme.colors.border),
                                        lineWidth: cell.isActive ? 2 : 1
                                    )
                            )
                    )
            }
        }
    }
}

// MARK: - Built-in: Filled

/// Filled cells without a resting border; only the active, error and valid states draw a stroke.
public struct DFFilledOTPFieldStyle: DFOTPFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFOTPFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        DFOTPFieldFrame(
            configuration: configuration,
            labelColor: configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textSecondary
        ) {
            DFOTPCellRow(configuration: configuration) { cell in
                let showsStroke = cell.isActive || configuration.validationState != .none
                DFOTPCellContent(cell: cell, configuration: configuration)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.md)
                            .fill(
                                configuration.isDisabled
                                    ? theme.colors.interactiveDisabled
                                    : theme.colors.surface
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.md)
                                    .stroke(
                                        configuration.cellStrokeColor(for: cell, idle: Color.clear),
                                        lineWidth: showsStroke ? 2 : 0
                                    )
                            )
                    )
            }
        }
    }
}

// MARK: - Built-in: Underlined

/// No box: each cell sits on a bottom rule; the active cell's rule is thicker and primary-colored.
public struct DFUnderlinedOTPFieldStyle: DFOTPFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFOTPFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        DFOTPFieldFrame(
            configuration: configuration,
            labelColor: configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textSecondary
        ) {
            DFOTPCellRow(configuration: configuration) { cell in
                DFOTPCellContent(cell: cell, configuration: configuration)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(configuration.cellStrokeColor(for: cell, idle: theme.colors.border))
                            .frame(height: cell.isActive ? 2 : 1)
                    }
            }
        }
    }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

@available(iOS 26, macOS 26, *)
public extension DFOTPFieldStyle where Self == DFGlassOTPFieldStyle {
    static var glass: DFGlassOTPFieldStyle { DFGlassOTPFieldStyle() }
}

/// Liquid Glass cells. Falls back to the outlined color-token look when `theme.materials.preferLiquidGlass`
/// is false. Only compiled with the Xcode 26 toolchain (Swift 6.2+).
@available(iOS 26, macOS 26, *)
public struct DFGlassOTPFieldStyle: DFOTPFieldStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFOTPFieldStyleConfiguration) -> some View {
        let theme = configuration.theme
        let useGlass = theme.materials.preferLiquidGlass
        let shape = RoundedRectangle(cornerRadius: theme.radius.md)
        DFOTPFieldFrame(
            configuration: configuration,
            labelColor: configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textSecondary
        ) {
            DFOTPCellRow(configuration: configuration) { cell in
                let stroke = configuration.cellStrokeColor(for: cell, idle: theme.colors.border)
                if useGlass {
                    DFOTPCellContent(cell: cell, configuration: configuration)
                        .background {
                            DFOTPGlassCellBackground(shape: shape, fallback: theme.colors.surface)
                        }
                        .overlay {
                            shape.stroke(
                                stroke.opacity(cell.isActive || configuration.validationState != .none ? 1 : 0),
                                lineWidth: 2
                            )
                        }
                } else {
                    DFOTPCellContent(cell: cell, configuration: configuration)
                        .background(theme.colors.surface, in: shape)
                        .overlay {
                            shape.stroke(stroke, lineWidth: cell.isActive ? 2 : 1)
                        }
                }
            }
        }
    }
}

/// The translucent cell background of `DFGlassOTPFieldStyle`. SwiftUI's `glassEffect` needs the iOS/macOS 26 SDK and does
/// not exist on visionOS, so other toolchains and visionOS fill with the surface color instead.
@available(iOS 26, macOS 26, *)
private struct DFOTPGlassCellBackground<S: InsettableShape>: View {
    let shape: S
    let fallback: Color

    var body: some View {
        #if compiler(>=6.2) && !os(visionOS)
        shape.fill(Color.clear).glassEffect(.regular, in: shape)
        #else
        shape.fill(fallback)
        #endif
    }
}

