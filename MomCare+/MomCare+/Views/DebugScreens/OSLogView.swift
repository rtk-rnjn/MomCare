import OSLog
import SwiftUI

enum LogLevel: String, CaseIterable, Sendable {
    case debug = "Debug"
    case info = "Info"
    case notice = "Notice"
    case error = "Error"
    case fault = "Fault"
    case unknown = "Other"

    // MARK: Internal

    var color: Color {
        switch self {
        case .debug: .secondary
        case .info: .blue
        case .notice: .teal
        case .error: .orange
        case .fault: .red
        case .unknown: .secondary
        }
    }

    var icon: String {
        switch self {
        case .debug: "ant"
        case .info: "info.circle"
        case .notice: "bell"
        case .error: "exclamationmark.triangle"
        case .fault: "xmark.octagon"
        case .unknown: "questionmark.circle"
        }
    }

    static func from(level: OSLogEntryLog.Level) -> Self {
        switch level {
        case .debug: .debug
        case .info: .info
        case .notice: .notice
        case .error: .error
        case .fault: .fault
        default: .unknown
        }
    }
}

struct LogEntry: Identifiable, Sendable, Equatable {
    let id: UUID = .init()
    let date: Date
    let osLogLevel: OSLogEntryLog.Level
    let category: String
    let subsystem: String
    let message: String

    var level: LogLevel {
        LogLevel.from(level: osLogLevel)
    }

    var timeString: String {
        date.formatted(date: .omitted, time: .standard)
    }
}

struct OSLogsView: View {
    // MARK: Internal

    var body: some View {
        VStack(spacing: 0) {
            filterBar
            Divider()
            logList
        }
        .navigationTitle("OS Logs")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, placement: .automatic, prompt: "Search messages, category…")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    try? fetchLogs()
                } label: {
                    if isLoading {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .disabled(isLoading)
                .accessibilityLabel("Refresh logs")
                .accessibilityHint("Fetches the latest OS log entries")
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Clear") { entries.removeAll() }
                    .foregroundStyle(.red)
                    .accessibilityLabel("Clear logs")
                    .accessibilityHint("Removes all currently displayed log entries")
            }
        }
        .onAppear { try? fetchLogs() }
        .overlay {
            if !isLoading, filtered.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "No Logs" : "No Results",
                    systemImage: searchText.isEmpty ? "doc.text" : "magnifyingglass",
                    description: Text(searchText.isEmpty ? "No log entries found in the last 5 minutes." : "No logs match \(searchText).")
                )
            }
        }
    }

    // MARK: Private

    @State private var entries: [LogEntry] = []
    @State private var searchText = ""
    @State private var selectedLevel: LogLevel?
    @State private var isLoading = false
    @State private var expandedIDs: Set<UUID> = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var filtered: [LogEntry] {
        entries.filter { entry in
            let matchesLevel = selectedLevel == nil || entry.level == selectedLevel
            let matchesSearch = searchText.isEmpty
                || entry.message.localizedCaseInsensitiveContains(searchText)
                || entry.category.localizedCaseInsensitiveContains(searchText)
                || entry.subsystem.localizedCaseInsensitiveContains(searchText)
            return matchesLevel && matchesSearch
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", icon: "line.3.horizontal.decrease.circle",
                           color: .primary, isSelected: selectedLevel == nil) {
                    selectedLevel = nil
                }
                ForEach(LogLevel.allCases, id: \.self) { level in
                    FilterChip(label: level.rawValue, icon: level.icon,
                               color: level.color,
                               isSelected: selectedLevel == level) {
                        selectedLevel = selectedLevel == level ? nil : level
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var logList: some View {
        List(filtered) { entry in
            LogEntryRow(entry: entry, isExpanded: expandedIDs.contains(entry.id)) {
                withAnimation(reduceMotion ? nil : .easeInOut) {
                    if expandedIDs.contains(entry.id) {
                        expandedIDs.remove(entry.id)
                    } else {
                        expandedIDs.insert(entry.id)
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
            .listRowBackground(Color(.systemGroupedBackground))
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
        .animation(reduceMotion ? nil : .easeInOut, value: filtered)
    }

    private func fetchLogs() throws {
        isLoading = true
        Task.detached {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let position = store.position(timeIntervalSinceLatestBoot: -300)
            for entry in try store.getEntries(at: position) {
                guard let log = entry as? OSLogEntryLog else {
                    continue
                }

                let date = log.date
                let level = log.level
                let category = log.category
                let subsystem = log.subsystem
                let message = log.composedMessage

                DispatchQueue.main.async {
                    withAnimation(reduceMotion ? nil : .snappy) {
                        entries.insert(LogEntry(
                            date: date,
                            osLogLevel: level,
                            category: category,
                            subsystem: subsystem,
                            message: message
                        ), at: 0)
                    }
                }
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }
}

private struct FilterChip: View {
    // MARK: Internal

    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .accessibilityHidden(true)
                Text(label).font(.caption.weight(.medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(isSelected ? color.opacity(0.18) : Color(.tertiarySystemFill))
            )
            .overlay(Capsule().stroke(isSelected ? color : .clear, lineWidth: 1))
            .foregroundStyle(isSelected ? color : .secondary)
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .snappy, value: isSelected)
        .accessibilityLabel(label)
        .accessibilityValue(isSelected ? "selected" : "not selected")
        .accessibilityHint("Filters log entries by \(label) level")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

private struct LogEntryRow: View {
    let entry: LogEntry
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: entry.level.icon)
                            .font(.caption2.weight(.semibold))
                        Text(entry.level.rawValue)
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(entry.level.color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(entry.level.color.opacity(0.12)))

                    Spacer()

                    Text(entry.timeString)
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.tertiary)
                }

                Text(entry.message)
                    .font(.footnote)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.primary)
                    .lineLimit(isExpanded ? nil : 2)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isExpanded {
                    Divider().padding(.vertical, 2)

                    HStack(spacing: 16) {
                        if !entry.subsystem.isEmpty {
                            LabeledDetail(icon: "app.badge", label: "Subsystem", value: entry.subsystem)
                        }
                        if !entry.category.isEmpty {
                            LabeledDetail(icon: "tag", label: "Category", value: entry.category)
                        }
                    }

                    LabeledDetail(
                        icon: "calendar.badge.clock",
                        label: "Timestamp",
                        value: entry.date.formatted(date: .abbreviated, time: .standard)
                    )
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(entry.level.color.opacity(isExpanded ? 0.35 : 0.0), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.level.rawValue) log at \(entry.timeString): \(entry.message)")
        .accessibilityHint(isExpanded ? "Double tap to collapse details" : "Double tap to expand details")
        .accessibilityValue(isExpanded ? "expanded" : "collapsed")
        .accessibilityAddTraits(.isButton)
    }
}

private struct LabeledDetail: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(value)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }
}
