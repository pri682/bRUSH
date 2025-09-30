import SwiftUI

struct ArtCardView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(Color.white)
            .frame(width: 260, height: 360)
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            )
    }
}
