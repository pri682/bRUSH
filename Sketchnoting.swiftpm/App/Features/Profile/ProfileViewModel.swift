import Foundation

class ProfileViewModel: ObservableObject {
    // Basic state for the Profile View, can be expanded later
    @Published var userName: String = "User Profile Name"
}
