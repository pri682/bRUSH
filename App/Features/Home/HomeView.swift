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
    @State private var isPromptExpanded: Bool = false
    @EnvironmentObject var dataModel: DataModel

    @AppStorage("displayName") private var storedDisplayName: String?
    @AppStorage("username") private var storedUsername: String?

    // Utility: the current user's handle as used in FeedItem.username
    private var currentHandle: String {
        (storedUsername?.isEmpty == false ? storedUsername! : "@you")
    }

    // Display name to show in the UI: prefer stored display name, otherwise derive
    // from the stored username (strip leading '@'), otherwise fall back to 'You'.
    private var displayNameForUI: String {
        if let name = storedDisplayName, !name.isEmpty { return name }
        if let uname = storedUsername, !uname.isEmpty {
            return uname.hasPrefix("@") ? String(uname.dropFirst()) : uname
        }
        return "You"
    }

    // Whether a post by the current user exists in the feed. We use this to
    // decide whether to keep showing the blurred CTA or swap to the prompt chip.
    private var hasUserPostInFeed: Bool {
        viewModel.feedItems.contains { $0.username == currentHandle }
    }

    // Prompt should be visible only after the user has an actual post in the feed.
    private var showPrompt: Bool { hasUserPostInFeed }

    var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 0) {
                topBar
                Divider()
                if showPrompt { promptSection }
                feedSection
            }
            if showingNotifications { notificationsOverlay }
        }
        .onTapGesture { if showingNotifications { withAnimation { showingNotifications = false } } }
        .onAppear { handleOnAppear() }
        .onChange(of: hasCompletedOnboarding) { oldValue, newValue in isOnboardingPresented = !newValue || showOnboarding }
        .onChange(of: showOnboarding) { oldValue, newValue in isOnboardingPresented = !hasCompletedOnboarding || newValue }
        .onChange(of: isOnboardingPresented) { oldValue, newValue in if !newValue { hasCompletedOnboarding = true; showOnboarding = false } }
        .fullScreenCover(isPresented: $isOnboardingPresented) { WelcomeView() }
        .fullScreenCover(isPresented: $isPresentingCreate) {
            NavigationStack {
                DrawingView(onSave: { newItem in
                    dataModel.addItem(newItem)
                }, prompt: drawingPrompt)
            }
        }
    }

    private var backgroundView: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
    }

    private var topBar: some View {
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
                            Circle().fill(Color.white)
                            Circle().fill(Color.red).frame(width: 7, height: 7)
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
    }

    private var promptSection: some View {
        PromptChip(drawingPrompt: $drawingPrompt, isPromptExpanded: $isPromptExpanded)
            .padding(.vertical, 12)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var feedSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                if !hasUserPostInFeed {
                    FirstPostCTA(onCreate: { isPresentingCreate = true })
                        .padding(.top, 8)
                }
                if viewModel.feedItems.isEmpty {
                    Text("Your feed will show your drawings here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                ForEach(Array(viewModel.feedItems.enumerated()), id: \.offset) { index, item in
                    let belongsToCurrentUser = (item.username == currentHandle)
                    UserFeedItemView(item: item)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
    }

    private var notificationsOverlay: some View {
        VStack {
            NotificationsDropdown()
                .offset(x: -15, y: 80)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }

    private func handleOnAppear() {
        isOnboardingPresented = !hasCompletedOnboarding || showOnboarding
        if PostState.hasPostedToday { hasPostedToday = true } else { hasPostedToday = false }
        NotificationCenter.default.addObserver(forName: .didAddItem, object: nil, queue: .main) { note in
            if let newItem = note.object as? Item {
                let feedItem = mapItemToFeedItem(newItem)
                viewModel.feedItems.insert(feedItem, at: 0)
                PostState.markPostedToday()
                hasPostedToday = true
            }
        }
    }
}

private struct PromptChip: View {
    @Binding var drawingPrompt: String
    @Binding var isPromptExpanded: Bool

    var body: some View {
        HStack {
            Spacer()
            Button(action: { withAnimation(.spring()) { isPromptExpanded.toggle() } }) {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Color.yellow)
                        .font(.system(size: 18))
                        .padding(.leading, 6)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Prompt:")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text(drawingPrompt)
                            .font(.subheadline)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                    .padding(.trailing, 12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isPromptExpanded) {
                VStack(spacing: 12) {
                    Text("Prompt:")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(drawingPrompt)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Close") { isPromptExpanded = false }
                        .padding(.top, 8)
                }
                .padding(20)
            }
            Spacer()
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

    private var cardCorner: CGFloat { 28 }
    private var cardShape: RoundedRectangle { RoundedRectangle(cornerRadius: cardCorner, style: .continuous) }

    @ViewBuilder
    private var cardMaterialBackground: some View {
        cardShape
            .fill(Color.clear)
            .background(
                cardShape
                    .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
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
                    .compositingGroup()
                    .mask(cardShape)
            )
    }

    @ViewBuilder
    private var ctaButton: some View {
        Button(action: onCreate) {
            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
                Text("Let’s create your first drawing")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .allowsTightening(false)
                    .kerning(0.2)
                    .minimumScaleFactor(0.98)
                    .baselineOffset(0)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header OUTSIDE the post, aligned like other feed items
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 0) {
                    Text("You").font(.headline).fontWeight(.semibold)
                    Text("@you").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            // Blurred post card
            ZStack {
                cardMaterialBackground
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16.0/9.0, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                    .overlay(
                        GeometryReader { geo in
                            HStack {
                                Spacer()
                                ctaButton
                                    .frame(maxWidth: min(geo.size.width * 0.76, 560))
                                Spacer()
                            }
                            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                        }
                    )
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

private extension HomeView {
    func mapItemToFeedItem(_ newItem: Item) -> FeedItem {
        // Derive user identity
        let displayName = storedDisplayName ?? "You"
        let username = (storedUsername?.isEmpty == false ? storedUsername! : "@you")

        // Art representations
        let profileSystemImageName = "person.circle.fill"
        let artSystemImageName = "photo.on.rectangle.angled"
        let artImageName: String? = nil

        // Default engagement/awards
        let medalGold = 0
        let medalSilver = 0
        let medalBronze = 0
        let upVotes = 0
        let downVotes = 0
        let comments = 0

        return FeedItem(
            displayName: displayName,
            username: username,
            profileSystemImageName: profileSystemImageName,
            artSystemImageName: artSystemImageName,
            artImageName: artImageName,
            artImageURL: newItem.url,
            medalGold: medalGold,
            medalSilver: medalSilver,
            medalBronze: medalBronze,
            upVotes: upVotes,
            downVotes: downVotes,
            comments: comments,
            awards: 0
        )
    }
}

#Preview {
    NavigationStack { HomeView() }
}
