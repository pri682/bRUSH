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
            hair: selectedHair
        )
    }

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
                    hair: selectedHair
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
                                // Use the improved preview that handles personal / fun mappings
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

    /// Improved option preview that:
    /// - Renders backgrounds only for the Background category (no avatar preview).
    /// - Composes layers correctly depending on avatar type.
    /// - Clips preview into a rounded rectangle and applies selection overlay.
    @ViewBuilder
    private func improvedOptionPreview(option: String, optionSize: CGFloat, screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        let cornerRadius = screenWidth * 0.03
        // defensive guard for index
        let categoryName = (selectedCategory >= 0 && selectedCategory < categories.count) ? categories[selectedCategory] : "Background"
        ZStack {
            // If this is the background category -> show only the background image,
            // scaledToFill and clipped so it doesn't overflow the small box.
            if categoryName.lowercased().contains("background") {
                Image(option)
                    .resizable()
                    .scaledToFill()
                    .frame(width: optionSize, height: optionSize)
                    .clipped()
            } else {
                // For non-background categories we need to compose existing layers (base/body/face, shirt if personal, eyes, mouth, hair)
                ZStack {
                    // Base layer (body / face)
                    if let body = selectedBody {
                        Image(body)
                            .resizable()
                            .scaledToFit()
                            .frame(width: optionSize, height: optionSize)
                    } else {
                        // If there's no selected body, optionally show a neutral placeholder (or nothing).
                        // We'll not show anything to keep the preview focused on the option.
                        Color.clear.frame(width: optionSize, height: optionSize)
                    }

                    // If personal: show shirt underneath eyes/mouth/hair
                    if selectedAvatarType == .personal {
                        if let shirt = selectedShirt {
                            Image(shirt)
                                .resizable()
                                .scaledToFit()
                                .frame(width: optionSize, height: optionSize)
                        }
                    }

                    // Eyes layer (if this preview is for eyes it will be the 'option')
                    if categoryName.lowercased().contains("eyes") {
                        Image(option)
                            .resizable()
                            .scaledToFit()
                            .frame(width: optionSize, height: optionSize)
                    } else {
                        // existing selected eyes (if any)
                        if let eyes = selectedEyes {
                            Image(eyes)
                                .resizable()
                                .scaledToFit()
                                .frame(width: optionSize, height: optionSize)
                        }
                    }

                    // Mouth layer
                    if categoryName.lowercased().contains("mouth") {
                        Image(option)
                            .resizable()
                            .scaledToFit()
                            .frame(width: optionSize, height: optionSize)
                    } else {
                        if let mouth = selectedMouth {
                            Image(mouth)
                                .resizable()
                                .scaledToFit()
                                .frame(width: optionSize, height: optionSize)
                        }
                    }

                    // Hair layer
                    if categoryName.lowercased().contains("hair") {
                        Image(option)
                            .resizable()
                            .scaledToFit()
                            .frame(width: optionSize, height: optionSize)
                    } else {
                        if let hair = selectedHair {
                            Image(hair)
                                .resizable()
                                .scaledToFit()
                                .frame(width: optionSize, height: optionSize)
                        }
                    }

                    // Body/Face preview when the category is Body/Face
                    if categoryName.lowercased().contains("body") || categoryName.lowercased().contains("face") {
                        Image(option)
                            .resizable()
                            .scaledToFit()
                            .frame(width: optionSize, height: optionSize)
                    }
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

    private func resetSelections() {
        selectedBody = nil
        selectedShirt = nil
        selectedEyes = nil
        selectedMouth = nil
        selectedHair = nil
        selectedCategory = 0
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
            case 0: selectedBody = option
            case 1: selectedEyes = option
            case 2: selectedMouth = option
            case 3: selectedHair = option
            case 4: selectedBackground = option
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
            userProfile = profile
        }

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
    }
}
