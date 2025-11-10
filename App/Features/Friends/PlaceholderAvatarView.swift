import SwiftUI

struct PlaceholderAvatarView: View {
    let size: CGFloat
    var borderColor: Color = Color(.systemGray4)
    var bgColor: Color = Color(.systemGray5)

    var body: some View {
        ZStack {
            Circle()
                .fill(bgColor)
                .frame(width: size, height: size)

            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color(.systemGray3))
                .frame(width: size * 0.48, height: size * 0.48)
        }
        .overlay(
            Circle()
                .stroke(borderColor, lineWidth: 3)
        )
    }
}

#if DEBUG
struct PlaceholderAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            PlaceholderAvatarView(size: 100)
            PlaceholderAvatarView(size: 72)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
