import SwiftUI

struct ProfileView: View {
    // Use the minimal ViewModel
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                
                Text(viewModel.userName)
                    .font(.largeTitle)
                    .padding(.top)
                
                Text("Welcome to your profile screen! Edit this file (and its ViewModel) to add features.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
