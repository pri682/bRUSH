import SwiftUI

struct LeaderboardSheet: View {
    @ObservedObject var vm: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    let maxPoints = vm.leaderboard.map(\.points).max() ?? 0
                    
                    if vm.isLoadingLeaderboard {
                        HStack {
                            ProgressView()
                            Text("Loading leaderboard…")
                        }
                    } else if let err = vm.leaderboardError {
                        Text(err).foregroundStyle(.red)
                    } else if vm.leaderboard.isEmpty {
                        Text("No friend rankings yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(vm.leaderboard.enumerated()), id: \.1.id) { index, entry in
                            LeaderboardBarRow(
                                rank: index + 1,
                                fullName: entry.fullName,
                                handle: entry.handle,
                                points: entry.points,
                                maxPoints: maxPoints,
                                isCurrentUser: entry.uid == vm.meUid
                            )
                            .listRowBackground(
                                entry.uid == vm.meUid
                                ? Color.accentColor.opacity(0.15)
                                : nil
                            )
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.compact)
            .navigationTitle("Leaderboard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        vm.loadLeaderboard()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
            .onAppear { vm.loadLeaderboard() }
            .onChange(of: vm.friendIds) { vm.loadLeaderboard() }
        }
        .presentationDetents([.large])
        .presentationBackground(Color(.systemBackground))
    }
}

private struct LeaderboardBarRow: View {
    let rank: Int
    let fullName: String
    let handle: String
    let points: Int
    let maxPoints: Int
    var isCurrentUser: Bool
    
    @Environment(\.colorScheme) private var scheme
    
    var ratio: CGFloat {
        guard maxPoints > 0 else { return 0 }
        return CGFloat(points) / CGFloat(maxPoints)
    }
    
    var barColor: Color {
        if !isCurrentUser {
            return .accentColor
        } else {
            switch rank {
            case 1: return .yellow
            case 2: return .gray
            case 3: return .brown
            default: return .blue
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title line
            HStack(spacing: 8) {
                Text("\(rank)")
                    .font(.system(.subheadline, design: .monospaced)).bold()
                    .frame(width: 22, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(fullName).font(.subheadline).bold()
                        
                        if isCurrentUser {
                            Text("(You)")
                                .font(.caption).bold()
                                .foregroundStyle(.accent)
                        }
                    }
                    Text(handle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
            }
            
            // Bar line
            GeometryReader { geo in
                let fullW = geo.size.width
                let barW = max(0, min(fullW, fullW * ratio))
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(scheme == .dark ? Color.white.opacity(0.10)
                              : Color.black.opacity(0.08))
                    
                    Capsule()
                        .fill(barColor)
                        .frame(width: barW)
                    
                    HStack {
                        Spacer()
                        Text("\(points)")
                            .font(.caption).bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .foregroundStyle(
                                isCurrentUser ? Color.black : (scheme == .dark ? .white : .black)
                            )
                            .padding(.trailing, 4)
                    }
                }
                .mask(Capsule())
            }
            .frame(height: 24)
        }
        .animation(.easeOut(duration: 0.22), value: points)
    }
}
