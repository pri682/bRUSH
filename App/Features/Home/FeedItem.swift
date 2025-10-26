//
//  FeedItem.swift
//  brush
//
//  Created by Vaidic Soni on 10/26/25.
//

import Foundation

struct FeedItem: Identifiable {
    let id: String               // Firestore document ID
    let userId: String           // UID of the user who made the post
    let displayName: String      // Full display name from /users/{uid}
    let username: String         // "@username" style handle
    let imageURL: String         // Firebase Storage image URL
    let medalGold: Int
    let medalSilver: Int
    let medalBronze: Int
    let date: String
    let createdAt: Date?
    
    // MARK: - Computed properties
    var upVotes: Int { medalGold * 3 + medalSilver * 2 + medalBronze }
    var downVotes: Int { 0 }
    var comments: Int { 0 }
    var awards: Int { medalGold + medalSilver + medalBronze }
    
    // Profile image placeholder for UI
    var profileSystemImageName: String { "person.circle.fill" }
}
