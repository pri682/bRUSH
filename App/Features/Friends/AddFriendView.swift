import SwiftUI

struct AddFriendView: View {
    @ObservedObject var vm: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack (spacing: 8){
                    Text("@")
                        .foregroundStyle(.secondary)
                        .baselineOffset(1.5)
                    TextField("username", text: $vm.addQuery)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .submitLabel(.search)
                        .onSubmit { vm.performAddSearch() }
                        .focused($isSearchFocused)
                }
                .padding(12)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    isSearchFocused = true
                }
                .padding([.horizontal, .top])
                
                if vm.isSearchingAdd {
                    Spacer()
                    ProgressView("Searching…")
                    Spacer()
                } else if let err = vm.addError {
                    Spacer()
                    ContentUnavailableView {
                        Label("Search Failed", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(err)
                    }
                    .padding(.horizontal)
                    Spacer()
                } else if !vm.addQuery.isEmpty && vm.addResults.isEmpty {
                    Spacer()
                    ContentUnavailableView {
                        Label("No Users Found", systemImage: "person.fill.questionmark")
                    } description: {
                        Text("No users match \"\(vm.addQuery)\".")
                    }
                    Spacer()
                } else if vm.addQuery.isEmpty && vm.addResults.isEmpty {
                    Spacer()
                    ContentUnavailableView {
                        Label("Find Friends", systemImage: "magnifyingglass")
                    } description: {
                        Text("Search for friends by their username.")
                    }
                    Spacer()
                } else {
                    List(vm.addResults) { user in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.fullName).font(.body.weight(.semibold))
                                Text("@\(user.handle)").font(.caption).foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                vm.openProfile(for: user)
                            }
                            
                            Spacer()
                            
                            let isFriend = vm.friendIds.contains(user.uid)
                            let isPending = vm.isRequestPending(uid: user.uid)
                            let isCurrentUser = (user.uid == vm.meUid)
                            let incomingReq = vm.requests.first(where: { $0.fromUid == user.uid })
                            
                            if isCurrentUser {
                                Text("You")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else if isFriend {
                                Text("Friend")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            else if let req = incomingReq {
                                Button {
                                    Task { await vm.accept(req) }
                                } label: {
                                    Text("Accept")
                                }
                                .buttonStyle(.glassProminent)
                            }
                            else if isPending {
                                Text("Pending")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            else {
                                Button {
                                    vm.sendFriendRequest(to: user)
                                }
                                label: {
                                    Label { Text("Add") } icon: {
                                        Image(systemName: "person.badge.plus")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                    }
                                }
                                .buttonStyle(.glassProminent)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Add Friend")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) { dismiss() }
                }
            }
            .onAppear {
                isSearchFocused = true
            }
            .sheet(isPresented: $vm.showingProfile, onDismiss: {
                vm.performAddSearch()
            }) {
                if let p = vm.selectedProfile {
                    FriendProfileSheet(vm: vm, profile: p)
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading profile…")
                    }
                    .padding()
                    .presentationDetents([.fraction(0.3)])
                }
            }
        }
    }
}
