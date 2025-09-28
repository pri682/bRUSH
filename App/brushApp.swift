//
//  brushApp.swift
//  brush
//
//  Created by Meidad Troper on 9/25/25.
//

import SwiftUI
import PencilKit // Keep this if any of your files in the *current* module use PencilKit
import UserNotifications

@main
struct brushApp: App {
    // Assuming DataModel and NotificationManager are defined elsewhere and ready to use
    @StateObject var dataModel = DataModel()
    
    init() {
        // Request notification permission as soon as the app launches
        NotificationManager.shared.requestPermission()
        NotificationManager.shared.scheduleDailyReminders(hour: 20, minute: 0)
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                // 1. Home Tab
                NavigationStack {
                    HomeView()
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }

                // 2. Friends Tab
                NavigationStack {
                    FriendsView()
                }
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }

                // 3. Drawings Tab
                NavigationStack {
                    //DrawingsGridView()
                }
                .tabItem {
                    // It's best to move this custom Vstack to a reusable struct
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

                // 4. Leaderboard Tab
                NavigationStack {
                    LeaderboardView()
                }
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy")
                }
                
                // 5. Profile Tab - UNCOMMENTED AND CORRECTED
                NavigationStack {
                    ProfileView() // Assuming ProfileView exists
                } // <-- THIS CLOSING BRACE WAS MISSING/COMMENTED
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            } // <-- CLOSES TabView
            .environmentObject(dataModel) // Inject the DataModel
        } // <-- CLOSES WindowGroup
    } // <-- CLOSES body
} // <-- CLOSES struct brushApp

// Note: You must define placeholder views for HomeView, FriendsView, etc.,
// and the DataModel and NotificationManager to make this compile fully.
// The code above focuses on correcting the syntax error.
