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
    @State private var rippleCounter: Int = 0
    @State private var rippleOrigin: CGPoint = .zero

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
            if let url = URL(string: item.imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: .infinity)
                            .clipped()
                            .modifier(RippleEffect(at: rippleOrigin, trigger: rippleCounter))
                    case .failure:
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }

            // Ripple & overlay handling
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
        .sheet(isPresented: $isSharing) {
            if let url = URL(string: item.imageURL),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                let itemSource = ImageActivityItemSource(
                    title: "Check out this drawing from \(item.firstName)!",
                    image: image
                )
                ShareSheet(activityItems: [itemSource])
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Overlays

    private var userOverlay: some View {
        HStack(spacing: 12) {
            Image(systemName: item.profileSystemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(item.firstName).font(.headline).fontWeight(.semibold)
                Text("@\(item.displayName)")
                    .font(.subheadline)
                    .opacity(0.9)
            }
        }
        .padding(16)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .opacity(showOverlays ? 1 : 0)
        .animation(.spring(response: 0.25, dampingFraction: 0.55).delay(0.9), value: showOverlays)
        .allowsHitTesting(showOverlays)
    }

    private var medalOverlay: some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.bottom, 20)
        .padding(.trailing, 20)
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

    // MARK: - Buttons

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
