import SwiftUI
import PencilKit // Keep this if any of your files in the *current* module use PencilKit

// DELETE the following lines:
// import Home
// import Friends
// import Drawings
// import Leaderboard
// import Profile

@main
struct MySketchnotingApp: App {
    @StateObject var dataModel = DataModel() // This file is now in Shared/Models
    
    var body: some Scene {
        WindowGroup {
            TabView {
                // Home Tab (Uses the new HomeView)
                NavigationStack {
                    HomeView() // Works without import because it's in the same module
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }

                // Friends Tab (Uses the new FriendsView)
                NavigationStack {
                    FriendsView()
                }
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }

                // Drawings Tab (Uses the renamed DrawingsGridView)
                NavigationStack {
                    DrawingsGridView()
                }
                .tabItem {
                    // It's best to move this custom Vstack to the new TabIconOverlay.swift in Shared/Utilities
                    VStack {
                        Image(systemName: "pencil.and.outline")
                             .overlay(
                                 Circle()
                                     .stroke(Color.accentColor, lineWidth: 2)
                                     .frame(width: 32, height: 32)
                             )
                         Text("Drawings")
                    }
                }

                // Leaderboard Tab (Uses the new LeaderboardView)
                NavigationStack {
                    LeaderboardView()
                }
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy")
                }

                // Profile Tab (Uses the new ProfileView)
                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            }
            .environmentObject(dataModel)
        }
    }
}
