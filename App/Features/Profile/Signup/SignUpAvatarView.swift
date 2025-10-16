import SwiftUI

struct SignUpAvatarView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @State private var selectedFace = "face_1"
    @State private var selectedEyes = "eyes_1"
    @State private var selectedMouth = "mouth_1"
    @State private var selectedCategory = 0 // 0: Face, 1: Eyes, 2: Mouth
    
    private let categories = ["Face", "Eyes", "Mouth"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button("Cancel") {
                    // Handle cancel
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Create Avatar")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    viewModel.selectedAvatar = AvatarParts(
                        face: selectedFace,
                        eyes: selectedEyes,
                        mouth: selectedMouth
                    )
                    Task {
                        await viewModel.submitStep3()
                    }
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
            
            // Large Avatar Preview
            AvatarView(
                face: selectedFace,
                eyes: selectedEyes,
                mouth: selectedMouth
            )
            .frame(width: 280, height: 280)
            .padding(.bottom, 40)
            
            // Category Selection
            HStack(spacing: 0) {
                ForEach(0..<categories.count, id: \.self) { index in
                    Button {
                        selectedCategory = index
                    } label: {
                        Text(categories[index])
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedCategory == index ? .blue : .gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                    }
                }
            }
            .padding(.bottom, 20)
            
            // Options Grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(currentOptions, id: \.self) { option in
                        Button {
                            updateSelection(option)
                        } label: {
                            VStack(spacing: 8) {
                                // Small preview of the option
                                if selectedCategory == 0 {
                                    // Face preview
                                    Image(option)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                } else if selectedCategory == 1 {
                                    // Eyes preview on face
                                    ZStack {
                                        Image(selectedFace)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                        Image(option)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                    }
                                } else {
                                    // Mouth preview on face
                                    ZStack {
                                        Image(selectedFace)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                        Image(selectedEyes)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                        Image(option)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                    }
                                }
                                
                                // Selection indicator
                                Circle()
                                    .fill(isSelected(option) ? Color.blue : Color.clear)
                                    .frame(width: 8, height: 8)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.blue, lineWidth: isSelected(option) ? 0 : 1)
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Skip Button
            Button("Skip for Now") {
                Task {
                    await viewModel.skipPhotoStep()
                }
            }
            .foregroundColor(.gray)
            .padding(.bottom, 32)
        }
        .background(Color.white)
    }
    
    private var currentOptions: [String] {
        switch selectedCategory {
        case 0: return AvatarOptions.faces
        case 1: return AvatarOptions.eyes
        case 2: return AvatarOptions.mouths
        default: return []
        }
    }
    
    private func updateSelection(_ option: String) {
        switch selectedCategory {
        case 0: selectedFace = option
        case 1: selectedEyes = option
        case 2: selectedMouth = option
        default: break
        }
    }
    
    private func isSelected(_ option: String) -> Bool {
        switch selectedCategory {
        case 0: return selectedFace == option
        case 1: return selectedEyes == option
        case 2: return selectedMouth == option
        default: return false
        }
    }
}
