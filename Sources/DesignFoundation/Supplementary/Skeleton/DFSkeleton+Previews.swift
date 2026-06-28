import SwiftUI

#Preview("DFSkeleton — Shapes") {
    VStack(spacing: 16) {
        DFSkeleton(shape: .roundedRectangle(cornerRadius: 8))
            .frame(height: 20)
        DFSkeleton(shape: .roundedRectangle(cornerRadius: 8))
            .frame(height: 14)
            .frame(maxWidth: .infinity * 0.6)
        HStack(spacing: 12) {
            DFSkeleton(shape: .circle)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 8) {
                DFSkeleton(shape: .roundedRectangle(cornerRadius: 4))
                    .frame(height: 14)
                DFSkeleton(shape: .roundedRectangle(cornerRadius: 4))
                    .frame(height: 12)
                    .frame(maxWidth: 120)
            }
        }
        DFSkeleton(shape: .capsule)
            .frame(width: 80, height: 32)
    }
    .padding()
}
