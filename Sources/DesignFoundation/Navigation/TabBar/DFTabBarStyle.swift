import SwiftUI

// MARK: - Supporting types

public struct DFTabItem: Identifiable, Sendable {
    public let id: String
    public let icon: String
    public let label: String
    public let badgeCount: Int?
    public let showDot: Bool

    public init(
        id: String,
        icon: String,
        label: String,
        badgeCount: Int? = nil,
        showDot: Bool = false
    ) {
        self.id = id
        self.icon = icon
        self.label = label
        self.badgeCount = badgeCount
        self.showDot = showDot
    }
}

// MARK: - Configuration

public struct DFTabBarStyleConfiguration: Sendable {
    public let items: [DFTabItem]
    public let selectedID: String
    public let onSelect: @MainActor (String) -> Void
    public let theme: DFTheme

    public init(items: [DFTabItem], selectedID: String, onSelect: @escaping @MainActor (String) -> Void, theme: DFTheme) {
        self.items = items
        self.selectedID = selectedID
        self.onSelect = onSelect
        self.theme = theme
    }
}

// MARK: - Protocol

@MainActor
public protocol DFTabBarStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFTabBarStyleConfiguration) -> Body
}

// MARK: - Type Erasure

/// Type-erased container for DFTabBarStyle. Uses @unchecked Sendable because
/// _makeBody is a non-Sendable closure (holds MainActor-isolated state).
/// Sendable conformance is safe: only called from @MainActor contexts.
public struct AnyDFTabBarStyle: DFTabBarStyle, @unchecked Sendable {
    private let _makeBody: @MainActor (DFTabBarStyleConfiguration) -> AnyView

    nonisolated public init<S: DFTabBarStyle & Sendable>(_ style: S) {
        _makeBody = { @MainActor configuration in AnyView(style.makeBody(configuration: configuration)) }
    }

    public func makeBody(configuration: DFTabBarStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

private struct DFTabBarStyleKey: EnvironmentKey {
    nonisolated static let defaultValue: AnyDFTabBarStyle = AnyDFTabBarStyle(DFStandardTabBarStyle())
}

// MARK: - Environment

public extension EnvironmentValues {
    var dfTabBarStyle: AnyDFTabBarStyle {
        get { self[DFTabBarStyleKey.self] }
        set { self[DFTabBarStyleKey.self] = newValue }
    }
}

public extension View {
    func dfTabBarStyle<S: DFTabBarStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfTabBarStyle, AnyDFTabBarStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFTabBarStyle where Self == DFStandardTabBarStyle {
    static var standard: DFStandardTabBarStyle { DFStandardTabBarStyle() }
}
public extension DFTabBarStyle where Self == DFMinimalTabBarStyle {
    static var minimal: DFMinimalTabBarStyle { DFMinimalTabBarStyle() }
}

// MARK: - Shared badge overlay builder (private)

private struct DFTabBadgeOverlay: View {
    let item: DFTabItem
    let destructiveColor: Color

    var body: some View {
        if item.showDot {
            Circle()
                .fill(destructiveColor)
                .frame(width: 8, height: 8)
                .offset(x: 4, y: -4)
        } else if let count = item.badgeCount, count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Capsule().fill(destructiveColor))
                .offset(x: 10, y: -8)
        }
    }
}

// MARK: - Shared button builders (private)

@MainActor private func makeStandardTabBarButton(
    item: DFTabItem,
    isSelected: Bool,
    theme: DFTheme,
    onSelect: @escaping @MainActor (String) -> Void
) -> some View {
    return Button {
        onSelect(item.id)
    } label: {
        VStack(spacing: 2) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: item.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(
                        isSelected ? theme.colors.primary : theme.colors.textSecondary
                    )
                DFTabBadgeOverlay(item: item, destructiveColor: theme.colors.destructive)
            }
            Text(item.label)
                .font(theme.typography.caption.font)
                .foregroundStyle(
                    isSelected ? theme.colors.primary : theme.colors.textSecondary
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.sm)
    }
    .buttonStyle(PlainButtonStyle())
    .accessibilityLabel(item.label)
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
}

@MainActor private func makeMinimalTabBarButton(
    item: DFTabItem,
    isSelected: Bool,
    theme: DFTheme,
    onSelect: @escaping @MainActor (String) -> Void
) -> some View {
    Button {
        onSelect(item.id)
    } label: {
        ZStack(alignment: .topTrailing) {
            Image(systemName: item.icon)
                .font(.system(size: 24))
                .foregroundStyle(
                    isSelected ? theme.colors.primary : theme.colors.textSecondary
                )
            DFTabBadgeOverlay(item: item, destructiveColor: theme.colors.destructive)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.md)
    }
    .buttonStyle(PlainButtonStyle())
    .accessibilityLabel(item.label)
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
}

// MARK: - Built-in: Standard (default)

/// Tab bar with icons and labels. Displays badge counts and dot badges.
@MainActor
public struct DFStandardTabBarStyle: DFTabBarStyle, Sendable {
    nonisolated public init() {}

    public func makeBody(configuration: DFTabBarStyleConfiguration) -> some View {
        let theme = configuration.theme
        let items = configuration.items
        let selectedID = configuration.selectedID
        let onSelect = configuration.onSelect

        return VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(items) { item in
                    let isSelected = item.id == selectedID
                    makeStandardTabBarButton(
                        item: item,
                        isSelected: isSelected,
                        theme: theme,
                        onSelect: onSelect
                    )
                }
            }
            .background(theme.colors.surface)
        }
    }
}

// MARK: - Built-in: Minimal

/// Tab bar with icons only — no labels. Suitable for space-constrained layouts.
@MainActor
public struct DFMinimalTabBarStyle: DFTabBarStyle, Sendable {
    nonisolated public init() {}

    public func makeBody(configuration: DFTabBarStyleConfiguration) -> some View {
        let theme = configuration.theme
        let items = configuration.items
        let selectedID = configuration.selectedID
        let onSelect = configuration.onSelect

        return VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(items) { item in
                    let isSelected = item.id == selectedID
                    makeMinimalTabBarButton(
                        item: item,
                        isSelected: isSelected,
                        theme: theme,
                        onSelect: onSelect
                    )
                }
            }
            .background(theme.colors.surface)
        }
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFTabBarStyle where Self == DFGlassTabBarStyle {
    static var glass: DFGlassTabBarStyle { DFGlassTabBarStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

@available(iOS 26, macOS 26, *)
@MainActor
public struct DFGlassTabBarStyle: DFTabBarStyle, Sendable {
    nonisolated public init() {}

    public func makeBody(configuration: DFTabBarStyleConfiguration) -> some View {
        let theme = configuration.theme
        let items = configuration.items
        let selectedID = configuration.selectedID
        let onSelect = configuration.onSelect

        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(items) { item in
                    let isSelected = item.id == selectedID
                    Button {
                        onSelect(item.id)
                    } label: {
                        VStack(spacing: 2) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 22))
                                    .foregroundStyle(
                                        isSelected ? theme.colors.primary : theme.colors.textSecondary
                                    )
                                DFTabBadgeOverlay(item: item, destructiveColor: theme.colors.destructive)
                            }
                            Text(item.label)
                                .font(theme.typography.caption.font)
                                .foregroundStyle(
                                    isSelected ? theme.colors.primary : theme.colors.textSecondary
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.sm)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(item.label)
                    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                }
            }
            .background(.regularMaterial)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 0.5)
            }
        }
    }
}
