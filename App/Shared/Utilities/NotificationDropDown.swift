import SwiftUI

struct NotificationsDropdown: View {
    @State private var notifications: [[String: String]] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Notifications")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if !notifications.isEmpty {
                    Button(action: {
                        withAnimation {
                            clearAllNotifications()
                        }
                    }) {
                        Text("Clear All")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color.red.opacity(0.1))
                }
            }
            .padding()
            .background(Color.accentColor.opacity(0.15))
            
            Divider()
            
            if notifications.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bell.slash")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No notifications yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(notifications.indices, id: \.self) { index in
                            let note = notifications[index]
                            
                            HStack(alignment: .top, spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.1))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color.accentColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note["title"] ?? "Notification")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    
                                    if let body = note["body"], !body.isEmpty {
                                        Text(body)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    if let time = note["time"] {
                                        Text(time)
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                            .padding(.top, 2)
                                    }
                                }
                                
                                Spacer(minLength: 8)
                                
                                Button(action: {
                                    withAnimation {
                                        removeNotification(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.glass)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            if index < notifications.count - 1 {
                                Divider()
                                    .padding(.leading, 68)
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
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
        .frame(width: 340)
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
