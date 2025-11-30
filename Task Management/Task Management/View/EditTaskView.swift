import SwiftUI
import CoreData

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
    @State private var showDeleteConfirmation = false

    // Enhancements: Priority & Color Tag
    @State private var priority: PriorityLevel = .medium
    @State private var selectedColorHex: String = "#4F8EF7" // default blue

    var onDelete: ((TaskEntity) -> Void)?
    var onSave: ((TaskEntity) -> Void)?

    init(task: TaskEntity, onDelete: ((TaskEntity) -> Void)? = nil, onSave: ((TaskEntity) -> Void)? = nil) {
        self._task = State(initialValue: task)
        self.onDelete = onDelete
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Basic Card
                    CardSection(title: "Basic", systemImage: "square.and.pencil") {
                        VStack(spacing: 12) {
                            LabeledRow(icon: "textformat") {
                                TextField("Title", text: $title)
                                    .textInputAutocapitalization(.sentences)
                                    .onChange(of: title) {
                                        if title.count > 80 { title = String(title.prefix(80)) }
                                    }
                            }
                            LabeledRow(icon: "mappin.and.ellipse") {
                                TextField("Location (optional)", text: $location)
                                    .textInputAutocapitalization(.words)
                            }
                            Divider().padding(.horizontal, -4)
                            Toggle(isOn: $isDone) {
                                Label(isDone ? "Done" : "Not Done", systemImage: isDone ? "checkmark.circle.fill" : "circle")
                            }
                            .tint(isDone ? .green : .orange)

                            if isOverdue(date: date, isDone: isDone) {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                                    Text("Overdue")
                                        .font(.caption).foregroundStyle(.orange)
                                }
                                .padding(.top, 2)
                            }
                        }
                    }

                    // When Card
                    CardSection(title: "When", systemImage: "calendar") {
                        VStack(spacing: 12) {
                            LabeledRow(icon: "calendar") {
                                DatePicker("Date", selection: $date, displayedComponents: .date)
                                    .labelsHidden()
                            }

                            Toggle("Has Start Time", isOn: $hasStartTime)
                            if hasStartTime {
                                HStack(spacing: 12) {
                                    Image(systemName: "clock").foregroundStyle(.secondary)
                                    DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                    Spacer()
                                    Button("Clear") { hasStartTime = false }
                                        .buttonStyle(.bordered)
                                }
                                .onChange(of: startTime) {
                                    if hasEndTime && endTime < startTime { endTime = startTime }
                                }
                            }

                            Toggle("Has End Time", isOn: $hasEndTime)
                            if hasEndTime {
                                HStack(spacing: 12) {
                                    Image(systemName: "clock.badge.checkmark").foregroundStyle(.secondary)
                                    DatePicker("End", selection: $endTime, in: (hasStartTime ? startTime... : Date.distantPast...), displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                    Spacer()
                                    Button("Clear") { hasEndTime = false }
                                        .buttonStyle(.bordered)
                                }
                            }
                        }
                    }

                    // Priority & Color Card
                    CardSection(title: "Appearance", systemImage: "paintpalette") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Priority")
                                .font(.subheadline).foregroundStyle(.secondary)
                            Picker("Priority", selection: $priority) {
                                ForEach(PriorityLevel.allCases) { level in
                                    Text(level.title).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                            .tint(priority.tint)

                            Divider().padding(.vertical, 4)

                            Text("Color Tag")
                                .font(.subheadline).foregroundStyle(.secondary)

                            // Simple color choices
                            HStack(spacing: 10) {
                                ForEach(colorChoices, id: \.self) { hex in
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Circle().strokeBorder(Color.primary.opacity(selectedColorHex == hex ? 0.8 : 0.15), lineWidth: selectedColorHex == hex ? 2 : 1)
                                        )
                                        .onTapGesture { selectedColorHex = hex }
                                }
                                Spacer()
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: selectedColorHex))
                                    .frame(width: 44, height: 28)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8).strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                                    )
                            }
                        }
                    }

                    // Notes Card
                    CardSection(title: "Notes", systemImage: "note.text") {
                        ZStack(alignment: .topLeading) {
                            if note.isEmpty {
                                Text("Add notes (optional)")
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 8)
                                    .padding(.horizontal, 4)
                            }
                            TextEditor(text: $note)
                                .frame(minHeight: 140)
                        }
                    }

                    // Delete Card
                    CardSection {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Task", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
                .padding(16)
            }
            .background(LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom))
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
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
                }
            }
            .onAppear { loadFromTask() }
            .alert("Delete Task", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    onDelete?(task)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this task?")
            }
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
        
        // Read priority and color directly from TaskEntity
        priority = task.priority
        selectedColorHex = task.colorHex
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
        
        // Update priority and color directly
        updatedTask.priority = priority
        updatedTask.colorHex = selectedColorHex
        
        task = updatedTask
        onSave?(updatedTask)
        dismiss()
    }
}



private let colorChoices: [String] = [
    "#4F8EF7", // blue
    "#34C759", // green
    "#FF9F0A", // orange
    "#FF453A", // red
    "#AF52DE", // purple
    "#5AC8FA"  // light blue
]

private func isOverdue(date: Date, isDone: Bool) -> Bool {
    guard !isDone else { return false }
    let today = Calendar.current.startOfDay(for: .now)
    let target = Calendar.current.startOfDay(for: date)
    return target < today
}



private struct CardSection<Content: View>: View {
    var title: String?
    var systemImage: String?
    @ViewBuilder var content: Content

    init(title: String? = nil, systemImage: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title, !title.isEmpty {
                HStack(spacing: 8) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .foregroundStyle(.secondary)
                    }
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
}

private struct LabeledRow<Content: View>: View {
    var icon: String
    @ViewBuilder var content: Content

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            content
        }
    }
}
