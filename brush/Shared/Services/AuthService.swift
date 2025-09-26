import Foundation
import Combine
import FirebaseAuth // Assuming this is present in your full file

public enum AuthError: LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case notAuthenticated
    case backend(String)

    public var errorDescription: String? {
        switch self {
        // 💡 FIX: Set the message to be user-friendly for invalid credentials
        case .invalidCredentials: return "Invalid username or password."
        case .userAlreadyExists: return "An account with this email already exists."
        case .notAuthenticated: return "Not authenticated."
        case .backend(let message): return message
        }
    }
}

public struct AppUser: Equatable {
    public let id: String
    public let email: String
    public let displayName: String?
}

public protocol AuthProviding {
    var currentUser: AppUser? { get }
    func signIn(email: String, password: String) async throws -> AppUser
    func signUp(email: String, password: String) async throws -> AppUser
    func signOut() async throws
}

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
}

protocol GoogleSignInProviding {
    @MainActor
    func signInWithGoogle() async throws -> AppUser
}

final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var user: AppUser?
    private let provider: AuthProviding

    init(provider: AuthProviding? = nil) {
        #if canImport(FirebaseAuth)
        let chosen: AuthProviding = provider ?? FirebaseAuthProvider()
        #else
        let chosen: AuthProviding = provider ?? InMemoryAuthProvider()
        #endif
        self.provider = chosen
        self.user = chosen.currentUser
    }
    
    // 💡 NEW HELPER: Maps cryptic system/Firebase errors to user-friendly AuthErrors.
    private func mapAuthError(_ error: Error) -> Error {
        let description = error.localizedDescription
        
        // Target the cryptic message you reported, as well as common password/email errors.
        if description.contains("malformed or has expired") ||
           description.contains("wrong password") ||
           description.contains("no user record") {
            return AuthError.invalidCredentials
        }
        
        // Map invalid email format (if not caught by ViewModel validation)
        if description.contains("email address is badly formatted") {
            return AuthError.backend("Invalid email address.")
        }
        
        // If it's already one of our custom errors, return it directly.
        if let authError = error as? AuthError {
            return authError
        }
        
        // If it's any other error (like network failure), use the default backend case.
        return AuthError.backend(description)
    }

    @MainActor
    func signIn(email: String, password: String) async throws {
        // 💡 FIX: Wrap in do/catch to intercept and map the provider's error
        do {
            let u = try await provider.signIn(email: email, password: password)
            self.user = u
        } catch {
            throw mapAuthError(error) // Re-throw the mapped error
        }
    }

    @MainActor
    func signUp(email: String, password: String) async throws {
        // 💡 FIX: Wrap in do/catch to intercept and map the provider's error
        do {
            let u = try await provider.signUp(email: email, password: password)
            self.user = u
        } catch {
            throw mapAuthError(error) // Re-throw the mapped error
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
}
