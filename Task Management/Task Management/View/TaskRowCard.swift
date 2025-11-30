import SwiftUI

struct TaskRowCard: View {
    let task: TaskEntity
    let onTapTask: (TaskEntity) -> Void
    var onDelete: ((TaskEntity) -> Void)? = nil
    var onEdit: ((TaskEntity) -> Void)? = nil
    var onUpdate: ((TaskEntity) -> Void)? = nil

    // Swipe State
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    @State private var swipeDirection: Int = 0 // 0: none, 1: right, -1: left

    // Increased height to comfortably display title + 2-line note + metadata
    private let minRowHeight: CGFloat = 96

    var body: some View {
        ZStack {
            // Swipe Actions Background
            HStack {
                ZStack(alignment: .leading) {
                    // Leading Action (Complete/Incomplete)
                    Button {
                        withAnimation(.snappy) {
                            offset = 0
                            isSwiped = false
                        }
                        var toggled = task
                        toggled.isDone.toggle()
                        onUpdate?(toggled)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: task.isDone ? "arrow.uturn.backward" : "checkmark")
                                .font(.title2)
                            Text(task.isDone ? "Undo" : "Done")
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 80, height: minRowHeight)
                        .frame(maxHeight: .infinity)
                    .background(task.isDone ? Color.gray : Color.green)
                }
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 14, bottomTrailingRadius: 0, topTrailingRadius: 0))
            }
            
            Spacer()
            
            ZStack(alignment: .trailing) {
                // Trailing Actions (Edit & Delete)
                HStack(spacing: 0) {
                    Button {
                        withAnimation(.snappy) {
                            offset = 0
                            isSwiped = false
                        }
                        onEdit?(task)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.title2)
                            Text("Edit")
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 70, height: minRowHeight)
                        .frame(maxHeight: .infinity)
                        .background(Color.orange)
                    }
                    
                    Button {
                        withAnimation(.snappy) {
                            offset = 0
                            isSwiped = false
                        }
                        onDelete?(task)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.title2)
                            Text("Delete")
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 70, height: minRowHeight)
                        .frame(maxHeight: .infinity)
                        .background(Color.red)
                    }
                }
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 14, topTrailingRadius: 14))
            }
        }

            // Main Card Content
            ZStack {
                // Background card with subtle border and shadow (Notes-like)
                UnevenRoundedRectangle(
                    topLeadingRadius: offset > 0 ? 0 : 14,
                    bottomLeadingRadius: offset > 0 ? 0 : 14,
                    bottomTrailingRadius: offset < 0 ? 0 : 14,
                    topTrailingRadius: offset < 0 ? 0 : 14,
                    style: .continuous
                )
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: offset > 0 ? 0 : 14,
                        bottomLeadingRadius: offset > 0 ? 0 : 14,
                        bottomTrailingRadius: offset < 0 ? 0 : 14,
                        topTrailingRadius: offset < 0 ? 0 : 14,
                        style: .continuous
                    )
                    .strokeBorder(Color(.separator).opacity(0.45), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)

                HStack(alignment: .top, spacing: 12) {
                    // Completion indicator with color
                    ZStack {
                        Circle()
                            .fill(task.isDone ? Color.green.opacity(0.2) : Color(hex: task.colorHex).opacity(0.15))
                            .frame(width: 24, height: 24)
                        Circle()
                            .strokeBorder(task.isDone ? Color.green : Color(hex: task.colorHex), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        if task.isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.green)
                        } else {
                            // Priority indicator
                            Text(task.priority.title.first?.uppercased() ?? "M")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color(hex: task.colorHex))
                        }
                    }
                    .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 6) {
                        // Title
                        Text((task.title?.isEmpty == false ? task.title : "Untitled") ?? "Untitled")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .contentTransition(.opacity)

                        // Note preview (2 lines)
                        if let note = task.note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(note)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .transition(.opacity)
                        }

                        // Metadata: time range / date and location
                        HStack(spacing: 10) {
                            if let date = task.date {
                                if let start = task.startTime, let end = task.endTime {
                                    Label("\(timeString(from: start)) – \(timeString(from: end))", systemImage: "clock")
                                        .labelStyle(.iconOnlyIfCompact)
                                } else if let start = task.startTime {
                                    Label(timeString(from: start), systemImage: "clock")
                                        .labelStyle(.iconOnlyIfCompact)
                                } else {
                                    Label(dateString(from: date), systemImage: "calendar")
                                        .labelStyle(.iconOnlyIfCompact)
                                }
                            }

                            if let location = task.location, !location.isEmpty {
                                Label(location, systemImage: "mappin.and.ellipse")
                                    .labelStyle(.iconOnlyIfCompact)
                                    .lineLimit(1)
                            }
                        }
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Accessory chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.tertiaryLabel)
                        .padding(.top, 2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .frame(minHeight: minRowHeight)
            .background(Color(.systemBackground)) // Ensure opacity
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation.width
                        
                        // Determine direction on first move if starting from closed
                        if !isSwiped && swipeDirection == 0 && abs(translation) > 0 {
                            swipeDirection = translation > 0 ? 1 : -1
                        }
                        
                        // Calculate proposed offset
                        var newOffset: CGFloat
                        if isSwiped {
                            // If starting open, add translation to current resting offset
                            let startOffset: CGFloat = offset > 0 ? 80 : -140
                            newOffset = startOffset + translation
                        } else {
                            newOffset = translation
                        }
                        
                        // Apply constraints based on direction/state
                        if isSwiped {
                            // If currently swiped RIGHT (positive), don't let it go negative
                            if offset > 0 {
                                newOffset = max(0, min(newOffset, 80))
                            }
                            // If currently swiped LEFT (negative), don't let it go positive
                            else {
                                newOffset = min(0, max(newOffset, -140))
                            }
                        } else {
                            // If starting closed, strictly follow the locked direction
                            if swipeDirection == 1 {
                                newOffset = max(0, min(newOffset, 80))
                            } else if swipeDirection == -1 {
                                newOffset = min(0, max(newOffset, -140))
                            } else {
                                newOffset = 0
                            }
                        }
                        
                        offset = newOffset
                    }
                    .onEnded { value in
                        swipeDirection = 0
                        withAnimation(.snappy) {
                            if offset < -70 { // Threshold for opening left (140/2)
                                offset = -140
                                isSwiped = true
                            } else if offset > 40 { // Threshold for opening right (80/2)
                                offset = 80
                                isSwiped = true
                            } else {
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
            .onTapGesture {
                if isSwiped {
                    withAnimation(.snappy) {
                        offset = 0
                        isSwiped = false
                    }
                } else {
                    onTapTask(task)
                }
            }
        }
    }

    private func timeString(from date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f.string(from: date)
    }

    private func dateString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }
}

private extension LabelStyle where Self == _IconOnlyIfCompact {
    static var iconOnlyIfCompact: _IconOnlyIfCompact { _IconOnlyIfCompact() }
}

private struct _IconOnlyIfCompact: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
                .font(.system(size: 12, weight: .semibold))
            configuration.title
        }
    }
}

private extension Color {
    // Tertiary label color approximation for iOS
    static var tertiaryLabel: Color {
        Color(UIColor.tertiaryLabel)
    }
}
