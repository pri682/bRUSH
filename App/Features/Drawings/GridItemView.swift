import SwiftUI

struct GridItemView: View {
    @EnvironmentObject var dataModel: DataModel
    let namespace: Namespace.ID
    let size: Double
    let item: Item
    var isSelected: Bool = false
    
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
        .overlay {
            if isSelected {
                ZStack {
                    RoundedRectangle(cornerRadius: 8.0)
                        .fill(Color.black.opacity(0.4))
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.title)
                }
            }
        }
        .onAppear {
            if item.image == nil {
                dataModel.loadImage(for: item.id)
            }
        }
    }
}
