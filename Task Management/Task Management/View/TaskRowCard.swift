import SwiftUI

struct TaskRowCard: View {
    let task: TaskEntity
    let onTapTask: (TaskEntity) -> Void
    var onDelete: ((TaskEntity) -> Void)? = nil
    var onUpdate: ((TaskEntity) -> Void)? = nil

    // Increased height to comfortably display title + 2-line note + metadata
    private let minRowHeight: CGFloat = 96

    var body: some View {
        ZStack {
            // Background card with subtle border and shadow (Notes-like)
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
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
        .allowsHitTesting(true)
        .contentShape(Rectangle())
        .animation(.snappy(duration: 0.2, extraBounce: 0), value: task.isDone)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete?(task)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                var toggled = task
                toggled.isDone.toggle()
                onUpdate?(toggled)
            } label: {
                if task.isDone {
                    Label("Mark Incomplete", systemImage: "circle")
                } else {
                    Label("Mark Complete", systemImage: "checkmark.circle.fill")
                }
            }
            .tint(task.isDone ? .gray : .green)
        }
        .onTapGesture {
            onTapTask(task)
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
