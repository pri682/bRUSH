import SwiftUI

struct WelcomeView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        ZStack {
            HomeBackground()
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // Logo + App Name
                VStack(spacing: 12) {
                    BrandIcon(size: 140, preferAsset: true)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        .accessibilityLabel("Brush app logo")

                    Text("Brush")
                        .font(BrushFont.title(40))
                        .foregroundStyle(BrushTheme.textBlue)
                        .accessibilityAddTraits(.isHeader)
                }
                .padding(.top, 40)

                // Headline
                Text("Sketch. Design. Inspire.")
                    .font(BrushFont.title(28))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BrushTheme.textBlue)
                    .padding(.horizontal)

                // Supporting points
                VStack(alignment: .leading, spacing: 12) {
                    Label("Create vivid sketches with your brush.", systemImage: "sparkles")
                    Label("Soft gradients and bold colors to match your style.", systemImage: "paintpalette")
                    Label("Share your creations and keep the streak alive.", systemImage: "square.and.arrow.up")
                }
                .font(BrushFont.body(17))
                .foregroundStyle(BrushTheme.textBlue.opacity(0.8))
                .padding(.horizontal, 24)

                Spacer()

                // CTA
                Button(action: { hasCompletedOnboarding = true }) {
                    HStack(spacing: 10) {
                        Text("Get Started")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(BrushTheme.BrushButtonStyle())
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    WelcomeView()
}

