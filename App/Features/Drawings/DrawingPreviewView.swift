import SwiftUI

struct DrawingPreviewView: View {
    let item: Item
    
    @State private var isSharing = false
    
    private var formattedDate: String {
        item.date.formatted(date: .long, time: .omitted)
    }
    
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
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if let image = resolvedImage {
                VStack(spacing: 20) {
                    Spacer()

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(24)
                        .shadow(radius: 10, y: 5)
                    
                    VStack(spacing: 12) {
                        Text(item.prompt)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassEffect(.clear.interactive())
                    .cornerRadius(20)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle(formattedDate)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.isSharing = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                .sheet(isPresented: $isSharing) {
                    ShareSheet(activityItems: [item.url])
                }
            } else {
                ProgressView()
                    .navigationTitle("Loading...")
            }
        }
    }
}

