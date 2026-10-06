import SwiftUI

// MARK: - Value types

/// What a reserved region is for.
///
/// Mirrors SwiftUI's `ReservedRegion.Kind` (iOS/macOS/visionOS 27.1). The DF types exist on every SDK so
/// layout code can be written once; on an SDK without iPhone Duo support there are simply no regions.
public enum DFReservedRegionKind: Sendable, Hashable {
    /// A region where content should split into two separate panes, such as the fold of iPhone Duo.
    case division
    /// A region covered by hardware or system UI, such as a camera.
    case occlusion
}

/// A rectangle of the screen that content should be arranged around, in the reading view's coordinate space.
public struct DFReservedRegion: Sendable, Equatable, Identifiable {
    public let id: Int
    public let kind: DFReservedRegionKind
    public let frame: CGRect
    /// The safe margins the system asks for around the region.
    public let margins: EdgeInsets
    /// Whether the region is currently in effect (a fold that is flat, or a closed device, is inactive).
    public let isActive: Bool

    public init(
        id: Int = 0,
        kind: DFReservedRegionKind,
        frame: CGRect,
        margins: EdgeInsets = EdgeInsets(),
        isActive: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.frame = frame
        self.margins = margins
        self.isActive = isActive
    }
}

/// The reserved regions that intersect a view, with pure helpers for arranging content around them.
///
/// There is no pose enum on iPhone Duo. Fold state is expressed as geometry, so this type answers the questions
/// layouts actually ask: is there an active fold, which way does it split the screen, and where are the panes.
public struct DFReservedRegions: Sendable, Equatable {
    public let regions: [DFReservedRegion]

    public init(_ regions: [DFReservedRegion] = []) {
        self.regions = regions
    }

    /// No regions: every SDK before iPhone Duo support, and any device that never has one.
    public static let none = DFReservedRegions()

    /// Active division regions (the fold), in the order the system reported them.
    public var divisions: [DFReservedRegion] {
        regions.filter { $0.kind == .division && $0.isActive }
    }

    /// Active occlusion regions (cameras and similar), in the order the system reported them.
    public var occlusions: [DFReservedRegion] {
        regions.filter { $0.kind == .occlusion && $0.isActive }
    }

    /// The first active division, if the screen is currently split.
    public var activeDivision: DFReservedRegion? { divisions.first }

    /// Whether content should currently be split into two panes.
    public var isSplit: Bool { activeDivision != nil }

    /// The stack axis along which the two panes sit: `.horizontal` when they are side by side (the fold is a
    /// tall, thin strip), `.vertical` when they are stacked (the fold is a wide, thin strip). `nil` when not split.
    public var splitAxis: Axis? {
        guard let division = activeDivision else { return nil }
        return division.frame.height > division.frame.width ? .horizontal : .vertical
    }

    /// The two panes either side of the active division inside `bounds`, in reading order (leading or top first).
    /// The division itself belongs to neither pane. Returns `nil` when not split, or when the division does not
    /// cross `bounds`.
    public func panes(in bounds: CGRect) -> (first: CGRect, second: CGRect)? {
        guard let division = activeDivision, let axis = splitAxis else { return nil }
        let strip = division.frame.intersection(bounds)
        guard !strip.isNull, strip.width > 0, strip.height > 0 else { return nil }
        switch axis {
        case .horizontal:
            return (
                CGRect(x: bounds.minX, y: bounds.minY, width: strip.minX - bounds.minX, height: bounds.height),
                CGRect(x: strip.maxX, y: bounds.minY, width: bounds.maxX - strip.maxX, height: bounds.height)
            )
        case .vertical:
            return (
                CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: strip.minY - bounds.minY),
                CGRect(x: bounds.minX, y: strip.maxY, width: bounds.width, height: bounds.maxY - strip.maxY)
            )
        }
    }

    /// Whether `rect` overlaps any active region of the given kind (default: any kind). Use it to keep a control
    /// off the fold or out from under a camera.
    public func intersects(_ rect: CGRect, kind: DFReservedRegionKind? = nil) -> Bool {
        regions.contains { region in
            region.isActive
                && (kind == nil || region.kind == kind)
                && region.frame.intersects(rect)
        }
    }
}

// MARK: - Reader

/// Supplies the reserved regions intersecting its own bounds to its content.
///
/// ```swift
/// DFReservedRegionReader { regions in
///     if let panes = regions.panes(in: CGRect(origin: .zero, size: size)) { ... }
/// }
/// ```
///
/// On SDKs without iPhone Duo support (everything before Xcode 27.1) the content always receives
/// `DFReservedRegions.none`, so the same code builds and runs everywhere. The reader fills its container like
/// `GeometryReader`.
public struct DFReservedRegionReader<Content: View>: View {
    private let content: (DFReservedRegions) -> Content

    public init(@ViewBuilder content: @escaping (DFReservedRegions) -> Content) {
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            content(DFReservedRegionSource.regions(in: proxy))
        }
    }
}

enum DFReservedRegionSource {
    static func regions(in proxy: GeometryProxy) -> DFReservedRegions {
        #if compiler(>=6.4) && canImport(SwiftUI, _version: 8.1) && !targetEnvironment(macCatalyst)
        if #available(iOS 27.1, macOS 27.1, visionOS 27.1, *) {
            var found: [DFReservedRegion] = []
            for (kind, mapped) in [(ReservedRegion.Kind.division, DFReservedRegionKind.division),
                                   (ReservedRegion.Kind.occlusion, DFReservedRegionKind.occlusion)] {
                for region in proxy.reservedRegions(kind: kind, options: .includeInactive) {
                    found.append(DFReservedRegion(
                        id: found.count,
                        kind: mapped,
                        frame: region.frame,
                        margins: region.margins,
                        isActive: region.isActive
                    ))
                }
            }
            return DFReservedRegions(found)
        }
        #endif
        return .none
    }
}
