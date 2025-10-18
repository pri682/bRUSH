import SwiftUI

struct GridItemView: View {
    @EnvironmentObject var dataModel: DataModel
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
        .frame(width: size, height: size * (16 / 9))
        .clipped()
        .cornerRadius(8.0)
        .shadow(radius: 5)
        .onAppear {
            if item.image == nil {
                dataModel.loadImage(for: item.id)
            }
        }
    }
}
