import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Ask user for notification permission
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("⚠️ Notification permission error: \(error)")
                } else {
                    print(granted ? "✅ Notifications granted" : "❌ Notifications denied")
                }
            }
    }
    
    // Save a notification into history (UserDefaults)
    private func saveNotificationToHistory(title: String, body: String) {
        var history = UserDefaults.standard.array(forKey: "notificationsHistory") as? [[String: String]] ?? []
        
        history.insert([
            "title": title,
            "body": body,
            "time": DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        ], at: 0)
        
        UserDefaults.standard.set(history, forKey: "notificationsHistory")
    }
    
    // Public getter for history
    func getNotificationHistory() -> [[String: String]] {
        return UserDefaults.standard.array(forKey: "notificationsHistory") as? [[String: String]] ?? []
    }
    
    // Schedule reminders every 2 hours until deadline
    func scheduleDailyReminders(hour: Int = 20, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        clearReminders() // Remove old ones first
        
        var startComponents = DateComponents()
        startComponents.hour = hour
        startComponents.minute = minute
        
        guard let startDate = Calendar.current.date(from: startComponents) else { return }
        
        for i in 0..<12 {
            if let notifyDate = Calendar.current.date(byAdding: .hour, value: i * 2, to: startDate) {
                let comps = Calendar.current.dateComponents([.hour, .minute], from: notifyDate)
                
                let content = UNMutableNotificationContent()
                let formattedTime = DateFormatter.localizedString(from: notifyDate, dateStyle: .none, timeStyle: .short)
                content.title = "🖌️ Reminder #\(i + 1)"
                content.body = "It’s now \(formattedTime). Don’t forget to finish today’s bRUSH!"
                content.sound = .default
                content.badge = NSNumber(value: i + 1)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "DailyBrush\(i)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }
        }
    }
    
    // Clear all reminders
    func clearReminders() {
        let identifiers = (0..<12).map { "DailyBrush\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // Reset Daily Brush Cycle
    func resetDailyReminders(hour: Int = 20, minute: Int = 0) {
        clearReminders()
        if let newDeadline = Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: Date().addingTimeInterval(86400)
        ) {
            UserDefaults.standard.set(newDeadline, forKey: "doodleDeadline")
        }
        scheduleDailyReminders(hour: hour, minute: minute)
    }
    
    // Clear app badge
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        clearReminders()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        saveNotificationToHistory(title: content.title, body: content.body)
        completionHandler([.banner, .sound, .badge])
    }
}
