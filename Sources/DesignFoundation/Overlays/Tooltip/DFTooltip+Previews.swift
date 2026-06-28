import SwiftUI

#Preview("DFTooltip — Top (long press on iOS)") {
    VStack(spacing: 40) {
        Text("Long press the button below")
            .foregroundStyle(.secondary)
        Button("Hover / Long Press Me") {}
            .dfTooltip("This is a tooltip", delay: 0.3, placement: .top)
    }
    .padding()
}

#Preview("DFTooltip — Bottom") {
    Button("Press for info") {}
        .dfTooltip("More info here", delay: 0.3, placement: .bottom)
        .padding(60)
}

#Preview("DFTooltip — Placements") {
    VStack(spacing: 32) {
        ForEach([DFTooltipPlacement.top, .bottom, .leading, .trailing], id: \.self) { p in
            Button("\(p)") {}
                .dfTooltip("Tooltip (\(p))", delay: 0.2, placement: p)
        }
    }
    .padding(80)
}
