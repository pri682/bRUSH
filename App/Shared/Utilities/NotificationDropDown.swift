import SwiftUI

struct NotificationsDropdown: View {
    @State private var notifications: [[String: String]] =
        NotificationManager.shared.getNotificationHistory()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
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
            .padding()
            .background(Color(.systemGray6))
            
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
                                    .foregroundColor(.pink)
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
                                
                                // ❌ Delete button
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
        .frame(width: 320) // wider panel
        .background(.ultraThinMaterial)
        .cornerRadius(14)
        .shadow(radius: 6)
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
