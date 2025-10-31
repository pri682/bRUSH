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
                                    .buttonStyle(.borderedProminent)
                            }
                            Spacer()
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
            }
            .navigationTitle("Add Friend")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) { dismiss() }
                }
            }
        }
    }
}
