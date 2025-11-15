import SwiftUI
import Combine

@MainActor
final class DynamicTasksViewModel: ObservableObject {
    private let taskManager = TaskManager()
    @Published var tasks: [TaskEntity] = []

    // Fetch tất cả task trong tuần chứa 'referenceDate'
    func fetchWeek(of referenceDate: Date?) {
        tasks = taskManager.fetchWeek(of: referenceDate)
    }

    func addTask(on date: Date) {
        taskManager.addTask(on: date)
        fetchWeek(of: nil) // Refresh the tasks list
    }
    
    func updateTask(_ task: TaskEntity) {
        taskManager.updateTask(task)
        fetchWeek(of: nil) // Refresh the tasks list
    }
    
    func deleteTask(_ task: TaskEntity) {
        taskManager.deleteTask(task)
        fetchWeek(of: nil) // Refresh the tasks list
    }
}
