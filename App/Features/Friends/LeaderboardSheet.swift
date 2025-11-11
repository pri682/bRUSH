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
    