import SwiftUI

struct LeaderboardSheet: View {
    @ObservedObject var vm: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    podiumSection
                    listSection
                }
                
                ToolbarSpacer()
                
                ToolbarItem() {
                    Button(role: .cancel) { dismiss() }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { vm.loadLeaderboard() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                vm.refreshFriends()
                vm.loadLeaderboard()
            }
            .onChange(of: vm.friendIds) { vm.loadLeaderboard() }
        }
        .presentationDetents([.large])
        .presentationBackground(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var podiumSection: some View {
        if vm.isLoadingLeaderboard {
            VStack {
                ProgressView()
                Text("Loading leaderboard…")
            }
            .frame(height: 280)
        } else if let err = vm.leaderboardError {
            Text(err)
                .foregroundStyle(.red)
                .frame(height: 280)
        } else {
            PodiumView(entries: Array(vm.leaderboard.prefix(3)), meUid: vm.meUid)
        }
    }

    @ViewBuilder
    private var listSection: some View {
        let count = vm.leaderboard.count
        if count > 3 {
            let rest = Array(vm.leaderboard.dropFirst(3))
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 255/255, green: 253/255, blue: 246/255))
                
                VStack(spacing: 12) {
                    Spacer().frame(height: 16)
                    LeaderboardRows(rest: rest, meUid: vm.meUid)
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 12)
            }
            .padding(.horizontal, 8)
            .padding(.top, 20)
        }
    }
    
    private struct LeaderboardRows: View {
        let rest: [LeaderboardEntry]
        let meUid: String?
        
        var body: some View {
            ForEach(rest.indices, id: \.self) { index in
                let element = rest[index]
                LeaderboardListRow(
                    rank: index + 4,
                    entry: element,
                    isCurrentUser: element.uid == meUid,
                    showDivider: index < rest.count - 1
                )
            }
        }
    }
}
// MARK: - Previews
struct LeaderboardSheet_Previews: PreviewProvider {
    static var sampleEntries: [LeaderboardEntry] {
        [
            LeaderboardEntry(uid: "u1", fullName: "Bryan Wolf", handle: "@bryan", gold: 0, silver: 0, bronze: 43, profileImageURL: "https://i.pravatar.cc/150?img=12"),
            LeaderboardEntry(uid: "u2", fullName: "Meghan Jess", handle: "@meghan", gold: 0, silver: 0, bronze: 40, profileImageURL: "https://i.pravatar.cc/150?img=15"),
            LeaderboardEntry(uid: "u3", fullName: "Alex Turner", handle: "@alex", gold: 0, silver: 0, bronze: 38, profileImageURL: "https://i.pravatar.cc/150?img=18"),
            LeaderboardEntry(uid: "u4", fullName: "Marsha Fisher", handle: "@marsha", gold: 0, silver: 0, bronze: 36, profileImageURL: "https://i.pravatar.cc/150?img=20"),
            LeaderboardEntry(uid: "u5", fullName: "Juanita Cormier", handle: "@juanita", gold: 0, silver: 0, bronze: 35, profileImageURL: "https://i.pravatar.cc/150?img=21"),
            LeaderboardEntry(uid: "me", fullName: "You", handle: "@me", gold: 0, silver: 0, bronze: 34, profileImageURL: "https://i.pravatar.cc/150?img=32"),
            LeaderboardEntry(uid: "u7", fullName: "Tamara Schmidt", handle: "@tamara", gold: 0, silver: 0, bronze: 33, profileImageURL: "https://i.pravatar.cc/150?img=33")
        ]
    }

    static var previews: some View {
        ScrollView {
            VStack(spacing: 0) {
                PodiumView(entries: Array(sampleEntries.prefix(3)), meUid: "me")

                VStack(spacing: 12) {
                    ForEach(Array(sampleEntries.enumerated()), id: \.element.id) { offset, element in
                        if offset >= 3 {
                            LeaderboardListRow(rank: offset + 1, entry: element, isCurrentUser: element.uid == "me")
                        }
                    }
                }
                .padding()
            }
        }
        .previewLayout(.sizeThatFits)
    }
}

// MARK: - Podium View (Top 3)
private struct PodiumView: View {
    let entries: [LeaderboardEntry]
    let meUid: String?

    private let gold = Color(red: 245/255, green: 182/255, blue: 51/255) // #F5B633
    private let placeholderBg = Color(red: 255/255, green: 245/255, blue: 217/255) // #FFF5D9
    private let darkGray = Color(red: 51/255, green: 51/255, blue: 51/255) // #333333

    private func safeEntry(_ index: Int) -> LeaderboardEntry? {
        guard entries.indices.contains(index) else { return nil }
        return entries[index]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Avatar section with badges aligned horizontally
            HStack(alignment: .center, spacing: 12) {
                // 2nd Place (Left)
                ZStack(alignment: .bottom) {
                    if let entry = safeEntry(1) {
                        ProfileImageView(
                            url: entry.profileImageURL,
                            name: entry.fullName,
                            size: 72,
                            showBorder: true,
                            borderColor: gold
                        )
                    } else {
                        PlaceholderAvatarView(size: 72, borderColor: gold, bgColor: placeholderBg)
                    }
                    
                    // Rank badge
                    Circle()
                        .fill(gold)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text("2")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(y: 14)
                }
                .frame(height: 86)
                
                // 1st Place (Center) - PROMINENT & ELEVATED
                VStack(spacing: 0) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(gold)
                        .offset(y: -8)
                    
                    ZStack(alignment: .bottom) {
                        if let entry = safeEntry(0) {
                            ProfileImageView(
                                url: entry.profileImageURL,
                                name: entry.fullName,
                                size: 100,
                                showBorder: true,
                                borderColor: gold
                            )
                        } else {
                            PlaceholderAvatarView(size: 100, borderColor: gold, bgColor: placeholderBg)
                        }
                        
                        Circle()
                            .fill(gold)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("1")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(y: 16)
                    }
                    .frame(height: 116)
                }
                .padding(.top, -16)
                
                // 3rd Place (Right)
                ZStack(alignment: .bottom) {
                    if let entry = safeEntry(2) {
                        ProfileImageView(
                            url: entry.profileImageURL,
                            name: entry.fullName,
                            size: 72,
                            showBorder: true,
                            borderColor: gold
                        )
                    } else {
                        PlaceholderAvatarView(size: 72, borderColor: gold, bgColor: placeholderBg)
                    }
                    
                    Circle()
                        .fill(gold)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text("3")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(y: 14)
                }
                .frame(height: 86)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
            
            // Names and Points Baseline (all three aligned horizontally)
            HStack(alignment: .top, spacing: 12) {
                // 2nd Place
                VStack(spacing: 2) {
                    if entries.indices.contains(1) {
                        Text(entries[1].fullName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(darkGray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        HStack(spacing: 3) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(gold)
                            Text("\(entries[1].points) pts")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(darkGray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                
                // 1st Place (larger)
                VStack(spacing: 2) {
                    if !entries.isEmpty {
                        Text(entries[0].fullName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(darkGray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        HStack(spacing: 3) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(gold)
                            Text("\(entries[0].points) pts")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(darkGray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                
                // 3rd Place
                VStack(spacing: 2) {
                    if entries.indices.contains(2) {
                        Text(entries[2].fullName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(darkGray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        HStack(spacing: 3) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(gold)
                            Text("\(entries[2].points) pts")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(darkGray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }
}
// MARK: - List Row View (Rank 4+)
private struct LeaderboardListRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    var showDivider: Bool = true

    // soft gold used for highlights and icons
    private let softGold = Color(red: 245/255, green: 182/255, blue: 51/255)
    private let highlightBg = Color(red: 255/255, green: 247/255, blue: 224/255) // #FFF7E0

    var body: some View {
        HStack(spacing: 12) {
            // left rank circle (white inside pill)
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                    .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                Text("\(rank)")
                    .font(.subheadline).bold()
            }

            // Profile image
            ProfileImageView(
                url: entry.profileImageURL,
                name: entry.fullName,
                size: 44,
                showBorder: true,
                borderColor: Color.white
            )

            // Name & handle
            VStack(alignment: .leading, spacing: 2) {
                Text(isCurrentUser ? "You" : entry.fullName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Text(entry.handle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Points with bolt (muted gold)
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.caption)
                    .foregroundColor(softGold)
                Text("\(entry.points) pts")
                    .font(.subheadline).bold()
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(isCurrentUser ? highlightBg : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .overlay(alignment: .bottom) {
            if showDivider {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 1)
                    .padding(.leading, 64)
            }
        }
    }
}
// MARK: - Profile Image View (Async loading)
private struct ProfileImageView: View {
    let url: String?
    let name: String
    let size: CGFloat
    let showBorder: Bool
    let borderColor: Color?

    var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.white)

            // Attempt to load image, fallback to initials
            if let url = url, !url.isEmpty, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Text(initials)
                            .font(.system(size: size * 0.4, weight: .bold))
                            .foregroundStyle(.primary)
                    @unknown default:
                        Text(initials)
                            .font(.system(size: size * 0.4, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                }
            } else {
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundStyle(.primary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    borderColor ?? Color.accentColor,
                    lineWidth: showBorder ? 3 : 0
                )
        )
    }
}


    