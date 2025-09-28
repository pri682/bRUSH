import Foundation

protocol AccountDeletionProviding {
    func deleteCurrentUser() async throws
}

#if canImport(FirebaseAuth)
import FirebaseAuth

final class FirebaseAccountDeletionProvider: AccountDeletionProviding {
    func deleteCurrentUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.notAuthenticated
        }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            user.delete { error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            }
        }
    }
}
#endif

final class AccountDeletionService {
    static let shared = AccountDeletionService()
    
    private let provider: AccountDeletionProviding
    
    init(provider: AccountDeletionProviding? = nil) {
        #if canImport(FirebaseAuth)
        self.provider = provider ?? FirebaseAccountDeletionProvider()
        #else
        self.provider = provider ?? MockAccountDeletionProvider()
        #endif
    }
    
    func deleteAccount() async throws {
        try await provider.deleteCurrentUser()
    }
}

// Mock implementation for builds without Firebase
private struct MockAccountDeletionProvider: AccountDeletionProviding {
    func deleteCurrentUser() async throws {
        // In-memory provider: nothing to delete from server
    }
}