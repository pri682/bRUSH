import Foundation
import SwiftUI
import UIKit

// A simple model representing a post in the feed (yours or a friend's)
struct FeedPost: Identifiable, Equatable {
    let id: UUID
    var username: String
    var timestamp: Date
    var preview: UIImage?

    static func ==(lhs: FeedPost, rhs: FeedPost) -> Bool { lhs.id == rhs.id }
}
