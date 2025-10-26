import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var appTitle: String = "bRUSH"
    @Published var feedItems: [FeedItem] = []
    @Published var dailyPrompt: String = "Loading..."
    @Published var isLoadingFeed: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

<<<<<<< Updated upstream
    // MARK: - Load Daily Prompt
=======
    // Tagline options to keep the UI lively
    let taglines: [String] = [
        "Sketch. Design. Inspire.",
        "Bold color. Smooth strokes.",
        "From idea to art in a swipe.",
    ]

    // Hard-coded feed data for now
    @Published var feedItems: [FeedItem] = [
        FeedItem(
            displayName: "Ava Thompson",
            username: "@avt",
            profileSystemImageName: "person.circle.fill",
            artSystemImageName: "photo.on.rectangle.angled",
            artImageName: "sample_drawing",
            medalGold: 12,
            medalSilver: 5,
            medalBronze: 2,
            upVotes: 3800,
            downVotes: 120,
            comments: 4100,
            awards: 3
        ),
        FeedItem(
            displayName: "Meidad Troper",
            username: "@meidady",
            profileSystemImageName: "person.circle.fill",
            artSystemImageName: "photo.on.rectangle.angled",
            artImageName: "sample_drawing2",
            medalGold: 12,
            medalSilver: 5,
            medalBronze: 2,
            upVotes: 3800,
            downVotes: 120,
            comments: 4100,
            awards: 3
        ),
        FeedItem(
            displayName: "Liam Chen",
            username: "@lchen",
            profileSystemImageName: "person.crop.circle.fill",
            artSystemImageName: "photo.on.rectangle.angled",
            artImageName: "sample_drawing",
            medalGold: 7,
            medalSilver: 9,
            medalBronze: 1,
            upVotes: 2450,
            downVotes: 80,
            comments: 1730,
            awards: 1
        ),
        FeedItem(
            displayName: "Sofia Martinez",
            username: "@sofiam",
            profileSystemImageName: "person.circle.fill",
            artSystemImageName: "photo.on.rectangle.angled",
            artImageName: "sample_drawing2",
            medalGold: 20,
            medalSilver: 11,
            medalBronze: 4,
            upVotes: 5200,
            downVotes: 160,
            comments: 2960,
            awards: 5
        )
    ]
    
    @Published var dailyPrompt: String = "Loading prompt..."
>>>>>>> Stashed changes
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
                    
                    let item = FeedItem(
                        id: docSnapshot.documentID,
                        userId: uid,
                        displayName: "", // can later fetch from /users
                        username: "",
                        imageURL: data["imageURL"] as? String ?? "",
                        medalGold: data["gold"] as? Int ?? 0,
                        medalSilver: data["silver"] as? Int ?? 0,
                        medalBronze: data["bronze"] as? Int ?? 0,
                        date: date,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
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
