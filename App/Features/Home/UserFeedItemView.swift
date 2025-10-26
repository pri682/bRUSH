import SwiftUI

struct UserFeedItemView: View {
    let item: FeedItem
    let prompt: String

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
<<<<<<< Updated upstream
    @State private var sharedImage: UIImage?

    init(item: FeedItem) {
        self.item = item
        _goldCount = State(initialValue: item.medalGold)
        _silverCount = State(initialValue: item.medalSilver)
        _bronzeCount = State(initialValue: item.medalBronze)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Header
            HStack(spacing: 12) {
                Image(systemName: item.profileSystemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(item.username)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
=======
    @State private var rippleCounter: Int = 0
    @State private var rippleOrigin: CGPoint = .zero

    private var resolvedImage: UIImage? {
        if let name = item.artImageName, let img = UIImage(named: name) {
            return img
        }
        if let symbol = item.artSystemImageName, let img = UIImage(systemName: symbol) {
            return img
        }
        print("UserFeedItemView: Could not resolve image for item \(item.id)")
        return nil
    }

    init(
        item: FeedItem,
        prompt: String,
        hasPostedToday: Binding<Bool>,
        hasAttemptedDrawing: Binding<Bool>,
        isPresentingCreate: Binding<Bool>
    ) {
        self.item = item
        self.prompt = prompt
        _goldCount = State(initialValue: item.medalGold)
        _silverCount = State(initialValue: item.medalSilver)
        _bronzeCount = State(initialValue: item.medalBronze)
        self._hasPostedToday = hasPostedToday
        self._hasAttemptedDrawing = hasAttemptedDrawing
        self._isPresentingCreate = isPresentingCreate
    }

    var body: some View {
        ZStack {
            Group {
                if let resolved = resolvedImage {
                    Image(uiImage: resolved)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: .infinity)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(.secondarySystemBackground))
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
>>>>>>> Stashed changes
                }
            }
            .modifier(RippleEffect(origin: rippleOrigin, trigger: rippleCounter, speed: 300))

<<<<<<< Updated upstream
            // MARK: - Artwork + Medal actions
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        AsyncImage(url: URL(string: item.imageURL)) { phase in
                            switch phase {
                            case .empty:
                                ZStack {
                                    Rectangle().fill(Color(UIColor.secondarySystemBackground))
                                    ProgressView()
                                }
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .onAppear {
                                        // Convert to UIImage for sharing later
                                        let renderer = ImageRenderer(content: image)
                                        if let uiImage = renderer.uiImage {
                                            sharedImage = uiImage
                                        }
                                    }
                            case .failure:
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .padding(48)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .clipped()
                    )

                // Medal + Share buttons
                HStack(spacing: 14) {
                    medalButton(systemName: "medal.fill", color: .yellow, count: $goldCount, isSelected: $goldSelected)
                    medalButton(systemName: "medal.fill", color: .gray, count: $silverCount, isSelected: $silverSelected)
                    medalButton(systemName: "medal.fill", color: .orange, count: $bronzeCount, isSelected: $bronzeSelected)
                    Spacer()
                    shareButton()
                        .disabled(sharedImage == nil)
                        .opacity(sharedImage == nil ? 0.4 : 1.0)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
=======
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            guard hasPostedToday else { return }
                            rippleOrigin = value.location
                            rippleCounter += 1

                            withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
                                showOverlays.toggle()
                            }
                        }
                )

            VStack {
                Text(prompt)
                    .font(.system(size: 16, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .glassEffect(.regular.interactive())
                    .opacity(hasPostedToday ? (showOverlays ? 1 : 0) : 0)
                    .scaleEffect(showOverlays ? 1 : 0.95)
                    .animation(.spring(response: 0.25, dampingFraction: 0.55).delay(0.8), value: showOverlays) // Added delay
                    .padding(.top, 10)
                Spacer()
            }
            .padding(.horizontal)
            .allowsHitTesting(false)

            if hasPostedToday {
                userOverlay
                medalOverlay
            } else {
                noPostOverlay
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 3)
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .padding(.top, 70)
>>>>>>> Stashed changes
        .sheet(isPresented: $isSharing) {
            if let image = sharedImage {
                let itemSource = ImageActivityItemSource(
                    title: "Check out this drawing from \(item.displayName)!",
                    image: image
                )
                ShareSheet(activityItems: [itemSource])
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private var userOverlay: some View {
        HStack(spacing: 12) {
            Image(systemName: item.profileSystemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName).font(.headline).fontWeight(.semibold)
                Text(item.username).font(.subheadline).opacity(0.9)
            }
        }
        .padding(16)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .opacity(showOverlays ? 1 : 0)
        .animation(.spring(response: 0.25, dampingFraction: 0.55).delay(0.7), value: showOverlays) // Added delay
        .allowsHitTesting(showOverlays)
    }

    private var medalOverlay: some View {
        VStack(spacing: 16) {
            medalButton(
                assetName: "gold_medal",
                color: Color(red: 0.8, green: 0.65, blue: 0.0),
                count: $goldCount,
                isSelected: $goldSelected
            )
            medalButton(
                assetName: "silver_medal",
                color: Color.gray,
                count: $silverCount,
                isSelected: $silverSelected
            )
            medalButton(
                assetName: "bronze_medal",
                color: Color(red: 0.6, green: 0.35, blue: 0.0),
                count: $bronzeCount,
                isSelected: $bronzeSelected
            )
            shareButton()
                .disabled(resolvedImage == nil)
                .opacity(resolvedImage == nil ? 0.4 : 1.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.bottom, 20)
        .padding(.trailing, 20)
        .opacity(showOverlays ? 1 : 0)
        .animation(.spring(response: 0.25, dampingFraction: 0.55).delay(0.4), value: showOverlays) // Added delay
        .allowsHitTesting(showOverlays)
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
            .buttonStyle(.borderedProminent)
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
        .glassEffect(.regular.tint(color).interactive(), in: RoundedRectangle(cornerRadius: 12))
        .frame(minWidth: 48, minHeight: 48)
    }

    private func shareButton() -> some View {
        Button { isSharing = true } label: {
            VStack(spacing: 4) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 24, weight: .medium))
                Text("Share")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(8)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
        .frame(minWidth: 48, minHeight: 48)
    }
}
