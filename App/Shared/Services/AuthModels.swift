import Foundation
import FirebaseAuth // Required for Firebase Auth interaction

// --- 1a. Error Handling Model ---
enum AppAuthError: Error, LocalizedError {
    case invalidEmail
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case networkError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "The email address is badly formatted."
        case .wrongPassword: return "The password is not valid or the user is disabled."
        case .userNotFound: return "No user found with this email."
        case .emailAlreadyInUse: return "This email is already in use by another account."
        case .networkError(let msg): return "Network error: \(msg)"
        case .unknown(let msg): return "An unknown error occurred: \(msg)"
        }
    }
}

// --- 1b. Auth User Model (Simplified) ---
struct AuthUser {
    let id: String // This is the Firebase UID
    let email: String?
}

// Note: AuthService is implemented in AuthService.swift, not here.
// This file contains only the data models and types.
