import Foundation
import Combine
import FirebaseAuth // Assuming this is present in your full file

// MARK: - AuthError
public enum AuthError: LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case notAuthenticated
    case backend(String)

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid username or password."
        case .userAlreadyExists: return "An account with this email already exists."
        case .notAuthenticated: return "Not authenticated."
        case .backend(let message): return message
        }
    }
}

// MARK: - AppUser
public struct AppUser: Equatable {
    public let id: String
    public let email: String
    public let displayName: String?
}

// MARK: - AuthProviding Protocol
public protocol AuthProviding {
    var currentUser: AppUser? { get }
    func signIn(email: String, password: String) async throws -> AppUser
    func signUp(email: String, password: String) async throws -> AppUser
    func signOut() async throws
    // ✨ NEW: Function to delete the currently authenticated user
    func deleteUser() async throws
}

// MARK: - InMemoryAuthProvider
final class InMemoryAuthProvider: AuthProviding {
    private var users: [String: (password: String, displayName: String?)] = [:]
    private(set) var currentUser: AppUser?

    func signIn(email: String, password: String) async throws -> AppUser {
        guard let entry = users[email.lowercased()], entry.password == password else {
            throw AuthError.invalidCredentials
        }
        let user = AppUser(id: UUID().uuidString, email: email, displayName: entry.displayName)
        currentUser = user
        return user
    }

    func signUp(email: String, password: String) async throws -> AppUser {
        let key = email.lowercased()
        guard users[key] == nil else { throw AuthError.userAlreadyExists }
        users[key] = (password, nil)
        let user = AppUser(id: UUID().uuidString, email: email, displayName: nil)
        currentUser = user
        return user
    }

    func signOut() async throws {
        currentUser = nil
    }
    
    // ✨ NEW: Implementation for in-memory deletion
    func deleteUser() async throws {
        guard let user = currentUser else { throw AuthError.notAuthenticated }
        // In-memory removal logic
        users.removeValue(forKey: user.email.lowercased())
        currentUser = nil
    }
}

// MARK: - GoogleSignInProviding Protocol
protocol GoogleSignInProviding {
    @MainActor
    func signInWithGoogle() async throws -> AppUser
}

// MARK: - AuthService
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var user: AppUser?
    private let provider: AuthProviding

    init(provider: AuthProviding? = nil) {
        #if canImport(FirebaseAuth)
        // NOTE: FirebaseAuthProvider must be defined in another file and conform to AuthProviding
        let chosen: AuthProviding = provider ?? FirebaseAuthProvider()
        #else
        let chosen: AuthProviding = provider ?? InMemoryAuthProvider()
        #endif
        self.provider = chosen
        self.user = chosen.currentUser
    }
    
    // 💡 HELPER: Maps cryptic system/Firebase errors to user-friendly AuthErrors.
    private func mapAuthError(_ error: Error) -> Error {
        let description = error.localizedDescription
        
        // Map common sign-in errors
        if description.contains("malformed or has expired") ||
           description.contains("wrong password") ||
           description.contains("no user record") {
            return AuthError.invalidCredentials
        }
        
        // Map invalid email format
        if description.contains("email address is badly formatted") {
            return AuthError.backend("Invalid email address.")
        }

        // Map errors related to delete/reauth, which Firebase often returns
        if description.contains("requires recent login") {
            return AuthError.backend("To delete your account, please sign out and sign in again to re-authenticate.")
        }
        
        if let authError = error as? AuthError {
            return authError
        }
        
        return AuthError.backend(description)
    }

    @MainActor
    func signIn(email: String, password: String) async throws {
        do {
            let u = try await provider.signIn(email: email, password: password)
            self.user = u
        } catch {
            throw mapAuthError(error)
        }
    }

    @MainActor
    func signUp(email: String, password: String) async throws {
        do {
            let u = try await provider.signUp(email: email, password: password)
            self.user = u
        } catch {
            throw mapAuthError(error)
        }
    }

    @MainActor
    func signInWithGoogle() async {
        if let googleProvider = provider as? GoogleSignInProviding {
            do {
                let u = try await googleProvider.signInWithGoogle()
                self.user = u
            } catch {
                print("Auth Google signIn error: \(error)")
            }
        } else {
            print("Google Sign-In not available in current build.")
        }
    }

    @MainActor
    func signOut() async {
        do {
            try await provider.signOut()
            self.user = nil
        } catch {
            print("Auth signOut error: \(error)")
        }
    }
    
    // ✨ NEW: Delete User function in AuthService
    @MainActor
    func deleteUser() async throws {
        do {
            try await provider.deleteUser()
            self.user = nil // Clear local user state upon successful deletion
        } catch {
            throw mapAuthError(error) // Map and re-throw the error
        }
    }
}
