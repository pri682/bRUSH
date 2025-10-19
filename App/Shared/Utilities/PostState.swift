import Foundation

enum PostState {
    private static let lastPostedKey = "lastPostedDate"

    /// Stores the last posted date as a yyyy-MM-dd string in UserDefaults.
    static var lastPostedDateString: String? {
        get { UserDefaults.standard.string(forKey: lastPostedKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: lastPostedKey) }
    }

    /// Returns true if lastPostedDateString is equal to today's date (in the device calendar's timezone).
    static var hasPostedToday: Bool {
        guard let str = lastPostedDateString else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return str == formatter.string(from: Date())
    }

    /// Marks that the user has posted today by storing today's date string.
    static func markPostedToday() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        lastPostedDateString = formatter.string(from: Date())
    }

    /// Clears the stored last-posted date (useful for testing)
    static func clear() {
        UserDefaults.standard.removeObject(forKey: lastPostedKey)
    }
}

extension Notification.Name {
    static let didAddItem = Notification.Name("didAddItem")
}
