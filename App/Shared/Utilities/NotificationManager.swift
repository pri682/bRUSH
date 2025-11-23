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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
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


    // MARK: - Reminder Logic (EVERY 2 HOURS)
    func scheduleNextReminder() {
        // If drawing is already done today → stop.
        if UserDefaults.standard.bool(forKey: "hasBrushedToday") {
            clearReminders()
            return
        }

        clearReminders()     // Remove old repeating schedules
        clearBadge()         // Reset badge to 0 first

        let content = UNMutableNotificationContent()
        content.title = "🖌️ Time to draw!"
        content.body = "You haven't completed your drawing today."
        content.sound = .default

        // For repeating reminders, ALWAYS use badge = 1
        // iOS will keep badge accurately based on unread notifications.
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: true)

        let request = UNNotificationRequest(
            identifier: "BrushReminder_Every2Hours",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling: \(error)")
            } else {
                print("⏰ Scheduled repeating reminder every 2 hours")
            }
        }
    }


    // MARK: - Completion + Daily Reset
    func markTodayCompleted() {
        UserDefaults.standard.set(true, forKey: "hasBrushedToday")
        clearReminders()
        clearBadge()
        print("🎨 Today's work complete. Notifications cleared.")
    }

    func resetForNewDay() {
        UserDefaults.standard.set(false, forKey: "hasBrushedToday")
        clearBadge()
        scheduleNextReminder()
    }


    // MARK: - Clearing
    func clearReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        clearBadge()
    }

    func clearBadge() {
        if #available(iOS 17.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
        }
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }


    // MARK: - Delegate Handlers
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let content = response.notification.request.content
        saveNotificationToHistory(title: content.title, body: content.body)

        if UserDefaults.standard.bool(forKey: "hasBrushedToday") {
            clearReminders()
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
