import SwiftUI

struct DrawingsGridView: View {
    @EnvironmentObject var dataModel: DataModel
    @State private var isAddingNewDrawing = false
    @State private var drawingPrompt = "What does your brain look like on a happy day?"
    
    @Namespace private var namespace
    @State private var selectedItem: Item? = nil
    
    @State private var isEditing = false
    @State private var selection = Set<UUID>()
    @State private var itemToDelete: Item? = nil
    @State private var showSingleDeleteAlert = false
    @State private var showMultiDeleteAlert = false
    
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        ForEach(dataModel.items) { item in
                            GridItemView(namespace: namespace, size: 100, item: item, isSelected: selection.contains(item.id))
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if isEditing {
                                            if selection.contains(item.id) {
                                                selection.remove(item.id)
                                            } else {
                                                selection.insert(item.id)
                                            }
                                        } else {
                                            selectedItem = item
                                        }
                                    }
                                }
                                .contextMenu {
                                    if !isEditing {
                                        Button(role: .destructive) {
                                            itemToDelete = item
                                            showSingleDeleteAlert = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Past Drawings")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    if selectedItem == nil {
                        ToolbarItem(placement: .navigationBarLeading) {
                            if !dataModel.items.isEmpty {
                                Button(isEditing ? "Done" : "Edit") {
                                    withAnimation {
                                        isEditing.toggle()
                                        selection.removeAll()
                                    }
                                }
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            if isEditing && !selection.isEmpty {
                                Button("Delete") {
                                    showMultiDeleteAlert = true
                                }
                                .tint(.red)
                            }
                            if !isEditing {
                                Button {
                                    isAddingNewDrawing = true
                                } label: {
                                    Image(systemName: "plus")
                                }
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
                    .zIndex(1)
                }
            }
            .alert("Delete Drawing?", isPresented: $showSingleDeleteAlert, presenting: itemToDelete) { item in
                Button("Delete", role: .destructive) {
                    dataModel.deleteItem(with: item.id)
                }
                Button("Cancel", role: .cancel) {}
            } message: { _ in
                Text("This drawing cannot be restored.")
            }
            .alert("Delete \(selection.count) Drawings?", isPresented: $showMultiDeleteAlert) {
                Button("Delete", role: .destructive) {
                    dataModel.deleteItems(with: selection)
                    selection.removeAll()
                    isEditing = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("These drawings cannot be restored.")
            }
        }
    }
}

