import SwiftUI

struct FriendProfileSheet: View {
    let profile: UserProfile
    var onConfirmRemove: (String) -> Void = { _ in }
    
    @Environment(\.dismiss) private var dismiss
    @State private var confirmRemove = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Circle()
                    .frame(width: 72, height: 72)
                    .overlay(Text(profile.displayName.prefix(1)).font(.title))
                    .accessibilityHidden(true)
                
                VStack(spacing: 2) {
                    Text([profile.firstName, profile.lastName].filter { !$0.isEmpty }.joined(separator: " "))
                        .font(.title3).bold()
                    Text("@\(profile.displayName)")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
                
                HStack(spacing: 24) {
                    Stat("Gold", profile.goldMedalsAccumulated)
                    Stat("Silver", profile.silverMedalsAccumulated)
                    Stat("Bronze", profile.bronzeMedalsAccumulated)
                }
                
                HStack(spacing: 12) {
                    Button(role: .destructive) {
                        confirmRemove = true
                    } label: {
                        Label("Remove Friend", systemImage: "person.fill.xmark")
                    }
                    .buttonStyle(.glass)
                    .tint(.red)
                }
                .padding(.top, 4)
            }
            .padding()
            .presentationDetents([.height(300)])
            .presentationBackground(Color(.systemBackground))
            
            .confirmationDialog(
                "Remove \(profile.displayName) as a friend?",
                isPresented: $confirmRemove,
                titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) {
                    onConfirmRemove(profile.uid)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .cancel) { dismiss() }
                }
            }
        }
    }
    
    private func Stat(_ label: String, _ value: Int) -> some View {
        var statColor: Color {
            switch label {
            case "Gold":
                return Color(red: 0.8, green: 0.65, blue: 0.0)
            case "Silver":
                return Color.gray
            case "Bronze":
                return Color(red: 0.6, green: 0.35, blue: 0.0)
            default:
                return Color.secondary
            }
        }
        
        return VStack {
            Text("\(value)").bold()
            Text(label).font(.caption).bold().foregroundStyle(statColor)
        }
        .frame(maxWidth: .infinity)
    }
}
