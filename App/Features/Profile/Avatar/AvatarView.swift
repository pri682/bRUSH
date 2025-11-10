import SwiftUI

struct AvatarView: View {
    let background: String
    let face: String?
    let eyes: String?
    let mouth: String?
    let hair: String?
    
    var body: some View {
        ZStack {
            Image(background)
                .resizable()
                .scaledToFill()
            
            VStack {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Color.clear
                        .frame(height: 80)
                }
                
                ZStack {
                    if let face = face { Image(face).resizable().scaledToFit() }
                    if let eyes = eyes { Image(eyes).resizable().scaledToFit() }
                    if let mouth = mouth { Image(mouth).resizable().scaledToFit() }
                    if let hair = hair { Image(hair).resizable().scaledToFit() }
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
