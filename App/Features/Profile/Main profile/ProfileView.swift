import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            if viewModel.isCheckingAuth {
                Color.clear
                    .ignoresSafeArea(.all)
            } else if viewModel.user != nil {
                SignedInProfileView(viewModel: viewModel)
            } else {
                SignInProfileView(viewModel: viewModel)
            }
        }
    }
}

