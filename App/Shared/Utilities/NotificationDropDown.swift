import SwiftUI

struct NotificationsDropdown: View {
    @State private var notifications: [[String: String]] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                UnevenRoundedRectangle(
                        topLeadingRadius: 14,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 14,
                    )
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(height: 50)
                    .ignoresSafeArea(edges: .horizontal)
                
                HStack {
                    Text("Notifications")
                        .font(.headline)
                    Spacer()
                    Button("Clear All") {
                        clearAllNotifications()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            if notifications.isEmpty {
                Text("No notifications yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(notifications.indices, id: \.self) { index in
                            let note = notifications[index]
                            
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "bell.fill")
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note["title"] ?? "Notification")
                                        .font(.subheadline).bold()
                                    Text(note["body"] ?? "")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    Text(note["time"] ?? "")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                Button(action: {
                                    removeNotification(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            
                            Divider()
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let history = NotificationManager.shared.getNotificationHistory()
                DispatchQueue.main.async {
                    self.notifications = history
                }
            }
        }
        .frame(width: 320)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
    }
    
    // MARK: - Delete helpers
    private func removeNotification(at index: Int) {
        notifications.remove(at: index)
        UserDefaults.standard.set(notifications, forKey: "notificationsHistory")
    }
    
    private func clearAllNotifications() {
        notifications.removeAll()
        UserDefaults.standard.set([], forKey: "notificationsHistory")
    }
}
