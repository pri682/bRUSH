import SwiftUI

struct ShareCardPreviewView: View {
    @Binding var backgroundColor: Color
    @Binding var cardColor: Color
    @Binding var cardText: String
    @Binding var textColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                
                // The Card
                ZStack(alignment: .center) {
                    // 1. Card Background
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(cardColor)
                    
                    // 2. The Text (Poster Style)
                    Text(cardText.uppercased())
                        // 🔥 NEW FONT: Black weight + Italic = Sporty/Fast look
                        .font(.system(size: 200, weight: .black))
                        .italic()
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-20) // Tighten line height
                        .minimumScaleFactor(0.1)
                        .padding(20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        // Blend mode overlay makes it look "printed" on the card color (Optional, remove if you want solid color)
                        // .blendMode(.overlay)
                }
                // Masking ensures text "bleeds" off the edge but respects corners
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 15)
                .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.65)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
