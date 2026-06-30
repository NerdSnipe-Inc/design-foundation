#if DEBUG
import SwiftUI

// MARK: - Showcase view

/// A realistic UI panel exercising the tokens that actually differ between themes:
/// primary (avatar, buttons), surface (card background), border (text field),
/// and corner radius.
private struct ThemeShowcase: View {
    @State private var email = "you@example.com"
    @Environment(\.dfTheme) private var theme

    var body: some View {
        VStack(spacing: 10) {
            DFCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        DFAvatar("MB", presence: .online)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Maya Brown").font(.headline)
                            Text("Product team").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        DFBadge(text: "Pro")
                    }

                    DFTextField("Email", text: $email, placeholder: "you@example.com")
                        .dfTextFieldStyle(.outlined)

                    HStack(spacing: 8) {
                        DFButton("Continue") {}.dfButtonStyle(.filled)
                        DFButton("Cancel") {}.dfButtonStyle(.ghost)
                    }
                }
            }

            HStack(spacing: 8) {
                DFBadge(text: "Active").dfBadgeStyle(.tinted)
                DFBadge(text: "Pending").dfBadgeStyle(.outlined)
                DFBadge(text: "Done").dfBadgeStyle(.filled)
                Spacer()
            }
            .padding(.horizontal, 4)
        }
        .padding()
        // Theme's own background fills the space around the card,
        // so light variants look light and dark variants look dark.
        .background(theme.colors.background)
    }
}

// MARK: - Column helper

private struct PresetColumn: View {
    let label: String
    let theme: DFTheme
    let scheme: ColorScheme

    var body: some View {
        VStack(spacing: 0) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            ThemeShowcase()
                .dfTheme(theme)
                .environment(\.colorScheme, scheme)
                .frame(width: 280)
        }
    }
}

// MARK: - Previews

#Preview("Default theme — light and dark") {
    HStack(spacing: 0) {
        ThemeShowcase()
            .environment(\.colorScheme, .light)
            .frame(maxWidth: .infinity)
        Divider()
        ThemeShowcase()
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
    }
}

#Preview("Slate — light and dark") {
    HStack(spacing: 0) {
        ThemeShowcase()
            .dfTheme(.slateLight)
            .environment(\.colorScheme, .light)
            .frame(maxWidth: .infinity)
        Divider()
        ThemeShowcase()
            .dfTheme(.slateDark)
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
    }
}

#Preview("Aurora — light and dark") {
    HStack(spacing: 0) {
        ThemeShowcase()
            .dfTheme(.auroraLight)
            .environment(\.colorScheme, .light)
            .frame(maxWidth: .infinity)
        Divider()
        ThemeShowcase()
            .dfTheme(.auroraDark)
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
    }
}

#Preview("Copper — light and dark") {
    HStack(spacing: 0) {
        ThemeShowcase()
            .dfTheme(.copperLight)
            .environment(\.colorScheme, .light)
            .frame(maxWidth: .infinity)
        Divider()
        ThemeShowcase()
            .dfTheme(.copperDark)
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
    }
}

#Preview("Sage — light and dark") {
    HStack(spacing: 0) {
        ThemeShowcase()
            .dfTheme(.sageLight)
            .environment(\.colorScheme, .light)
            .frame(maxWidth: .infinity)
        Divider()
        ThemeShowcase()
            .dfTheme(.sageDark)
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
    }
}

#Preview("All presets — light") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 0) {
            PresetColumn(label: "Default",    theme: .default,     scheme: .light)
            Divider()
            PresetColumn(label: "Slate",      theme: .slateLight,  scheme: .light)
            Divider()
            PresetColumn(label: "Aurora",     theme: .auroraLight, scheme: .light)
            Divider()
            PresetColumn(label: "Copper",     theme: .copperLight, scheme: .light)
            Divider()
            PresetColumn(label: "Sage",       theme: .sageLight,   scheme: .light)
        }
    }
}

#Preview("All presets — dark") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 0) {
            PresetColumn(label: "Default",    theme: .default,    scheme: .dark)
            Divider()
            PresetColumn(label: "Slate",      theme: .slateDark,  scheme: .dark)
            Divider()
            PresetColumn(label: "Aurora",     theme: .auroraDark, scheme: .dark)
            Divider()
            PresetColumn(label: "Copper",     theme: .copperDark, scheme: .dark)
            Divider()
            PresetColumn(label: "Sage",       theme: .sageDark,   scheme: .dark)
        }
    }
}

#endif
