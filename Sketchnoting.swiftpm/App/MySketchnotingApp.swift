import SwiftUI

@main
struct MySketchnotingApp: App {
    @StateObject var dataModel = DataModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                // Home Tab
                NavigationStack {
                    Text("Home")
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }

                // Friends Tab
                NavigationStack {
                    Text("Friends")
                }
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }

                // Drawings Tab (center, with ring highlight)
                NavigationStack {
                    GridView()
                }
                .tabItem {
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

                // Leaderboard Tab
                NavigationStack {
                    Text("Leaderboard")
                }
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy")
                }

                // Profile Tab
                NavigationStack {
                    Text("Profile")
                }
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            }
            .environmentObject(dataModel)
        }
    }
}
