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
                        // Persistent CTA at the top (no gradient)
                        FirstPostCTA {
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
                DrawingView { _, _ in
                    hasPostedToday = true
                }
                .navigationTitle("New Drawing")
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
    var onCreate: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))

            VStack(spacing: 16) {
                Image(systemName: "scribble.variable")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.secondary)

                Button(action: onCreate) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                        Text("Draw your first drawing")
                    }
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.systemGray5))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .aspectRatio(16.0/9.0, contentMode: .fit)
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
