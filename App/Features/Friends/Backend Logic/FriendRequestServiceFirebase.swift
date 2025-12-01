import Foundation
import FirebaseFirestore
import FirebaseCore

struct IncomingRequestDTO {
    let fromUid: String
    let fromHandle: String
    let fromDisplay: String
    let createdAt: Date?
}

final class FriendRequestServiceFirebase {
    private let db = Firestore.firestore()
    private var incomingRequestsListener: ListenerRegistration? // New: Listener property

    // Send a request: creates /friendRequests/{toUid}/incoming/{fromUid}
    func sendRequest(fromUid: String, fromHandle: String, fromDisplay: String, toUid: String) async throws {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }

        let ref = db.collection("friendRequests")
            .document(toUid)
            .collection("incoming")
            .document(fromUid)

        try await ref.setData([
            "fromUid": fromUid,
            "fromHandle": "@\(fromHandle)",
            "fromDisplay": fromDisplay,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    // List incoming for me: /friendRequests/{me}/incoming/* (One-time fetch - KEPT FOR REFERENCE, but not used by ViewModel)
    func fetchIncoming(forUid: String) async throws -> [IncomingRequestDTO] {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }

        let snap = try await db.collection("friendRequests")
            .document(forUid)
            .collection("incoming")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snap.documents.compactMap { d in
            let data = d.data()
            return IncomingRequestDTO(
                fromUid: data["fromUid"] as? String ?? d.documentID,
                fromHandle: data["fromHandle"] as? String ?? "",
                fromDisplay: data["fromDisplay"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
            )
        }
    }
    
    // NEW: Real-time listener for incoming requests
    func startListeningForIncoming(forUid uid: String, completion: @escaping ([IncomingRequestDTO]) -> Void) {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
        
        // Stop any existing listener first to prevent duplicates
        stopListeningForIncoming()
        
        incomingRequestsListener = db.collection("friendRequests")
            .document(uid)
            .collection("incoming")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print("Error listening for incoming requests: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let dtos: [IncomingRequestDTO] = snapshot.documents.compactMap { d in
                    let data = d.data()
                    return IncomingRequestDTO(
                        fromUid: data["fromUid"] as? String ?? d.documentID,
                        fromHandle: data["fromHandle"] as? String ?? "",
                        fromDisplay: data["fromDisplay"] as? String ?? "",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
                    )
                }
                // Call the completion handler with the new data
                completion(dtos)
            }
    }
    
    // NEW: Function to stop the real-time listener
    func stopListeningForIncoming() {
        incomingRequestsListener?.remove()
        incomingRequestsListener = nil
    }

    // Accept: create friendships both ways, then delete request doc
    func accept(me: String, other: String) async throws {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
        let batch = db.batch()
        let since = FieldValue.serverTimestamp()

        let a = db.collection("friendships").document(me).collection("friends").document(other)
        let b = db.collection("friendships").document(other).collection("friends").document(me)
        batch.setData(["since": since], forDocument: a, merge: true)
        batch.setData(["since": since], forDocument: b, merge: true)

        let req = db.collection("friendRequests").document(me).collection("incoming").document(other)
        batch.deleteDocument(req)

        try await batch.commit()
    }

    // Decline: just delete request doc
    func decline(me: String, other: String) async throws {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
        try await db.collection("friendRequests")
            .document(me)
            .collection("incoming")
            .document(other)
            .delete()
    }
    // Deletes both friendship edges:
    // /friendships/{me}/friends/{other} and /friendships/{other}/friends/{me}
    func removeFriend(me: String, other: String) async throws {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
        let batch = db.batch()
        let a = db.collection("friendships").document(me).collection("friends").document(other)
        let b = db.collection("friendships").document(other).collection("friends").document(me)
        batch.deleteDocument(a)
        batch.deleteDocument(b)
        try await batch.commit()
    }
    
    // precise: did fromUid send a friend request to toUid
    func hasPending(fromUid: String, toUid: String) async throws -> Bool {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
        let doc = try await db
            .collection("friendRequests").document(toUid)
            .collection("incoming").document(fromUid)
            .getDocument()
        return doc.exists
    }
}
