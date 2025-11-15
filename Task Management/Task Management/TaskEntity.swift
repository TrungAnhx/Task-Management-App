//
//  TaskEntity.swift
//  Task Management
//
//  Created by TrungAnhx on 8/11/25.
//

import Foundation

struct TaskEntity: Identifiable, Codable {
    let id: UUID
    var date: Date?
    var endTime: Date?
    var isDone: Bool
    var location: String?
    var note: String?
    var startTime: Date?
    var title: String?
    
    init(id: UUID = UUID(), title: String = "New Task", date: Date? = nil, startTime: Date? = nil, endTime: Date? = nil, isDone: Bool = false, location: String? = nil, note: String? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.isDone = isDone
        self.location = location
        self.note = note
    }
}
