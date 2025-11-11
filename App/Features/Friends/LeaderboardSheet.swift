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
    