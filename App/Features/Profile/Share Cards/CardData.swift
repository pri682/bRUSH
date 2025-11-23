import SwiftUI

// MARK: - Icon and Customization Data Models

/// Defines the available icons for the card.
enum CardIcon: String, CaseIterable, Identifiable {
    case none = "None"
    case user = "User Avatar"
    case gold = "Gold Medal"
    case silver = "Silver Medal"
    case bronze = "Bronze Medal"
    
    var id: String { self.rawValue }
    
    // Simple way to represent the icon using SF Symbols
    var systemName: String {
        switch self {
        case .none: return "circle"
        case .user: return "person.crop.circle.fill"
        case .gold: return "trophy.fill"
        case .silver: return "medal.fill"
        case .bronze: return "star.fill"
        }
    }
    
    // Color logic for the icon
    var iconColor: Color {
        switch self {
        case .none: return .gray
        case .user: return .white
        case .gold: return Color(hex: "#FFD700") ?? .yellow
        case .silver: return Color(hex: "#C0C0C0") ?? .gray
        case .bronze: return Color(hex: "#CD7F32") ?? .brown
        }
    }
}

/// The single source of truth for all card customizations.
struct CardCustomization: Equatable {
    var backgroundColor: Color
    var cardColor: Color
    var cardText: String
    var textColor: Color
    var cardIcon: CardIcon
}

// MARK: - Card Template Metadata

/// Metadata about a single card design template for the carousel.
struct CardTemplate: Identifiable {
    let id = UUID()
    let name: String
    // This holds the unique "Starter Data" for this specific template
    let defaultConfiguration: CardCustomization
    // We use a closure to create the view so we can pass bindings dynamically
    let viewBuilder: (Binding<CardCustomization>) -> AnyView
}
