import SwiftUI

// MARK: - RoundedCorners Shape (only specific corners)
struct RoundedCorners: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - GradientOutlineBox
struct GradientOutlineBox<Content: View>: View {
    let title: String
    let gradient: LinearGradient
    let content: Content
    
    @Environment(\.colorScheme) var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }

    init(title: String, gradient: LinearGradient, @ViewBuilder content: () -> Content) {
        self.title = title
        self.gradient = gradient
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
                .padding(.top, 16)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(gradient, lineWidth: 3)
                .mask {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .overlay(alignment: .topLeading) {
                            Text(title)
                                .font(.headline)
                                .padding(.horizontal, 10)
                                .padding(.top, 3)
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                                .blendMode(.destinationOut)
                        }
                }
        )
        .overlay(
            Text(title)
                .font(.headline)
                .padding(.horizontal, 10)
                .background(backgroundColor)
                .padding(.top, -10)
                .padding(.leading, 20),
            alignment: .topLeading
        )
    }
}

// MARK: - StreakBox
struct StreakBox: View {
    let streakCount: Int
    let gradient: LinearGradient
    let boxHeight: CGFloat = 120
    
    @Environment(\.colorScheme) var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Image(systemName: "flame.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .foregroundColor(.orange)
                
                Text("\(streakCount)")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.orange)
            }
            .padding(.top, 18)
            .padding(.bottom, 8)
        }
        .frame(width: 120, height: boxHeight)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(gradient, lineWidth: 3)
                .mask {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .overlay(alignment: .top) {
                            Text("Streak")
                                .font(.headline)
                                .padding(.horizontal, 10)
                                .padding(.top, 3)
                                .padding(.bottom, 2)
                                .blendMode(.destinationOut)
                        }
                }
        )
        .overlay(
            Text("Streak")
                .font(.headline)
                .padding(.horizontal, 10)
                .background(backgroundColor)
                .padding(.top, -10),
            alignment: .top
        )
    }
}

// MARK: - MedalView
struct MedalView: View {
    let imageName: String
    let count: Int
    let medalSize: CGFloat
    let textSize: Font

    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: medalSize, height: medalSize)
            Text("\(count)")
                .font(textSize)
                .fontWeight(.bold)
        }
    }
}
