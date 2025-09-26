import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSignUp: Bool = false
    @Published private(set) var user: AppUser? = nil   // ✅ use your custom AppUser

    private let auth = AuthService.shared

    init() {
        self.user = auth.user   // ✅ this matches AppUser now
    }

    func toggleSignUp() {
        isSignUp.toggle()
    }

    func signIn() async {
        await auth.signIn(email: email, password: password)
        self.user = auth.user
    }

    func signUp() async {
        await auth.signUp(email: email, password: password)
        self.user = auth.user
    }

//    func signInWithGoogle() async {
//        await auth.signInWithGoogle()
//        self.user = auth.user
//    }
    
    
}
