import SwiftUI

struct SignUpAvatarView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @State private var selectedAvatarType: AvatarType = .personal
    @State private var selectedBackground = "background_1"
    @State private var selectedBody: String? = nil
    @State private var selectedShirt: String? = nil
    @State private var selectedEyes: String? = nil
    @State private var selectedMouth: String? = nil
    @State private var selectedHair: String? = nil
    @State private var selectedCategory = 0
    
    // Undo/Redo functionality
    @State private var history: [AvatarParts] = []
    @State private var currentHistoryIndex = -1
    
    private var categories: [String] {
        switch selectedAvatarType {
        case .personal:
            return ["Body", "Shirt", "Eyes", "Mouth", "Hair", "Background"]
        case .fun:
            return ["Face", "Eyes", "Mouth", "Hair", "Background"]
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width // get screen width
            let screenHeight = geometry.size.height // get screen height
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad // is it an iPad?
            
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
                                .foregroundColor(canUndo ? .blue : .gray) // if can undo blue, else grey
                        }
                        .disabled(!canUndo)
                        
                        Button {
                            redo()
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                                .font(.system(size: screenWidth * 0.04, weight: .medium))
                                .foregroundColor(canRedo ? .blue : .gray) // if can undo blue, else grey
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
                            avatarType: selectedAvatarType,
                            background: selectedBackground,
                            body: selectedBody,
                            shirt: selectedShirt,
                            eyes: selectedEyes,
                            mouth: selectedMouth,
                            hair: selectedHair
                        )
                        Task {
                            await viewModel.submitStep3() // submit changes to firebase
                            // Technically this actually sends the data back to signupViewModel, which
                            // completes the signup an writes the FULL UPDATE to firebase
                            // all in one write.
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
                        .clipShape(RoundedRectangle(cornerRadius: 6)) // Less rounded corners
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, screenHeight * 0.02)
            
                Spacer()
                
                // Avatar Type Selection Tabs
                HStack(spacing: 0) {
                    ForEach(AvatarType.allCases, id: \.self) { avatarType in
                        Button {
                            selectedAvatarType = avatarType
                            // Reset selections when switching types
                            selectedBody = nil
                            selectedShirt = nil
                            selectedEyes = nil
                            selectedMouth = nil
                            selectedHair = nil
                            selectedCategory = 0
                        } label: {
                            Text(avatarType.displayName)
                                .font(.system(size: screenWidth * 0.04, weight: .medium))
                                .foregroundColor(selectedAvatarType == avatarType ? .white : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, screenHeight * 0.015)
                                .background(
                                    RoundedRectangle(cornerRadius: screenWidth * 0.02)
                                        .fill(selectedAvatarType == avatarType ? Color.accentColor : Color(.systemGray6))
                                )
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, screenHeight * 0.02)
                
                // Large Avatar Preview
                AvatarView(
                    avatarType: selectedAvatarType,
                    background: selectedBackground,
                    avatarBody: selectedBody,
                    shirt: selectedShirt,
                    eyes: selectedEyes,
                    mouth: selectedMouth,
                    hair: selectedHair
                )
                .frame(width: avatarSize, height: avatarSize)
                .padding(.bottom, screenHeight * 0.05)
                
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
                    LazyVGrid(columns: columns, spacing: screenWidth * 0.04) {
                        ForEach(currentOptions, id: \.self) { option in
                            Button {
                                updateSelection(option)
                            } label: {
                                VStack(spacing: screenHeight * 0.015) {
                                    // Preview of the option
                                    ZStack {
                                        if selectedCategory == 0 {
                                            // Body preview
                                            Image(option)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: optionSize, height: optionSize)
                                        } else if selectedCategory == 1 {
                                            // Shirt preview on body
                                            ZStack {
                                                if let body = selectedBody {
                                                    Image(body)
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
                                            // Eyes preview on body and shirt
                                            ZStack {
                                                if let body = selectedBody {
                                                    Image(body)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: optionSize, height: optionSize)
                                                }
                                                if let shirt = selectedShirt {
                                                    Image(shirt)
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
                                            // Mouth preview on body, shirt, and eyes
                                            ZStack {
                                                if let body = selectedBody {
                                                    Image(body)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: optionSize, height: optionSize)
                                                }
                                                if let shirt = selectedShirt {
                                                    Image(shirt)
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
                                        } else if selectedCategory == 4 {
                                            // Hair preview on body, shirt, eyes, and mouth
                                            ZStack {
                                                if let body = selectedBody {
                                                    Image(body)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: optionSize, height: optionSize)
                                                }
                                                if let shirt = selectedShirt {
                                                    Image(shirt)
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
                                                .scaledToFill()
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
                                }
                            }
                        }
                    }
                    .padding(.top, 3)
                    .padding(.horizontal, horizontalPadding)
                }
                .frame(maxHeight: screenHeight * 0.4)
            
                Spacer()
                
                // REMOVED FOR NOW!! Skip Button
//                Button("Skip for Now") {
//                    Task {
//                        await viewModel.skipPhotoStep()
//                    }
//                }
                
                .foregroundColor(.gray)
                .font(.system(size: screenWidth * 0.04))
                .padding(.bottom, screenHeight * 0.04)
            }
            .navigationBarHidden(true)
            .onAppear {
                initializeHistory()
            }
        }
    }
    
    private var currentOptions: [String] {
        switch selectedAvatarType {
        case .personal:
            switch selectedCategory {
            case 0: return AvatarOptions.personalBodies
            case 1: return AvatarOptions.personalShirts
            case 2: return AvatarOptions.personalEyes
            case 3: return AvatarOptions.personalMouths
            case 4: return AvatarOptions.personalHairs
            case 5: return AvatarOptions.personalBackgrounds
            default: return []
            }
        case .fun:
            switch selectedCategory {
            case 0: return AvatarOptions.funFaces
            case 1: return AvatarOptions.funEyes
            case 2: return AvatarOptions.funMouths
            case 3: return AvatarOptions.funHairs
            case 4: return AvatarOptions.funBackgrounds
            default: return []
            }
        }
    }
    
    private func updateSelection(_ option: String) {
        saveToHistory()
        
        switch selectedAvatarType {
        case .personal:
            switch selectedCategory {
            case 0: selectedBody = option
            case 1: selectedShirt = option
            case 2: selectedEyes = option
            case 3: selectedMouth = option
            case 4: selectedHair = option
            case 5: selectedBackground = option
            default: break
            }
        case .fun:
            switch selectedCategory {
            case 0: selectedBody = option // Face maps to body for fun avatars
            case 1: selectedEyes = option
            case 2: selectedMouth = option
            case 3: selectedHair = option
            case 4: selectedBackground = option
            default: break
            }
        }
    }
    
    private func isSelected(_ option: String) -> Bool {
        switch selectedAvatarType {
        case .personal:
            switch selectedCategory {
            case 0: return selectedBody == option
            case 1: return selectedShirt == option
            case 2: return selectedEyes == option
            case 3: return selectedMouth == option
            case 4: return selectedHair == option
            case 5: return selectedBackground == option
            default: return false
            }
        case .fun:
            switch selectedCategory {
            case 0: return selectedBody == option // Face maps to body
            case 1: return selectedEyes == option
            case 2: return selectedMouth == option
            case 3: return selectedHair == option
            case 4: return selectedBackground == option
            default: return false
            }
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
            avatarType: selectedAvatarType,
            background: selectedBackground,
            body: selectedBody,
            shirt: selectedShirt,
            eyes: selectedEyes,
            mouth: selectedMouth,
            hair: selectedHair
        )
        history = [initialAvatar]
        currentHistoryIndex = 0
    }
    
    private func saveToHistory() {
        let currentAvatar = AvatarParts(
            avatarType: selectedAvatarType,
            background: selectedBackground,
            body: selectedBody,
            shirt: selectedShirt,
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
        selectedAvatarType = state.avatarType
        selectedBackground = state.background
        selectedBody = state.body
        selectedShirt = state.shirt
        selectedEyes = state.eyes
        selectedMouth = state.mouth
        selectedHair = state.hair
    }
}
