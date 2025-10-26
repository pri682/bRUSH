import SwiftUI

struct AvatarView: View {
    let background: String
    let face: String? // optional face
    let eyes: String? // optional eyes
    let mouth: String? // etc... you get it lol
    let hair: String?
    
    var body: some View {
        ZStack { // defines the order of the images, background is bottom, face on top, etc..
            // Background layer (bottom) - scaled to fill.
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
    // render a 200 x 200 image of anything. calling avatar.renderimage will render the avatar as image:
    func renderAsImage(size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        let renderer = ImageRenderer(content: self.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage // returns the image
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
