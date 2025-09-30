import SwiftUI

struct DrawingPreviewView: View {
    let item: Item
    
    @State private var isSharing = false
    
    // This computed property resolves the image for display within your app.
    private var resolvedImage: UIImage? {
        if let img = item.image {
            return img
        } else if let data = try? Data(contentsOf: item.url),
                  let img = UIImage(data: data) {
            return img
        }
        return nil
    }
    
    var body: some View {
        Group {
            if let image = resolvedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .navigationTitle("Drawing")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                // Just toggle the sheet's presentation state.
                                self.isSharing = true
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                    // The sheet now receives the item's URL directly.
                    .sheet(isPresented: $isSharing) {
                        ShareSheet(activityItems: [item.url])
                    }
            } else {
                ProgressView()
            }
        }
    }
}
