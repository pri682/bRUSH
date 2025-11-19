import SwiftUI

struct LeaderboardSheet: View {
    @ObservedObject var vm: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showScoringInfo = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    podiumSection
                    listSection
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
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Text("Leaderboard")
                            .font(.headline)
                        Button(action: { showScoringInfo = true }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("Score calculation info")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { vm.loadLeaderboard() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .alert("How Scores Are Calculated", isPresented: $showScoringInfo) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Points are based on medals earned:\n\n🥇 Gold = 100 pts\n🥈 Silver = 25 pts\n🥉 Bronze = 10 pts\n\nEarn medals in challenges to climb the leaderboard.")
            }
            .onAppear {
                vm.refreshFriends()
                vm.loadLeaderboard()
            }
            .onChange(of: vm.friendIds) { vm.loadLeaderboard() }
        }
        // Profile sheet presentation
        .sheet(isPresented: $vm.showingProfile) {
            if let profile = vm.selectedProfile {
                FriendProfileSheet(vm: vm, profile: profile)
            }
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
            PodiumView(entries: Array(vm.leaderboard.prefix(3)), meUid: vm.meUid) { entry in
                let friend = Friend(uid: entry.uid, name: entry.fullName, handle: entry.handle, profileImageURL: entry.profileImageURL)
                vm.openProfile(for: friend)
            }
        }
    }

    @ViewBuilder
    private var listSection: some View {
        let count = vm.leaderboard.count
        if count > 3 {
            let rest = Array(vm.leaderboard.dropFirst(3))
            ZStack(alignment: .top) {
                // Clear container background per latest design request
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.clear)
                
                VStack(spacing: 12) {
                    Spacer().frame(height: 16)
                    LeaderboardRows(rest: rest, meUid: vm.meUid) { entry in
                        let friend = Friend(uid: entry.uid, name: entry.fullName, handle: entry.handle, profileImageURL: entry.profileImageURL)
                        vm.openProfile(for: friend)
                    }
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
        let onSelect: (LeaderboardEntry) -> Void
        
        var body: some View {
            ForEach(rest.indices, id: \.self) { index in
                let element = rest[index]
                LeaderboardListRow(
                    rank: index + 4,
                    entry: element,
                    isCurrentUser: element.uid == meUid,
                    showDivider: false,
                    onSelect: { onSelect(element) }
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
                PodiumView(entries: Array(sampleEntries.prefix(3)), meUid: "me") { _ in }

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
    let onSelect: (LeaderboardEntry) -> Void

    private let gold = Color(red: 245/255, green: 182/255, blue: 51/255) // #F5B633
    private let placeholderBg = Color(red: 255/255, green: 245/255, blue: 217/255) // #FFF5D9
    private let darkGray = Color(red: 51/255, green: 51/255, blue: 51/255) // #333333

    private func safeEntry(_ index: Int) -> LeaderboardEntry? {
        guard entries.indices.contains(index) else { return nil }
        return entries[index]
    }
    
    private func formatPoints(_ points: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: points)) ?? "\(points)"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Avatar section with badges aligned horizontally
            HStack(alignment: .center, spacing: 12) {
                // 2nd Place (Left)
                ZStack(alignment: .bottom) {
                    if let entry = safeEntry(1) {
                        LeaderboardAvatarView(entry: entry, size: 72, borderColor: gold)
                            .onTapGesture { onSelect(entry) }
                    } else {
                        PlaceholderAvatarView(size: 72, borderColor: gold, bgColor: placeholderBg)
                    }
                    Circle()
                        .fill(gold)
                        .frame(width: 28, height: 28)
                        .overlay(Text("2").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
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
                            LeaderboardAvatarView(entry: entry, size: 100, borderColor: gold)
                                .onTapGesture { onSelect(entry) }
                        } else {
                            PlaceholderAvatarView(size: 100, borderColor: gold, bgColor: placeholderBg)
                        }
                        Circle()
                            .fill(gold)
                            .frame(width: 32, height: 32)
                            .overlay(Text("1").font(.system(size: 14, weight: .bold)).foregroundColor(.white))
                            .offset(y: 16)
                    }
                    .frame(height: 116)
                }
                .padding(.top, -16)
                
                // 3rd Place (Right)
                ZStack(alignment: .bottom) {
                    if let entry = safeEntry(2) {
                        LeaderboardAvatarView(entry: entry, size: 72, borderColor: gold)
                            .onTapGesture { onSelect(entry) }
                    } else {
                        PlaceholderAvatarView(size: 72, borderColor: gold, bgColor: placeholderBg)
                    }
                    Circle()
                        .fill(gold)
                        .frame(width: 28, height: 28)
                        .overlay(Text("3").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
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
                            Text("\(formatPoints(entries[1].points)) pts")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(darkGray)
                        }
                    }
                }
                .onTapGesture { if let e = safeEntry(1) { onSelect(e) } }
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
                            Text("\(formatPoints(entries[0].points)) pts")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(darkGray)
                        }
                    }
                }
                .onTapGesture { if let e = safeEntry(0) { onSelect(e) } }
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
                            Text("\(formatPoints(entries[2].points)) pts")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(darkGray)
                        }
                    }
                }
                .onTapGesture { if let e = safeEntry(2) { onSelect(e) } }
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
    var onSelect: (() -> Void)? = nil
    
    private func formattedPoints(_ points: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: points)) ?? "\(points)"
    }

    // soft gold used for highlights and icons
    private let softGold = Color(red: 245/255, green: 182/255, blue: 51/255)
    private let highlightBg = Color(red: 1.0, green: 0.95, blue: 0.70)

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

            // Avatar and Name grouped together
            HStack(spacing: 10) {
                LeaderboardAvatarView(entry: entry, size: 44, borderColor: Color.white)
                
                VStack(alignment: .leading, spacing: 2) {
                Text(isCurrentUser ? "You" : entry.fullName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                    Text(entry.handle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Points with bolt (muted gold)
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.caption)
                    .foregroundColor(softGold)
                Text("\(formattedPoints(entry.points)) pts")
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
        .contentShape(Rectangle())
        .onTapGesture { onSelect?() }
    }
}
// MARK: - Profile Image View (Async loading)
// Avatar view for leaderboard that supports either uploaded image URL OR generated avatar parts OR initials fallback
private struct LeaderboardAvatarView: View {
    let entry: LeaderboardEntry
    let size: CGFloat
    let borderColor: Color
    var body: some View {
        ZStack {
            Circle().fill(Color.white)
            if let url = entry.profileImageURL, !url.isEmpty, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: size, height: size)
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        avatarFallback
                    @unknown default:
                        avatarFallback
                    }
                }
            } else if let type = entry.avatarType, let bg = entry.avatarBackground {
                // Render composite avatar if we have at least one valid foreground layer
                let foregroundParts = [entry.avatarBody, entry.avatarShirt, entry.avatarEyes, entry.avatarMouth, entry.avatarHair, entry.avatarFacialHair]
                    .compactMap { $0 }
                    .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                
                if !foregroundParts.isEmpty {
                    // Render avatar larger and centered to show the face clearly
                    AvatarView(
                        avatarType: type == "fun" ? .fun : .personal,
                        background: bg,
                        avatarBody: entry.avatarBody,
                        shirt: entry.avatarShirt,
                        eyes: entry.avatarEyes,
                        mouth: entry.avatarMouth,
                        hair: entry.avatarHair,
                        facialHair: entry.avatarFacialHair,
                        includeSpacer: false
                    )
                    .frame(width: size * 1.3, height: size * 1.3)
                    .offset(y: -size * 0.05)
                    .frame(width: size, height: size)
                    .clipped()
                } else {
                    avatarFallback
                }
            } else {
                avatarFallback
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(borderColor, lineWidth: 3))
    }
    private var avatarFallback: some View {
        let initials = entry.fullName.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined()
        return Text(initials)
            .font(.system(size: size * 0.4, weight: .bold))
            .foregroundStyle(.primary)
            .frame(width: size, height: size)
    }
}

    
