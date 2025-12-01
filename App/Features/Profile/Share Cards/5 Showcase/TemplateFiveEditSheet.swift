import SwiftUI

struct TemplateFiveEditSheet: View {
    @Binding var showUsername: Bool
    @Binding var showPrompt: Bool
    @Binding var showDrawingPicker: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        isPresented = false
                        showDrawingPicker = true
                    }) {
                        HStack {
                            Image(systemName: "pencil.and.scribble")
                                .foregroundColor(.purple)
                            Text("Change Drawing")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Display Options") {
                    Toggle("Show Username", isOn: $showUsername)
                        .tint(.accentColor)
                    Toggle("Show Prompt", isOn: $showPrompt)
                        .tint(.accentColor)
                }
            }
            .navigationTitle("Customize Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .confirm) {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
