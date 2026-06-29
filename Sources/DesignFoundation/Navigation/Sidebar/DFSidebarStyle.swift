import SwiftUI

// MARK: - Configuration
// IS Sendable: holds only DFSidebarItem (Sendable), Bool, and DFTheme (Sendable).

public struct DFSidebarItemStyleConfiguration: Sendable {
    public let item: DFSidebarItem
    public let isSelected: Bool
    public let isEnabled: Bool
    public let theme: DFTheme

    public init(item: DFSidebarItem, isSelected: Bool, isEnabled: Bool, theme: DFTheme) {
        self.item = item
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.theme = theme
    }
}

// MARK: - Protocol

/// Style controls how each sidebar item row is rendered. The sidebar's overall chrome
/// (background, section headers, scroll view) is always rendered by DFSidebar itself.
public protocol DFSidebarStyle {
    associatedtype Body: View
    @ViewBuilder func makeItemBody(configuration: DFSidebarItemStyleConfiguration) -> Body
    func sidebarBackground(theme: DFTheme) -> AnyView
}

public extension DFSidebarStyle {
    func sidebarBackground(theme: DFTheme) -> AnyView {
        AnyView(theme.colors.surface)
    }
}

// MARK: - Type Erasure

public struct AnyDFSidebarStyle: DFSidebarStyle, @unchecked Sendable {
    private let _makeItemBody: (DFSidebarItemStyleConfiguration) -> AnyView
    private let _sidebarBackground: (DFTheme) -> AnyView

    public init<S: DFSidebarStyle & Sendable>(_ style: S) {
        _makeItemBody = { AnyView(style.makeItemBody(configuration: $0)) }
        _sidebarBackground = { style.sidebarBackground(theme: $0) }
    }

    public func makeItemBody(configuration: DFSidebarItemStyleConfiguration) -> some View {
        _makeItemBody(configuration)
    }

    public func sidebarBackground(theme: DFTheme) -> AnyView {
        _sidebarBackground(theme)
    }
}

// MARK: - Environment

private struct DFSidebarStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFSidebarStyle = AnyDFSidebarStyle(DFStandardSidebarStyle())
}

public extension EnvironmentValues {
    var dfSidebarStyle: AnyDFSidebarStyle {
        get { self[DFSidebarStyleKey.self] }
        set { self[DFSidebarStyleKey.self] = newValue }
    }
}

public extension View {
    func dfSidebarStyle<S: DFSidebarStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfSidebarStyle, AnyDFSidebarStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFSidebarStyle where Self == DFStandardSidebarStyle {
    static var standard: DFStandardSidebarStyle { DFStandardSidebarStyle() }
}
public extension DFSidebarStyle where Self == DFPlainSidebarStyle {
    static var plain: DFPlainSidebarStyle { DFPlainSidebarStyle() }
}

// MARK: - Built-in: Standard (default)

/// Item rows with a filled rounded-rect background on selection.
public struct DFStandardSidebarStyle: DFSidebarStyle, Sendable {
    public init() {}

    public func makeItemBody(configuration: DFSidebarItemStyleConfiguration) -> some View {
        let theme = configuration.theme
        HStack(spacing: theme.spacing.sm) {
            if let icon = configuration.item.icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(
                        configuration.isSelected ? theme.colors.primary : theme.colors.textSecondary
                    )
                    .frame(width: 20)
            }
            Text(configuration.item.label)
                .font(theme.typography.label.font)
                .foregroundStyle(
                    configuration.isSelected ? theme.colors.primary : theme.colors.textPrimary
                )
            Spacer()
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .fill(configuration.isSelected ? theme.colors.primary.opacity(0.12) : Color.clear)
        )
        .opacity(configuration.isEnabled ? 1.0 : 0.5)
        .contentShape(Rectangle())
    }
}

// MARK: - Built-in: Plain

/// Item rows without a background highlight — selection indicated by color and weight only.
public struct DFPlainSidebarStyle: DFSidebarStyle, Sendable {
    public init() {}

    public func makeItemBody(configuration: DFSidebarItemStyleConfiguration) -> some View {
        let theme = configuration.theme
        HStack(spacing: theme.spacing.sm) {
            if let icon = configuration.item.icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(
                        configuration.isSelected ? theme.colors.primary : theme.colors.textSecondary
                    )
                    .frame(width: 20)
            }
            Text(configuration.item.label)
                .font(theme.typography.label.font)
                .fontWeight(configuration.isSelected ? .semibold : .regular)
                .foregroundStyle(
                    configuration.isSelected ? theme.colors.primary : theme.colors.textPrimary
                )
            Spacer()
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .opacity(configuration.isEnabled ? 1.0 : 0.5)
        .contentShape(Rectangle())
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFSidebarStyle where Self == DFGlassSidebarStyle {
    static var glass: DFGlassSidebarStyle { DFGlassSidebarStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

@available(iOS 26, macOS 26, *)
public struct DFGlassSidebarStyle: DFSidebarStyle, Sendable {
    public init() {}

    public func sidebarBackground(theme: DFTheme) -> AnyView {
        AnyView(Color.clear)
    }

    public func makeItemBody(configuration: DFSidebarItemStyleConfiguration) -> some View {
        let theme = configuration.theme
        HStack(spacing: theme.spacing.sm) {
            if let icon = configuration.item.icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(
                        configuration.isSelected ? theme.colors.primary : theme.colors.textSecondary
                    )
                    .frame(width: 20)
            }
            Text(configuration.item.label)
                .font(theme.typography.label.font)
                .foregroundStyle(
                    configuration.isSelected ? theme.colors.primary : theme.colors.textPrimary
                )
            Spacer()
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background {
            if configuration.isSelected {
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.md)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
            }
        }
        .opacity(configuration.isEnabled ? 1.0 : 0.5)
        .contentShape(Rectangle())
    }
}
