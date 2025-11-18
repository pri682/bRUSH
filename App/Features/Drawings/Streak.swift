//
//  Streak.swift
//  brush
//
//  Created by Vaidic Soni on 9/29/25.
//

import Foundation

struct StreakManager {
    private let currentKey = "currentStreak"
    private let longestKey = "longestStreak"
    private let lastCompletedKey = "lastCompletedDate"
    
    var currentStreak: Int {
        UserDefaults.standard.integer(forKey: currentKey)
    }
    
    var longestStreak: Int {
        UserDefaults.standard.integer(forKey: longestKey)
    }
    
    mutating func markCompletedToday() {
        let today = Calendar.current.startOfDay(for: Date())
        let last = UserDefaults.standard.object(forKey: lastCompletedKey) as? Date
        let current = UserDefaults.standard.integer(forKey: currentKey)
        let longest = UserDefaults.standard.integer(forKey: longestKey)
        
        var newStreak = 1  // Default if first day or missed day
        
        if let lastDate = last {
            
            if Calendar.current.isDate(lastDate, inSameDayAs: today) {
                // Already completed today → streak stays the same
                newStreak = current
                
            } else if Calendar.current.isDateInYesterday(lastDate) {
                // Completed yesterday → continue streak
                newStreak = current + 1
            }
            
        } else {
            // First completion ever
            newStreak = 1
        }
        
        // Save final streak values
        UserDefaults.standard.set(newStreak, forKey: currentKey)
        UserDefaults.standard.set(today, forKey: lastCompletedKey)
        
        // Update longest streak if needed
        if newStreak > longest {
            UserDefaults.standard.set(newStreak, forKey: longestKey)
        }
    }
}
