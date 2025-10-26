import SwiftUI

struct AddFriendView: View {
    @ObservedObject var vm: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack (spacing: 8){
                    Text("@").foregroundStyle(.secondary)
                    TextField("username", text: $vm.addQuery)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .submitLabel(.search)
                        .onSubmit { vm.performAddSearch() }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder),
                                                    to: nil, from: nil, for: nil)
                }
                .padding([.horizontal, .top])
                
                if vm.isSearchingAdd {
                    ProgressView("Searching…").padding(.top, 12)
                } else if let err = vm.addError {
                    Text(err).foregroundStyle(.red).padding(.horizontal)
                } else if vm.addResults.isEmpty && !vm.addQuery.isEmpty {
                    Text("No users found for “\(vm.addQuery)”")
                        .foregroundStyle(.secondary)
                        .padding(.top, 12)
                }
                
                List(vm.addResults) { user in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.displayName).font(.body.weight(.semibold))
                            Text("@\(user.handle)").font(.caption).foregroundStyle(.secondary)
                                .buttonStyle(.borderedProminent)
                        }
                        Spacer()
                            // Row status: Friend / Pending / Add
                            let isFriend = vm.friendIds.contains(user.uid)
                            let isPending = vm.isRequestPending(uid: user.uid)
                            
                            if isFriend {
                                Text("Friend")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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
                                        Image(systemName: "person.badge.plus").foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.inset)
                }
                .navigationTitle("Add Friend")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Search") { vm.performAddSearch() }.disabled(vm.addQuery.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }

