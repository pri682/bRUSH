import Foundation
import Combine

struct LocalUserProfile: Codable {
    let firstName: String
    let lastName: String
    let displayName: String
    let email: String
    let uid: String
    let photoURL: String? // For future profile photos
    
    // Convenience initializer without photo
    init(firstName: String, lastName: String, displayName: String, email: String, uid: String, photoURL: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName
        self.email = email
        self.uid = uid
        self.photoURL = photoURL
    }
}

class LocalUserStorage: ObservableObject {
    static let shared = LocalUserStorage()
    
    @Published var currentProfile: LocalUserProfile?
    
    private let userDefaultsKey = "current_user_profile"
    
    private init() {
        loadProfile()
    }
    
    func saveProfile(_ profile: LocalUserProfile) {
        currentProfile = profile
        
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let profile = try? JSONDecoder().decode(LocalUserProfile.self, from: data) else {
            currentProfile = nil
            return
        }
        currentProfile = profile
    }
    
    func clearProfile() {
        currentProfile = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}