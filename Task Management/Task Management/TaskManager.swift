//
//  TaskManager.swift
//  Task Management
//
//  Created by TrungAnhx on 8/11/25.
//

import Foundation
import Combine

class TaskManager: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    
    private let tasksKey = "SavedTasks"
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey) {
            if let decodedTasks = try? JSONDecoder().decode([TaskEntity].self, from: data) {
                self.tasks = decodedTasks
                return
            }
        }
        
        // Add sample tasks for first time users
        let today = Calendar.current.startOfDay(for: Date())
        let sampleTasks = [
            TaskEntity(
                title: "Morning Meeting",
                date: today,
                startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: today),
                endTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: today),
                isDone: false,
                location: "Office",
                note: nil,
                priority: .high,
                colorHex: "#4F8EF7"
            ),
            TaskEntity(
                title: "Lunch with Team",
                date: today,
                startTime: Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: today),
                endTime: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: today),
                isDone: false,
                location: "Restaurant",
                note: nil,
                priority: .medium,
                colorHex: "#34C759"
            )
        ]
        tasks = sampleTasks
        saveTasks()
    }
    
    func saveTasks() {
        if let encodedData = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encodedData, forKey: tasksKey)
        }
    }
    
    func addTask(on date: Date) {
        let newTask = TaskEntity(
            title: "New Task",
            date: Calendar.current.startOfDay(for: date),
            startTime: nil,
            endTime: nil,
            isDone: false,
            location: nil,
            note: nil,
            priority: .medium,
            colorHex: "#4F8EF7"
        )
        
        tasks.append(newTask)
        saveTasks()
    }
    
    func updateTask(_ task: TaskEntity) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: TaskEntity) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func fetchWeek(of referenceDate: Date?) -> [TaskEntity] {
        let ref = referenceDate ?? Date()
        let cal = Calendar.current
        
        // Lấy đầu tuần và cuối tuần
        let weekInterval = cal.dateInterval(of: .weekOfMonth, for: ref) ?? DateInterval(start: cal.startOfDay(for: ref), duration: 7 * 24 * 3600)
        let start = weekInterval.start
        let end = cal.date(byAdding: .day, value: 7, to: start) ?? start.addingTimeInterval(7 * 24 * 3600)
        
        let filteredTasks = tasks.filter { task in
            guard let taskDate = task.date else { return false }
            return taskDate >= start && taskDate < end
        }.sorted { 
            if let date1 = $0.date, let date2 = $1.date {
                if date1 != date2 {
                    return date1 < date2
                }
            }
            
            if let startTime1 = $0.startTime, let startTime2 = $1.startTime {
                return startTime1 < startTime2
            }
            
            return false
        }
        
        
        
        return filteredTasks
    }
    
    func tasks(for date: Date?) -> [TaskEntity] {
        guard let date = date else { return [] }
        let calendar = Calendar.current
        
        return tasks.filter { task in
            guard let taskDate = task.date else { return false }
            return calendar.isDate(taskDate, inSameDayAs: date)
        }.sorted {
            if let startTime1 = $0.startTime, let startTime2 = $1.startTime {
                return startTime1 < startTime2
            }
            return false
        }
    }
}
