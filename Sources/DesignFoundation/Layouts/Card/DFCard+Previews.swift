import SwiftUI

#Preview("DFCard — Elevated") {
    DFCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Elevated Card").font(.headline)
            Text("Default style with shadow.").font(.subheadline).foregroundStyle(.secondary)
        }
    }
    .padding()
}

#Preview("DFCard — Interactive") {
    DFCard(action: { print("tapped") }) {
        Text("Tap me").font(.headline)
    }
    .dfCardStyle(.elevated)
    .padding()
}

#Preview("DFCard — Outlined") {
    DFCard {
        Text("Outlined Card").font(.headline)
    }
    .dfCardStyle(.outlined)
    .padding()
}

#Preview("DFCard — Filled") {
    DFCard {
        Text("Filled Card").font(.headline)
    }
    .dfCardStyle(.filled)
    .padding()
}

#Preview("DFCard — Disabled") {
    DFCard(action: {}) {
        Text("Disabled Card").font(.headline)
    }
    .disabled(true)
    .padding()
}
