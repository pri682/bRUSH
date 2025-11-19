import SwiftUI

struct ShareCardEditView: View {
    @Binding var backgroundColor: Color
    @Binding var cardColor: Color
    @Binding var cardText: String
    @Binding var textColor: Color
    
    let categories = ["Message", "Text Color", "Card Color", "Background"]
    @State private var selectedCategoryIndex = 0
    
    let presetColors: [Color] = [
        .white, .black, .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. Top Half: Mini Preview
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    // Pass showActions: false to hide the buttons/dots here
                    ShareCardPreviewView(
                        backgroundColor: .constant(.clear),
                        cardColor: $cardColor,
                        cardText: $cardText,
                        textColor: $textColor,
                        showActions: false // <--- Hides controls
                    )
                    .scaleEffect(0.65)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.7)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(height: UIScreen.main.bounds.height * 0.45)
            .background(Color.black.opacity(0.05))
            .clipped()
            
            // 2. Bottom Half: Controls
            VStack(spacing: 20) {
                
                // Category Tabs
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
                            messageInstructionControl
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
                    .padding(.bottom, 50)
                }
            }
            .background(Color.white)
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    // MARK: - Sub-Controls
    
    var messageInstructionControl: some View {
        VStack(spacing: 15) {
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 20)
            
            Text("The card is using the static asset 'card_1.png'.")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Static Card")
                .font(.caption.bold())
                .foregroundColor(.black.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.05))
                .clipShape(Capsule())
        }
        .frame(height: 150)
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
