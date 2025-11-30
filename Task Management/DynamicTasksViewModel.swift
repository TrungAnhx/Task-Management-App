import SwiftUI
import Foundation
import Combine

@MainActor
final class DynamicTasksViewModel: ObservableObject {
    let taskManager = TaskManager()
    
    @Published var tasks: [TaskEntity] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Synchronize with TaskManager's source of truth
        taskManager.$tasks
            .receive(on: DispatchQueue.main)
            .assign(to: \.tasks, on: self)
            .store(in: &cancellables)
    }

    func addTask(on date: Date) {
        taskManager.addTask(on: date)
    }
    
    func updateTask(_ task: TaskEntity) {
        taskManager.updateTask(task)
    }
    
    func deleteTask(_ task: TaskEntity) {
        taskManager.deleteTask(task)
    }
}