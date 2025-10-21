import Foundation
import SwiftUI
import Combine

@MainActor
class FriendProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userService = UserService.shared
    
    func loadFriendProfile(uid: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let friendProfile = try await userService.fetchProfile(uid: uid)
            self.profile = friendProfile
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshProfile(uid: String) async {
        await loadFriendProfile(uid: uid)
    }
}

