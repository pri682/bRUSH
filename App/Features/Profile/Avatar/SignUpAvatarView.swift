import SwiftUI

struct SignUpAvatarView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @State private var selectedBackground = "background_1"
    @State private var selectedFace: String? = nil
    @State private var selectedEyes: String? = nil
    @State private var selectedMouth: String? = nil
    @State private var selectedHair: String? = nil
    @State private var selectedCategory = 0 // 0: Background, 1: Face, 2: Eyes, 3: Mouth, 4: Hair
    
    // Undo/Redo functionality
    @State private var history: [AvatarParts] = []
    @State private var currentHistoryIndex = -1
    
    private let categories = ["Face", "Eyes", "Mouth", "Hair", "Background"]
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            
            // Dynamic sizing based on screen
            let avatarSize = min(screenWidth * 0.7, screenHeight * 0.4)
            let optionSize = screenWidth * 0.2
            let columnsCount = isIpad ? 6 : (screenWidth > 400 ? 4 : 3)
            let columns = Array(repeating: GridItem(.flexible(), spacing: screenWidth * 0.03), count: columnsCount)
            let horizontalPadding = screenWidth * 0.05
            
            VStack(spacing: 0) {
                // Navigation Bar with Undo/Redo
                HStack {
                    // Undo/Redo buttons
                    HStack(spacing: screenWidth * 0.03) {
                        Button {
                            undo()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: screenWidth * 0.04, weight: .medium))
                                .foregroundColor(canUndo ? .blue : .gray)
                        }
                        .disabled(!canUndo)
                        
                        Button {
                            redo()
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                                .font(.system(size: screenWidth * 0.04, weight: .medium))
                                .foregroundColor(canRedo ? .blue : .gray)
                        }
                        .disabled(!canRedo)
                    }
                    
                    Spacer()
                    
                    Text("Create Yourself")
                        .font(.system(size: screenWidth * 0.05, weight: .bold))
                    
                    Spacer()
                    
                    // Done/Next Button with green background and check icon
                    Button {
                        saveToHistory()
                        viewModel.selectedAvatar = AvatarParts(
                            background: selectedBackground,
                            face: selectedFace,
                            eyes: selectedEyes,
                            mouth: selectedMouth,
                            hair: selectedHair
                        )
                        Task {
                            await viewModel.submitStep3()
                        }
                    } label: {
                        HStack(spacing: screenWidth * 0.015) {
                            Image(systemName: selectedCategory == categories.count - 1 ? "checkmark" : "arrow.right")
                                .font(.system(size: screenWidth * 0.035, weight: .semibold))
                            Text(selectedCategory == categories.count - 1 ? "Done" : "Next")
                                .font(.system(size: screenWidth * 0.04, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, screenWidth * 0.04)
                        .padding(.vertical, screenWidth * 0.02)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: screenWidth * 0.05))
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, screenHeight * 0.02)
            
                Spacer()
                
                // Large Avatar Preview
                AvatarView(
                    background: selectedBackground,
                    face: selectedFace,
                    eyes: selectedEyes,
                    mouth: selectedMouth,
                    hair: selectedHair
                )
                .frame(width: avatarSize, height: avatarSize)
                .padding(.bottom, screenHeight * 0.02)
                
                // Enhanced Category Selection - Horizontal Scroll with Auto-scroll
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(0..<categories.count, id: \.self) { index in
                                Button {
                                    selectedCategory = index
                                    // Auto-scroll to center the selected category
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo(index, anchor: .center)
                                    }
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(categories[index])
                                            .font(.system(size: screenWidth * 0.04, weight: .bold))
                                            .foregroundColor(selectedCategory == index ? .blue : .gray)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .frame(minWidth: screenWidth * 0.2)
                                        
                                        // Underline indicator
                                        Rectangle()
                                            .fill(selectedCategory == index ? Color.blue : Color.clear)
                                            .frame(height: 3)
                                            .frame(width: screenWidth * 0.15)
                                    }
                                    .padding(.horizontal, screenWidth * 0.02)
                                    .padding(.vertical, screenHeight * 0.01)
                                }
                                .id(index)
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                    }
                }
                .padding(.bottom, screenHeight * 0.02)
            
                // Options Grid - Vertical Scroll
                ScrollView {
                    LazyVGrid(columns: columns, spacing: screenWidth * 0.03) {
                        ForEach(currentOptions, id: \.self) { option in
                            Button {
                                updateSelection(option)
                            } label: {
                                VStack(spacing: screenHeight * 0.015) {
                                    // Preview of the option
                                    ZStack {
                                        if selectedCategory == 0 {
                                            // Face preview
                                            Image(option)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: optionSize, height: optionSize)
                                        } else if selectedCategory == 1 {
                                            // Eyes preview on face
                                            ZStack {
                                                if let face = selectedFace {
                                                    Image(face)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: optionSize, height: optionSize)
                                                }
                                                Image(option)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: optionSize, height: optionSize)
                                            }
                                        } else if selectedCategory == 2 {
                                            // Mouth preview on face
                                            ZStack {
                                                if let face = selectedFace {
                                                    Image(face)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: optionSize, height: optionSize)
                                                }
                                                if let eyes = selectedEyes {
                                                    Image(eyes)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: optionSize, height: optionSize)
                                                }
                                                Image(option)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: optionSize, height: optionSize)
                                            }
                                        } else if selectedCategory == 3 {
                                            // Hair preview on full avatar
                                            ZStack {
                                                if let face = selectedFace {
                                                    Image(face)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: optionSize, height: optionSize)
                                                }
                                                if let eyes = selectedEyes {
                                                    Image(eyes)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: optionSize, height: optionSize)
                                                }
                                                if let mouth = selectedMouth {
                                                    Image(mouth)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: optionSize, height: optionSize)
                                                }
                                                Image(option)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: optionSize, height: optionSize)
                                            }
                                        } else {
                                            // Background preview
                                            Image(option)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: optionSize, height: optionSize)
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: screenWidth * 0.03)
                                            .stroke(isSelected(option) ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected(option) ? 3 : 1)
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: screenWidth * 0.03)
                                            .fill(isSelected(option) ? Color.blue.opacity(0.1) : Color.clear)
                                    )
                                    
                                    // Selection indicator
                                    Circle()
                                        .fill(isSelected(option) ? Color.blue : Color.clear)
                                        .frame(width: screenWidth * 0.03, height: screenWidth * 0.03)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.blue, lineWidth: isSelected(option) ? 0 : 2)
                                        )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .frame(maxHeight: screenHeight * 0.4)
            
                Spacer()
                
                // Skip Button
                Button("Skip for Now") {
                    Task {
                        await viewModel.skipPhotoStep()
                    }
                }
                .foregroundColor(.gray)
                .font(.system(size: screenWidth * 0.04))
                .padding(.bottom, screenHeight * 0.04)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .onAppear {
                initializeHistory()
            }
        }
    }
    
    private var currentOptions: [String] {
        switch selectedCategory {
        case 0: return AvatarOptions.faces
        case 1: return AvatarOptions.eyes
        case 2: return AvatarOptions.mouths
        case 3: return AvatarOptions.hairs
        case 4: return AvatarOptions.backgrounds
        default: return []
        }
    }
    
    private func updateSelection(_ option: String) {
        saveToHistory()
        
        switch selectedCategory {
        case 0: selectedFace = option
        case 1: selectedEyes = option
        case 2: selectedMouth = option
        case 3: selectedHair = option
        case 4: selectedBackground = option
        default: break
        }
    }
    
    private func isSelected(_ option: String) -> Bool {
        switch selectedCategory {
        case 0: return selectedFace == option
        case 1: return selectedEyes == option
        case 2: return selectedMouth == option
        case 3: return selectedHair == option
        case 4: return selectedBackground == option
        default: return false
        }
    }
    
    // MARK: - Undo/Redo functionality
    
    private var canUndo: Bool {
        return currentHistoryIndex > 0
    }
    
    private var canRedo: Bool {
        return currentHistoryIndex < history.count - 1
    }
    
    private func initializeHistory() {
        let initialAvatar = AvatarParts(
            background: selectedBackground,
            face: selectedFace,
            eyes: selectedEyes,
            mouth: selectedMouth,
            hair: selectedHair
        )
        history = [initialAvatar]
        currentHistoryIndex = 0
    }
    
    private func saveToHistory() {
        let currentAvatar = AvatarParts(
            background: selectedBackground,
            face: selectedFace,
            eyes: selectedEyes,
            mouth: selectedMouth,
            hair: selectedHair
        )
        
        // Remove any history after current index
        history = Array(history.prefix(currentHistoryIndex + 1))
        
        // Add new state
        history.append(currentAvatar)
        currentHistoryIndex = history.count - 1
        
        // Limit history size
        if history.count > 20 {
            history.removeFirst()
            currentHistoryIndex -= 1
        }
    }
    
    private func undo() {
        guard canUndo else { return }
        currentHistoryIndex -= 1
        applyHistoryState()
    }
    
    private func redo() {
        guard canRedo else { return }
        currentHistoryIndex += 1
        applyHistoryState()
    }
    
    private func applyHistoryState() {
        let state = history[currentHistoryIndex]
        selectedBackground = state.background
        selectedFace = state.face
        selectedEyes = state.eyes
        selectedMouth = state.mouth
        selectedHair = state.hair
    }
}
