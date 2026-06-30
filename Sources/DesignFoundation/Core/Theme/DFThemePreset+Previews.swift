#if DEBUG
import SwiftUI

// MARK: - Shared showcase view

/// A compact UI panel that exercises real components so every themed preview
/// shows authentic radius, shadow, and color personality.
private struct ThemeShowcase: View {
    @State private var email = "you@example.com"

    var body: some View {
        VStack(spacing: 12) {
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
        }
        .padding()
    }
}

// MARK: - Previews

#Preview("Default theme") {
    HStack(spacing: 0) {
        ThemeShowcase()
            .environment(\.colorScheme, .light)
            .frame(maxWidth: .infinity)
        Divider()
        ThemeShowcase()
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
            .background(Color(.sRGB, white: 0.1, opacity: 1))
    }
}

#Preview("Slate — light and dark") {
    HStack(spacing: 0) {
        ThemeShowcase()
            .environment(\.colorScheme, .light)
            .frame(maxWidth: .infinity)
        Divider()
        ThemeShowcase()
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
            .background(Color(.sRGB, white: 0.1, opacity: 1))
    }
    .dfThemePreset(.slate)
}

#Preview("Aurora — light and dark") {
    HStack(spacing: 0) {
        ThemeShowcase()
            .environment(\.colorScheme, .light)
            .frame(maxWidth: .infinity)
        Divider()
        ThemeShowcase()
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
            .background(Color(.sRGB, white: 0.1, opacity: 1))
    }
    .dfThemePreset(.aurora)
}

#Preview("Copper — light and dark") {
    HStack(spacing: 0) {
        ThemeShowcase()
            .environment(\.colorScheme, .light)
            .frame(maxWidth: .infinity)
        Divider()
        ThemeShowcase()
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
            .background(Color(.sRGB, white: 0.1, opacity: 1))
    }
    .dfThemePreset(.copper)
}

#Preview("Sage — light and dark") {
    HStack(spacing: 0) {
        ThemeShowcase()
            .environment(\.colorScheme, .light)
            .frame(maxWidth: .infinity)
        Divider()
        ThemeShowcase()
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
            .background(Color(.sRGB, white: 0.1, opacity: 1))
    }
    .dfThemePreset(.sage)
}

#Preview("All presets side by side") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(presetRows.enumerated()), id: \.offset) { _, row in
                VStack(spacing: 4) {
                    Text(row.label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                    ThemeShowcase()
                        .frame(width: 260)
                        .applyPreset(row.preset)
                }
                if row.label != presetRows.last?.label {
                    Divider()
                }
            }
        }
    }
}

private struct PresetRow {
    let label: String
    let preset: DFThemePreset?
}

private let presetRows: [PresetRow] = [
    PresetRow(label: "Default", preset: nil),
    PresetRow(label: "Slate",   preset: .slate),
    PresetRow(label: "Aurora",  preset: .aurora),
    PresetRow(label: "Copper",  preset: .copper),
    PresetRow(label: "Sage",    preset: .sage),
]

private extension View {
    @ViewBuilder
    func applyPreset(_ preset: DFThemePreset?) -> some View {
        if let preset {
            self.dfThemePreset(preset)
        } else {
            self
        }
    }
}

#endif
