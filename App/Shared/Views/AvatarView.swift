import SwiftUI

struct AvatarView: View {
    let face: String
    let eyes: String
    let mouth: String
    
    var body: some View {
        ZStack {
            // Face layer (bottom)
            Image(face)
                .resizable()
                .scaledToFit()
            
            // Eyes layer
            Image(eyes)
                .resizable()
                .scaledToFit()
            
            // Mouth layer (top)
            Image(mouth)
                .resizable()
                .scaledToFit()
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
            face: "face_1",
            eyes: "eyes_1",
            mouth: "mouth_1"
        )
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
    }
}
