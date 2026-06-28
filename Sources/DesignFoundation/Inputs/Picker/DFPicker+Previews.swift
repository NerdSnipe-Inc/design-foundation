#if DEBUG
import SwiftUI

private enum Fruit: String, CaseIterable, Hashable {
    case apple = "Apple"
    case banana = "Banana"
    case cherry = "Cherry"
}

#Preview("Segmented Style") {
    VStack(spacing: 24) {
        DFPicker("Fruit", selection: .constant(Fruit.apple)) {
            ForEach(Fruit.allCases, id: \.self) { fruit in
                Text(fruit.rawValue).tag(fruit)
            }
        }
        DFPicker("Disabled", selection: .constant(Fruit.banana)) {
            ForEach(Fruit.allCases, id: \.self) { fruit in
                Text(fruit.rawValue).tag(fruit)
            }
        }
        .disabled(true)
    }
    .padding()
    .dfPickerStyle(.segmented)
}

#Preview("Menu Style") {
    VStack(spacing: 24) {
        DFPicker("Fruit", selection: .constant(Fruit.cherry)) {
            ForEach(Fruit.allCases, id: \.self) { fruit in
                Text(fruit.rawValue).tag(fruit)
            }
        }
    }
    .padding()
    .dfPickerStyle(.menu)
}

#if os(iOS) || os(watchOS)
#Preview("Wheel Style") {
    DFPicker("Fruit", selection: .constant(Fruit.apple)) {
        ForEach(Fruit.allCases, id: \.self) { fruit in
            Text(fruit.rawValue).tag(fruit)
        }
    }
    .padding()
    .dfPickerStyle(.wheel)
}
#endif
#endif
