import SwiftUI

struct AddFriendView: View {
    @ObservedObject var vm: FriendsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("@").foregroundStyle(.secondary)
                    TextField("username", text: $vm.addQuery)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .submitLabel(.search)
                        //.onSubmit { vm.performAddSearch() }
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
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
                        }
                        Spacer()
                        if vm.sent.contains(where: { $0.handle == "@\(user.handle)" }) {
                            Text("Pending")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Button {
                                vm.sendFriendRequest(to: user)
                            } label: {
                                Label {
                                    Text("Add")
                                } icon: {
                                    Image(systemName: "person.badge.plus")
                                        .foregroundColor(.white)
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
