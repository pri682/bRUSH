import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var appTitle: String = "bRUSH"
    @Published var feedItems: [FeedItem] = []
    @Published var dailyPrompt: String = "Loading..."
    @Published var isLoadingFeed: Bool = true
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func loadDailyPrompt() async {
        do {
            let snapshot = try await db.collection("prompts").document("daily").getDocument()
            if let data = snapshot.data(), let prompt = data["prompt"] as? String {
                dailyPrompt = prompt
                print("✅ Loaded prompt: \(prompt)")
            } else {
                dailyPrompt = "No prompt found"
            }
        } catch {
            dailyPrompt = "Error loading prompt"
            print("❌ Error loading prompt:", error.localizedDescription)
        }
    }

    // MARK: - Load Feed (Friends + Own)
    func loadFeed() async {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("❌ No logged in user found")
            return
        }

        isLoadingFeed = true
        defer { isLoadingFeed = false }

        do {
            // 1️⃣ Fetch all friend IDs for the current user
            let friendsSnapshot = try await db.collection("friendships")
                .document(currentUID)
                .collection("friends")
                .getDocuments()

            var userAndFriends = friendsSnapshot.documents.map { $0.documentID }
            userAndFriends.append(currentUID) // include self

            print("✅ Found \(userAndFriends.count) total users (self + friends)")

            // 2️⃣ Get today's date string (must match DrawingUploader)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            let todayString = formatter.string(from: Date())

            var allFeedItems: [FeedItem] = []

            // 3️⃣ Fetch dailyFeed doc for each user (no subcollection)
            for uid in userAndFriends {
                let docSnapshot = try await db.collection("dailyFeed").document(uid).getDocument()
                
                if let data = docSnapshot.data(),
                   let date = data["date"] as? String,
                   date == todayString {
                    
                    let userDocSnapshot = try await db.collection("users").document(uid).getDocument()
                    let userData = userDocSnapshot.data()
                    
                    let firstName = userData?["firstName"] as? String ?? "User"
                    let displayName = userData?["displayName"] as? String ?? "username"
                    
                    let lastName = userData?["lastName"] as? String ?? ""
                    let email = userData?["email"] as? String ?? ""
                    let avatarType = userData?["avatarType"] as? String ?? "personal"
                    let avatarBackground = userData?["avatarBackground"] as? String
                    let avatarBody = userData?["avatarBody"] as? String
                    let avatarShirt = userData?["avatarShirt"] as? String
                    let avatarEyes = userData?["avatarEyes"] as? String
                    let avatarMouth = userData?["avatarMouth"] as? String
                    let avatarHair = userData?["avatarHair"] as? String
                    let avatarFacialHair = userData?["avatarFacialHair"] as? String
                    
                    let goldMedalsAccumulated = userData?["goldMedalsAccumulated"] as? Int ?? 0
                    let silverMedalsAccumulated = userData?["silverMedalsAccumulated"] as? Int ?? 0
                    let bronzeMedalsAccumulated = userData?["bronzeMedalsAccumulated"] as? Int ?? 0
                    let goldMedalsAwarded = userData?["goldMedalsAwarded"] as? Int ?? 0
                    let silverMedalsAwarded = userData?["silverMedalsAwarded"] as? Int ?? 0
                    let bronzeMedalsAwarded = userData?["bronzeMedalsAwarded"] as? Int ?? 0
                    let totalDrawingCount = userData?["totalDrawingCount"] as? Int ?? 0
                    let streakCount = userData?["streakCount"] as? Int ?? 0
                    let memberSince = (userData?["memberSince"] as? Timestamp)?.dateValue() ?? Date()
                    
                    let item = FeedItem(
                        id: docSnapshot.documentID,
                        userId: uid,
                        firstName: firstName,
                        displayName: displayName,
                        imageURL: data["imageURL"] as? String ?? "",
                        medalGold: data["gold"] as? Int ?? 0,
                        medalSilver: data["silver"] as? Int ?? 0,
                        medalBronze: data["bronze"] as? Int ?? 0,
                        date: date,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                        lastName: lastName,
                        email: email,
                        avatarType: avatarType,
                        avatarBackground: avatarBackground,
                        avatarBody: avatarBody,
                        avatarShirt: avatarShirt,
                        avatarEyes: avatarEyes,
                        avatarMouth: avatarMouth,
                        avatarHair: avatarHair,
                        avatarFacialHair: avatarFacialHair,
                        goldMedalsAccumulated: goldMedalsAccumulated,
                        silverMedalsAccumulated: silverMedalsAccumulated,
                        bronzeMedalsAccumulated: bronzeMedalsAccumulated,
                        goldMedalsAwarded: goldMedalsAwarded,
                        silverMedalsAwarded: silverMedalsAwarded,
                        bronzeMedalsAwarded: bronzeMedalsAwarded,
                        totalDrawingCount: totalDrawingCount,
                        streakCount: streakCount,
                        memberSince: memberSince
                    )
                    allFeedItems.append(item)
                }
            }

            // 4️⃣ Sort newest first
            allFeedItems.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }

            // 5️⃣ Update the published feedItems on main thread
            await MainActor.run {
                self.feedItems = allFeedItems
                print("✅ Loaded \(allFeedItems.count) drawings for today (\(todayString))")
            }

        } catch {
            print("❌ Error loading feed:", error.localizedDescription)
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
