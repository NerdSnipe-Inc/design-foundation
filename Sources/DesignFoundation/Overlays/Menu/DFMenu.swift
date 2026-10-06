import SwiftUI

// MARK: - DFMenu

/// A themed menu: a trigger button that opens a popover-style list of sections and items.
///
/// Built on `.dfPopover`, so it works on iOS, macOS and visionOS. On iPhone the popover is pinned
/// to popover presentation (`presentationCompactAdaptation(.popover)`) rather than adapting to a
/// sheet. Style it with `.dfMenuStyle(_:)`; the trigger follows the environment `dfButtonStyle`.
///
/// Items are buttons: a selected item exposes the "Selected" value and trait, a destructive item
/// announces "Destructive action", rows are at least 44pt tall on iOS, and Escape dismisses.
public struct DFMenu: View {
    private let title: String
    private let systemImage: String?
    private let sections: [DFMenuSection]

    @State private var isPresented = false
    @Environment(\.dfTheme) private var theme
    @Environment(\.dfMenuStyle) private var style

    public init(_ title: String, systemImage: String? = nil, sections: [DFMenuSection]) {
        self.title = title
        self.systemImage = systemImage
        self.sections = sections
    }

    public var body: some View {
        trigger
            .dfPopover(isPresented: $isPresented, arrowEdge: .top) { panel }
            // Style sits outside `.dfPopover` so the popover reads it. The menu style draws the
            // panel itself, so the generic popover surface is replaced with a pass-through.
            .dfPopoverStyle(DFMenuPassthroughPopoverStyle())
    }

    @ViewBuilder
    private var trigger: some View {
        if let systemImage {
            Button {
                isPresented.toggle()
            } label: {
                Label(title, systemImage: systemImage)
            }
            .buttonStyle(.df(.filled))
        } else {
            DFButton(title) { isPresented.toggle() }
        }
    }

    private var panel: some View {
        style.makeBody(configuration: DFMenuStyleConfiguration(
            content: AnyView(DFMenuList(
                sections: DFMenuLogic.visibleSections(sections),
                theme: theme,
                onActivate: { item in activate(item) }
            )),
            theme: theme
        ))
        .presentationCompactAdaptation(.popover)
        .onKeyPress(.escape) {
            isPresented = false
            return .handled
        }
        .accessibilityAction(.escape) { isPresented = false }
    }

    private func activate(_ item: DFMenuItem) {
        guard DFMenuLogic.isActionable(item) else { return }
        isPresented = false
        DFMenuLogic.activate(item)
    }
}

// MARK: - Popover surface pass-through

private struct DFMenuPassthroughPopoverStyle: DFPopoverStyle, Sendable {
    func makeBody(configuration: DFPopoverStyleConfiguration) -> some View {
        configuration.content
    }
}

// MARK: - List

private struct DFMenuList: View {
    let sections: [DFMenuSection]
    let theme: DFTheme
    let onActivate: (DFMenuItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                if index > 0 {
                    DFDivider()
                }
                if let title = section.title {
                    Text(title)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.textSecondary)
                        .padding(.horizontal, theme.spacing.md)
                        .padding(.top, theme.spacing.sm)
                        .padding(.bottom, theme.spacing.xs)
                        .accessibilityAddTraits(.isHeader)
                }
                ForEach(Array(section.items.enumerated()), id: \.offset) { _, item in
                    DFMenuRow(item: item, theme: theme, onActivate: onActivate)
                }
            }
        }
    }
}

// MARK: - Row

private struct DFMenuRow: View {
    let item: DFMenuItem
    let theme: DFTheme
    let onActivate: (DFMenuItem) -> Void

    private var foreground: Color {
        if item.isDisabled { return theme.colors.textDisabled }
        if item.role == .destructive { return theme.colors.destructive }
        return theme.colors.textPrimary
    }

    var body: some View {
        Button {
            onActivate(item)
        } label: {
            HStack(spacing: theme.spacing.md) {
                if let systemImage = item.systemImage {
                    Image(systemName: systemImage)
                        .frame(width: 20)
                        .accessibilityHidden(true)
                }
                Text(item.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if item.isSelected {
                    Image(systemName: "checkmark")
                        .accessibilityHidden(true)
                }
            }
            .font(theme.typography.body.font)
            .foregroundStyle(foreground)
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .dfMinimumTouchHeight()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(item.isDisabled)
        .accessibilityValue(DFMenuLogic.accessibilityValue(for: item))
        .accessibilityHint(DFMenuLogic.accessibilityHint(for: item))
        .accessibilityAddTraits(item.isSelected ? .isSelected : [])
    }
}

// MARK: - Context menu

private struct DFContextMenuContent: View {
    let sections: [DFMenuSection]

    var body: some View {
        ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
            if let title = section.title {
                Section(title) {
                    DFContextMenuItems(items: section.items)
                }
            } else {
                Section {
                    DFContextMenuItems(items: section.items)
                }
            }
        }
    }
}

private struct DFContextMenuItems: View {
    let items: [DFMenuItem]

    var body: some View {
        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
            Button(role: item.role?.buttonRole) {
                item.action?()
            } label: {
                if item.isSelected {
                    Label(item.title, systemImage: "checkmark")
                } else if let systemImage = item.systemImage {
                    Label(item.title, systemImage: systemImage)
                } else {
                    Text(item.title)
                }
            }
            .disabled(item.isDisabled)
        }
    }
}

public extension View {
    /// Attaches a native context menu built from DF menu sections.
    ///
    /// Native context menus are drawn by the system and cannot be themed, so `.dfMenuStyle` and the
    /// theme do not apply here. A selected item shows a checkmark in place of its own icon.
    func dfContextMenu(sections: [DFMenuSection]) -> some View {
        contextMenu {
            DFContextMenuContent(sections: DFMenuLogic.visibleSections(sections))
        }
    }
}
