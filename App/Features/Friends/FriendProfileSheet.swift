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
        
        let isCurrentUser = profile.uid == vm.meUid
        
        let avatarFrameSize: CGFloat = 225
        let ovalFrameSize = (width: CGFloat(210), height: CGFloat(180))
        let popAmount: CGFloat = 60

        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack(alignment: .bottom) {
                        let ovalClip = Ellipse()
                        
                        Image(profile.avatarBackground ?? "background_1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: ovalFrameSize.width, height: ovalFrameSize.height)
                            .clipShape(ovalClip)
                            .shadow(color: .black.opacity(0.2), radius: 3, y: 2)

                        PoppingAvatarView(profile: profile, layer: .body)
                            .frame(width: avatarFrameSize, height: avatarFrameSize)
                            .frame(width: ovalFrameSize.width, height: ovalFrameSize.height, alignment: .bottom)
                            .clipShape(ovalClip)

                        PoppingAvatarView(profile: profile, layer: .head)
                            .frame(width: avatarFrameSize, height: avatarFrameSize, alignment: .bottom)
                            .offset(y: -popAmount)
                    }
                    .offset(y: -50)
                    .padding(.bottom, -50)

                    VStack(spacing: 2) {
                        Text([profile.firstName, profile.lastName].filter { !$0.isEmpty }.joined(separator: " "))
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Text("@\(profile.displayName)")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    
                    let isFriend = vm.friendIds.contains(profile.uid)
                    let isPending = vm.isRequestPending(uid: profile.uid)
                    
                    VStack {
                        if !isCurrentUser {
                            if isFriend {
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
                            }
                        }
                    }
                    
                    let cardStackHorizontalPadding: CGFloat = 30

                    CardStackView(cards: [
                        CardItem(content: AnyView(
                            AwardsStackCardView(
                                cardTypeTitle: "Awards Accumulated",
                                firstPlaceCount: profile.goldMedalsAccumulated,
                                secondPlaceCount: profile.silverMedalsAccumulated,
                                thirdPlaceCount: profile.bronzeMedalsAccumulated,
                                medalIconSize: largeMedalSize,
                                isCurrentUser: false
                            )
                        )),
                        CardItem(content: AnyView(
                            AwardsStackCardView(
                                cardTypeTitle: "Awarded to Friends",
                                firstPlaceCount: profile.goldMedalsAwarded,
                                secondPlaceCount: profile.silverMedalsAwarded,
                                thirdPlaceCount: profile.bronzeMedalsAwarded,
                                medalIconSize: largeMedalSize,
                                isCurrentUser: false
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
