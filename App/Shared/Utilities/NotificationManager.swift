import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    // Ask user for notification permission
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error = error {
                    print("⚠️ Notification permission error: \(error)")
                } else {
                    print(granted ? "✅ Notifications granted" : "❌ Notifications denied")
                }
            }
    }
    
    // Schedule reminders every 2 hours until deadline
    func scheduleDailyReminders(hour: Int = 20, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        clearReminders() // Remove old ones first
        
        // Base start time (e.g. 8 PM)
        var startComponents = DateComponents()
        startComponents.hour = hour
        startComponents.minute = minute
        
        guard let startDate = Calendar.current.date(from: startComponents) else { return }
        
        // Schedule every 2 hours for 24h (12 reminders)
        for i in 0..<12 {
            if let notifyDate = Calendar.current.date(byAdding: .hour, value: i * 2, to: startDate) {
                let comps = Calendar.current.dateComponents([.hour, .minute], from: notifyDate)
                
                let content = UNMutableNotificationContent()
                content.title = "🖌️ Time to bRUSH!"
                content.body = "You still have time, but don’t forget to finish today’s bRUSH."
                content.sound = .default
                content.badge = NSNumber(value: i + 1)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "DailyBrush\(i)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }
        }
    }
    
    // Stop all reminders (called when doodle is completed)
    func clearReminders() {
        let identifiers = (0..<12).map { "DailyBrush\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
