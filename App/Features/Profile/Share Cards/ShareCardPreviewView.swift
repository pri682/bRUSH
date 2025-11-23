import SwiftUI

struct ShareCardPreviewView: View {
    @Binding var backgroundColor: Color
    @Binding var cardColor: Color
    @Binding var cardText: String
    @Binding var textColor: Color
    
    var userProfile: UserProfile?
    
    // Toggle to hide buttons in the Edit View mini-preview
    var showActions: Bool = true
    
    // Track current page for custom dots
    @Binding var currentPage: Int
    
    // Share sheet state
    @State private var isSharing = false
    @State private var cardImage: UIImage? = nil
    
    // Template 5 - Custom drawing state
    @State private var selectedDrawing: Item? = nil
    @State private var showDrawingPicker = false
    @State private var showTemplate5Edit = false
    @State private var showUsername = true
    @State private var showPrompt = true
    
    @EnvironmentObject var dataModel: DataModel
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            
            // Card logic (same as before)
            let customizationBinding = Binding<CardCustomization>(
                get: {
                    CardCustomization(
                        backgroundColor: backgroundColor,
                        cardColor: cardColor,
                        cardText: cardText,
                        textColor: textColor,
                        cardIcon: .user
                    )
                },
                set: { _ in }
            )
            
            ZStack {
                // 1. THE CAROUSEL (Cards) - Moved higher to prevent overlap
                TabView(selection: $currentPage) {
                    CardTemplateOneView(customization: customizationBinding, userProfile: userProfile)
                        .tag(0)
                    
                    CardTemplateTwoView(customization: customizationBinding, userProfile: userProfile)
                        .tag(1)
                        
                    CardTemplateThreeView(customization: customizationBinding, userProfile: userProfile)
                        .tag(2)
                        
                    CardTemplateFourView(customization: customizationBinding, userProfile: userProfile)
                        .tag(3)
                    
                    CardTemplateFiveView(
                        customization: customizationBinding,
                        selectedDrawing: $selectedDrawing,
                        showUsername: showUsername,
                        showPrompt: showPrompt,
                        userProfile: userProfile,
                        onTapAddDrawing: {
                            showDrawingPicker = true
                        }
                    )
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default dots
                .padding(.bottom, height * 0.20) // Move cards up to prevent overlap
                
                // 2. OVERLAY: Dots and Share Button
                if showActions {
                    VStack {
                        Spacer()
                        
                        // Custom Dots - Smooth stretch animation from circle to line
                        HStack(spacing: 8) {
                            ForEach(0..<5) { index in
                                Capsule()
                                    .fill(Color.white.opacity(currentPage == index ? 1.0 : 0.4))
                                    .frame(
                                        width: currentPage == index ? 20 : 8,
                                        height: 8
                                    )
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                            }
                        }
                        .padding(.bottom, 24)
                        
                        // Share Button(s) - Split into two when on Template 5
                        if currentPage == 4 {
                            GlassEffectContainer(spacing: 12.0) {
                                HStack(spacing: 12) {
                                    // Share Button
                                    Button(action: {
                                        captureCardAndShare()
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "arrowshape.turn.up.right.fill")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("Share")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 16)
                                        .glassEffect(.regular.tint(buttonTintColor(for: currentPage)).interactive(), in: RoundedRectangle(cornerRadius: 30))
                                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                    }
                                    
                                    // Edit Button for Template 5 - Icon only
                                    Button(action: {
                                        showTemplate5Edit = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 50, height: 50)
                                            .glassEffect(.regular.tint(buttonTintColor(for: currentPage)).interactive(), in: Circle())
                                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                    }
                                }
                            }
                            .padding(.bottom, height * 0.06)
                        } else {
                            // Single Share Button for Templates 1-4
                            Button(action: {
                                captureCardAndShare()
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrowshape.turn.up.right.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Share")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .glassEffect(.regular.tint(buttonTintColor(for: currentPage)).interactive(), in: RoundedRectangle(cornerRadius: 30))
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                            }
                            .padding(.bottom, height * 0.06)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isSharing) {
            if let image = cardImage {
                let itemSource = ImageActivityItemSource(title: "Brush Share Card", image: image)
                ShareSheet(activityItems: [itemSource])
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $showDrawingPicker) {
            DrawingPickerView(
                selectedDrawing: $selectedDrawing,
                isPresented: $showDrawingPicker
            )
            .environmentObject(dataModel)
        }
        .sheet(isPresented: $showTemplate5Edit) {
            TemplateFiveEditSheet(
                showUsername: $showUsername,
                showPrompt: $showPrompt,
                showDrawingPicker: $showDrawingPicker,
                isPresented: $showTemplate5Edit
            )
        }
    }
    
    // MARK: - Helper Functions
    
    /// Returns the tint color for the share button based on current template
    private func buttonTintColor(for templateIndex: Int) -> Color {
        switch templateIndex {
        case 0: // Streak Card - Fire/Orange
            return Color(hex: "#FF8C42") ?? .orange
        case 1: // Medals Card - Pink/Purple
            return Color(hex: "#E91E8C") ?? .pink
        case 2: // Total Drawings - Blue
            return Color(hex: "#4A90A4") ?? .blue
        case 3: // Member Since - Maroon/Red
            return Color(hex: "#A63446") ?? .red
        case 4: // Custom Drawing - Purple
            return Color(hex: "#A78BFA") ?? .purple
        default:
            return .orange
        }
    }
    
    /// Captures the current card as an image and presents share sheet
    private func captureCardAndShare() {
        let customization = CardCustomization(
            backgroundColor: backgroundColor,
            cardColor: cardColor,
            cardText: cardText,
            textColor: textColor,
            cardIcon: .user
        )
        
        // Create the view to render based on current page
        let cardView: AnyView
        switch currentPage {
        case 0:
            cardView = AnyView(CardTemplateOneView(customization: .constant(customization), userProfile: userProfile))
        case 1:
            cardView = AnyView(CardTemplateTwoView(customization: .constant(customization), userProfile: userProfile))
        case 2:
            cardView = AnyView(CardTemplateThreeView(customization: .constant(customization), userProfile: userProfile))
        case 3:
            cardView = AnyView(CardTemplateFourView(customization: .constant(customization), userProfile: userProfile))
        case 4:
            cardView = AnyView(CardTemplateFiveView(customization: .constant(customization), selectedDrawing: .constant(selectedDrawing), showUsername: showUsername, showPrompt: showPrompt, userProfile: userProfile, onTapAddDrawing: {}))
        default:
            cardView = AnyView(CardTemplateOneView(customization: .constant(customization), userProfile: userProfile))
        }
        
        // Render the card at screen size
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let renderer = ImageRenderer(content: cardView.frame(width: screenWidth, height: screenHeight))
        renderer.scale = 3.0 // High quality export
        
        if let image = renderer.uiImage {
            self.cardImage = image
            self.isSharing = true
        }
    }
}
