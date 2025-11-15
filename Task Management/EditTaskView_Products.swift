import SwiftUI

struct EditTaskView_Products: View {
    @Environment(\.dismiss) private var dismiss

    @State private var task: TaskEntity

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var date: Date = .now
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var location: String = ""
    @State private var isDone: Bool = false

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
                    DatePicker("Start", selection: Binding(unwrapping: $startTime, default: date), displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: Binding(unwrapping: $endTime, default: date), displayedComponents: .hourAndMinute)
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
        startTime = task.startTime
        endTime = task.endTime
        location = task.location ?? ""
        isDone = task.isDone
    }

    private func saveAndDismiss() {
        var updatedTask = task
        updatedTask.title = title
        updatedTask.note = note.isEmpty ? nil : note
        updatedTask.date = Calendar.current.startOfDay(for: date)
        updatedTask.startTime = startTime
        updatedTask.endTime = endTime
        updatedTask.location = location.isEmpty ? nil : location
        updatedTask.isDone = isDone
        
        task = updatedTask
        onSave?(updatedTask)
        dismiss()
    }
}

private extension Binding where Value == Date {
    // Wrap a Binding<Date?> as a non-optional Binding<Date> with a default for reads,
    // and write back to the optional on changes.
    init(unwrapping source: Binding<Date?>, default defaultDate: Date) {
        self.init(
            get: { source.wrappedValue ?? defaultDate },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}
