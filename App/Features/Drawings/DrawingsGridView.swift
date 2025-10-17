import SwiftUI

struct DrawingsGridView: View {
    @EnvironmentObject var dataModel: DataModel
    @State private var isAddingNewDrawing = false
    @State private var drawingPrompt = "What does your brain look like on a happy day?"
    
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
                DrawingView(onSave: { newItem in
                    dataModel.addItem(newItem)
                }, prompt: drawingPrompt)
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
