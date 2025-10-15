import Foundation
import FirebaseFirestore

struct HandleHit {
    let handle: String     // lowercased handle without @
    let uid: String
    let displayName: String
}

final class HandleServiceFirebase {
    private let db = Firestore.firestore()
    
    // Prefix search by @handle (case insensitive). Min length guard (>= 2) recommended in caller.
    func searchHandles(prefix raw: String, limit: Int = 20) async throws -> [HandleHit] {
        let prefix = raw.replacingOccurrences(of: "@", with: "").lowercased().trimmingCharacters(in: .whitespaces)
        guard !prefix.isEmpty else { return [] }
        // Store handleLower as the document ID in "handles" collection
        let q = db.collection("handles")
            .order(by: FieldPath.documentID())
            .start(at: [prefix])
            .end(at: [prefix + "\u{f8ff}"])
            .limit(to: limit)
        
        let snap = try await q.getDocuments()
        return snap.documents.compactMap { doc in
            let handleLower = doc.documentID
            let data = doc.data()
            guard let uid = data["uid"] as? String else { return nil }
            let displayName = (data["displayName"] as? String) ?? handleLower
            return HandleHit(handle: handleLower, uid: uid, displayName: displayName)
        }
    }
}
