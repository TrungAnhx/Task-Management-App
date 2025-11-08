//
//  Date+Extensions.swift
//  Task Management
//
//  Created by TrungAnhx on 8/11/25.
//

import SwiftUI

extension Date {
    // Get the current week dates
    static var currentWeek: [Day] {
        let calendar = Calendar.current
        guard let firstWeekDay = calendar.dateInterval(of: .weekOfMonth, for: .now)?.start else {
            return []
        }
        
        var week: [Day] = []
        for index in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: index, to: firstWeekDay) {
                week.append(.init(date: day))
            }
        }
        return week
    }
    
    // Convert date to String in the given format
    func string(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    // Check if both the dates are same
    func isSame(_ date: Date?) -> Bool {
        guard let date else { return false }
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    struct Day: Identifiable {
        var id: String = UUID().uuidString
        var date: Date
    }
}
