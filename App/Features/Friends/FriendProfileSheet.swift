import SwiftUI

struct FriendProfileSheet: View {
    @ObservedObject var vm: FriendsViewModel
    let profile: UserProfile
    
    @Environment(\.dismiss) private var dismiss
    @State private var confirmRemove = false
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let standardPadding = screenWidth * 0.05
        let contentWidth = screenWidth - (standardPadding * 2)
        let largeMedalSize = contentWidth * 0.16

        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    AvatarView(
                        avatarType: AvatarType(rawValue: profile.avatarType) ?? .personal,
                        background: profile.avatarBackground ?? "background_1",
                        avatarBody: profile.avatarBody,
                        shirt: profile.avatarShirt,
                        eyes: profile.avatarEyes,
                        mouth: profile.avatarMouth,
                        hair: profile.avatarHair,
                        includeSpacer: false
                    )
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(.top, 20)
                    
                    VStack(spacing: 2) {
                        Text([profile.firstName, profile.lastName].filter { !$0.isEmpty }.joined(separator: " "))
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Text("@\(profile.displayName)")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    
                    let isCurrentUser = (profile.uid == vm.meUid)
                    let isFriend = vm.friendIds.contains(profile.uid)
                    let isPending = vm.isRequestPending(uid: profile.uid)
                    
                    VStack {
                        if isCurrentUser {
                            EmptyView()
                        } else if isFriend {
                            Button(role: .destructive) {
                                confirmRemove = true
                            } label: {
                                Label("Remove Friend", systemImage: "person.fill.xmark")
                            }
                            .buttonStyle(.glass)
                            .tint(.red)
                            .confirmationDialog(
                                "Remove \(profile.displayName) as a friend?",
                                isPresented: $confirmRemove,
                                titleVisibility: .visible
                            ) {
                                Button("Remove", role: .destructive) {
                                    let friendToRemove = Friend(
                                        uid: profile.uid,
                                        name: profile.displayName,
                                        handle: profile.displayName
                                    )
                                    vm.remove(friend: friendToRemove)
                                    dismiss()
                                }
                                Button("Cancel", role: .cancel) {}
                            }
                        } else if isPending {
                            Text("Request Pending")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(12)
                                .glassEffect()
                        } else {
                            Button {
                                let userToAdd = FriendSearchResult(
                                    uid: profile.uid,
                                    handle: profile.displayName,
                                    fullName: profile.firstName
                                )
                                vm.sendFriendRequest(to: userToAdd)
                                dismiss()
                            } label: {
                                Label("Add Friend", systemImage: "person.badge.plus")
                            }
                            .buttonStyle(.glassProminent)
                            .tint(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    let cardStackHorizontalPadding: CGFloat = 30

                    CardStackView(cards: [
                        CardItem(content: AnyView(
                            AwardsStackCardView(
                                cardTypeTitle: "Awards Accumulated",
                                firstPlaceCount: profile.goldMedalsAccumulated,
                                secondPlaceCount: profile.silverMedalsAccumulated,
                                thirdPlaceCount: profile.bronzeMedalsAccumulated,
                                medalIconSize: largeMedalSize
                            )
                        )),
                        CardItem(content: AnyView(
                            AwardsStackCardView(
                                cardTypeTitle: "Awarded to Friends",
                                firstPlaceCount: profile.goldMedalsAwarded,
                                secondPlaceCount: profile.silverMedalsAwarded,
                                thirdPlaceCount: profile.bronzeMedalsAwarded,
                                medalIconSize: largeMedalSize
                            )
                        )),
                        CardItem(content: AnyView(
                            StreakCardView(
                                streakCount: profile.streakCount,
                                totalDrawings: profile.totalDrawingCount,
                                memberSince: profile.memberSince,
                                iconSize: largeMedalSize
                            )
                        ))
                    ])
                    .aspectRatio(0.9, contentMode: .fit)
                    .padding(.horizontal, cardStackHorizontalPadding)
                    .padding(.top, 20)
                }
            }
            .presentationDetents([.large])
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .cancel) { dismiss() }
                }
            }
        }
    }
}
