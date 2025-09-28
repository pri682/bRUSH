import SwiftUI

struct HomeView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            HomeBackground(palette: HomeBackground.brandVivid).ignoresSafeArea()
            VStack(spacing: 24) {
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
                
                VStack(spacing: 8) {
                    Text("Welcome Home!")
                        .font(BrushFont.title(34))
                        .foregroundStyle(BrushTheme.textBlue)
                    Text("Bring your ideas to life with bold color and soft gradients.")
                        .font(BrushFont.body(17))
                        .foregroundStyle(BrushTheme.textBlue.opacity(0.8))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                Spacer()

                NavigationLink(destination: DrawingsGridView()) {
                    HStack(spacing: 10) {
                        Image(systemName: "pencil.and.outline")
                        Text("Start Brushing")
                    }
                }
                .buttonStyle(BrushTheme.BrushButtonStyle())
                .brushGlass(cornerRadius: 22)
                .padding(.bottom, 24)
            }
        }
        .fullScreenCover(isPresented: Binding(get: { !hasCompletedOnboarding || showOnboarding }, set: { newValue in
            if !newValue { hasCompletedOnboarding = true; showOnboarding = false }
        })) {
            WelcomeView()
        }
    }
}

#Preview {
    NavigationStack { HomeView() }
}
