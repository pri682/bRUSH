import SwiftUI

struct ShareCardEditView: View {
    @Binding var backgroundColor: Color
    @Binding var cardColor: Color
    @Binding var cardText: String
    @Binding var textColor: Color
    
    // Categories for the "Steps"
    let categories = ["Message", "Text Color", "Card Color", "Background"]
    @State private var selectedCategoryIndex = 0
    
    // Preset Colors for quick selection
    let presetColors: [Color] = [
        .white, .black, .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. Top Half: Mini Preview
            // We use a GeometryReader to give it specific proportion of the screen
            GeometryReader { geo in
                ZStack {
                    // We pass bindings so the mini preview updates live
                    ShareCardPreviewView(
                        backgroundColor: .constant(.clear), // Transparent BG so it fits in the edit view
                        cardColor: $cardColor,
                        cardText: $cardText,
                        textColor: $textColor
                    )
                    .scaleEffect(0.7) // Scale it down to fit nicely
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(height: UIScreen.main.bounds.height * 0.45) // Takes up top 45% of screen
            
            // 2. Bottom Half: Controls (The "White Sheet" look)
            VStack(spacing: 20) {
                
                // Category Tabs (Scrollable)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25) {
                        ForEach(0..<categories.count, id: \.self) { index in
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    selectedCategoryIndex = index
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Text(categories[index])
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(selectedCategoryIndex == index ? .black : .gray)
                                    
                                    // Active Indicator
                                    Capsule()
                                        .fill(selectedCategoryIndex == index ? Color.black : Color.clear)
                                        .frame(width: 20, height: 3)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                }
                
                Divider()
                
                // Dynamic Controls Area
                ScrollView {
                    VStack {
                        switch selectedCategoryIndex {
                        case 0: // Message
                            textInputControl
                        case 1: // Text Color
                            colorGridControl(binding: $textColor)
                        case 2: // Card Color
                            colorGridControl(binding: $cardColor)
                        case 3: // Background
                            colorGridControl(binding: $backgroundColor)
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 50) // Space for Home bar
                }
            }
            .background(Color.white)
            // We assume 'cornerRadius(_:corners:)' is defined elsewhere in your project
            .cornerRadius(30, corners: [.topLeft, .topRight])
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    // MARK: - Sub-Controls
    
    var textInputControl: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("What's the vibe?")
                .font(.headline)
                .foregroundColor(.gray)
            
            TextField("LETS GO", text: $cardText, axis: .vertical)
                .font(.system(size: 30, weight: .black).italic())
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .frame(height: 100)
            
            Text("Tip: Short words (2-3 lines) look best.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }
    
    func colorGridControl(binding: Binding<Color>) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 20) {
            // 1. Custom Color Picker Button
            ColorPicker("", selection: binding, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(Image(systemName: "pencil").foregroundColor(.gray))
            
            // 2. Presets
            ForEach(presetColors, id: \.self) { color in
                Button(action: {
                    withAnimation {
                        binding.wrappedValue = color
                    }
                }) {
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                        .overlay(
                            // Checkmark if selected
                            Image(systemName: "checkmark")
                                .foregroundColor(color == .white ? .black : .white)
                                .opacity(binding.wrappedValue == color ? 1 : 0)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                }
            }
        }
        .padding(.top, 20)
    }
}
