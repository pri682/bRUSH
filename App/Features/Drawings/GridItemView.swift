import SwiftUI

struct GridItemView: View {
    @EnvironmentObject var dataModel: DataModel
    let namespace: Namespace.ID
    let size: Double
    let item: Item
    var isSelected: Bool = false
    var isDeleting: Bool = false
    var onDeletionFinished: () -> Void = {}

    var body: some View {
        imageContent
            .opacity(isDeleting ? 0 : 1)
            .overlay {
                if isDeleting, let image = item.image {
                    ShredderView(image: image, onFinished: onDeletionFinished)
                        .clipShape(.rect(cornerRadius: 8.0))
                }
            }
            .onAppear {
                if item.image == nil {
                    dataModel.loadImage(for: item.id)
                }
            }
    }

    private var imageContent: some View {
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
    }
}

