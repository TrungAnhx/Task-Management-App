//
//  Home.swift
//  Task Management
//
//  Created by TrungAnhx on 8/11/25.
//

import SwiftUI
import Combine

struct Home: View {
    // View Properties
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var selectedDate: Date?
    @State private var scrollTarget: Date?

    // Task Management
    @StateObject private var viewModel = DynamicTasksViewModel()

    // Sheet/Edit
    @State private var editingTask: TaskEntity?
    @State private var showEditor: Bool = false

    // Matched Geometry Effect
    @Namespace private var namespace

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                HeaderView()
                    .environment(\.colorScheme, .dark)

                GeometryReader { proxy in
                    let size = proxy.size

                    ScrollView(.vertical) {
                        LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                            ForEach(currentWeek) { day in
                                WeekSection(
                                    day: day,
                                    isLast: currentWeek.last?.id == day.id,
                                    size: size,
                                    tasksForDay: tasks(on: day.date),
                                    onTapTask: { task in
                                        editingTask = task
                                        showEditor = true
                                    },
                                    onDeleteTask: { task in
                                        viewModel.deleteTask(task)
                                    },
                                    onUpdateTask: { task in
                                        viewModel.updateTask(task)
                                    }
                                )
                                .id(day.date as Date)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.all , 20, for: .scrollContent)
                    .contentMargins(.vertical , 20, for: .scrollIndicators)
                    .scrollPosition(id: Binding<Date?>(
                        get: { scrollTarget },
                        set: { newValue in
                            scrollTarget = newValue
                            selectedDate = newValue
                            fetchTasks()
                        }
                    ), anchor: .top)
                    .safeAreaPadding(.bottom, 70)
                    .padding(.bottom, -70)
                }
                .background(.background)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
                .environment(\.colorScheme, .light)
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .background(.mainBackground)
            .onAppear {
                DispatchQueue.main.async {
                    guard self.selectedDate == nil else { return }
                    self.selectedDate = self.currentWeek.first(where: { $0.date.isSame(.now) })?.date
                    self.scrollTarget = self.selectedDate
                    self.fetchTasks()
                }
            }
            // Replace deprecated onChange(of:perform:) with iOS 17 form, with fallback
            .modifier(SelectedDateChangeHandler(selectedDate: $selectedDate, onChange: { 
                DispatchQueue.main.async {
                    self.fetchTasks()
                }
            }))

            // Floating add button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        addTask()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.accentColor))
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
            .allowsHitTesting(true)
        }
        .sheet(isPresented: $showEditor, onDismiss: {
            fetchTasks()
        }) {
            if let task = editingTask {
                EditTaskView(task: task, onDelete: { toDelete in
                    viewModel.deleteTask(toDelete)
                }, onSave: { updatedTask in
                    viewModel.updateTask(updatedTask)
                })
            } else {
                // Empty view to prevent sheet presentation issues
                Text("No task selected")
            }
        }
    }

    private func fetchTasks() {
        // Fetch toàn bộ task trong tuần chứa selectedDate
        viewModel.fetchWeek(of: selectedDate)
    }

    private func addTask() {
        let date = selectedDate ?? .now
        viewModel.addTask(on: date)
    }

    // Trả về tasks theo đúng ngày trong tuần đang render
    private func tasks(on date: Date) -> [TaskEntity] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(24*3600)
        return viewModel.tasks.filter { t in
            guard let d = t.date else { return false }
            return (d >= start) && (d < end)
        }
    }

    // MARK: - Header View
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 12){
            HStack {
                Text("This Week")
                    .font(.title.bold())

                Spacer(minLength: 0)

                Button {
                    // profile button action if needed
                } label: {
                    Image(.pic)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .clipShape(.circle)
                }
            }

            // Week View
            HStack(spacing: 0) {
                ForEach(currentWeek) { day in
                    let date = day.date
                    let isSameDate = date.isSame(selectedDate)

                    VStack(spacing: 6) {
                        Text(date.string("EEE"))
                            .font(.caption)

                        Text(date.string("dd"))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSameDate ? .black : .white)
                            .frame(width: 38, height: 38)
                            .background {
                                if isSameDate {
                                    Circle()
                                        .fill(.white)
                                        .matchedGeometryEffect(id: "ACTIVEDATE", in: namespace)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            selectedDate = date
                            scrollTarget = date
                        }
                    }

                }
            }
            .animation(.snappy(duration: 0.25, extraBounce: 0), value: selectedDate)
            .frame(height: 80)
            .padding(.vertical, 5)
            .offset(y: 5)

            HStack {
                Text(selectedDate?.string("MMM") ?? "" )

                Spacer()

                Text(selectedDate?.string("YYYY") ?? "")

            }
            .font(.caption2)
        }
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 10)
    }
}

private struct WeekSection: View {
    let day: Date.Day
    let isLast: Bool
    let size: CGSize
    let tasksForDay: [TaskEntity]
    let onTapTask: (TaskEntity) -> Void
    let onDeleteTask: (TaskEntity) -> Void
    let onUpdateTask: (TaskEntity) -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 15) {
                if tasksForDay.isEmpty {
                    TaskRow(isEmpty: true)
                } else {
                    // TaskEntity is Identifiable (id: UUID), so no need to supply id:
                    ForEach(tasksForDay) { task in
                        TaskRowCard(
                            task: task,
                            onTapTask: onTapTask,
                            onDelete: { toDelete in
                                onDeleteTask(toDelete)
                            },
                            onUpdate: { toUpdate in
                                onUpdateTask(toUpdate)
                            }
                        )
                        .onTapGesture {
                            onTapTask(task)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.leading, 70)
            .padding(.top, -70)
            .padding(.bottom, 10)
            // Remove the minHeight to avoid the last card being stretched
            //.frame(minHeight: isLast ? (size.height - 110) : nil, alignment: .top)
        } header: {
            let date = day.date
            VStack(spacing: 4) {
                Text(date.string("EEE"))

                Text(date.string("dd"))
                    .font(.largeTitle.bold())
            }
            .frame(width: 56, height: 70)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TaskRow: View {
    var isEmpty: Bool = false
    var body: some View {
        Group {
            if isEmpty{
                VStack(spacing: 8) {
                    Text("No task found on this day!")

                    Text("Try adding some new tasks!")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
            } else {
                // Not used when Core Data is enabled
                EmptyView()
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
                .shadow(color: Color.black.opacity(0.35), radius: 1)
        }
    }
}

#Preview {
    Home()
}

// MARK: - Helper to bridge onChange API differences
private struct SelectedDateChangeHandler: ViewModifier {
    @Binding var selectedDate: Date?
    let onChange: () -> Void

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onChange(of: selectedDate) {
                    onChange()
                }
        } else {
            content
                .onChange(of: selectedDate) { _ in
                    onChange()
                }
        }
    }
}
