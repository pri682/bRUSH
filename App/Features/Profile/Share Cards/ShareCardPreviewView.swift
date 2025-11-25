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
    
    @Namespace private var namespace
    
    private var canEditTemplateFive: Bool {
        currentPage == 4
    }
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            
            let cardHeightFactor: CGFloat = 0.65
            let cardHeight = height * cardHeightFactor
            let cardWidth = cardHeight * (2/3)
            
            let horizontalPadding = max(30, (width - cardWidth) / 2)
            let verticalPadding: CGFloat = 50
            
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
                TabView(selection: $currentPage) {
                    CardTemplateOneView(customization: customizationBinding, userProfile: userProfile)
                        .frame(height: cardHeight)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, verticalPadding)
                        .tag(0)
                    
                    CardTemplateTwoView(customization: customizationBinding, userProfile: userProfile)
                        .frame(height: cardHeight)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, verticalPadding)
                        .tag(1)
                        
                    CardTemplateThreeView(customization: customizationBinding, userProfile: userProfile)
                        .frame(height: cardHeight)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, verticalPadding)
                        .tag(2)
                        
                    CardTemplateFourView(customization: customizationBinding, userProfile: userProfile)
                        .frame(height: cardHeight)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, verticalPadding)
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
                        .frame(height: cardHeight)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, verticalPadding)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .padding(.top, 20)
                .padding(.bottom, height * 0.25)
                
                if showActions {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            ForEach(0..<5) { index in
                                Capsule()
                                    .fill(Color.white.opacity(currentPage == index ? 1.0 : 0.4))
                                    .frame(
                                        width: currentPage == index ? 24 : 8,
                                        height: 8
                                    )
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                            }
                        }
                        .padding(.bottom, 24)
                        
                        GlassEffectContainer(spacing: 12.0) {
                            HStack(alignment: .top, spacing: 12) {
                                Button(action: {
                                    Task {
                                        let image = captureCard()
                                        await MainActor.run {
                                            self.cardImage = image
                                            if self.cardImage != nil {
                                                self.isSharing = true
                                            }
                                        }
                                    }
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
                                    .glassEffect(.clear.tint(buttonTintColor(for: currentPage).opacity(0.2)).interactive())
                                    .glassEffectID("shareButton", in: namespace)
                                }
                                .disabled(currentPage == 4 && selectedDrawing == nil)
                                                                
                                if canEditTemplateFive {
                                    Button(action: {
                                        showTemplate5Edit = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 53, height: 53)
                                            .glassEffect(.clear.tint(buttonTintColor(for: currentPage).opacity(0.2)).interactive())
                                            .glassEffectID("editPencilButton", in: namespace)
                                    }
                                    .disabled(selectedDrawing == nil)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom, height * 0.06)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: canEditTemplateFive)
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { self.isSharing },
            set: { self.isSharing = $0 }
        )) {
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
            .transaction { tx in
                tx.animation = nil
            }
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
        case 0:
            return Color(hex: "#CC522A") ?? .orange
        case 1:
            return Color(hex: "#B0186E") ?? .pink
        case 2:
            return Color(hex: "#1E445A") ?? .blue
        case 3:
            return Color(hex: "#7A0040") ?? .red
        case 4:
            return Color(hex: "#054336") ?? .green
        default:
            return .orange
        }
    }
    
    private func captureCard() -> UIImage? {
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
                
        let fullScreenHeight = UIScreen.main.bounds.height
        let shadowBuffer: CGFloat = 40.0
        
        let finalCardHeight: CGFloat
        let finalCardWidth: CGFloat
        
        let ratio2_3: CGFloat = 2.0 / 3.0
        let ratio9_16: CGFloat = 9.0 / 16.0
        
        if currentPage == 4 {
            let exportHeightFactor: CGFloat = 0.9
            finalCardHeight = fullScreenHeight * exportHeightFactor
            finalCardWidth = finalCardHeight * ratio9_16
        } else {
            let cardHeightFactor: CGFloat = 0.65
            finalCardHeight = fullScreenHeight * cardHeightFactor
            finalCardWidth = finalCardHeight * ratio2_3
        }

        let renderContent = cardView
            .frame(width: finalCardWidth, height: finalCardHeight)
            .padding(shadowBuffer / 2)
            .background(Color.clear)
        
        let renderer = ImageRenderer(content: renderContent)
        
        renderer.scale = 3.0
        
        renderer.proposedSize = .init(width: finalCardWidth + shadowBuffer, height: finalCardHeight + shadowBuffer)
        
        guard let uiImage = renderer.uiImage else {
            return nil
        }
        
        if let pngData = uiImage.pngData(), let finalImage = UIImage(data: pngData) {
            return finalImage
        }
        
        return uiImage
    }
}
