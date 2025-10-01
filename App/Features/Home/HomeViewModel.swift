import Foundation
import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    // Centralized app title in case branding changes again
    @Published var appTitle: String = "Brush"

    // (Onboarding removed)
    // @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    // Tagline options to keep the UI lively (optional; still usable elsewhere)
    let taglines: [String] = [
        "Sketch. Design. Inspire.",
        "Bold color. Smooth strokes.",
        "From idea to art in a swipe.",
    ]
}
