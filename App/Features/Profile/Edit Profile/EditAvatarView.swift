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
    @State private var selectedFacialHair: String?
    
    @State private var selectedCategory = 0
    
    let onAvatarChange: (AvatarParts) -> Void
    
    // Unique identifier for the "Remove/None" option
    private static let removeOptionId = "__REMOVE__"

    // Undo/Redo functionality
    @State private var history: [AvatarParts] = []
    @State private var currentHistoryIndex = -1

    // Computed property to get current avatar parts
    var currentAvatarParts: AvatarParts {
        AvatarParts(
            avatarType: selectedAvatarType,
            background: selectedBackground,
            body: selectedBody,
            shirt: selectedShirt,
            eyes: selectedEyes,
            mouth: selectedMouth,
            hair: selectedHair,
            facialHair: selectedFacialHair // Assuming AvatarParts has been updated
        )
    }

    private var categories: [String] {
        switch selectedAvatarType {
        case .personal:
            return ["Body", "Shirt", "Eyes", "Mouth", "Hair","Facial Hair", "Background"]
        case .fun:
            return ["Face", "Eyes", "Mouth", "Hair", "Background"]
        }
    }

    init(userProfile: Binding<UserProfile?>, onAvatarChange: @escaping (AvatarParts) -> Void) {
        self._userProfile = userProfile
        self.onAvatarChange = onAvatarChange
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(userProfile: userProfile.wrappedValue!))

        let avatarType = AvatarType(rawValue: userProfile.wrappedValue?.avatarType ?? "personal") ?? .personal
        self._selectedAvatarType = State(initialValue: avatarType)
        self._selectedBackground = State(initialValue: userProfile.wrappedValue?.avatarBackground ?? "background_1")
        self._selectedBody = State(initialValue: userProfile.wrappedValue?.avatarBody)
        self._selectedShirt = State(initialValue: userProfile.wrappedValue?.avatarShirt)
        self._selectedEyes = State(initialValue: userProfile.wrappedValue?.avatarEyes)
        self._selectedMouth = State(initialValue: userProfile.wrappedValue?.avatarMouth)
        self._selectedHair = State(initialValue: userProfile.wrappedValue?.avatarHair)
        self._selectedFacialHair = State(initialValue: userProfile.wrappedValue?.avatarFacialHair) // Assuming UserProfile has been updated
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad

            let avatarSize = min(screenWidth * 0.6, screenHeight * 0.35)
            let columnsCount = isIpad ? 6 : (screenWidth > 400 ? 4 : 3)
            let columns = Array(repeating: GridItem(.flexible(), spacing: screenWidth * 0.03), count: columnsCount)
            let horizontalPadding = screenWidth * 0.05
            let optionSize = screenWidth * 0.18

            VStack(spacing: 0) {
                // Navigation Bar with Undo/Redo
                HStack {
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
                            // Save current state before resetting for type change
                            saveToHistory()
                            selectedAvatarType = avatarType
                            resetSelections()
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

                // Avatar Preview
                AvatarView(
                    avatarType: selectedAvatarType,
                    background: selectedBackground,
                    avatarBody: selectedBody,
                    shirt: selectedShirt,
                    eyes: selectedEyes,
                    mouth: selectedMouth,
                    hair: selectedHair,
                    facialHair: selectedFacialHair // CORRECTED: Now includes the new argument
                    
                )
                .frame(width: avatarSize, height: avatarSize)
                .padding(.bottom, screenHeight * 0.04)

                // Category Selection
                categorySelector(screenWidth: screenWidth, screenHeight: screenHeight, horizontalPadding: horizontalPadding)

                // Options Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: screenWidth * 0.04) {
                        ForEach(currentOptions, id: \.self) { option in
                            Button {
                                updateSelection(option)
                            } label: {
                                improvedOptionPreview(
                                    option: option,
                                    optionSize: optionSize,
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight
                                )
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

    // MARK: - Subviews

    private func categorySelector(screenWidth: CGFloat, screenHeight: CGFloat, horizontalPadding: CGFloat) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(0..<categories.count, id: \.self) { index in
                        Button {
                            selectedCategory = index
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(index, anchor: .center)
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(categories[index])
                                    .font(.system(size: screenWidth * 0.04, weight: .bold))
                                    .foregroundColor(selectedCategory == index ? .accentColor : .gray)
                                    .frame(minWidth: screenWidth * 0.2)

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
    }

    /// Improved option preview that correctly composes layers for the current category, including the "__REMOVE__" option.
    @ViewBuilder
    private func improvedOptionPreview(option: String, optionSize: CGFloat, screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        let cornerRadius = screenWidth * 0.03
        let categoryName = (selectedCategory >= 0 && selectedCategory < categories.count) ? categories[selectedCategory] : "Background"
        
        // Booleans for category determination
        let isBackgroundCategory = categoryName.lowercased().contains("background")
        let isBodyOrFaceCategory = categoryName.lowercased().contains("body") || categoryName.lowercased().contains("face")
        let isShirtCategory = categoryName.lowercased().contains("shirt")
        let isEyesCategory = categoryName.lowercased().contains("eyes")
        
        let isFacialHairCategory = categoryName.lowercased().contains("facial hair") // ADDED: new boolean
        
        let isMouthCategory = categoryName.lowercased().contains("mouth")
        let isHairCategory = categoryName.lowercased().contains("hair")
        
        
        ZStack {
            if option == Self.removeOptionId {
                // RENDER THE REMOVE ICON (Nothing option)
                VStack {
                    Image(systemName: "circle.slash.fill")
                        .font(.system(size: optionSize * 0.5, weight: .bold))
                        .foregroundColor(.orange)
                    Text("None")
                        .font(.system(size: screenWidth * 0.035, weight: .medium))
                        .foregroundColor(.gray)
                }
                .frame(width: optionSize, height: optionSize)
                .background(Color(.systemGray6))
            } else if isBackgroundCategory {
                // MARK: - Background Preview
                Image(option)
                    .resizable()
                    .scaledToFill()
                    .frame(width: optionSize, height: optionSize)
                    .clipped()
            } else {
                // MARK: - Avatar Part Previews (Layered)
                
                // Determine which asset string to use for each layer:
                // Use 'option' if the category matches the layer being previewed, otherwise use the 'selected' part.
                let baseLayer: String? = isBodyOrFaceCategory ? option : selectedBody
                let shirtLayer: String? = isShirtCategory ? option : selectedShirt
                let eyesLayer: String? = isEyesCategory ? option : selectedEyes
                let mouthLayer: String? = isMouthCategory ? option : selectedMouth
                let hairLayer: String? = isHairCategory ? option : selectedHair
                let facialHairLayer: String? = isFacialHairCategory ? option : selectedFacialHair // CORRECTED: Define the local variable
                
                // --- 1. BASE LAYER (Body/Face) ---
                if let base = baseLayer {
                    Image(base)
                        .resizable()
                        .scaledToFit()
                        .frame(width: optionSize, height: optionSize)
                } else {
                    Color.clear.frame(width: optionSize, height: optionSize)
                }
                
                // --- 2. SHIRT LAYER (Personal Only) ---
                if selectedAvatarType == .personal, let shirt = shirtLayer {
                    Image(shirt)
                        .resizable()
                        .scaledToFit()
                        .frame(width: optionSize, height: optionSize)
                }
                
                // --- 3. EYES LAYER ---
                if let eyes = eyesLayer {
                    Image(eyes)
                        .resizable()
                        .scaledToFit()
                        .frame(width: optionSize, height: optionSize)
                }
                
                // --- 4. FACIAL HAIR LAYER ---
                if selectedAvatarType == .personal, let facialHair = facialHairLayer { // ADDED: Check for personal
                    Image(facialHair)
                        .resizable()
                        .scaledToFit()
                        .frame(width: optionSize, height: optionSize)
                }
                
                // --- 5. MOUTH LAYER ---
                if let mouth = mouthLayer {
                    Image(mouth)
                        .resizable()
                        .scaledToFit()
                        .frame(width: optionSize, height: optionSize)
                }
                
                // --- 6. HAIR LAYER ---
                if let hair = hairLayer {
                    Image(hair)
                        .resizable()
                        .scaledToFit()
                        .frame(width: optionSize, height: optionSize)
                }
                
                            
            }
        }
        .frame(width: optionSize, height: optionSize)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isSelected(option) ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isSelected(option) ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected(option) ? 3 : 1)
        )
    }

    // MARK: - Helper Functions

    private var currentOptions: [String] {
        let options: [String]
        let currentCategoryName = categories[selectedCategory].lowercased()
        
        switch selectedAvatarType {
        case .personal:
            switch selectedCategory {
            case 0: options = AvatarOptions.personalBodies
            case 1: options = AvatarOptions.personalShirts
            case 2: options = AvatarOptions.personalEyes
            case 3: options = AvatarOptions.personalMouths
            case 4: options = AvatarOptions.personalHairs
            case 5: options = AvatarOptions.personalFacialHairs
            case 6: options = AvatarOptions.personalBackgrounds
            default: return []
            }
        case .fun:
            switch selectedCategory {
            case 0: options = AvatarOptions.funFaces
            case 1: options = AvatarOptions.funEyes
            case 2: options = AvatarOptions.funMouths
            case 3: options = AvatarOptions.funHairs
            case 4: options = AvatarOptions.funBackgrounds
            default: return []
            }
        }
        
        // Only add the remove option for non-background categories
        if currentCategoryName != "background" {
            return [Self.removeOptionId] + options
        } else {
            return options
        }
    }

    private func resetSelections() {
        selectedBody = nil
        selectedShirt = nil
        selectedEyes = nil
        selectedMouth = nil
        selectedHair = nil
        selectedFacialHair = nil
        // Background is intentionally not reset
        selectedCategory = 0
    }

    private func updateSelection(_ option: String) {
        saveToHistory()
        
        // Determine the value to set: nil if __REMOVE__, otherwise the option string
        let newValue: String? = (option == Self.removeOptionId) ? nil : option
        
        switch selectedAvatarType {
        case .personal:
            switch selectedCategory {
            case 0: selectedBody = newValue
            case 1: selectedShirt = newValue
            case 2: selectedEyes = newValue
            case 3: selectedMouth = newValue
            case 4: selectedHair = newValue
            case 5: selectedFacialHair = newValue // NEW CASE
            case 6: selectedBackground = option // Background cannot be nil
            default: break
            }
        case .fun:
            switch selectedCategory {
            case 0: selectedBody = newValue
            case 1: selectedEyes = newValue
            case 2: selectedMouth = newValue
            case 3: selectedHair = newValue
            case 4: selectedBackground = option // Background cannot be nil
            default: break
            }
        }

        if var profile = userProfile {
            profile.avatarType = selectedAvatarType.rawValue
            profile.avatarBackground = selectedBackground
            profile.avatarBody = selectedBody
            profile.avatarShirt = selectedShirt
            profile.avatarEyes = selectedEyes
            profile.avatarMouth = selectedMouth
            profile.avatarHair = selectedHair
            profile.avatarFacialHair = selectedFacialHair // Assuming UserProfile has been updated
            userProfile = profile
        }

        onAvatarChange(currentAvatarParts)
    }

    private func isSelected(_ option: String) -> Bool {
        if option == Self.removeOptionId {
            // The 'None' option is selected if the corresponding part is currently nil
            switch selectedAvatarType {
            case .personal:
                switch selectedCategory {
                case 0: return selectedBody == nil
                case 1: return selectedShirt == nil
                case 2: return selectedEyes == nil
                case 3: return selectedMouth == nil
                case 4: return selectedHair == nil
                case 5: return selectedFacialHair == nil
                case 6: return false // Background must always have a value
                default: return false
                }
            case .fun:
                switch selectedCategory {
                case 0: return selectedBody == nil
                case 1: return selectedEyes == nil
                case 2: return selectedMouth == nil
                case 3: return selectedHair == nil
                case 4: return false // Background must always have a value
                default: return false
                }
            }
        }
        
        // For a normal part, check if it matches the selected state variable.
        switch selectedAvatarType {
        case .personal:
            switch selectedCategory {
            case 0: return selectedBody == option
            case 1: return selectedShirt == option
            case 2: return selectedEyes == option
            case 3: return selectedMouth == option
            case 4: return selectedHair == option
            case 5: return selectedFacialHair == option
            case 6: return selectedBackground == option
            default: return false
            }
        case .fun:
            switch selectedCategory {
            case 0: return selectedBody == option
            case 1: return selectedEyes == option
            case 2: return selectedMouth == option
            case 3: return selectedHair == option
            case 4: return selectedBackground == option
            default: return false
            }
        }
    }

    // MARK: - Undo/Redo

    private var canUndo: Bool { currentHistoryIndex > 0 }
    private var canRedo: Bool { currentHistoryIndex < history.count - 1 }

    private func initializeHistory() {
        let initial = currentAvatarParts
        history = [initial]
        currentHistoryIndex = 0
    }

    private func saveToHistory() {
        let state = currentAvatarParts
        history = Array(history.prefix(currentHistoryIndex + 1))
        history.append(state)
        currentHistoryIndex = history.count - 1

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
        selectedFacialHair = state.facialHair
    }
}
