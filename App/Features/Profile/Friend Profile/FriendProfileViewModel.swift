import Foundation
import SwiftUI
import Combine

/**
 * FriendProfileViewModel - ViewModel for managing friend profile data
 * 
 * This ViewModel handles loading and managing a friend's profile information.
 * It's similar to ProfileViewModel but specifically for viewing friend profiles
 * in a read-only manner. It uses the existing UserService to fetch profile data
 * from Firebase Firestore.
 */
@MainActor
class FriendProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The friend's profile data loaded from Firebase
    /// This contains all the friend's information: name, avatar, medals, stats, etc.
    @Published var profile: UserProfile?
    
    /// Indicates whether we're currently loading the friend's profile data
    /// Used to show loading spinner in the UI
    @Published var isLoading = false
    
    /// Error message if profile loading fails
    /// Used to display error state in the UI
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    /// Shared instance of UserService for fetching profile data from Firebase
    /// This is the same service used by the main ProfileViewModel
    private let userService = UserService.shared
    
    // MARK: - Public Methods
    
    /**
     * Loads a friend's profile data from Firebase
     * 
     * This method fetches the complete profile information for a specific friend
     * using their unique identifier. It handles loading states and error conditions.
     * 
     * - Parameter uid: The unique identifier of the friend whose profile to load
     */
    func loadFriendProfile(uid: String) async {
        // Set loading state to true to show loading spinner
        isLoading = true
        // Clear any previous error messages
        errorMessage = nil
        
        do {
            // Fetch the friend's profile data from Firebase using UserService
            let friendProfile = try await userService.fetchProfile(uid: uid)
            // Update the published profile property with the loaded data
            self.profile = friendProfile
        } catch {
            // If loading fails, store the error message for display
            self.errorMessage = error.localizedDescription
        }
        
        // Loading is complete, hide the loading spinner
        isLoading = false
    }
    
    /**
     * Refreshes the friend's profile data
     * 
     * This method reloads the profile data, useful for pull-to-refresh
     * or when you want to get the latest information.
     * 
     * - Parameter uid: The unique identifier of the friend whose profile to refresh
     */
    func refreshProfile(uid: String) async {
        // Simply call loadFriendProfile again to refresh the data
        await loadFriendProfile(uid: uid)
    }
}