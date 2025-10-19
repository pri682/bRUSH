import Foundation
import FirebaseFirestore
import FirebaseCore

struct HandleHit {
    let uid: String
    let handle: String
    let displayName: String
}

final class HandleServiceFirebase {
    private let db = Firestore.firestore()
    
    // Prefix search by @handle (case insensitive). Min length guard (>= 2) recommended in caller.
    func searchHandles(prefix raw: String, limit: Int = 20) async throws -> [HandleHit] {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }

        let prefix = raw.replacingOccurrences(of: "@", with: "").lowercased().trimmingCharacters(in: .whitespaces)
        guard !prefix.isEmpty else { return [] }

        let users = db.collection("users")
       
        // as typed
        let q1 = users
            .order(by: "displayName")
            .start(at: [prefix])
            .end(at: [prefix + "\u{f8ff}"])
            .limit(to: limit)

        // capital first letter
        let cap = prefix.prefix(1).uppercased() + prefix.dropFirst()
        let q2 = users
            .order(by: "displayName")
            .start(at: [cap])
            .end(at: [cap + "\u{f8ff}"])
            .limit(to: limit)

        let (snap1, snap2) = try await (q1.getDocuments(), q2.getDocuments())
        
        var seen = Set<String>()
        var hits: [HandleHit] = []

        for doc in (snap1.documents + snap2.documents) {
            let uid = doc.documentID
            guard !seen.contains(uid) else { continue }
            let dn = (doc.data()["displayName"] as? String) ?? ""
                hits.append(HandleHit(uid: uid, handle: dn, displayName: dn))
                seen.insert(uid)
            if hits.count >= limit { break }
        }
        print("[HandleServiceFirebase] prefix='\(prefix)' -> \(hits.count) hit(s)")
        return hits
    }
}
