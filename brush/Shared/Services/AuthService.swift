import Foundation
import Combine

public enum AuthError: LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case notAuthenticated
    case backend(String)

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password."
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
        // NOTE: FirebaseAuthProvider must exist elsewhere in your project for this to compile with FirebaseAuth
        #if canImport(FirebaseAuth)
        let chosen: AuthProviding = provider ?? FirebaseAuthProvider()
        #else
        let chosen: AuthProviding = provider ?? InMemoryAuthProvider()
        #endif
        self.provider = chosen
        self.user = chosen.currentUser
    }

    @MainActor
    // 💡 FIX: Mark the method as 'throws'
    func signIn(email: String, password: String) async throws {
        // 💡 FIX: Removed the internal do-catch block, errors will now propagate up
        let u = try await provider.signIn(email: email, password: password)
        self.user = u
    }

    @MainActor
    // 💡 FIX: Mark the method as 'throws'
    func signUp(email: String, password: String) async throws {
        // 💡 FIX: Removed the internal do-catch block, errors will now propagate up
        let u = try await provider.signUp(email: email, password: password)
        self.user = u
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
