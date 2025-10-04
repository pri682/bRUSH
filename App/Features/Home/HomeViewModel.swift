import Foundation
import SwiftUI
import Combine

struct FeedItem: Identifiable {
    let id = UUID()
    let displayName: String
    let username: String
    let profileSystemImageName: String
    let artSystemImageName: String?
    let artImageName: String?
    let medalGold: Int
    let medalSilver: Int
    let medalBronze: Int
    let upVotes: Int
    let downVotes: Int
    let comments: Int
    let awards: Int
}

final class HomeViewModel: ObservableObject {
    // Centralized app title in case branding changes again
    @Published var appTitle: String = "Brush"

    // Onboarding storage
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    // Tagline options to keep the UI lively
    let taglines: [String] = [
        "Sketch. Design. Inspire.",
        "Bold color. Smooth strokes.",
        "From idea to art in a swipe.",
    ]

    // Hard-coded feed data for now
    @Published var feedItems: [FeedItem] = [
        FeedItem(
            displayName: "Ava Thompson",
            username: "@avt",
            profileSystemImageName: "person.circle.fill",
            artSystemImageName: "photo.on.rectangle.angled",
            artImageName: "sample_drawing",
            medalGold: 12,
            medalSilver: 5,
            medalBronze: 2,
            upVotes: 3800,
            downVotes: 120,
            comments: 4100,
            awards: 3
        ),
        FeedItem(
            displayName: "Liam Chen",
            username: "@lchen",
            profileSystemImageName: "person.crop.circle.fill",
            artSystemImageName: "scribble",
            artImageName: nil,
            medalGold: 7,
            medalSilver: 9,
            medalBronze: 1,
            upVotes: 2450,
            downVotes: 80,
            comments: 1730,
            awards: 1
        ),
        FeedItem(
            displayName: "Sofia Martinez",
            username: "@sofiam",
            profileSystemImageName: "person.circle.fill",
            artSystemImageName: "paintpalette.fill",
            artImageName: nil,
            medalGold: 20,
            medalSilver: 11,
            medalBronze: 4,
            upVotes: 5200,
            downVotes: 160,
            comments: 2960,
            awards: 5
        )
    ]
}
