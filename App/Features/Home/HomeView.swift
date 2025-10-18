import SwiftUI

struct HomeView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboarding: Bool = false
    
    // Controls dropdown
    @State private var showingNotifications: Bool = false
    
    // View model for feed data and title
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()
    @State private var isOnboardingPresented: Bool = false
    @State private var isPresentingCreate: Bool = false
    
    @AppStorage("hasPostedToday") private var hasPostedToday: Bool = false
    
    @State private var drawingPrompt = "What does your brain look like on a happy day?"
    @EnvironmentObject var dataModel: DataModel

    @AppStorage("displayName") private var storedDisplayName: String?
    @AppStorage("username") private var storedUsername: String?

    var body: some View {
        ZStack {
            // Plain background – no gradients
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack(spacing: 12) {
                    Text(viewModel.appTitle)
                        .font(BrushFont.title(22))
                    
                    Spacer()
                    
                    Button(action: { withAnimation { showingNotifications.toggle() } }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .imageScale(.large)
                                .frame(width: 44, height: 44, alignment: .center)

                            if !NotificationManager.shared.getNotificationHistory().isEmpty {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 7, height: 7)
                                }
                                .frame(width: 10, height: 10)
                                .offset(x: -9, y: 9)
                            }
                        }
                    }
                    .glassEffect(.regular.interactive())
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                Divider()
                
                // Feed – scrollable list of user art posts
                ScrollView {
                    LazyVStack(spacing: 24) {
                        FirstPostCTA(displayName: storedDisplayName ?? "Your Name", handle: (storedUsername?.isEmpty == false ? storedUsername! : "@you")) {
                            isPresentingCreate = true
                        }
                        .padding(.top, 8)

                        if viewModel.feedItems.isEmpty {
                            Text("Your feed will show your drawings here.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        // Feed items without actions bar below each post
                        ForEach(viewModel.feedItems) { item in
                            UserFeedItemView(item: item)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                }
            }
            
            // Notification dropdown aligned under the bell
            if showingNotifications {
                VStack {
                    NotificationsDropdown()
                        .offset(x: -15, y: 80)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        // Tap outside closes dropdown
        .onTapGesture {
            if showingNotifications { withAnimation { showingNotifications = false } }
        }
        .onAppear {
            isOnboardingPresented = !hasCompletedOnboarding || showOnboarding
        }
        .onChange(of: hasCompletedOnboarding) { oldValue, newValue in
            isOnboardingPresented = !newValue || showOnboarding
        }
        .onChange(of: showOnboarding) { oldValue, newValue in
            isOnboardingPresented = !hasCompletedOnboarding || newValue
        }
        .onChange(of: isOnboardingPresented) { oldValue, newValue in
            if !newValue {
                hasCompletedOnboarding = true
                showOnboarding = false
            }
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            WelcomeView()
        }
        .fullScreenCover(isPresented: $isPresentingCreate) {
            NavigationStack {
                DrawingView(onSave: { newItem in
                    dataModel.addItem(newItem)
                    hasPostedToday = true
                }, prompt: drawingPrompt)
            }
        }
    }
}

private struct PostActionsBar: View {
    @State private var voteCount: Int = 3800
    @State private var commentCount: Int = 4100

    var body: some View {
        HStack(spacing: 12) {
            // Vote pill (up/down)
            Button(action: { voteCount += 1 }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up")
                    Text(Formatter.compact.string(for: voteCount) ?? "\(voteCount)")
                    Image(systemName: "arrow.down")
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray5))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            // Comments pill
            Button(action: { /* open comments */ }) {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                    Text(Formatter.compact.string(for: commentCount) ?? "\(commentCount)")
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray5))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            // Badge/medal pill
            Button(action: { /* show awards */ }) {
                HStack(spacing: 6) {
                    Image(systemName: "rosette")
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray5))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            // Share pill
            ShareLink(item: "Check out this drawing from Brush!") {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray5))
                .clipShape(Capsule())
            }
        }
    }
}

private struct FirstPostCTA: View {
    let displayName: String
    let handle: String
    var onCreate: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: avatar + name/handle (crisp)
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(handle.hasPrefix("@") ? handle : "@\(handle)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            // Post card area: background-only watery blur, foreground sharp
            ZStack(alignment: .bottomLeading) {
                let corner: CGFloat = 28
                // Card background with Apple-like glass material strictly confined to the shape
                let cardShape = RoundedRectangle(cornerRadius: corner, style: .continuous)

                cardShape
                    .fill(.clear)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16.0/9.0, contentMode: .fit)
                    // Use a system Material and mask it to the card shape so it never bleeds
                    .background(
                        cardShape
                            .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                            // Cool Notification Center tone, very subtle
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        Color(.sRGB, red: 0.10, green: 0.24, blue: 0.35, opacity: 0.10),
                                        Color(.sRGB, red: 0.05, green: 0.18, blue: 0.30, opacity: 0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            // Slight neutral darkening for depth
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(colorScheme == .dark ? 0.14 : 0.08),
                                        Color.black.opacity(colorScheme == .dark ? 0.10 : 0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .blendMode(.overlay)
                            )
                            // Ensure all of the above is strictly inside the rounded rect
                            .compositingGroup()
                            .mask(cardShape)
                    )
                    // Subtle watery depth kept inside the shape
                    .overlay(
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.06))
                                .frame(width: 300, height: 300)
                                .blur(radius: 28)
                                .offset(x: -60, y: -6)

                            Circle()
                                .fill(Color.black.opacity(0.05))
                                .frame(width: 230, height: 230)
                                .blur(radius: 24)
                                .offset(x: 80, y: 24)

                            Ellipse()
                                .fill(Color.black.opacity(0.045))
                                .frame(width: 360, height: 160)
                                .blur(radius: 26)
                                .offset(y: 56)

                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.05),
                                    Color.white.opacity(0.01)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .opacity(0.5)
                        }
                        .compositingGroup()
                        .mask(cardShape)
                    )
                    // Keep the CTA crisp above the blur
                    .overlay(
                        ZStack {
                            Button(action: onCreate) {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus")
                                    Text("Let’s create your first drawing")
                                }
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(Color(UIColor.systemBackground).opacity(0.92))
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    )
                    // Crisp inner/outer edge definition like iOS glass
                    .overlay(
                        cardShape.strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
                    )

                // Medal buttons – reuse spacing/sizing from feed (crisp)
                HStack(spacing: 14) {
                    medalPill(systemName: "medal.fill", color: .yellow, text: "0")
                    medalPill(systemName: "medal.fill", color: .gray, text: "0")
                    medalPill(systemName: "medal.fill", color: .orange, text: "0")
                }
                .padding(.leading, 12)
                .padding(.bottom, 12)
            }
        }
    }

    @ViewBuilder
    private func medalPill(systemName: String, color: Color, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(UIColor.systemBackground).opacity(0.85))
        )
    }
}

private enum Formatter {
    static let compact: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 1
        f.usesGroupingSeparator = true
        f.locale = .current
        return f
    }()
}

#Preview {
    NavigationStack { HomeView() }
}
