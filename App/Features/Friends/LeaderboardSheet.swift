import SwiftUI

struct LeaderboardSheet: View {
    @ObservedObject var vm: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showScoringInfo = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        podiumSection
                            .zIndex(1)
                            .padding(.top, 40)

                        listSection(minHeight: max(geo.size.height - 220, 300))
                    }
                }
                .navigationTitle("Leaderboard")
                .navigationBarTitleDisplayMode(.automatic)
                .toolbar {
                    ToolbarItem {
                        Button(action: { showScoringInfo = true }) {
                            Image(systemName: "info.circle")
                                .accessibilityLabel("Score calculation info")
                        }
                        .popover(isPresented: $showScoringInfo, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                            ScoringInfoView()
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                    ToolbarItem {
                        Button(action: { vm.loadLeaderboard() }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    ToolbarItem {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .onAppear {
                    vm.loadLeaderboard()
                }
            }
        }
        .sheet(isPresented: $vm.showingProfile) {
            if let profile = vm.selectedProfile {
                FriendProfileSheet(vm: vm, profile: profile)
            }
        }
        .presentationDetents([.large])
        .presentationBackground(Color(.systemBackground))
    }
    
    private struct ScoringInfoView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("How Scores Are Calculated")
                    .font(.headline)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Points are based on medals earned:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack { Text("\u{1F947} Gold"); Spacer(); Text("100 pts").bold() }
                    HStack { Text("\u{1F948} Silver"); Spacer(); Text("25 pts").bold() }
                    HStack { Text("\u{1F949} Bronze"); Spacer(); Text("10 pts").bold() }
                }
                .font(.subheadline)
                
                Divider()
                
                Text("Earn medals in challenges to climb the leaderboard.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(width: 280)
        }
    }
    
    @ViewBuilder
    private var podiumSection: some View {
        if vm.isLoadingLeaderboard {
            VStack {
                ProgressView()
                Text("Updating leaderboard…")
            }
            .frame(height: 280)
        } else if let err = vm.leaderboardError {
            Text(err)
                .foregroundStyle(.red)
                .frame(height: 280)
        } else {
            PodiumView(entries: Array(vm.leaderboard.prefix(3)), meUid: vm.meUid) { entry in
                vm.openProfile(for: entry.profile)
            }
        }
    }

    @ViewBuilder
    private func listSection(minHeight: CGFloat) -> some View {
        let count = vm.leaderboard.count
        let rest = count > 3 ? Array(vm.leaderboard.dropFirst(3)) : []

        VStack(spacing: 0) {
            Spacer().frame(height: 12)

            VStack(spacing: 12) {
                if !rest.isEmpty {
                    LeaderboardRows(rest: rest, meUid: vm.meUid) { entry in
                        vm.openProfile(for: entry.profile)
                    }
                } else {
                    Spacer().frame(height: 20)
                }

                Spacer()
            }
            .padding(.horizontal, 18)
            .frame(minHeight: minHeight, alignment: .top)
        }
        .padding(.top, 8)
        .background(
            Color.accentColor.opacity(0.15)
                .frame(height: 2000)
                .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                , alignment: .top
        )
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

private struct PodiumView: View {
    let entries: [LeaderboardEntry]
    let meUid: String?
    let onSelect: (LeaderboardEntry) -> Void

    private let gold = Color(red: 245/255, green: 182/255, blue: 51/255)
    private let placeholderBg = Color(red: 255/255, green: 245/255, blue: 217/255)
    
    private func safeEntry(_ index: Int) -> LeaderboardEntry? {
        guard entries.indices.contains(index) else { return nil }
        return entries[index]
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // 2nd Place (Left)
            PodiumEntryView(
                entry: safeEntry(1),
                rank: 2,
                meUid: meUid,
                baseColor: gold,
                placeholderBg: placeholderBg,
                onSelect: onSelect
            )
            
            // 1st Place (Center - Elevated)
            PodiumEntryView(
                entry: safeEntry(0),
                rank: 1,
                meUid: meUid,
                baseColor: gold,
                placeholderBg: placeholderBg,
                onSelect: onSelect
            )
            .offset(y: -25)
            .zIndex(1)

            // 3rd Place (Right)
            PodiumEntryView(
                entry: safeEntry(2),
                rank: 3,
                meUid: meUid,
                baseColor: gold,
                placeholderBg: placeholderBg,
                onSelect: onSelect
            )
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 24)
    }
}

private struct PodiumEntryView: View {
    let entry: LeaderboardEntry?
    let rank: Int
    let meUid: String?
    let baseColor: Color
    let placeholderBg: Color
    let onSelect: (LeaderboardEntry) -> Void
    
    private var isWinner: Bool { rank == 1 }
    private var avatarSize: CGFloat { isWinner ? 100 : 72 }
    private var badgeSize: CGFloat { isWinner ? 32 : 28 }
    private var nameFont: Font { isWinner ? .system(size: 15, weight: .bold) : .system(size: 13, weight: .semibold) }
    private var darkGray: Color { Color(red: 51/255, green: 51/255, blue: 51/255) }

    private func formatPoints(_ points: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: points)) ?? "\(points)"
    }

    var body: some View {
        VStack(spacing: 8) {
            // Crown for Winner
            if isWinner {
                Image(systemName: "crown.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(baseColor)
                    .padding(.bottom, -14)
                    .zIndex(2)
            }
            
            // Avatar + Badge
            ZStack(alignment: .bottom) {
                if let entry = entry {
                    LeaderboardAvatarView(entry: entry, size: avatarSize, borderColor: baseColor)
                } else {
                    PlaceholderAvatarView(size: avatarSize, borderColor: baseColor, bgColor: placeholderBg)
                }
                
                Circle()
                    .fill(baseColor)
                    .frame(width: badgeSize, height: badgeSize)
                    .overlay(Text("\(rank)").font(.system(size: isWinner ? 14 : 12, weight: .bold)).foregroundColor(.white))
                    .offset(y: badgeSize / 2)
            }
            .frame(height: avatarSize + (badgeSize / 2))
            .padding(.bottom, 4)

            // Name and Points
            if let entry = entry {
                VStack(spacing: 2) {
                    Text(entry.uid == meUid ? "You" : entry.fullName)
                        .font(nameFont)
                        .foregroundColor(darkGray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: isWinner ? 11 : 10, weight: .semibold))
                            .foregroundColor(baseColor)
                        Text("\(formatPoints(entry.points)) pts")
                            .font(.system(size: isWinner ? 12 : 11, weight: .semibold))
                            .foregroundColor(darkGray)
                    }
                }
            } else {
                Text(" ").font(nameFont)
                Text(" ").font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if let e = entry { onSelect(e) }
        }
    }
}

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

    private let softGold = Color(red: 245/255, green: 182/255, blue: 51/255)
    private let highlightBg = Color(red: 1.0, green: 0.95, blue: 0.70)

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                    .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                Text("\(rank)")
                    .font(.subheadline).bold()
            }

            HStack(spacing: 10) {
                LeaderboardAvatarView(entry: entry, size: 44, borderColor: Color.white)
                
                // Name ONLY (Username removed)
                Text(isCurrentUser ? "You" : entry.fullName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }

            Spacer()

            // Points
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

private struct LeaderboardAvatarView: View {
    let entry: LeaderboardEntry
    let size: CGFloat
    let borderColor: Color
    
    var body: some View {
        ZStack {
            Circle().fill(Color.white)
            if let bg = entry.avatarBackground {
                AvatarView(
                    avatarType: AvatarType(rawValue: entry.avatarType) ?? .personal,
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
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(borderColor, lineWidth: 3))
    }
    private var avatarFallback: some View {
        let initials = entry.fullName.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined()
        return Text(initials.isEmpty ? "?" : initials)
            .font(.system(size: size * 0.4, weight: .bold))
            .foregroundStyle(.primary)
            .frame(width: size, height: size)
    }
}
