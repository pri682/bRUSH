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
        center.removePendingNotificationRequests(withIdentifiers: ["DailyBrushStart", "DailyBrushHalf"])
        
        // --- First reminder (start of the 24h window) ---
        let startContent = UNMutableNotificationContent()
        startContent.title = "🖌️ Daily Brush Reminder"
        startContent.body = "You have 24 hours to complete today’s brush!"
        startContent.sound = .default
        startContent.badge = NSNumber(value: 1)
        
        var startComponents = DateComponents()
        startComponents.hour = hour
        startComponents.minute = minute
        
        let startTrigger = UNCalendarNotificationTrigger(dateMatching: startComponents, repeats: true)
        let startRequest = UNNotificationRequest(identifier: "DailyBrushStart", content: startContent, trigger: startTrigger)
        center.add(startRequest)
        
        // --- Second reminder (12h before deadline) ---
        let halfContent = UNMutableNotificationContent()
        halfContent.title = "⏳ 12 Hours Left!"
        halfContent.body = "Only 12 hours remain to finish today’s brush. Don’t miss your streak!"
        halfContent.sound = .default
        halfContent.badge = NSNumber(value: 1)
        
        if let startDate = Calendar.current.date(from: startComponents),
           let halfDate = Calendar.current.date(byAdding: .hour, value: 12, to: startDate) {
            
            let halfComponents = Calendar.current.dateComponents([.hour, .minute], from: halfDate)
            let halfTrigger = UNCalendarNotificationTrigger(dateMatching: halfComponents, repeats: true)
            let halfRequest = UNNotificationRequest(identifier: "DailyBrushHalf", content: halfContent, trigger: halfTrigger)
            center.add(halfRequest)
        }
    }
    
    // Clear all reminders
    func clearReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["DailyBrushStart", "DailyBrushHalf"]
        )
    }
    
    // Reset Daily Brush Cycle
    func resetDailyReminders(hour: Int = 20, minute: Int = 0) {
        // stop reminders for today
        clearReminders()
        
        // save deadline for tomorrow (optional, if you want to track it)
        if let newDeadline = Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: Date().addingTimeInterval(86400)
        ) {
            UserDefaults.standard.set(newDeadline, forKey: "doodleDeadline")
        }
        
        // Reschedule both reminders (24h + 12h)
        scheduleDailyReminders(hour: hour, minute: minute)
    }
    
    // Clear app badge + remove today's reminders
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["DailyBrushStart", "DailyBrushHalf"])
    }
    
    // Debug: schedule a test notification in 30 seconds
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🔔 Test Notification"
        content.body = "This is a test notification firing in 30 seconds."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(identifier: "TestBrush", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("✅ Scheduled test notification in 30 seconds")
    }
}

