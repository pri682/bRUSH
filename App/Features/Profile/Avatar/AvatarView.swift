import SwiftUI
import UIKit // Keep UIKit for UIDevice and the renderAsImage extension

// **NOTE:** The AvatarType enum is expected to be defined elsewhere in your project.
// We are removing the minimal definition that was causing the 'redeclaration' error.

struct AvatarView: View {
    // Keep your original properties
    let avatarType: AvatarType // Ensure AvatarType is accessible (e.g., in a shared file)
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
            
            VStack {
                // Conditional spacer for iPhone devices
                if UIDevice.current.userInterfaceIdiom == .phone {
                    // This spacer pushes the ZStack down on iPhones
                    Color.clear
                        .frame(height: 65)
                }
                
                // Group all avatar elements (Personal or Fun)
                ZStack {
                    if avatarType == .personal {
                        // Personal avatar layers (human)
                        // Body layer
                        if let avatarBody = avatarBody {
                            Image(avatarBody)
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Shirt layer (on top of body)
                        if let shirt = shirt {
                            Image(shirt)
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Eyes layer
                        if let eyes = eyes {
                            Image(eyes)
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Mouth layer
                        if let mouth = mouth {
                            Image(mouth)
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Hair layer (topmost)
                        if let hair = hair {
                            Image(hair)
                                .resizable()
                                .scaledToFit()
                        }
                    } else {
                        // Fun avatar layers (alien) - mapping avatarBody to face
                        // Face layer
                        if let face = avatarBody {
                            Image(face)
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Eyes layer
                        if let eyes = eyes {
                            Image(eyes)
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Mouth layer
                        if let mouth = mouth {
                            Image(mouth)
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Hair layer (topmost)
                        if let hair = hair {
                            Image(hair)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } // End inner ZStack for avatar parts
            } // End VStack for conditional spacing
        }
        .clipped()
    }
}

// Extension to render AvatarView as a single UIImage
extension AvatarView {
    // render a 200 x 200 image of anything. calling avatar.renderimage will render the avatar as image:
    func renderAsImage(size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        // We use ImageRenderer and UIScreen which require 'import SwiftUI' and 'import UIKit'
        let renderer = ImageRenderer(content: self.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage // returns the image
    }
}

// Preview for development
// Ensure this is treated as a SwiftUI file for the PreviewProvider to work
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
        .previewLayout(.sizeThatFits) // This should now resolve
    }
}
