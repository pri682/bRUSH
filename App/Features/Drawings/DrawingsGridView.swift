import SwiftUI
import PencilKit

struct DrawingsGridView: View {
    @EnvironmentObject var dataModel: DataModel
    
    private static let columns = 3
    @State private var isEditing = false
    
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: columns)
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: gridColumns) {
                    ForEach(dataModel.items) { item in
                        NavigationLink(destination: DetailView(item: item)) {
                            GridItemView(size: 120, item: item)
                        }
                        .overlay(alignment: .topTrailing) {
                            if isEditing {
                                Button {
                                    withAnimation { dataModel.removeItem(item) }
                                } label: {
                                    Image(systemName: "xmark.square.fill")
                                        .font(.title)
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, .red)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle("Past Drawings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                // 👇 This is the fix: Changed from a Button to a NavigationLink
                NavigationLink {
                    // Destination: A new DrawingView for a blank canvas
                    DrawingView { drawing in
                        saveNewDrawing(drawing)
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func saveNewDrawing(_ drawing: PKDrawing) {
        let data = drawing.dataRepresentation()
        let filename = UUID().uuidString + ".drawing"
        
        if let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(filename) {
            do {
                try data.write(to: fileURL, options: .atomic)
                
                let previewSize = CGRect(x: 0, y: 0, width: 200, height: 200)
                let preview = drawing.image(from: previewSize, scale: 2.0)
                
                // Create a new Item with a drawingURL but no imageURL
                let newItem = Item(imageURL: nil, drawingURL: fileURL, preview: preview)
                dataModel.addItem(newItem)
                
            } catch {
                print("Error saving new drawing: \(error)")
            }
        }
    }
}
