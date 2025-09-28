import SwiftUI

struct GridItemView: View {
    let size: Double
    let item: Item
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // The grid now displays the preview image
            if let previewImage = item.preview {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView() // Shows while the preview is loading
            }
        }
        .frame(width: size, height: size)
        .clipped()
    }
}
