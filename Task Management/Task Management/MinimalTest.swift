import SwiftUI

struct MinimalSwipeTest: View {
    @State private var tasks = [
        TaskEntity(title: "Test Task 1", date: Date(), isDone: false),
        TaskEntity(title: "Test Task 2", date: Date(), isDone: true)
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    VStack {
                        Text(task.title ?? "No Title")
                            .font(.headline)
                        Text(task.isDone ? "Done" : "Not Done")
                            .font(.caption)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            tasks.removeAll { $0.id == task.id }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                tasks[index].isDone.toggle()
                            }
                        } label: {
                            Label(task.isDone ? "Undone" : "Done", systemImage: task.isDone ? "arrow.uturn.backward" : "checkmark")
                        }
                        .tint(task.isDone ? .orange : .green)
                    }
                }
            }
            .navigationTitle("Swipe Test")
        }
    }
}

#Preview {
    MinimalSwipeTest()
}
