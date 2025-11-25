import SwiftUI

struct LeaderboardSheet: View {
    @ObservedObject var vm: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showScoringInfo = false
    
    // MARK: - Toast State
    @State private var showRefreshToast = false
    
    private let listBgOpacity: CGFloat = 0.15
    private let currentUserRowOpacity: CGFloat = 0.25
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            podiumSection
                                .zIndex(1)
                                .padding(.top, 40)

                            listSection(minHeight: max(geo.size.height - 220, 300))
                        }
                    }
                    
                    if showRefreshToast {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Leaderboard Updated")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .glassEffect(.regular)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(100)
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
                        Button(action: {
                            handleRefresh()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    
                    ToolbarSpacer()
                    
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
    
    // MARK: - Refresh Logic
    private func handleRefresh() {
        vm.loadLeaderboard()
        
        // Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Show Toast
        withAnimation(.spring()) {
            showRefreshToast = true
        }
        
        // Hide Toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut) {
                showRefreshToast = false
            }
        }
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
        
        if count > 3 {
            let rest = Array(vm.leaderboard.dropFirst(3))

            VStack(spacing: 0) {
                Spacer().frame(height: 12)

                VStack(spacing: 12) {
                    if !rest.isEmpty {
                        LeaderboardRows(rest: rest, meUid: vm.meUid, rowOpacity: currentUserRowOpacity) { entry in
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
                Color.accentColor.opacity(listBgOpacity)
                    .frame(height: 2000)
                    .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                    , alignment: .top
            )
        }
    }

    private struct LeaderboardRows: View {
        let rest: [LeaderboardEntry]
        let meUid: String?
        let rowOpacity: CGFloat
        let onSelect: (LeaderboardEntry) -> Void
        
        var body: some View {
            ForEach(rest.indices, id: \.self) { index in
                let element = rest[index]
                LeaderboardListRow(
                    rank: index + 4,
                    entry: element,
                    isCurrentUser: element.uid == meUid,
                    rowOpacity: rowOpacity,
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
    
    private let baseColor = Color.accentColor
    private let placeholderBg = Color.accentColor.opacity(0.15)
    
    private func safeEntry(_ index: Int) -> LeaderboardEntry? {
        guard entries.indices.contains(index) else { return nil }
        return entries[index]
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // 2nd Place
            PodiumEntryView(
                entry: safeEntry(1),
                rank: 2,
                meUid: meUid,
                baseColor: baseColor,
                placeholderBg: placeholderBg,
                onSelect: onSelect
            )
            
            // 1st Place
            PodiumEntryView(
                entry: safeEntry(0),
                rank: 1,
                meUid: meUid,
                baseColor: baseColor,
                placeholderBg: placeholderBg,
                onSelect: onSelect
            )
            .offset(y: -25)
            .zIndex(1)

            // 3rd Place
            PodiumEntryView(
                entry: safeEntry(2),
                rank: 3,
                meUid: meUid,
                baseColor: baseColor,
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
                    .zIndex(2)
            }
            
            // Avatar + Badge
            ZStack(alignment: .bottom) {
                ZStack {
                    if let entry = entry {
                        PoppingPodiumAvatarView(
                            profile: entry.profile,
                            size: avatarSize,
                            borderColor: baseColor
                        )
                    } else {
                        PlaceholderAvatarView(size: avatarSize, borderColor: baseColor, bgColor: placeholderBg)
                    }
                }
                .offset(y: -10)
                
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
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: isWinner ? 11 : 10, weight: .semibold))
                            .foregroundColor(baseColor)
                        Text("\(formatPoints(entry.points)) pts")
                            .font(.system(size: isWinner ? 12 : 11, weight: .semibold))
                            .foregroundStyle(.primary)
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

private struct PoppingPodiumAvatarView: View {
    let profile: UserProfile
    let size: CGFloat
    let borderColor: Color
    
    private var avatarFrameSize: CGFloat { size * 1.25 }
    private var popAmount: CGFloat { size * 0.3 }
    private var isWinner: Bool { size > 90 }
    
    private var bodyClip: some Shape {
        Ellipse()
            .scale(x: 0.90, y: 1.0, anchor: .center)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            let bgClip = Circle()
            
            Image(profile.avatarBackground ?? "background_1")
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(bgClip)
                
            PoppingAvatarView(profile: profile, layer: .body)
                .frame(width: avatarFrameSize, height: avatarFrameSize, alignment: .bottom)
                .clipShape(bodyClip)
            
            Circle()
                .stroke(borderColor, lineWidth: 3)
                .frame(width: size, height: size)

            PoppingAvatarView(profile: profile, layer: .head)
                .frame(width: avatarFrameSize, height: avatarFrameSize, alignment: .bottom)
                .offset(y: isWinner ? -popAmount*2 : -popAmount*2.8)
        }
        .frame(width: size, height: size)
    }
}

private struct LeaderboardListRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    let rowOpacity: CGFloat
    var showDivider: Bool = true
    var onSelect: (() -> Void)? = nil
    
    private func formattedPoints(_ points: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: points)) ?? "\(points)"
    }

    // Highlight Color using accent
    private var highlightBg: Color {
        Color.accentColor.opacity(rowOpacity)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                Circle()
                    .fill(isCurrentUser ? highlightBg : Color(.secondarySystemGroupedBackground))
                    .frame(width: 36, height: 36)
                    .shadow(color: Color.black.opacity(isCurrentUser ? 0 : 0.06), radius: 2, x: 0, y: 1)
                
                Text("\(rank)")
                    .font(.subheadline).bold()
                    .foregroundStyle(.primary)
            }

            HStack(spacing: 10) {
                LeaderboardAvatarView(entry: entry, size: 44, borderColor: isCurrentUser ? highlightBg : Color(.clear))
                
                // Name
                Text(isCurrentUser ? "You" : entry.fullName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer()

            // Points
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.caption)
                    .foregroundColor(Color.accentColor)
                Text("\(formattedPoints(entry.points)) pts")
                    .font(.subheadline).bold()
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(isCurrentUser ? highlightBg : Color(.secondarySystemGroupedBackground))
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
                .frame(width: size, height: size)
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
