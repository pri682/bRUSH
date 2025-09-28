import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    // Ask user for notification permission
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    print("⚠️ Notification permission error: \(error)")
                } else {
                    print(granted ? "✅ Notifications granted" : "❌ Notifications denied")
                }
            }
    }
    
    // Schedule daily reminders: one at start (24h left), one at halfway (12h left)
    func scheduleDailyReminders(hour: Int = 20, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        
        // Remove old requests so they don't pile up
        center.removePendingNotificationRequests(withIdentifiers: ["DailyDoodleStart", "DailyDoodleHalf"])
        
        // --- First reminder (start of the 24h window) ---
        let startContent = UNMutableNotificationContent()
        startContent.title = "✏️ Daily Doodle Reminder"
        startContent.body = "You have 24 hours to complete today’s doodle!"
        startContent.sound = .default
        startContent.badge = NSNumber(value: 1)
        
        var startComponents = DateComponents()
        startComponents.hour = hour
        startComponents.minute = minute
        
        let startTrigger = UNCalendarNotificationTrigger(dateMatching: startComponents, repeats: true)
        let startRequest = UNNotificationRequest(identifier: "DailyDoodleStart", content: startContent, trigger: startTrigger)
        center.add(startRequest)
        
        // --- Second reminder (12h before deadline) ---
        let halfContent = UNMutableNotificationContent()
        halfContent.title = "⏳ 12 Hours Left!"
        halfContent.body = "Only 12 hours remain to finish today’s doodle. Don’t miss your streak!"
        halfContent.sound = .default
        halfContent.badge = NSNumber(value: 1)
        
        if let startDate = Calendar.current.date(from: startComponents),
           let halfDate = Calendar.current.date(byAdding: .hour, value: 12, to: startDate) {
            
            let halfComponents = Calendar.current.dateComponents([.hour, .minute], from: halfDate)
            let halfTrigger = UNCalendarNotificationTrigger(dateMatching: halfComponents, repeats: true)
            let halfRequest = UNNotificationRequest(identifier: "DailyDoodleHalf", content: halfContent, trigger: halfTrigger)
            center.add(halfRequest)
        }
    }
    
    // Clear app badge + remove today's reminders
    func clearBadge() {
        // Asynchronously set the badge count to 0
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                // Handle any errors here, e.g., print a warning
                print("Error setting badge count: \(error.localizedDescription)")
            }
        }
        
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["DailyDoodleStart", "DailyDoodleHalf"])
    }
    
    // Debug: schedule a test notification in 30 seconds
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🔔 Test Notification"
        content.body = "This is a test notification firing in 30 seconds."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(identifier: "TestDoodle", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("✅ Scheduled test notification in 30 seconds")
    }
}
