import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var task: TaskEntity

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var date: Date = .now
    @State private var startTime: Date = .now
    @State private var endTime: Date = .now
    @State private var location: String = ""
    @State private var isDone: Bool = false
    @State private var hasStartTime: Bool = false
    @State private var hasEndTime: Bool = false

    var onDelete: ((TaskEntity) -> Void)?
    var onSave: ((TaskEntity) -> Void)?

    init(task: TaskEntity, onDelete: ((TaskEntity) -> Void)? = nil, onSave: ((TaskEntity) -> Void)? = nil) {
        self._task = State(initialValue: task)
        self.onDelete = onDelete
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic") {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                    Toggle("Done", isOn: $isDone)
                }

                Section("When") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    Toggle("Has Start Time", isOn: $hasStartTime)
                    if hasStartTime {
                        DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Toggle("Has End Time", isOn: $hasEndTime)
                    if hasEndTime {
                        DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                }

                Section("Notes") {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }

                Section {
                    Button(role: .destructive) {
                        onDelete?(task)
                        dismiss()
                    } label: {
                        Text("Delete Task")
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndDismiss() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear { loadFromTask() }
        }
    }

    private func loadFromTask() {
        title = task.title ?? ""
        note = task.note ?? ""
        date = task.date ?? Calendar.current.startOfDay(for: .now)
        location = task.location ?? ""
        isDone = task.isDone
        
        hasStartTime = task.startTime != nil
        hasEndTime = task.endTime != nil
        
        if let start = task.startTime {
            startTime = start
        }
        if let end = task.endTime {
            endTime = end
        }
    }

    private func saveAndDismiss() {
        var updatedTask = task
        updatedTask.title = title
        updatedTask.note = note.isEmpty ? nil : note
        updatedTask.date = Calendar.current.startOfDay(for: date)
        updatedTask.startTime = hasStartTime ? startTime : nil
        updatedTask.endTime = hasEndTime ? endTime : nil
        updatedTask.location = location.isEmpty ? nil : location
        updatedTask.isDone = isDone
        
        task = updatedTask
        onSave?(updatedTask)
        dismiss()
    }
}
