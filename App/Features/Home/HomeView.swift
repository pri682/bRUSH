import SwiftUI

struct HomeView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboarding: Bool = false
    @State private var showingNotifications: Bool = false
    @StateObject private var viewModel = HomeViewModel()
    @State private var isOnboardingPresented: Bool = false
    @State private var isPresentingCreate: Bool = false

    @AppStorage("hasPostedToday") private var hasPostedToday: Bool = false
    @AppStorage("lastPostDateString") private var lastPostDateString: String = ""
    @State private var hasAttemptedDrawing: Bool = false
    @State private var didDismissCreate = false

    @EnvironmentObject var dataModel: DataModel
    @State private var currentFeedIndex: Int = 0

    var body: some View {
        ZStack(alignment: .top) {
            AnimatedMeshGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                GeometryReader { geometry in
                    TabView(selection: $currentFeedIndex) {
                        ForEach(viewModel.feedItems.indices, id: \.self) { index in
                            let item = viewModel.feedItems[index]

                            UserFeedItemView(
                                item: item,
                                prompt: viewModel.dailyPrompt,
                                hasPostedToday: $hasPostedToday,
                                hasAttemptedDrawing: $hasAttemptedDrawing,
                                isPresentingCreate: $isPresentingCreate
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 3)
                            .tag(index)
                            .rotationEffect(.degrees(-90))
                            .contentShape(Rectangle())
                        }
                    }
                    .frame(width: geometry.size.height, height: geometry.size.width)
                    .rotationEffect(.degrees(90), anchor: .topLeading)
                    .offset(x: geometry.size.width)
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    if !viewModel.feedItems.isEmpty {
                        let itemCount = viewModel.feedItems.count
                        let feedItemTopPadding: CGFloat = 12 + 70
                        let feedItemBottomPadding: CGFloat = 12
                        let availableHeight = geometry.size.height - feedItemTopPadding - feedItemBottomPadding
                        let spacing: CGFloat = 8
                        let totalSpacing = CGFloat(max(0, itemCount - 1)) * spacing
                        let capsuleHeight = max(1, (availableHeight - totalSpacing) / CGFloat(itemCount))

                        HStack {
                            Spacer()
                                .allowsHitTesting(false)

                            VStack {
                                ScrollViewReader { proxy in
                                    ScrollView(.vertical) {
                                        VStack(spacing: spacing) {
                                            ForEach(viewModel.feedItems.indices, id: \.self) { index in
                                                Button(action: {
                                                    withAnimation(.spring()) {
                                                        currentFeedIndex = index
                                                    }
                                                }) {
                                                    Capsule()
                                                        .fill(currentFeedIndex == index ? Color.red : Color.orange)
                                                        .frame(width: 6, height: capsuleHeight)
                                                        .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 1)
                                                        .shadow(color: Color.white.opacity(0.15), radius: 1, x: 0, y: -1)
                                                }
                                                .id(index)
                                            }
                                        }
                                    }
                                    .offset(x: 2)
                                    .scrollIndicators(.hidden)
                                    .onChange(of: currentFeedIndex) {
                                        withAnimation {
                                            proxy.scrollTo(currentFeedIndex, anchor: .center)
                                        }
                                    }
                                    .onAppear {
                                        proxy.scrollTo(currentFeedIndex, anchor: .center)
                                    }
                                }
                            }
                            .frame(maxHeight: .infinity)
                        }
                        .padding(.top, feedItemTopPadding)
                        .padding(.bottom, feedItemBottomPadding)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .zIndex(1)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)

            if showingNotifications {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showingNotifications = false
                        }
                    }
                    .zIndex(4)
            }

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image("brush_logo_1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)

                    Spacer()

                    Button(action: { withAnimation { showingNotifications.toggle() } }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .imageScale(.large)
                                .frame(width: 44, height: 44, alignment: .center)

                            if !NotificationManager.shared.getNotificationHistory().isEmpty {
                                ZStack {
                                    Circle().fill(Color.white)
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 7, height: 7)
                                }
                                .frame(width: 10, height: 10)
                                .offset(x: -9, y: 9)
                            }
                        }
                        .glassEffect(.regular.interactive())
                    }
                }
                .padding(.horizontal)
                .padding(.top, safeAreaInsetsTop())
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.85), location: 0),
                            .init(color: Color.white.opacity(0.0), location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .background(.ultraThinMaterial)
                )
                .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .top)
            .zIndex(3)

            if showingNotifications {
                VStack {
                    NotificationsDropdown()
                        .offset(x: 0, y: 80)
                        .transition(.move(edge: .top).combined(with: .opacity))

                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(.trailing)
                .zIndex(5)
            }

            if viewModel.isLoadingFeed {
                VStack {
                    ProgressView()
                        .padding()
                    Text("Loading Feed...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
                .zIndex(1)
            } else if viewModel.feedItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "scribble.variable")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text("Be the first one to draw today!")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Button {
                        isPresentingCreate = true
                    } label: {
                        Text("Draw Now")
                            .padding(.horizontal)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(hasAttemptedDrawing)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AnimatedMeshGradientBackground().ignoresSafeArea())
                .zIndex(1)
            }
        }
        .onAppear {
            checkDailyPostStatus()
            isOnboardingPresented = !hasCompletedOnboarding || showOnboarding
        }
        .onChange(of: hasCompletedOnboarding) {
            isOnboardingPresented = !hasCompletedOnboarding || showOnboarding
        }
        .onChange(of: showOnboarding) {
            isOnboardingPresented = !hasCompletedOnboarding || showOnboarding
        }
        .onChange(of: isOnboardingPresented) {
            if !isOnboardingPresented {
                hasCompletedOnboarding = true
                showOnboarding = false
            }
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            WelcomeView()
        }
        .fullScreenCover(isPresented: $isPresentingCreate, onDismiss: {
             didDismissCreate = true
        }) {
            NavigationStack {
                DrawingView(onSave: { newItem in
                    dataModel.addItem(newItem)
                    hasPostedToday = true

                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    formatter.timeZone = TimeZone(identifier: "America/Chicago")
                    lastPostDateString = formatter.string(from: Date())
                }, prompt: viewModel.dailyPrompt)
            }
        }
        .onChange(of: didDismissCreate) {
             if didDismissCreate {
                 if !hasPostedToday {
                     hasAttemptedDrawing = true
                 }
                 didDismissCreate = false
             }
        }
        .task {
            await viewModel.loadDailyPrompt()
            await viewModel.loadFeed()
        }
        .refreshable {
            await viewModel.loadFeed()
        }
    }

    private func safeAreaInsetsTop() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
        return keyWindow?.safeAreaInsets.top ?? 0
    }

    private func checkDailyPostStatus() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "America/Chicago")
        let todayString = formatter.string(from: Date())

        if lastPostDateString != todayString {
            hasPostedToday = false
            hasAttemptedDrawing = false
        }
    }
}
