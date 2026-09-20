import SwiftUI

// MARK: - Position

/// Where a popup rests inside its host view.
public enum DFPopupPosition: Sendable, CaseIterable {
    case topLeading, top, topTrailing
    case leading, center, trailing
    case bottomLeading, bottom, bottomTrailing

    public var alignment: Alignment {
        switch self {
        case .topLeading:     return .topLeading
        case .top:            return .top
        case .topTrailing:    return .topTrailing
        case .leading:        return .leading
        case .center:         return .center
        case .trailing:       return .trailing
        case .bottomLeading:  return .bottomLeading
        case .bottom:         return .bottom
        case .bottomTrailing: return .bottomTrailing
        }
    }

    /// The screen edge a popup at this position enters from and exits toward.
    /// `.center` has no natural edge and uses the bottom.
    public var exitEdge: Edge {
        switch self {
        case .topLeading, .top, .topTrailing:          return .top
        case .leading:                                 return .leading
        case .trailing:                                return .trailing
        case .bottomLeading, .bottom, .bottomTrailing,
             .center:                                  return .bottom
        }
    }
}

// MARK: - Kind

/// The shape of a popup's surface and how it relates to the screen edges.
public enum DFPopupKind: Sendable {
    /// A width-limited card, inset from the edges.
    case center
    /// Full-width and flush with the edge, extending under the safe area.
    case toast
    /// Inset from the edges by the popup padding token, with rounded corners.
    case floater
}

// MARK: - Transition

public enum DFPopupTransition: Sendable, Equatable {
    /// Scale for `.center`, slide for every other position.
    case automatic
    case slide
    case scale
    case fade
    case none
    /// Enters from one edge and leaves toward another.
    case asymmetric(insert: Edge, remove: Edge)
}

// MARK: - Configuration

/// Behavior of a presented popup. Plain value, safe to share and store.
public struct DFPopupConfiguration: Sendable, Equatable {
    public var kind: DFPopupKind
    public var position: DFPopupPosition
    public var transition: DFPopupTransition
    /// Overrides the theme's default animation for presenting and dismissing. nil = theme.
    public var animation: Animation?
    /// Seconds before the popup dismisses itself. nil = stays until dismissed.
    public var autoDismissAfter: TimeInterval?
    public var dismissOnTap: Bool
    public var dismissOnOutsideTap: Bool
    public var dismissOnDrag: Bool
    /// Dims the host behind the popup and blocks touches to it.
    public var dimsBackground: Bool

    public init(
        kind: DFPopupKind = .center,
        position: DFPopupPosition = .center,
        transition: DFPopupTransition = .automatic,
        animation: Animation? = nil,
        autoDismissAfter: TimeInterval? = nil,
        dismissOnTap: Bool = false,
        dismissOnOutsideTap: Bool = true,
        dismissOnDrag: Bool = false,
        dimsBackground: Bool = true
    ) {
        self.kind = kind
        self.position = position
        self.transition = transition
        self.animation = animation
        self.autoDismissAfter = autoDismissAfter
        self.dismissOnTap = dismissOnTap
        self.dismissOnOutsideTap = dismissOnOutsideTap
        self.dismissOnDrag = dismissOnDrag
        self.dimsBackground = dimsBackground
    }

    public static let centered = DFPopupConfiguration()

    /// Flush, full-width, no backdrop, touches pass through to the host.
    public static func toast(
        position: DFPopupPosition = .top,
        autoDismissAfter: TimeInterval? = 3,
        dismissOnDrag: Bool = true
    ) -> DFPopupConfiguration {
        DFPopupConfiguration(
            kind: .toast,
            position: position,
            autoDismissAfter: autoDismissAfter,
            dismissOnTap: true,
            dismissOnOutsideTap: false,
            dismissOnDrag: dismissOnDrag,
            dimsBackground: false
        )
    }

    /// Inset rounded card, no backdrop, touches pass through to the host.
    public static func floater(
        position: DFPopupPosition = .bottom,
        autoDismissAfter: TimeInterval? = nil,
        dismissOnDrag: Bool = true
    ) -> DFPopupConfiguration {
        DFPopupConfiguration(
            kind: .floater,
            position: position,
            autoDismissAfter: autoDismissAfter,
            dismissOnTap: false,
            dismissOnOutsideTap: false,
            dismissOnDrag: dismissOnDrag,
            dimsBackground: false
        )
    }
}
