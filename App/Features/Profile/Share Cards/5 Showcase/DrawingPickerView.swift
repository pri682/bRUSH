import SwiftUI

struct DrawingPickerView: View {
    @EnvironmentObject var dataModel: DataModel
    @Binding var selectedDrawing: Item?
    @Binding var isPresented: Bool

    private let gridColumns = [
        GridItem(.adaptive(minimum: 100), spacing: 30)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                if dataModel.items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No drawings yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Create your first drawing to use it on a card")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 30) {
                            ForEach(dataModel.items) { item in
                                Button(action: {
                                    if item.image != nil {
                                        selectedDrawing = item
                                        isPresented = false
                                    }
                                }) {
                                    ZStack {
                                        if let image = item.image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .aspectRatio(9/16, contentMode: .fill)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.2))
                                                .aspectRatio(9/16, contentMode: .fill)
                                                .overlay(ProgressView())
                                        }
                                    }
                                    .aspectRatio(9/16, contentMode: .fit)
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    if item.image == nil {
                                        dataModel.loadImage(for: item.id)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Choose Drawing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .cancel) {
                        isPresented = false
                    }
                }
            }
        }
    }
}
