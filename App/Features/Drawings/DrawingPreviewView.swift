import SwiftUI

struct DrawingPreviewView: View {
    let item: Item
    
    // State to hold the image for sharing
    @State private var imageToShare: UIImage?
    @State private var isSharing = false
    
    var body: some View {
        Group {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .navigationTitle("Drawing")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                self.imageToShare = image
                                self.isSharing = true
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                    .sheet(isPresented: $isSharing) {
                        if let imageToShare = imageToShare {
                            ShareSheet(activityItems: [imageToShare])
                        }
                    }
            } else {
                // This view should only be shown if an image is already loaded
                ProgressView()
            }
        }
    }
}
