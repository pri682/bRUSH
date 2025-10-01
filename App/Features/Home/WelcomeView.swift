import SwiftUI
import Combine

struct WelcomeView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    var onGetStarted: (() -> Void)? = nil

    var body: some View {
        ZStack {
            HomeBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Branding
                VStack(spacing: 10) {
                    BrandIcon(size: 120, preferAsset: true)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        .accessibilityLabel("Brush app logo")

                    Text("Brush")
                        .font(BrushFont.title(38))
                        .foregroundStyle(BrushTheme.textBlue)
                        .accessibilityAddTraits(.isHeader)
                }
                .padding(.top, 24)

                // Stacked art cards (no photos)
                ZStack {
                    ArtCardView(colors: [.orange, .red])
                        .frame(width: 220, height: 320)
                        .rotationEffect(.degrees(-12))
                        .offset(x: -70, y: 40)
                        .shadow(color: .black.opacity(0.25), radius: 20, y: 10)

                    ArtCardView(colors: [.blue, .purple])
                        .frame(width: 280, height: 380)
                        .rotationEffect(.degrees(-2))
                        .shadow(color: .black.opacity(0.3), radius: 28, y: 16)
                        .overlay(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.9), lineWidth: 3)
                                .frame(height: 36)
                                .padding(.horizontal, 28)
                                .padding(.bottom, 18)
                                .accessibilityHidden(true)
                        }
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "heart")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.ultraThinMaterial, in: Circle())
                                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                                .padding(16)
                        }

                    ArtCardView(colors: [.green, .teal])
                        .frame(width: 220, height: 320)
                        .rotationEffect(.degrees(12))
                        .offset(x: 70, y: 80)
                        .shadow(color: .black.opacity(0.25), radius: 20, y: 10)

                    ReactionBubble(text: "🔥💎💜")
                        .offset(x: -40, y: -110)

                    ReactionBubble(icon: "star.fill")
                        .offset(x: 120, y: -10)

                    AvatarBubble()
                        .offset(x: 130, y: 120)

                    HeartBubble()
                        .offset(x: -140, y: 80)
                }
                .padding(.vertical, 8)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Artwork previews")

                // Featured people row (stories-style)
                PeopleStoriesRow(names: ["Alex","Sam","Jordan","Taylor","Morgan","Riley","Casey","Jamie","Avery","Kai"])
                    .padding(.horizontal, 8)
                    .padding(.top, 4)

                // Headline
                Text("Sketch. Design. Inspire.")
                    .font(BrushFont.title(24))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BrushTheme.textBlue.opacity(0.95))
                    .padding(.horizontal)

                Spacer(minLength: 10)

                // CTA
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasCompletedOnboarding = true
                    }
                    onGetStarted?()
                }) {
                    HStack(spacing: 10) {
                        Text("Get Started")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(BrushTheme.BrushButtonStyle())
                .padding(.bottom, 24)
            }
            .padding(.horizontal)
        }
    }
}

private struct ArtCardView: View {
    var colors: [Color]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))

            // Decorative shapes to feel like abstract art
            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: 120, height: 120)
                .blur(radius: 2)
                .offset(x: -50, y: -60)

            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 200, height: 200)
                .offset(x: 60, y: 40)

            RoundedRectangle(cornerRadius: 2)
                .fill(.white.opacity(0.18))
                .frame(height: 3)
                .rotationEffect(.degrees(-18))
                .padding(32)
                .offset(y: -20)

            RoundedRectangle(cornerRadius: 2)
                .fill(.white.opacity(0.12))
                .frame(height: 3)
                .rotationEffect(.degrees(-18))
                .padding(48)
                .offset(y: 10)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct ReactionBubble: View {
    var text: String? = nil
    var icon: String? = nil

    var body: some View {
        Group {
            if let text = text {
                Text(text)
                    .font(.system(size: 14))
            } else if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        .accessibilityHidden(true)
    }
}

private struct AvatarBubble: View {
    var body: some View {
        Circle()
            .fill(LinearGradient(colors: [.purple, .pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 68, height: 68)
            .overlay {
                Circle()
                    .strokeBorder(AngularGradient(gradient: Gradient(colors: [.pink, .orange, .yellow, .green, .blue, .purple, .pink]), center: .center), lineWidth: 3)
                    .padding(2)
            }
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            .accessibilityHidden(true)
    }
}

private struct HeartBubble: View {
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 18))
            .foregroundStyle(.white)
            .padding(12)
            .background(
                Circle()
                    .fill(LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
            .accessibilityHidden(true)
    }
}

private struct PeopleStoriesRow: View {
    let names: [String]

    private var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [BrushTheme.pink, BrushTheme.orange]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(names, id: \.self) { name in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(gradient)
                            .frame(width: 64, height: 64)
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
                        Text(name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .accessibilityLabel("Featured creators")
    }
}

private struct OnboardingPreviewSwitcher: View {
    @State private var showMain = false
    var body: some View {
        Group {
            if showMain {
                MainTabView()
            } else {
                WelcomeView(onGetStarted: { showMain = true })
            }
        }
    }
}

#Preview("Onboarding Flow") {
    OnboardingPreviewSwitcher()
        .environmentObject(DataModel())
}

#Preview("Welcome Only") {
    WelcomeView()
}
