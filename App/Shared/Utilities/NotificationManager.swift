import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("⚠️ Notification permission error: \(error)")
            } else {
                print(granted ? "✅ Notifications granted" : "❌ Notifications denied")
            }
        }
    }
    
    
    // MARK: - History
    private func saveNotificationToHistory(title: String, body: String) {
        var history = UserDefaults.standard.array(forKey: "notificationsHistory") as? [[String: String]] ?? []
        
        history.insert([
            "title": title,
            "body": body,
            "time": DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        ], at: 0)
        
        UserDefaults.standard.set(history, forKey: "notificationsHistory")
    }
    
    func getNotificationHistory() -> [[String: String]] {
        return UserDefaults.standard.array(forKey: "notificationsHistory") as? [[String: String]] ?? []
    }
    
    
    // MARK: - Reminder Logic (BEST FIX)
    
    /// Schedule the *next* reminder only
    func scheduleNextReminder() {
        // If already completed today → do not schedule anything
        if UserDefaults.standard.bool(forKey: "hasBrushedToday") {
            clearReminders()
            return
        }
        
        clearReminders() // Only 1 reminder at a time
        
        let content = UNMutableNotificationContent()
        content.title = "🖌️ Daily Brush Reminder"
        content.body = "Don't forget to complete today's bRUSH!"
        content.sound = .default
        
        // Next reminder = now + 2 hours
        let nextDate = Date().addingTimeInterval(30)
        let comps = Calendar.current.dateComponents([.hour, .minute], from: nextDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "NextBrushReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
        print("⏰ Scheduled next reminder at \(comps.hour!):\(String(format: "%02d", comps.minute!))")
    }
    
    
    /// Call this when the user completes their drawing
    func markTodayCompleted() {
        UserDefaults.standard.set(true, forKey: "hasBrushedToday")
        clearReminders()
        clearBadge()
        print("🎨 Today’s brush marked complete. All reminders cancelled.")
    }
    
    /// Call this at midnight to reset streak & start new day
    func resetForNewDay() {
        UserDefaults.standard.set(false, forKey: "hasBrushedToday")
        scheduleNextReminder()
    }
    
    
    // MARK: - Clearing
    
    func clearReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["NextBrushReminder"])
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    
    // MARK: - Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // If already done → suppress notification
        if UserDefaults.standard.bool(forKey: "hasBrushedToday") {
            completionHandler([])
            return
        }
        
        let content = notification.request.content
        saveNotificationToHistory(title: content.title, body: content.body)
        
        // Schedule next reminder when this fires
        scheduleNextReminder()
        
        completionHandler([.banner, .sound])
    }
}
