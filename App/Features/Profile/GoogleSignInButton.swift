import SwiftUI
import Combine
import FirebaseAuth

struct GoogleSignInButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image("google-logo") // Add Google logo asset (transparent PNG)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("Continue with Google")
                    .fontWeight(.medium)
            }
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }
}
