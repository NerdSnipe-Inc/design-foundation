import SwiftUI

// MARK: - Drag math

/// Pure gesture math, separated from the view so it can be unit tested.
enum DFPopupDrag {
    /// Points of travel toward the exit edge that commit a dismissal.
    static let dismissDistance: CGFloat = 60
    /// Sheets are taller, so they need a longer pull before committing.
    static let sheetDismissDistance: CGFloat = 100

    static func dismissDistance(for kind: DFPopupKind) -> CGFloat {
        kind == .sheet ? sheetDismissDistance : dismissDistance
    }

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

    static func shouldDismiss(
        translation: CGSize,
        predictedEnd: CGSize,
        toward edge: Edge,
        kind: DFPopupKind? = nil
    ) -> Bool {
        let distance = kind.map(dismissDistance(for:)) ?? dismissDistance
        return travel(translation, toward: edge) >= distance
            || travel(predictedEnd, toward: edge) >= distance * 2.5
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
        ZStack(alignment: configuration.resolvedPosition.alignment) {
            if isPresented {
                backdrop
                popup
            }
        }
        // Fill the host so non-center positions rest at their edge/corner, not the middle.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.resolvedPosition.alignment)
        .animation(resolvedAnimation, value: isPresented)
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
        switch configuration.resolvedBackdrop {
        case .dim:
            Color.black
                .opacity(theme.components.popup.backdropOpacity ?? 0.35)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { if configuration.dismissOnOutsideTap { dismiss() } }
                .transition(.opacity)
                .accessibilityHidden(true)
        case .blur:
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.08))
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { if configuration.dismissOnOutsideTap { dismiss() } }
                .transition(.opacity)
                .accessibilityHidden(true)
        case .none:
            if configuration.dismissOnOutsideTap {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { dismiss() }
                    .accessibilityHidden(true)
            }
        }
    }

    private var popup: some View {
        let edge = configuration.resolvedPosition.exitEdge
        return popupBody
        
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
                        toward: edge,
                        kind: configuration.kind
                    ) {
                        dismiss()
                    } else {
                        withAnimation(reduceMotion ? theme.animation.fast : theme.animation.spring) { dragOffset = .zero }
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
        .accessibilityAddTraits(configuration.resolvedBackdrop != .none ? .isModal : [])
        .accessibilityAction(.escape) { dismiss() }
        #if os(macOS)
        .focusable()
        .focusEffectDisabled()
        .onExitCommand { dismiss() }
        #endif
    }

    private var popupBody: some View {
        style.makeBody(configuration: DFPopupStyleConfiguration(
            content: AnyView(content),
            kind: configuration.kind,
            position: configuration.resolvedPosition,
            theme: theme
        ))
    }

    /// Explicit animation if given, else the theme spring. Reduce Motion swaps the spring
    /// for a short fade-friendly ease.
    private var resolvedAnimation: Animation {
        if let custom = configuration.animation { return custom }
        return reduceMotion ? theme.animation.fast : theme.animation.spring
    }

    // MARK: Layout

    private var maxWidth: CGFloat? {
        switch configuration.kind {
        case .toast, .sheet: return .infinity
        case .center:        return theme.components.popup.maxWidth ?? 420
        case .floater:       return nil
        }
    }

    private var outerPadding: CGFloat {
        switch configuration.kind {
        case .toast, .sheet: return 0
        case .center:  return theme.spacing.xl
        case .floater: return theme.components.popup.padding ?? theme.spacing.lg
        }
    }

    private var resolvedTransition: AnyTransition {
        if reduceMotion { return .opacity }
        if configuration.kind == .sheet && configuration.transition == .automatic {
            return .move(edge: .bottom)
        }
        let transition: DFPopupTransition = configuration.transition == .automatic
            ? (configuration.position == .center ? .scale : .slide)
            : configuration.transition
        switch transition {
        case .automatic, .slide:
            return .move(edge: configuration.resolvedPosition.exitEdge).combined(with: .opacity)
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
