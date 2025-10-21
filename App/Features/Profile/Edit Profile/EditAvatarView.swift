import SwiftUI

struct EditAvatarView: View {
    @Binding var userProfile: UserProfile?
    @StateObject private var viewModel: EditProfileViewModel
    @State private var selectedAvatarType: AvatarType
    @State private var selectedBackground: String
    @State private var selectedBody: String?
    @State private var selectedShirt: String?
    @State private var selectedEyes: String?
    @State private var selectedMouth: String?
    @State private var selectedHair: String?
    @State private var selectedCategory = 0
    
    let onAvatarChange: (AvatarParts) -> Void
    
    // Computed property to get current avatar parts
    var currentAvatarParts: AvatarParts {
        AvatarParts(
            avatarType: selectedAvatarType,
            background: selectedBackground,
            body: selectedBody,
            shirt: selectedShirt,
            eyes: selectedEyes,
            mouth: selectedMouth,
            hair: selectedHair
        )
    }
    
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
    
    init(userProfile: Binding<UserProfile?>, onAvatarChange: @escaping (AvatarParts) -> Void) {
        self._userProfile = userProfile
        self.onAvatarChange = onAvatarChange
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(userProfile: userProfile.wrappedValue!))
        // Initialize with current avatar values
        let avatarType = AvatarType(rawValue: userProfile.wrappedValue?.avatarType ?? "personal") ?? .personal
        self._selectedAvatarType = State(initialValue: avatarType)
        self._selectedBackground = State(initialValue: userProfile.wrappedValue?.avatarBackground ?? "background_1")
        self._selectedBody = State(initialValue: userProfile.wrappedValue?.avatarBody)
        self._selectedShirt = State(initialValue: userProfile.wrappedValue?.avatarShirt)
        self._selectedEyes = State(initialValue: userProfile.wrappedValue?.avatarEyes)
        self._selectedMouth = State(initialValue: userProfile.wrappedValue?.avatarMouth)
        self._selectedHair = State(initialValue: userProfile.wrappedValue?.avatarHair)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            
            // Dynamic sizing based on screen
            let avatarSize = min(screenWidth * 0.6, screenHeight * 0.35)
            let optionSize = screenWidth * 0.18
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
                                .foregroundColor(canUndo ? .accentColor : .gray)
                        }
                        .disabled(!canUndo)
                        
                        Button {
                            redo()
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                                .font(.system(size: screenWidth * 0.04, weight: .medium))
                                .foregroundColor(canRedo ? .accentColor : .gray)
                        }
                        .disabled(!canRedo)
                    }
                    
                    Spacer()
                    
                    Text("Edit Avatar")
                        .font(.system(size: screenWidth * 0.05, weight: .bold))
                    
                    Spacer()
                    
                    // Placeholder for spacing
                    Color.clear
                        .frame(width: screenWidth * 0.2, height: screenWidth * 0.08)
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
                .padding(.bottom, screenHeight * 0.04)
                
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
                                            .foregroundColor(selectedCategory == index ? .accentColor : .gray)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .frame(minWidth: screenWidth * 0.2)
                                        
                                        // Underline indicator
                                        Rectangle()
                                            .fill(selectedCategory == index ? Color.accentColor : Color.clear)
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
                                            .stroke(isSelected(option) ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected(option) ? 3 : 1)
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: screenWidth * 0.03)
                                            .fill(isSelected(option) ? Color.accentColor.opacity(0.1) : Color.clear)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.top, 3)
                    .padding(.horizontal, horizontalPadding)
                }
                .frame(maxHeight: screenHeight * 0.35)
                
                Spacer()
            }
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
        
        // Update userProfile binding for real-time preview (but not saved to Firebase yet)
        if var profile = userProfile {
            profile.avatarType = selectedAvatarType.rawValue
            profile.avatarBackground = selectedBackground
            profile.avatarBody = selectedBody
            profile.avatarShirt = selectedShirt
            profile.avatarEyes = selectedEyes
            profile.avatarMouth = selectedMouth
            profile.avatarHair = selectedHair
            userProfile = profile
        }
        
        // Notify parent of avatar changes for preview (but not saved yet)
        onAvatarChange(currentAvatarParts)
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
