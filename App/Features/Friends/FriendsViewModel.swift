import Foundation
import SwiftUI
import Combine

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    
    func loadMock() {
        friends = [
            Friend(name: "Ted", handle: "@grumpyoldman"),
            Friend(name: "Aaron", handle: "@lunchalone"),
            Friend(name: "Jeffrey", handle: "@dahmer")
        ]
    }
}

