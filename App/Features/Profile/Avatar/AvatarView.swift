import SwiftUI
import UIKit

struct AvatarView: View {
    let avatarType: AvatarType
    let background: String
    let avatarBody: String?
    let shirt: String?
    let eyes: String?
    let mouth: String?
    let hair: String?
    let facialHair: String?
    
    let includeSpacer: Bool
    
    init(
        avatarType: AvatarType,
        background: String,
        avatarBody: String?,
        shirt: String?,
        eyes: String?,
        mouth: String?,
        hair: String?,
        includeSpacer: Bool = true
    ) {
        self.avatarType = avatarType
        self.background = background
        self.avatarBody = avatarBody
        self.shirt = shirt
        self.eyes = eyes
        self.mouth = mouth
        self.hair = hair
        self.includeSpacer = includeSpacer
    }
    
    var body: some View {
        ZStack {
            Image(background)
                .resizable()
                .scaledToFill()
            
            VStack {
                if includeSpacer && UIDevice.current.userInterfaceIdiom == .phone {
                    Color.clear
                        .frame(height: 65)
                }
                
                ZStack {
                    if avatarType == .personal {
                        if let avatarBody = avatarBody {
                            Image(avatarBody)
                                .resizable()
                                .scaledToFit()
                        }
                        if let shirt = shirt {
                            Image(shirt)
                                .resizable()
                                .scaledToFit()
                        }
                        if let eyes = eyes {
                            Image(eyes)
                                .resizable()
                                .scaledToFit()
                        }
                        
                        if let facialHair = facialHair {
                            Image(facialHair)
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Mouth layer
                        if let mouth = mouth {
                            Image(mouth)
                                .resizable()
                                .scaledToFit()
                        }
                        if let hair = hair {
                            Image(hair)
                                .resizable()
                                .scaledToFit()
                        }
                        
                        
                    } else {
                        if let face = avatarBody {
                            Image(face)
                                .resizable()
                                .scaledToFit()
                        }
                        if let eyes = eyes {
                            Image(eyes)
                                .resizable()
                                .scaledToFit()
                        }
                        if let mouth = mouth {
                            Image(mouth)
                                .resizable()
                                .scaledToFit()
                        }
                        if let hair = hair {
                            Image(hair)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }
        }
        .clipped()
    }
}

extension AvatarView {
    func renderAsImage(size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        let renderer = ImageRenderer(content: self.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}

struct AvatarView_Previews: PreviewProvider {
    // NOTE: This minimal AvatarType definition is required if it's not in an imported file,
    // to ensure the PreviewProvider can compile.
    // enum AvatarType { case personal, fun }
    
    static var previews: some View {
        AvatarView(
            avatarType: .personal,
            background: "background_1",
            avatarBody: "body_1",
            shirt: "shirt_1",
            eyes: "eyes_1",
            mouth: "mouth_1",
            hair: "hair_1",
            facialHair: "facial_hair_1" // Only passed once with a static string value
        )
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
    }
}
