import SwiftUI

struct CardTemplateFiveView: View {
    @Binding var customization: CardCustomization
    @Binding var selectedDrawing: Item?
    var showUsername: Bool
    var showPrompt: Bool

    var userProfile: UserProfile?
    var isExporting: Bool = false
    var onTapAddDrawing: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            let cardHeight = geo.size.height
            
            ZStack {
                Color.clear
                
                ZStack {
                    if let drawing = selectedDrawing, let drawingImage = drawing.image {
                        Image(uiImage: drawingImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth, height: cardHeight)
                            .clipped()
                            .backgroundExtensionEffect()
                            .blur(radius: 20)
                        
                        Image(uiImage: drawingImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: cardWidth, height: cardHeight)
                            .clipped()
                        
                        VStack {
                            HStack {
                                Spacer()
                                Image("brush_logo_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: cardWidth * 0.18)
                                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                                    .padding(.top, cardHeight * 0.03)
                                    .padding(.trailing, cardWidth * 0.04)
                            }
                            Spacer()
                            
                            VStack(spacing: cardHeight * 0.02) {
                                if showPrompt {
                                    Text(drawing.prompt)
                                        .font(.system(size: cardHeight * 0.03, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .shadow(color: isExporting ? .clear : .black.opacity(1.0), radius: 2, x: 0, y: 0)
                                        .shadow(color: isExporting ? .clear : .black.opacity(0.8), radius: 8, x: 0, y: 4)
                                        .shadow(color: isExporting ? .clear : .black.opacity(0.6), radius: 16, x: 0, y: 8)
                                        .padding(.horizontal, cardWidth * 0.08)
                                }
                                
                                if showUsername, let profile = userProfile {
                                    Text("@\(profile.displayName)")
                                        .font(.system(size: cardHeight * 0.035, weight: .black, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color(hex: "#FFD700") ?? .yellow, Color(hex: "#FF4500") ?? .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: isExporting ? .clear : .black.opacity(1.0), radius: 2, x: 0, y: 0)
                                        .shadow(color: isExporting ? .clear : .black.opacity(0.8), radius: 6, x: 0, y: 3)
                                        .shadow(color: isExporting ? .clear : .black.opacity(0.6), radius: 12, x: 0, y: 6)
                                }
                            }
                            .padding(.bottom, cardHeight * 0.05)
                        }
                    } else {
                        Image("showcase")
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth, height: cardHeight)
                            .clipped()
                        
                        VStack(spacing: cardHeight * 0.06) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: cardHeight * 0.075))
                                .foregroundColor(Color(red: 0, green: 0.6, blue: 0))
                                .frame(width: cardHeight * 0.17, height: cardHeight * 0.17)
                                .glassEffect(.clear.interactive(), in: Circle())
                            
                            Text("Add Drawing")
                                .foregroundColor(.white)
                                .padding(.vertical, cardHeight * 0.015)
                                .padding(.horizontal, cardWidth * 0.05)
                                .glassEffect(.regular.tint(Color(red: 0, green: 0.6, blue: 0)).interactive())
                        }
                        
                        VStack {
                            HStack {
                                Spacer()
                                Image("brush_logo_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: cardWidth * 0.18)
                                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                                    .padding(.top, cardHeight * 0.03)
                                    .padding(.trailing, cardWidth * 0.04)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedDrawing == nil {
                        onTapAddDrawing()
                    }
                }
            }
        }
    }
}
