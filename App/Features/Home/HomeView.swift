import SwiftUI

struct HomeView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasCreatedFirstPost") private var hasCreatedFirstPost: Bool = false
    @State private var showOnboarding = false
    @State private var showCreate = false

    var body: some View {
        ZStack {
            HomeBackground(palette: HomeBackground.brandVivid).ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    BrandIcon(size: 26, preferAsset: true)
                    Text("Brush")
                        .font(BrushFont.title(26))
                        .foregroundStyle(BrushTheme.textBlue)
                    Spacer()
                    Button("Welcome") { showOnboarding = true }
                        .font(.footnote)
                        .tint(BrushTheme.pink)
                }
                .padding(.horizontal)
                .padding(.top, 4)

                // Hidden navigation trigger for creating the first post
                NavigationLink(destination: DrawingsGridView(), isActive: $showCreate) { EmptyView() }

                // Feed
                ScrollView {
                    LazyVStack(spacing: 20) {
                        if !hasCreatedFirstPost {
                            FirstPostPlaceholderCard {
                                // Trigger creation flow and remember that the user started their first post
                                hasCreatedFirstPost = true
                                showCreate = true
                            }
                            .padding(.horizontal)
                        }

                        ForEach(SamplePost.examples) { post in
                            FeedPostCard(post: post)
                                .padding(.horizontal)
                        }

                        Color.clear.frame(height: 24)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: Binding(get: { !hasCompletedOnboarding || showOnboarding }, set: { newValue in
            if !newValue { hasCompletedOnboarding = true; showOnboarding = false }
        })) {
            WelcomeView()
        }
    }
}

// MARK: - Models

struct SamplePost: Identifiable {
    let id = UUID()
    let title: String
    let style: ArtStyle
    let upvotes: String
    let comments: String
    let awards: String

    static let examples: [SamplePost] = [
        SamplePost(
            title: "Neighborhood Sketch",
            style: .neighborhoodA,
            upvotes: "30 K", comments: "467", awards: "1"
        ),
        SamplePost(
            title: "Riverside Street",
            style: .neighborhoodB,
            upvotes: "2.4 K", comments: "112", awards: "3"
        ),
        SamplePost(
            title: "Purple Hillside",
            style: .neighborhoodC,
            upvotes: "9.1 K", comments: "329", awards: "7"
        )
    ]
}

enum ArtStyle {
    case neighborhoodA
    case neighborhoodB
    case neighborhoodC
}

// MARK: - Views

struct FeedPostCard: View {
    let post: SamplePost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                PostArtworkView(style: post.style)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Text(post.title)
                .font(BrushFont.title(20))
                .foregroundStyle(BrushTheme.textBlue)

            FeedActionsRow(upvotes: post.upvotes, comments: post.comments, awards: post.awards)
        }
        .padding(14)
        .brushGlass(cornerRadius: 22)
    }
}

struct FirstPostPlaceholderCard: View {
    var onCreate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [.pink, .orange, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 220)
                    .blur(radius: 10)

                VStack(spacing: 10) {
                    Image(systemName: "scribble.variable")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))

                    Button(action: onCreate) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("Let’s create your first post")
                        }
                    }
                    .buttonStyle(BrushTheme.BrushButtonStyle())
                }
            }

            // Optional helper text under the placeholder
            Text("Your feed will show your drawings here.")
                .font(BrushFont.body(15))
                .foregroundStyle(BrushTheme.textBlue.opacity(0.8))
        }
        .padding(14)
        .brushGlass(cornerRadius: 22)
    }
}

struct FeedActionsRow: View {
    let upvotes: String
    let comments: String
    let awards: String

    var body: some View {
        HStack(spacing: 10) {
            Pill(icon: "arrow.up", trailingIcon: "arrow.down", text: upvotes)
            Pill(icon: "bubble.left", text: comments)
            Pill(icon: "rosette", text: awards)
            Pill(icon: "square.and.arrow.up", text: "Share")
        }
    }

    @ViewBuilder
    private func Pill(icon: String, trailingIcon: String? = nil, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            if let trailing = trailingIcon {
                Text(text)
                    .font(BrushFont.body(14))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                Image(systemName: trailing)
            } else {
                Text(text)
                    .font(BrushFont.body(14))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .foregroundStyle(BrushTheme.textBlue)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(Color.white.opacity(0.22))
        )
        .overlay(
            Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct PostArtworkView: View {
    let style: ArtStyle

    var body: some View {
        let hue: Double
        switch style {
        case .neighborhoodA: hue = 0
        case .neighborhoodB: hue = 35
        case .neighborhoodC: hue = -35
        }

        return NeighborhoodArtView()
            .hueRotation(.degrees(hue))
            .drawingGroup()
    }
}

struct NeighborhoodArtView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Sky
                LinearGradient(colors: [Color(red: 0.78, green: 0.90, blue: 1.0), Color(red: 0.52, green: 0.75, blue: 1.0)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                // Grass
                VStack { Spacer() }
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(colors: [Color(red: 0.65, green: 0.88, blue: 0.58), Color(red: 0.44, green: 0.75, blue: 0.46)], startPoint: .top, endPoint: .bottom)
                            .frame(height: h * 0.48)
                            .offset(y: h * 0.26)
                    )

                // Road - diagonal slice on the left
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h * 0.20))
                    p.addLine(to: CGPoint(x: w * 0.40, y: 0))
                    p.addLine(to: CGPoint(x: w * 0.54, y: 0))
                    p.addLine(to: CGPoint(x: 0.14 * w, y: h))
                    p.addLine(to: CGPoint(x: 0, y: h))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [Color(white: 0.22), Color(white: 0.16)], startPoint: .top, endPoint: .bottom))
                .overlay(
                    Path { p in
                        p.move(to: CGPoint(x: 0.07 * w, y: h))
                        p.addLine(to: CGPoint(x: 0.46 * w, y: 0))
                    }
                    .stroke(Color.white.opacity(0.35), style: StrokeStyle(lineWidth: 3, dash: [10, 8]))
                )

                // House group on the right
                let houseW = w * 0.40
                let houseH = h * 0.44
                let houseX = w * 0.58
                let houseY = h * 0.42

                // House body
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white)
                    .frame(width: houseW, height: houseH)
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
                    .position(x: houseX + houseW/2 - 8, y: houseY)

                // Roof
                Path { p in
                    let baseY = houseY - houseH/2
                    p.move(to: CGPoint(x: houseX - 8, y: baseY))
                    p.addLine(to: CGPoint(x: houseX + houseW/2 - 8, y: baseY - houseH * 0.30))
                    p.addLine(to: CGPoint(x: houseX + houseW - 8, y: baseY))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [Color(red: 0.05, green: 0.45, blue: 0.45), Color(red: 0.02, green: 0.35, blue: 0.35)], startPoint: .leading, endPoint: .trailing))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)

                // Door
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.85, green: 0.45, blue: 0.35))
                    .frame(width: houseW * 0.16, height: houseH * 0.38)
                    .position(x: houseX + houseW * 0.18, y: houseY + houseH * 0.10)

                // Windows
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.85, green: 0.95, blue: 1.0))
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.black.opacity(0.15), lineWidth: 1))
                        .frame(width: houseW * 0.18, height: houseH * 0.22)
                        .position(x: houseX + houseW * (0.42 + 0.18 * CGFloat(i)), y: houseY - houseH * 0.06)
                }

                // Trees (simple stylized circles)
                Group {
                    tree(x: w * 0.12, y: h * 0.74, scale: 1.0)
                    tree(x: w * 0.24, y: h * 0.68, scale: 0.85)
                    tree(x: w * 0.36, y: h * 0.78, scale: 1.2)
                    tree(x: w * 0.70, y: h * 0.78, scale: 0.9)
                }

                // Water slice top-right for color interest
                Path { p in
                    p.move(to: CGPoint(x: w * 0.74, y: 0))
                    p.addLine(to: CGPoint(x: w, y: 0))
                    p.addLine(to: CGPoint(x: w, y: h * 0.26))
                    p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.34))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [Color(red: 0.03, green: 0.45, blue: 0.85), Color(red: 0.01, green: 0.35, blue: 0.75)], startPoint: .top, endPoint: .bottom))
                .opacity(0.85)
            }
        }
    }

    @ViewBuilder
    private func tree(x: CGFloat, y: CGFloat, scale: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [Color(red: 0.52, green: 0.78, blue: 0.34), Color(red: 0.32, green: 0.60, blue: 0.22)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 60 * scale, height: 60 * scale)
                .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 2)
            Rectangle()
                .fill(Color(red: 0.45, green: 0.30, blue: 0.20))
                .frame(width: 8 * scale, height: 28 * scale)
                .offset(y: 40 * scale / 2)
        }
        .position(x: x, y: y)
    }
}

#Preview {
    NavigationStack { HomeView() }
}
