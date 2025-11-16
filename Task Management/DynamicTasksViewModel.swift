import SwiftUI
import Foundation
import Combine

@MainActor
final class DynamicTasksViewModel: ObservableObject {
    let taskManager = TaskManager()
    
    init() {
        // Lắng nghe thay đổi từ TaskManager
        taskManager.$tasks
            .receive(on: DispatchQueue.main)
            .assign(to: \.tasks, on: self)
            .store(in: &cancellables)
    }
    
    @Published var tasks: [TaskEntity] = []
    private var cancellables = Set<AnyCancellable>()

    // Fetch tất cả task trong tuần chứa 'referenceDate'
    func fetchWeek(of referenceDate: Date?) {
        let fetchedTasks = taskManager.fetchWeek(of: referenceDate)
        if tasks != fetchedTasks {
            tasks = fetchedTasks
        }
    }

    func addTask(on date: Date) {
        taskManager.addTask(on: date)
        // TaskManager sẽ tự động cập nhật tasks
    }
    
    func updateTask(_ task: TaskEntity) {
        taskManager.updateTask(task)
        // TaskManager sẽ tự động cập nhật tasks
    }
    
    func deleteTask(_ task: TaskEntity) {
        taskManager.deleteTask(task)
        // TaskManager sẽ tự động cập nhật tasks
    }
}
