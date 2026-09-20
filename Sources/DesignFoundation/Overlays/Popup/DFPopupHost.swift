import SwiftUI

// MARK: - Drag math

/// Pure gesture math, separated from the view so it can be unit tested.
enum DFPopupDrag {
    /// Points of travel toward the exit edge that commit a dismissal.
    static let dismissDistance: CGFloat = 60

    /// Restricts a drag to the axis and direction of the exit edge; dragging the
    /// other way is ignored so the popup can only be pushed off, not pulled inward.
    static func constrained(_ translation: CGSize, toward edge: Edge) -> CGSize {
        switch edge {
        case .top:      return CGSize(width: 0, height: min(0, translation.height))
        case .bottom:   return CGSize(width: 0, height: max(0, translation.height))
        case .leading:  return CGSize(width: min(0, translation.width), height: 0)
        case .trailing: return CGSize(width: max(0, translation.width), height: 0)
        }
    }

    /// Travel toward the exit edge, always non-negative.
    static func travel(_ translation: CGSize, toward edge: Edge) -> CGFloat {
        let c = constrained(translation, toward: edge)
        return abs(edge == .top || edge == .bottom ? c.height : c.width)
    }

    static func shouldDismiss(translation: CGSize, predictedEnd: CGSize, toward edge: Edge) -> Bool {
        travel(translation, toward: edge) >= dismissDistance
            || travel(predictedEnd, toward: edge) >= dismissDistance * 2.5
    }
}

// MARK: - Host

/// Draws a popup over whatever this view is overlaid on. Most callers want
/// `.dfPopup(isPresented:)`; use the host directly to embed a popup layer in
/// custom containers (for example a dedicated window).
public struct DFPopupHost<Content: View>: View {
    @Binding private var isPresented: Bool
    private let identity: AnyHashable?
    private let configuration: DFPopupConfiguration
    private let onDismiss: (() -> Void)?
    private let content: Content

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfPopupStyle) private var style
    @State private var dragOffset: CGSize = .zero

    public init(
        isPresented: Binding<Bool>,
        identity: AnyHashable? = nil,
        configuration: DFPopupConfiguration,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.identity = identity
        self.configuration = configuration
        self.onDismiss = onDismiss
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: configuration.position.alignment) {
            if isPresented {
                backdrop
                popup
            }
        }
        .animation(configuration.animation ?? theme.animation.default, value: isPresented)
        .onChange(of: isPresented) { _, presented in
            if !presented {
                dragOffset = .zero
                onDismiss?()
            }
        }
    }

    // MARK: Pieces

    @ViewBuilder
    private var backdrop: some View {
        if configuration.dimsBackground {
            Color.black
                .opacity(theme.components.popup.backdropOpacity ?? 0.35)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { if configuration.dismissOnOutsideTap { dismiss() } }
                .transition(.opacity)
                .accessibilityHidden(true)
        } else if configuration.dismissOnOutsideTap {
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { dismiss() }
                .accessibilityHidden(true)
        }
    }

    private var popup: some View {
        let edge = configuration.position.exitEdge
        return style.makeBody(configuration: DFPopupStyleConfiguration(
            content: AnyView(content),
            kind: configuration.kind,
            position: configuration.position,
            theme: theme
        ))
        .frame(maxWidth: maxWidth)
        .padding(outerPadding)
        .offset(dragOffset)
        .contentShape(Rectangle())
        .onTapGesture { if configuration.dismissOnTap { dismiss() } }
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    dragOffset = DFPopupDrag.constrained(value.translation, toward: edge)
                }
                .onEnded { value in
                    if DFPopupDrag.shouldDismiss(
                        translation: value.translation,
                        predictedEnd: value.predictedEndTranslation,
                        toward: edge
                    ) {
                        dismiss()
                    } else {
                        withAnimation(theme.animation.fast) { dragOffset = .zero }
                    }
                },
            including: configuration.dismissOnDrag ? .all : .subviews
        )
        .transition(resolvedTransition)
        .task(id: identity) {
            guard let seconds = configuration.autoDismissAfter else { return }
            try? await Task.sleep(for: .seconds(seconds))
            if !Task.isCancelled { dismiss() }
        }
        .accessibilityAddTraits(configuration.dimsBackground ? .isModal : [])
        .accessibilityAction(.escape) { dismiss() }
    }

    // MARK: Layout

    private var maxWidth: CGFloat? {
        switch configuration.kind {
        case .toast:   return .infinity
        case .center:  return theme.components.popup.maxWidth ?? 420
        case .floater: return nil
        }
    }

    private var outerPadding: CGFloat {
        switch configuration.kind {
        case .toast:   return 0
        case .center:  return theme.spacing.xl
        case .floater: return theme.components.popup.padding ?? theme.spacing.lg
        }
    }

    private var resolvedTransition: AnyTransition {
        let transition: DFPopupTransition = configuration.transition == .automatic
            ? (configuration.position == .center ? .scale : .slide)
            : configuration.transition
        switch transition {
        case .automatic, .slide:
            return .move(edge: configuration.position.exitEdge).combined(with: .opacity)
        case .scale:
            return .scale(scale: 0.9).combined(with: .opacity)
        case .fade:
            return .opacity
        case .none:
            return .identity
        case .asymmetric(let insert, let remove):
            return .asymmetric(
                insertion: .move(edge: insert).combined(with: .opacity),
                removal: .move(edge: remove).combined(with: .opacity)
            )
        }
    }

    private func dismiss() {
        isPresented = false
    }
}
