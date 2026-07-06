import Testing
@testable import DesignFoundation

@Suite("DFDividerTokens")
struct DFDividerTokensTests {
    @Test("default has nil lineWidth")
    func defaultValues() {
        let tokens = DFDividerTokens.default
        #expect(tokens.lineWidth == nil)
    }

    @Test("overriding lineWidth changes what DFStandardDividerStyle resolves")
    func overrideChangesResolvedValue() {
        var theme = DFTheme.default
        let defaultResolved = theme.components.divider.lineWidth ?? 1
        theme.components.divider = DFDividerTokens(lineWidth: 5)
        let overriddenResolved = theme.components.divider.lineWidth ?? 1
        #expect(defaultResolved == 1)
        #expect(overriddenResolved == 5)
        #expect(overriddenResolved != defaultResolved)
    }
}

@Suite("DFProgressBarTokens")
struct DFProgressBarTokensTests {
    @Test("default has nil trackHeight")
    func defaultValues() {
        let tokens = DFProgressBarTokens.default
        #expect(tokens.trackHeight == nil)
    }

    @Test("overriding trackHeight changes what DFDefaultProgressBarStyle resolves")
    func overrideChangesResolvedValue() {
        var theme = DFTheme.default
        let defaultResolved = theme.components.progressBar.trackHeight ?? 6
        theme.components.progressBar = DFProgressBarTokens(trackHeight: 12)
        let overriddenResolved = theme.components.progressBar.trackHeight ?? 6
        #expect(defaultResolved == 6)
        #expect(overriddenResolved == 12)
        #expect(overriddenResolved != defaultResolved)
    }
}

@Suite("DFSkeletonTokens")
struct DFSkeletonTokensTests {
    @Test("default has all nil fields")
    func defaultValues() {
        let tokens = DFSkeletonTokens.default
        #expect(tokens.defaultCornerRadius == nil)
        #expect(tokens.shimmerBaseOpacity == nil)
        #expect(tokens.shimmerHighlightOpacity == nil)
        #expect(tokens.shimmerDuration == nil)
    }

    @Test("overriding defaultCornerRadius changes DFSkeleton's resolved shape radius")
    func overrideChangesCornerRadius() {
        var theme = DFTheme.default
        let defaultResolved = theme.components.skeleton.defaultCornerRadius ?? 8
        theme.components.skeleton = DFSkeletonTokens(defaultCornerRadius: 20)
        let overriddenResolved = theme.components.skeleton.defaultCornerRadius ?? 8
        #expect(defaultResolved == 8)
        #expect(overriddenResolved == 20)
        #expect(overriddenResolved != defaultResolved)
    }

    @Test("overriding shimmer opacities changes DFDefaultSkeletonStyle's resolved values")
    func overrideChangesShimmerOpacities() {
        var theme = DFTheme.default
        let defaultBase = theme.components.skeleton.shimmerBaseOpacity ?? 0.25
        let defaultHighlight = theme.components.skeleton.shimmerHighlightOpacity ?? 0.55
        theme.components.skeleton = DFSkeletonTokens(
            shimmerBaseOpacity: 0.1,
            shimmerHighlightOpacity: 0.9
        )
        let overriddenBase = theme.components.skeleton.shimmerBaseOpacity ?? 0.25
        let overriddenHighlight = theme.components.skeleton.shimmerHighlightOpacity ?? 0.55
        #expect(defaultBase == 0.25)
        #expect(defaultHighlight == 0.55)
        #expect(overriddenBase == 0.1)
        #expect(overriddenHighlight == 0.9)
    }

    @Test("overriding shimmerDuration changes DFSkeleton's resolved animation duration")
    func overrideChangesShimmerDuration() {
        var theme = DFTheme.default
        let defaultResolved = theme.components.skeleton.shimmerDuration ?? 1.4
        theme.components.skeleton = DFSkeletonTokens(shimmerDuration: 2.0)
        let overriddenResolved = theme.components.skeleton.shimmerDuration ?? 1.4
        #expect(defaultResolved == 1.4)
        #expect(overriddenResolved == 2.0)
        #expect(overriddenResolved != defaultResolved)
    }
}

@Suite("DFToggleTokens")
struct DFToggleTokensTests {
    @Test("default has nil checkboxSize")
    func defaultValues() {
        let tokens = DFToggleTokens.default
        #expect(tokens.checkboxSize == nil)
    }

    @Test("overriding checkboxSize changes what DFCheckboxToggleStyle resolves")
    func overrideChangesResolvedValue() {
        var theme = DFTheme.default
        let defaultResolved = theme.components.toggle.checkboxSize ?? 20
        theme.components.toggle = DFToggleTokens(checkboxSize: 28)
        let overriddenResolved = theme.components.toggle.checkboxSize ?? 20
        #expect(defaultResolved == 20)
        #expect(overriddenResolved == 28)
        #expect(overriddenResolved != defaultResolved)
    }
}

@Suite("DFDatePickerTokens")
struct DFDatePickerTokensTests {
    @Test("default has nil fields")
    func defaultValues() {
        let tokens = DFDatePickerTokens.default
        #expect(tokens.horizontalPadding == nil)
        #expect(tokens.verticalPadding == nil)
    }

    @Test("overriding padding changes what DFCompactDatePickerStyle resolves")
    func overrideChangesResolvedValue() {
        var theme = DFTheme.default
        let defaultHorizontal = theme.components.datePicker.horizontalPadding ?? theme.spacing.md
        let defaultVertical = theme.components.datePicker.verticalPadding ?? theme.spacing.sm
        theme.components.datePicker = DFDatePickerTokens(horizontalPadding: 30, verticalPadding: 2)
        let overriddenHorizontal = theme.components.datePicker.horizontalPadding ?? theme.spacing.md
        let overriddenVertical = theme.components.datePicker.verticalPadding ?? theme.spacing.sm
        #expect(defaultHorizontal == theme.spacing.md)
        #expect(defaultVertical == theme.spacing.sm)
        #expect(overriddenHorizontal == 30)
        #expect(overriddenVertical == 2)
        #expect(overriddenHorizontal != defaultHorizontal)
        #expect(overriddenVertical != defaultVertical)
    }
}

@Suite("DFSidebarTokens")
struct DFSidebarTokensTests {
    @Test("default has nil fields")
    func defaultValues() {
        let tokens = DFSidebarTokens.default
        #expect(tokens.itemCornerRadius == nil)
        #expect(tokens.iconSize == nil)
    }

    @Test("overriding itemCornerRadius changes what DFStandardSidebarStyle resolves")
    func overrideChangesCornerRadius() {
        var theme = DFTheme.default
        let defaultResolved = theme.components.sidebar.itemCornerRadius ?? theme.radius.md
        theme.components.sidebar = DFSidebarTokens(itemCornerRadius: 2)
        let overriddenResolved = theme.components.sidebar.itemCornerRadius ?? theme.radius.md
        #expect(defaultResolved == theme.radius.md)
        #expect(overriddenResolved == 2)
        #expect(overriddenResolved != defaultResolved)
    }

    @Test("overriding iconSize changes what sidebar item styles resolve")
    func overrideChangesIconSize() {
        var theme = DFTheme.default
        let defaultResolved = theme.components.sidebar.iconSize ?? 16
        theme.components.sidebar = DFSidebarTokens(iconSize: 24)
        let overriddenResolved = theme.components.sidebar.iconSize ?? 16
        #expect(defaultResolved == 16)
        #expect(overriddenResolved == 24)
        #expect(overriddenResolved != defaultResolved)
    }
}

@Suite("DFTabBarTokens")
struct DFTabBarTokensTests {
    @Test("default has nil iconSize")
    func defaultValues() {
        let tokens = DFTabBarTokens.default
        #expect(tokens.iconSize == nil)
    }

    @Test("overriding iconSize changes what standard/minimal tab bar styles resolve")
    func overrideChangesResolvedValue() {
        var theme = DFTheme.default
        let defaultStandardResolved = theme.components.tabBar.iconSize ?? 22
        let defaultMinimalResolved = theme.components.tabBar.iconSize ?? 24
        theme.components.tabBar = DFTabBarTokens(iconSize: 30)
        let overriddenStandardResolved = theme.components.tabBar.iconSize ?? 22
        let overriddenMinimalResolved = theme.components.tabBar.iconSize ?? 24
        #expect(defaultStandardResolved == 22)
        #expect(defaultMinimalResolved == 24)
        #expect(overriddenStandardResolved == 30)
        #expect(overriddenMinimalResolved == 30)
        #expect(overriddenStandardResolved != defaultStandardResolved)
        #expect(overriddenMinimalResolved != defaultMinimalResolved)
    }
}

@Suite("DFComponentTokens root")
struct DFComponentTokensRootTests {
    @Test("default root has default sub-tokens for all new components")
    func defaultRootHasDefaultSubTokens() {
        let tokens = DFComponentTokens.default
        #expect(tokens.divider.lineWidth == nil)
        #expect(tokens.progressBar.trackHeight == nil)
        #expect(tokens.skeleton.defaultCornerRadius == nil)
        #expect(tokens.toggle.checkboxSize == nil)
        #expect(tokens.datePicker.horizontalPadding == nil)
        #expect(tokens.sidebar.itemCornerRadius == nil)
        #expect(tokens.tabBar.iconSize == nil)
    }

    @Test("root init accepts all new component token structs")
    func rootInitAcceptsNewTokens() {
        let tokens = DFComponentTokens(
            divider: DFDividerTokens(lineWidth: 3),
            progressBar: DFProgressBarTokens(trackHeight: 10),
            skeleton: DFSkeletonTokens(defaultCornerRadius: 4),
            toggle: DFToggleTokens(checkboxSize: 24),
            datePicker: DFDatePickerTokens(horizontalPadding: 10, verticalPadding: 4),
            sidebar: DFSidebarTokens(itemCornerRadius: 6, iconSize: 18),
            tabBar: DFTabBarTokens(iconSize: 20)
        )
        #expect(tokens.divider.lineWidth == 3)
        #expect(tokens.progressBar.trackHeight == 10)
        #expect(tokens.skeleton.defaultCornerRadius == 4)
        #expect(tokens.toggle.checkboxSize == 24)
        #expect(tokens.datePicker.horizontalPadding == 10)
        #expect(tokens.datePicker.verticalPadding == 4)
        #expect(tokens.sidebar.itemCornerRadius == 6)
        #expect(tokens.sidebar.iconSize == 18)
        #expect(tokens.tabBar.iconSize == 20)
    }
}
