import SwiftUI

/// How `DFArrangement` places its two views.
public enum DFArrangementKind: Sendable, Hashable {
    /// Let the system decide. Currently resolves to `.split`.
    case automatic
    /// Primary and secondary side by side when the space is wider than tall, stacked when taller than wide.
    /// `axes` limits which of the two arrangements may be used (default: both).
    case split(axes: Axis.Set = [.horizontal, .vertical])
    /// Primary layered over secondary. When the screen is partially folded, primary goes in the trailing or bottom
    /// part and secondary in the leading or top part.
    case overlay
}

/// A two-pane layout that follows the device: side by side, stacked, or layered, and fold-aware on iPhone Duo.
///
/// ```swift
/// DFArrangement {
///     InboxList()
/// } secondary: {
///     MessageDetail()
/// }
///
/// DFArrangement(.split(axes: .horizontal)) { List() } secondary: { Detail() }
/// ```
///
/// On Xcode 27.1 and later (iOS, macOS and visionOS 27.1) this is SwiftUI's `ArrangementView`, so it divides around
/// the fold of iPhone Duo. On every other SDK, and on OS versions before 27.1, it is a plain stack that picks its
/// orientation from the available space, with the same `.split` rule. Do not place it inside a navigation split
/// view, list or scroll view. For a fold-aware `NavigationSplitView` use the system container.
public struct DFArrangement<Primary: View, Secondary: View>: View {
    private let kind: DFArrangementKind
    private let primary: Primary
    private let secondary: Secondary

    public init(
        _ kind: DFArrangementKind = .automatic,
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary
    ) {
        self.kind = kind
        self.primary = primary()
        self.secondary = secondary()
    }

    public var body: some View {
        #if compiler(>=6.4) && canImport(SwiftUI, _version: 8.1) && !targetEnvironment(macCatalyst)
        if #available(iOS 27.1, macOS 27.1, visionOS 27.1, *) {
            DFNativeArrangement(kind: kind, primary: primary, secondary: secondary)
        } else {
            DFStackArrangement(kind: kind, primary: primary, secondary: secondary)
        }
        #else
        DFStackArrangement(kind: kind, primary: primary, secondary: secondary)
        #endif
    }
}

// MARK: - Pure rules (shared by the fallback and covered by tests)

enum DFArrangementRules {
    /// The stack axis the fallback uses for a `.split` arrangement in a space of the given size.
    /// Wider than tall: side by side (`.horizontal`). Otherwise stacked (`.vertical`). A single allowed axis wins.
    static func splitAxis(for size: CGSize, axes: Axis.Set) -> Axis {
        let allowsHorizontal = axes.contains(.horizontal)
        let allowsVertical = axes.contains(.vertical)
        if allowsHorizontal && !allowsVertical { return .horizontal }
        if allowsVertical && !allowsHorizontal { return .vertical }
        return size.width > size.height ? .horizontal : .vertical
    }

    /// The axes a kind allows. `.overlay` allows none (it does not divide).
    static func axes(for kind: DFArrangementKind) -> Axis.Set {
        switch kind {
        case .automatic: return [.horizontal, .vertical]
        case .split(let axes): return axes
        case .overlay: return []
        }
    }
}

// MARK: - Fallback

struct DFStackArrangement<Primary: View, Secondary: View>: View {
    let kind: DFArrangementKind
    let primary: Primary
    let secondary: Secondary

    var body: some View {
        switch kind {
        case .overlay:
            ZStack {
                secondary.frame(maxWidth: .infinity, maxHeight: .infinity)
                primary.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .automatic, .split:
            GeometryReader { proxy in
                let axes = DFArrangementRules.axes(for: kind)
                switch DFArrangementRules.splitAxis(for: proxy.size, axes: axes) {
                case .horizontal:
                    HStack(spacing: 0) {
                        primary.frame(maxWidth: .infinity, maxHeight: .infinity)
                        secondary.frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                case .vertical:
                    VStack(spacing: 0) {
                        primary.frame(maxWidth: .infinity, maxHeight: .infinity)
                        secondary.frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Native (iPhone Duo SDK)

#if compiler(>=6.4) && canImport(SwiftUI, _version: 8.1) && !targetEnvironment(macCatalyst)
@available(iOS 27.1, macOS 27.1, visionOS 27.1, *)
struct DFNativeArrangement<Primary: View, Secondary: View>: View {
    let kind: DFArrangementKind
    let primary: Primary
    let secondary: Secondary

    var body: some View {
        switch kind {
        case .automatic:
            ArrangementView(primary: { primary }, secondary: { secondary })
        case .split(let axes):
            ArrangementView(primary: { primary }, secondary: { secondary })
                .arrangementViewStyle(.split.axes(axes))
        case .overlay:
            ArrangementView(primary: { primary }, secondary: { secondary })
                .arrangementViewStyle(.overlay)
        }
    }
}
#endif
