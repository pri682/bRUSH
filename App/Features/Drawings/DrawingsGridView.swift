import SwiftUI

struct DrawingsGridView: View {
    @EnvironmentObject var dataModel: DataModel
    @State private var isAddingNewDrawing = false
    @State private var drawingPrompt = "What does your brain look like on a happy day?"
    @AppStorage("hasPostedToday") private var hasPostedToday: Bool = false
    
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
            .fullScreenCover(isPresented: $isAddingNewDrawing) {
                NavigationStack {
                    DrawingView(onSave: { newItem in
                        dataModel.addItem(newItem)
                        // Mark that the user has posted today so other parts of the app react (CTA -> Prompt chip)
                        PostState.markPostedToday()
                        hasPostedToday = true
                    }, prompt: drawingPrompt)
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
