import SwiftUI

struct DrawingsGridView: View {
    @EnvironmentObject var dataModel: DataModel
    @State private var isAddingNewDrawing = false
    @State private var drawingPrompt = "What does your brain look like on a happy day?"
    
    @Namespace private var namespace
    @State private var selectedItem: Item? = nil
    
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        ForEach(dataModel.items) { item in
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedItem = item
                                }
                            } label: {
                                GridItemView(namespace: namespace, size: 100, item: item)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Previous Drawings")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    if selectedItem == nil {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isAddingNewDrawing = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                .fullScreenCover(isPresented: $isAddingNewDrawing) {
                    NavigationStack {
                        DrawingView(onSave: { newItem in
                            dataModel.addItem(newItem)
                        }, prompt: drawingPrompt)
                    }
                }
                
                if let selectedItem = selectedItem {
                    DrawingPreviewView(
                        namespace: namespace,
                        item: selectedItem,
                        selectedItem: $selectedItem
                    )
                    .ignoresSafeArea()
                }
            }
        }
    }
}
