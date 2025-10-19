import SwiftUI

struct GridItemView: View {
    @EnvironmentObject var dataModel: DataModel
    let namespace: Namespace.ID
    let size: Double
    let item: Item
    
    var body: some View {
        ZStack {
            if let cachedImage = item.image {
                Image(uiImage: cachedImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
            }
        }
        .frame(width: size, height: size * (16 / 9))
        .clipShape(.rect(cornerRadius: 8.0))
        .matchedGeometryEffect(id: item.id, in: namespace)
        .shadow(radius: 5)
        .onAppear {
            if item.image == nil {
                dataModel.loadImage(for: item.id)
            }
        }
    }
}

