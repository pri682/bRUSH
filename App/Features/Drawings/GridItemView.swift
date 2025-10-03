import SwiftUI

struct GridItemView: View {
    let size: Double
    let item: Item
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // The grid now displays the 'image' property from the in-memory cache
            if let cachedImage = item.image {
                Image(uiImage: cachedImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView() // Shows while the preview is loading
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .cornerRadius(8.0)
        .shadow(radius: 5)
    }
}
