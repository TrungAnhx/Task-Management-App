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
                        VStack(spacing: 20) {
                            ForEach(currentWeek) { day in
                                DailyRowView(
                                    day: day,
                                    tasks: tasks(on: day.date),
                                    onTap: { task in
                                        editingTask = task
                                    },
                                    onDelete: { task in
                                        viewModel.deleteTask(task)
                                    },
                                    onUpdate: { task in
                                        viewModel.updateTask(task)
                                    }
                                )
                            }
                            
                            // Add empty space at bottom to allow last day to scroll to top
                            Color.clear
                                .frame(height: size.height - 80)
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(20, for: .scrollContent)
                    .scrollPosition(id: Binding(
                        get: { scrollTarget },
                        set: { newValue in
                            scrollTarget = newValue
                            if let date = newValue {
                                selectedDate = date
                            }
                        }
                    ), anchor: .top)
                    .safeAreaPadding(.bottom, 70)
                    .padding(.bottom, 100)
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
                }
            }

            // Floating add button in bottom right corner
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        // Add task for selected date
                        let date = selectedDate ?? Date()
                        if tasks(on: date).count < 5 {
                            viewModel.addTask(on: date)
                        }
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
        .sheet(item: $editingTask) { task in
            EditTaskView(task: task, onDelete: { toDelete in
                viewModel.deleteTask(toDelete)
            }, onSave: { updatedTask in
                viewModel.updateTask(updatedTask)
            })
        }
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

private struct WeekDaySection: View {
    let day: Date.Day
    let isLast: Bool
    let size: CGSize
    let tasksForDay: [TaskEntity]
    let onTapTask: (TaskEntity) -> Void
    let onDeleteTask: (TaskEntity) -> Void
    let onUpdateTask: (TaskEntity) -> Void
    let onAddTaskForDay: (Date) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left side: Date column
            let date = day.date
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text(date.string("EEE"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(date.string("dd"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(width: 56)
            }
            .frame(width: 60, alignment: .leading)
            
            // Divider between columns
            Rectangle()
                .fill(Color(.separator))
                .frame(width: 2)
                .padding(.vertical, 12)
            
            // Right side: Tasks for this day
            VStack(alignment: .leading, spacing: 0) {
                if tasksForDay.isEmpty {
                    // Show message when no tasks
                    Text("No tasks added...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding()
                    .frame(height: 80)
                } else {
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
                    }
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
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

private struct DailyRowView: View {
    let day: Date.Day
    let tasks: [TaskEntity]
    let onTap: (TaskEntity) -> Void
    let onDelete: (TaskEntity) -> Void
    let onUpdate: (TaskEntity) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left side: Date column
            let date = day.date
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text(date.string("EEE"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(date.string("dd"))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(width: 56)
            }
            .frame(width: 80, alignment: .leading)
            
            // Divider
            Rectangle()
                .fill(Color(.separator))
                .frame(width: 1)
                .padding(.vertical, 12)
            
            // Right side: Tasks
            VStack(alignment: .leading, spacing: 12) {
                if tasks.isEmpty {
                    // Empty State Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color(.separator).opacity(0.45), lineWidth: 0.8)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                        
                        Text("No tasks added...")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 70)
                } else {
                    ForEach(tasks) { task in
                        TaskRowCard(
                            task: task,
                            onTapTask: onTap,
                            onDelete: onDelete,
                            onUpdate: onUpdate
                        )
                    }
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 15) // Add trailing padding for better edge spacing
        }
        .id(day.date as Date)
    }
}

#Preview {
    Home()
}

