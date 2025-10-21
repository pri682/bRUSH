import SwiftUI

struct AvatarView: View {
    let avatarType: AvatarType
    let background: String
    let avatarBody: String?
    let shirt: String?
    let eyes: String?
    let mouth: String?
    let hair: String?
    
    var body: some View {
        ZStack {
            Image(background)
                .resizable()
                .scaledToFill()
            
            if avatarType == .personal {
                // Personal avatar layers (human)
                // Body layer (if exists)
                if let avatarBody = avatarBody {
                    Image(avatarBody)
                        .resizable()
                        .scaledToFit()
                }
                
                // Shirt layer (if exists)
                if let shirt = shirt {
                    Image(shirt)
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
            } else {
                // Fun avatar layers (alien) - face, eyes, mouth, hair
                // Face layer (if exists) - mapped from body
                if let face = avatarBody {
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
            avatarType: .personal,
            background: "background_1",
            avatarBody: "body_1",
            shirt: "shirt_1",
            eyes: "eyes_1",
            mouth: "mouth_1",
            hair: "hair_1"
        )
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
    }
}
