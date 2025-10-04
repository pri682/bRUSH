import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            if viewModel.user != nil {
                SignedInProfileView(viewModel: viewModel)
            } else {
                SignInProfileView(viewModel: viewModel)
            }
        }
    }
}

