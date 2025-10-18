import SwiftUI

struct AvatarView: View {
    let background: String
    let face: String?
    let eyes: String?
    let mouth: String?
    let hair: String?
    
    var body: some View {
        ZStack {
            // Background layer (bottom) - scaled to fill to remove white sides
            Image(background)
                .resizable()
                .scaledToFill()
            
            // Face layer (if exists)
            if let face = face {
                Image(face)
                    .resizable()
                    .scaledToFit()
            }
            
            // Eyes layer (if exists)
            if let eyes = eyes {
                Image(eyes)
                    .resizable()
                    .scaledToFit()
            }
            
            // Mouth layer (if exists)
            if let mouth = mouth {
                Image(mouth)
                    .resizable()
                    .scaledToFit()
            }
            
            // Hair layer (top, if exists)
            if let hair = hair {
                Image(hair)
                    .resizable()
                    .scaledToFit()
            }
        }
        .clipped()
    }
}

// Extension to render AvatarView as a single UIImage
extension AvatarView {
    func renderAsImage(size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        let renderer = ImageRenderer(content: self.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}

// Preview for development
struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(
            background: "background_1",
            face: "face_1",
            eyes: "eyes_1",
            mouth: "mouth_1",
            hair: "hair_1"
        )
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
    }
}
