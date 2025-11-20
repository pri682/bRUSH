import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AwardType: String {
    case gold
    case silver
    case bronze
}

struct AwardCounts {
    let gold: Int
    let silver: Int
    let bronze: Int
}

final class AwardServiceFirebase {
    
    static let shared = AwardServiceFirebase()
    private let db = Firestore.firestore()
    
    private init() {}
    
    private func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }
    
    func setAward(_ type: AwardType, forPostOwner userId: String) async throws {
        guard let giverUid = Auth.auth().currentUser?.uid else { return }
        guard giverUid != userId else { return }  // no self awards

        let awardRef = db.collection("dailyFeed")
            .document(userId)
            .collection("awards")
            .document(giverUid)

        let dateKey = todayKey()
        let usageRef = db.collection("awardUsage")
            .document("\(giverUid)_\(dateKey)")
        
        // dont care about return value
     _ = try await db.runTransaction { transaction, errorPointer in

            let usageSnapshot = try? transaction.getDocument(usageRef)

            var goldUsed   = usageSnapshot?.get("goldUsed") as? Bool ?? false
            var silverUsed = usageSnapshot?.get("silverUsed") as? Bool ?? false
            var bronzeUsed = usageSnapshot?.get("bronzeUsed") as? Bool ?? false

            // stop if already used today
            switch type {
            case .gold where goldUsed: return nil
            case .silver where silverUsed: return nil
            case .bronze where bronzeUsed: return nil
            default: break
            }

            // mark usage
            switch type {
            case .gold:   goldUsed = true
            case .silver: silverUsed = true
            case .bronze: bronzeUsed = true
            }

            transaction.setData([
                "giverUid": giverUid,
                "date": dateKey,
                "goldUsed": goldUsed,
                "silverUsed": silverUsed,
                "bronzeUsed": bronzeUsed
            ], forDocument: usageRef, merge: true)

            // Update award doc for this post owner
            let awardSnapshot = try? transaction.getDocument(awardRef)

            var gold  = awardSnapshot?.get("gold") as? Bool ?? false
            var silver = awardSnapshot?.get("silver") as? Bool ?? false
            var bronze = awardSnapshot?.get("bronze") as? Bool ?? false

            // Only one medal active per post (for each users award doc)
            switch type {
            case .gold:
                gold = true; silver = false; bronze = false
            case .silver:
                silver = true; gold = false; bronze = false
            case .bronze:
                bronze = true; gold = false; silver = false
            }

            transaction.setData([
                "giverUid": giverUid,
                "gold": gold,
                "silver": silver,
                "bronze": bronze,
                "updatedAt": FieldValue.serverTimestamp()
            ], forDocument: awardRef, merge: true)

            return nil
        }
    }

    func fetchAwardCounts(forPostOwner userId: String) async throws -> AwardCounts {
        let snapshot = try await db.collection("dailyFeed")
                .document(userId)
                .collection("awards")
                .getDocuments()

            var gold = 0
            var silver = 0
            var bronze = 0

            for doc in snapshot.documents {
                if doc.get("gold") as? Bool ?? false { gold += 1 }
                if doc.get("silver") as? Bool ?? false { silver += 1 }
                if doc.get("bronze") as? Bool ?? false { bronze += 1 }
            }
        
        return AwardCounts(gold: gold, silver: silver, bronze: bronze)
    }
}
