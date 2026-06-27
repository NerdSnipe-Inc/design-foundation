import SwiftUI

private struct DFThemeKey: EnvironmentKey {
    static let defaultValue: DFTheme = .default
}

public extension EnvironmentValues {
    var dfTheme: DFTheme {
        get { self[DFThemeKey.self] }
        set { self[DFThemeKey.self] = newValue }
    }
}
