import SwiftUI

struct UserFeedItemView: View {
    let item: FeedItem
    let prompt: String
    let loadID: UUID

    @State private var goldCount: Int
    @State private var silverCount: Int
    @State private var bronzeCount: Int
    @State private var goldSelected = false
    @State private var silverSelected = false
    @State private var bronzeSelected = false
    @State private var showOverlays = true

    @Binding var hasPostedToday: Bool
    @Binding var hasAttemptedDrawing: Bool
    @Binding var isPresentingCreate: Bool
    
    @State private var isSharing = false
    @State private var rippleCounter: Int = 0
    @State private var rippleOrigin: CGPoint = .zero
    
    @Namespace private var transition
    @State private var loadedImage: UIImage? = nil
    @State private var imageLoadFailed = false
    
    @State private var isContentLoaded = false
    
    @State private var isShowingProfileSheet: Bool = false
    @StateObject private var friendsViewModel = FriendsViewModel()

    init(
        item: FeedItem,
        prompt: String,
        hasPostedToday: Binding<Bool>,
        hasAttemptedDrawing: Binding<Bool>,
        isPresentingCreate: Binding<Bool>,
        loadID: UUID,
    ) {
        self.item = item
        self.prompt = prompt
        self.loadID = loadID
        _goldCount = State(initialValue: item.medalGold)
        _silverCount = State(initialValue: item.medalSilver)
        _bronzeCount = State(initialValue: item.medalBronze)
        self._hasPostedToday = hasPostedToday
        self._hasAttemptedDrawing = hasAttemptedDrawing
        self._isPresentingCreate = isPresentingCreate
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ZStack {
                    AsyncImage(url: URL(string: item.imageURL), transaction: Transaction(animation: .easeIn(duration: 0.3))) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .modifier(RippleEffect(at: rippleOrigin, trigger: rippleCounter))
                        case .failure:
                            Rectangle()
                                .fill(Color(.secondarySystemBackground))
                                .overlay(Image(systemName: "photo.fill").foregroundColor(.gray))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        @unknown default:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }

                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            guard hasPostedToday else { return }
                            rippleOrigin = location
                            rippleCounter += 1
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
                                showOverlays.toggle()
                            }
                        }

                    VStack {
                        Text(prompt)
                            .font(.system(size: 16, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .glassEffect(.regular.interactive())
                            .opacity(hasPostedToday ? (showOverlays ? 1 : 0) : 0)
                            .scaleEffect(showOverlays ? 1 : 0.95)
                            .animation(.spring(response: 0.25, dampingFraction: 0.55).delay(1.00), value: showOverlays)
                            .padding(.top, 10)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .allowsHitTesting(false)

                    if hasPostedToday {
                        userOverlay
                        actionsOverlay
                    }
                }

                if !hasPostedToday {
                    noPostOverlay
                }
            }
        }
        .aspectRatio(9/16, contentMode: .fit)
        .background(Color.clear)
        .opacity(isContentLoaded ? 1 : 0)
        .animation(.easeIn(duration: 0.3), value: isContentLoaded)
        .sheet(isPresented: $isShowingProfileSheet) {
            let profile = UserProfile(
                uid: item.userId,
                firstName: item.firstName,
                lastName: item.lastName,
                displayName: item.displayName,
                email: item.email,
                avatarType: item.avatarType,
                avatarBackground: item.avatarBackground,
                avatarBody: item.avatarBody,
                avatarShirt: item.avatarShirt,
                avatarEyes: item.avatarEyes,
                avatarMouth: item.avatarMouth,
                avatarHair: item.avatarHair,
                avatarFacialHair: item.avatarFacialHair,
                goldMedalsAccumulated: item.goldMedalsAccumulated,
                silverMedalsAccumulated: item.silverMedalsAccumulated,
                bronzeMedalsAccumulated: item.bronzeMedalsAccumulated,
                goldMedalsAwarded: item.goldMedalsAwarded,
                silverMedalsAwarded: item.silverMedalsAwarded,
                bronzeMedalsAwarded: item.bronzeMedalsAwarded,
                totalDrawingCount: item.totalDrawingCount,
                streakCount: item.streakCount,
                memberSince: item.memberSince
            )
            FriendProfileSheet(vm: friendsViewModel, profile: profile)
        }
        .sheet(isPresented: $isSharing) {
            ShareSheetLoaderView(item: item, cachedImage: loadedImage)
                .presentationDetents([.medium, .large])
        }
        .task(id: loadID) {
            let isFirstLoad = (loadedImage == nil)
            
            if isFirstLoad {
                self.isContentLoaded = false
                self.imageLoadFailed = false
            }

            let image = await fetchImage()
            
            if Task.isCancelled { return }

            if let image = image {
                self.loadedImage = image
                self.imageLoadFailed = false
            } else {
                if isFirstLoad {
                    self.imageLoadFailed = true
                }
            }
            
            if isFirstLoad {
                self.isContentLoaded = true
            }
        }
        .onAppear {
            friendsViewModel.refreshFriends()
            friendsViewModel.refreshIncoming()
        }
    }
    
    private func fetchImage() async -> UIImage? {
        guard let url = URL(string: item.imageURL) else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if Task.isCancelled { return nil }
            return UIImage(data: data)
        } catch {
            if !(error is CancellationError) {
                print("Error loading image: \(error.localizedDescription)")
            }
            return nil
        }
    }

    private var userOverlay: some View {
        HStack(spacing: 12) {
            AvatarView(
                avatarType: AvatarType(rawValue: item.avatarType) ?? .personal,
                background: item.avatarBackground ?? "background_1",
                avatarBody: item.avatarBody,
                shirt: item.avatarShirt,
                eyes: item.avatarEyes,
                mouth: item.avatarMouth,
                hair: item.avatarHair,
                facialHair: item.avatarFacialHair,
                includeSpacer: false
            )
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 1) {
                Text(item.firstName).font(.headline).fontWeight(.semibold)
            }
        }
        .padding(8)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture { isShowingProfileSheet = true }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(10)
        .opacity(showOverlays ? 1 : 0)
        .animation(.spring(response: 0.25, dampingFraction: 0.55).delay(0.9), value: showOverlays)
        .allowsHitTesting(showOverlays)
    }

    private var actionsOverlay: some View {
        VStack(spacing: 16) {
            medalButton(assetName: "gold_medal", color: Color(red: 0.8, green: 0.65, blue: 0.0), count: $goldCount, isSelected: $goldSelected)
                .opacity(showOverlays ? 1 : 0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55).delay(0.4), value: showOverlays)
                .allowsHitTesting(showOverlays)

            medalButton(assetName: "silver_medal", color: Color.gray, count: $silverCount, isSelected: $silverSelected)
                .opacity(showOverlays ? 1 : 0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55).delay(0.55), value: showOverlays)
                .allowsHitTesting(showOverlays)
            
            medalButton(assetName: "bronze_medal", color: Color(red: 0.6, green: 0.35, blue: 0.0), count: $bronzeCount, isSelected: $bronzeSelected)
                .opacity(showOverlays ? 1 : 0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55).delay(0.75), value: showOverlays)
                .allowsHitTesting(showOverlays)
            
            shareButton()
                .opacity(showOverlays ? 1 : 0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55).delay(0.90), value: showOverlays)
                .allowsHitTesting(showOverlays)
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(10)
    }

    private var noPostOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.secondary)
            Button {
                isPresentingCreate = true
            } label: {
                Text("Create Today's Drawing").padding(.horizontal)
            }
            .buttonStyle(.glassProminent)
            .contentShape(Capsule())
            .disabled(hasAttemptedDrawing)

            if hasAttemptedDrawing {
                Text("You chose not to draw today.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .zIndex(1)
    }

    @ViewBuilder
    private func medalButton(assetName: String, color: Color, count: Binding<Int>, isSelected: Binding<Bool>) -> some View {
        Button {
            isSelected.wrappedValue.toggle()
            count.wrappedValue += isSelected.wrappedValue ? 1 : -1
        } label: {
            VStack(spacing: 4) {
                Image(assetName).resizable().scaledToFit().frame(width: 32, height: 32)
                Text("\(count.wrappedValue)")
                    .foregroundColor(.white)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected.wrappedValue ? Color.accentColor : .clear, lineWidth: 2)
            )
        }
        .glassEffect(.clear.tint(color.opacity(0.7)).interactive(), in: RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .frame(minWidth: 48, minHeight: 48)
    }

    private func shareButton() -> some View {
        Button { isSharing = true } label: {
            VStack(spacing: 4) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 24, weight: .medium))
            }
            .padding(8)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .frame(minWidth: 48, minHeight: 48)
    }
}

struct ShareSheetLoaderView: View {
    let item: FeedItem
    let cachedImage: UIImage?

    @State private var image: UIImage? = nil
    @State private var isLoading = true

    var body: some View {
        Group {
            if let cached = cachedImage {
                ShareSheet(activityItems: [ImageActivityItemSource(title: "Check out this drawing from \(item.firstName)!", image: cached)])
            } else if isLoading {
                ProgressView("Preparing share item...")
                    .padding()
                    .task { await loadImage() }
            } else if let image = image {
                ShareSheet(activityItems: [ImageActivityItemSource(title: "Check out this drawing from \(item.firstName)!", image: image)])
            } else {
                Text("Failed to load image.").foregroundColor(.secondary)
            }
        }
    }

    private func loadImage() async {
        guard let url = URL(string: item.imageURL) else { isLoading = false; return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) { image = uiImage }
        } catch { print(error) }
        isLoading = false
    }
}
