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
    // Stop all reminders (called when doodle is completed)
    func clearReminders() {
        let identifiers = (0..<12).map { "DailyBrush\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
