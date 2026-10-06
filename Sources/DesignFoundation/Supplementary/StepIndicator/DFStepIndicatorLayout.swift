import SwiftUI

// Shared renderers behind every built-in DFStepIndicator style and DFTimeline style:
// the marker (circle / dot), the connector line, and the horizontal / compact / vertical step layouts.
// Internal on purpose: styles pick a `DFStepMarkerKind` and a marker size; everything else is shared.

// MARK: - Marker

enum DFStepMarkerKind: Sendable, Equatable {
    /// Filled circle: checkmark when complete, number or custom icon otherwise.
    case filled
    /// Small dot (current gets a ring, error gets an exclamation symbol).
    case dot
    /// Circle that always shows its number; complete is a tinted fill, current is solid.
    case numbered
}

/// A step marker. State is carried by shape as well as color: solid check, ringed current,
/// hollow upcoming, exclamation for error. Hidden from VoiceOver; the owning row describes the step.
struct DFStepMarker: View {
    let kind: DFStepMarkerKind
    let state: DFStepState
    /// 1-based position shown as the number.
    let position: Int
    let systemImage: String?
    let size: CGFloat
    let theme: DFTheme

    nonisolated init(
        kind: DFStepMarkerKind,
        state: DFStepState,
        position: Int,
        systemImage: String?,
        size: CGFloat,
        theme: DFTheme
    ) {
        self.kind = kind
        self.state = state
        self.position = position
        self.systemImage = systemImage
        self.size = size
        self.theme = theme
    }

    private var accent: Color {
        state == .error ? theme.colors.destructive : theme.colors.primary
    }

    private var isSolid: Bool {
        switch state {
        case .current, .error: return true
        case .complete: return kind == .filled
        case .upcoming: return false
        }
    }

    private var fillColor: Color {
        if isSolid { return accent }
        if state == .complete { return accent.opacity(0.15) }
        return Color.clear
    }

    private var outlineColor: Color {
        state == .upcoming ? theme.colors.border : accent
    }

    private var glyphColor: Color {
        if isSolid { return theme.colors.background }
        return state == .upcoming ? theme.colors.textSecondary : accent
    }

    private var glyphSymbol: String? {
        switch state {
        case .error: return "exclamationmark"
        case .complete: return kind == .numbered ? nil : "checkmark"
        case .current, .upcoming: return systemImage
        }
    }

    var body: some View {
        Group {
            if kind == .dot {
                dot
            } else {
                circle
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var circle: some View {
        ZStack {
            Circle().fill(fillColor)
            Circle().strokeBorder(outlineColor, lineWidth: 1.5)
            glyph
        }
        .overlay {
            if state == .current {
                Circle()
                    .strokeBorder(accent, lineWidth: 2)
                    .padding(-theme.spacing.xs)
            }
        }
    }

    @ViewBuilder
    private var glyph: some View {
        if let symbol = glyphSymbol {
            Image(systemName: symbol)
                .font(theme.typography.caption.font.weight(.bold))
                .foregroundStyle(glyphColor)
        } else {
            Text("\(position)")
                .font(theme.typography.label.font.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .foregroundStyle(glyphColor)
                .padding(2)
        }
    }

    @ViewBuilder
    private var dot: some View {
        switch state {
        case .complete:
            Circle()
                .fill(accent)
                .frame(width: size * 0.6, height: size * 0.6)
        case .current:
            ZStack {
                Circle().strokeBorder(accent, lineWidth: 2)
                Circle()
                    .fill(accent)
                    .frame(width: size * 0.5, height: size * 0.5)
            }
        case .upcoming:
            Circle()
                .strokeBorder(theme.colors.border, lineWidth: 2)
                .frame(width: size * 0.6, height: size * 0.6)
        case .error:
            Image(systemName: "exclamationmark.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(accent)
        }
    }
}

// MARK: - Connector

/// A line between two markers. Complete connectors are full thickness in the primary color;
/// not-yet-complete ones are half thickness in the border color, so the difference is not color alone.
struct DFStepConnector: View {
    let axis: Axis
    let isComplete: Bool
    let thickness: CGFloat
    /// Minimum length along the axis (horizontal connectors stretch to fill spare width).
    let minLength: CGFloat
    let theme: DFTheme

    nonisolated init(axis: Axis, isComplete: Bool, thickness: CGFloat, minLength: CGFloat, theme: DFTheme) {
        self.axis = axis
        self.isComplete = isComplete
        self.thickness = thickness
        self.minLength = minLength
        self.theme = theme
    }

    var body: some View {
        let drawn = isComplete ? thickness : max(1, thickness / 2)
        let color = isComplete ? theme.colors.primary : theme.colors.border
        if axis == .horizontal {
            Rectangle()
                .fill(color)
                .frame(height: drawn)
                .frame(minWidth: minLength, maxWidth: .infinity)
                .frame(height: thickness)
                .accessibilityHidden(true)
        } else {
            Rectangle()
                .fill(color)
                .frame(width: drawn)
                .frame(minHeight: minLength, maxHeight: .infinity)
                .frame(width: thickness)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Accessibility

extension View {
    /// "Step 2 of 4, Shipping" as the label, "current" as the value, the subtitle as a hint.
    func dfStepAccessibility(step: DFStep, position: Int, total: Int, state: DFStepState) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(DFStep.accessibilityLabel(position: position, of: total, title: step.title))
            .accessibilityValue(state.accessibilityValue)
            .accessibilityHint(step.subtitle ?? "")
    }
}

// MARK: - Step layout

/// Lays out a `DFStepIndicatorStyleConfiguration`: horizontal (marker over title), horizontal compact
/// (markers only, plus the current title), or vertical (marker column beside title + subtitle).
struct DFStepIndicatorLayout: View {
    let configuration: DFStepIndicatorStyleConfiguration
    let kind: DFStepMarkerKind
    let markerSize: CGFloat

    nonisolated init(configuration: DFStepIndicatorStyleConfiguration, kind: DFStepMarkerKind, markerSize: CGFloat) {
        self.configuration = configuration
        self.kind = kind
        self.markerSize = markerSize
    }

    private var theme: DFTheme { configuration.theme }
    private var connectorThickness: CGFloat { theme.components.stepIndicator.connectorThickness ?? 2 }

    var body: some View {
        if configuration.axis == .vertical {
            verticalLayout
        } else if configuration.isCompact {
            compactLayout
        } else {
            horizontalLayout
        }
    }

    private func state(at index: Int) -> DFStepState {
        configuration.states.indices.contains(index) ? configuration.states[index] : .upcoming
    }

    private func marker(at index: Int, showsIcon: Bool) -> DFStepMarker {
        DFStepMarker(
            kind: kind,
            state: state(at: index),
            position: index + 1,
            systemImage: showsIcon ? configuration.steps[index].systemImage : nil,
            size: markerSize,
            theme: theme
        )
    }

    private func connector(after index: Int, axis: Axis, minLength: CGFloat) -> DFStepConnector {
        DFStepConnector(
            axis: axis,
            isComplete: state(at: index) == .complete,
            thickness: connectorThickness,
            minLength: minLength,
            theme: theme
        )
    }

    private func titleColor(_ state: DFStepState) -> Color {
        switch state {
        case .complete, .current: return theme.colors.textPrimary
        case .upcoming: return theme.colors.textSecondary
        case .error: return theme.colors.destructive
        }
    }

    private func titleFont(_ state: DFStepState) -> Font {
        state == .current
            ? theme.typography.label.font.weight(.bold)
            : theme.typography.label.font
    }

    // MARK: Horizontal

    private var horizontalLayout: some View {
        let steps = configuration.steps
        return HStack(alignment: .top, spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                VStack(spacing: theme.spacing.xs) {
                    marker(at: index, showsIcon: true)
                    Text(step.title)
                        .font(titleFont(state(at: index)))
                        .foregroundStyle(titleColor(state(at: index)))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .dfStepAccessibility(step: step, position: index + 1, total: steps.count, state: state(at: index))
                if index < steps.count - 1 {
                    connector(after: index, axis: .horizontal, minLength: 16)
                        .padding(.top, (markerSize - connectorThickness) / 2)
                        .padding(.horizontal, theme.spacing.xs)
                }
            }
        }
    }

    // MARK: Compact

    private var compactLayout: some View {
        let steps = configuration.steps
        let currentIndex = configuration.states.firstIndex(of: .current)
        return VStack(spacing: theme.spacing.xs) {
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    marker(at: index, showsIcon: false)
                        .dfStepAccessibility(step: step, position: index + 1, total: steps.count, state: state(at: index))
                    if index < steps.count - 1 {
                        connector(after: index, axis: .horizontal, minLength: 6)
                            .padding(.horizontal, theme.spacing.xs)
                    }
                }
            }
            if let currentIndex, steps.indices.contains(currentIndex) {
                Text(steps[currentIndex].title)
                    .font(titleFont(.current))
                    .foregroundStyle(titleColor(.current))
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
    }

    // MARK: Vertical

    private var verticalLayout: some View {
        let steps = configuration.steps
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                let isLast = index == steps.count - 1
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    marker(at: index, showsIcon: true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.title)
                            .font(titleFont(state(at: index)))
                            .foregroundStyle(titleColor(state(at: index)))
                        if let subtitle = step.subtitle {
                            Text(subtitle)
                                .font(theme.typography.caption.font)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, isLast ? 0 : theme.spacing.lg)
                }
                .background(alignment: .topLeading) {
                    if !isLast {
                        connector(after: index, axis: .vertical, minLength: 8)
                            .padding(.top, markerSize + theme.spacing.xs)
                            .padding(.leading, (markerSize - connectorThickness) / 2)
                    }
                }
                .dfStepAccessibility(step: step, position: index + 1, total: steps.count, state: state(at: index))
            }
        }
    }
}
