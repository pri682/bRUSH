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
        let lastCompleted = UserDefaults.standard.object(forKey: lastCompletedKey) as? Date
        
        if let last = lastCompleted {
            if Calendar.current.isDateInYesterday(last) {
            
                let newStreak = currentStreak + 1
                UserDefaults.standard.set(newStreak, forKey: currentKey)
                UserDefaults.standard.set(today, forKey: lastCompletedKey)
                
                if newStreak > longestStreak {
                    UserDefaults.standard.set(newStreak, forKey: longestKey)
                }
            } else if !Calendar.current.isDateInToday(last) {
           
                UserDefaults.standard.set(1, forKey: currentKey)
                UserDefaults.standard.set(today, forKey: lastCompletedKey)
            }
        } else {
      
            UserDefaults.standard.set(1, forKey: currentKey)
            UserDefaults.standard.set(today, forKey: lastCompletedKey)
        }
    }
}
