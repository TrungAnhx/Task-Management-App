//
//  TaskEntity.swift
//  Task Management
//
//  Created by TrungAnhx on 8/11/25.
//

import Foundation
import SwiftUI

struct TaskEntity: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date?
    var endTime: Date?
    var isDone: Bool
    var location: String?
    var note: String?
    var startTime: Date?
    var title: String?
    var priority: PriorityLevel = .medium
    var colorHex: String = "#4F8EF7"
    
    init(id: UUID = UUID(), title: String = "New Task", date: Date? = nil, startTime: Date? = nil, endTime: Date? = nil, isDone: Bool = false, location: String? = nil, note: String? = nil, priority: PriorityLevel = .medium, colorHex: String = "#4F8EF7") {
        self.id = id
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.isDone = isDone
        self.location = location
        self.note = note
        self.priority = priority
        self.colorHex = colorHex
    }
    
    static func == (lhs: TaskEntity, rhs: TaskEntity) -> Bool {
        return lhs.id == rhs.id
    }
}

enum PriorityLevel: Int, CaseIterable, Identifiable, Codable {
    case low = 0, medium = 1, high = 2
    var id: Int { rawValue }
    var title: String {
        switch self { case .low: return "Low"; case .medium: return "Medium"; case .high: return "High" }
    }
    var tint: Color {
        switch self { case .low: return .green; case .medium: return .orange; case .high: return .red }
    }
}
