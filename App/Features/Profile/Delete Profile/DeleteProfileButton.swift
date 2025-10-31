import SwiftUI

struct DeleteProfileButton: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingConfirmation = false

    var body: some View {
        Button("Delete Profile") {
            showingConfirmation = true
        }
        .tint(.red)
        .padding(.top, 40)
        .alert("Confirm Deletion", isPresented: $showingConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    // Call the ViewModel action when confirmed
                    await viewModel.deleteProfile()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete your profile? This action cannot be undone.")
        }
    }
}
