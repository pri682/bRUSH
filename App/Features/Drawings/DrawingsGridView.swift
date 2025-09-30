import SwiftUI

struct DrawingsGridView: View {
    @EnvironmentObject var dataModel: DataModel
    @State private var isAddingNewDrawing = false
    
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 20) {
                    ForEach(dataModel.items) { item in
                        NavigationLink(destination: DrawingPreviewView(item: item)) {
                            GridItemView(size: 100, item: item)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Previous Drawings")
            .navigationDestination(isPresented: $isAddingNewDrawing) {
                DrawingView { url, image in
                    let newItem = Item(url: url, image: image)
                    dataModel.addItem(newItem)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isAddingNewDrawing = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
