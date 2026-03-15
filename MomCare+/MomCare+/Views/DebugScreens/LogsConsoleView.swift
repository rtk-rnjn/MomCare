import SwiftUI

struct LogsConsoleView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DebugLogEntry.LogCategory.allCases, id: \.self) { cat in
                        CategoryChip(
                            cat: cat,
                            isSelected: selectedCategory == cat,
                            count: store.logEntries.filter { $0.category == cat || cat == .all }.count
                        ) {
                            selectedCategory = cat
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))

            Divider()

            if filtered.isEmpty {
                ContentUnavailableView(
                    "No Logs",
                    systemImage: "text.alignleft",
                    description: Text("Use DebugLogger.shared.log() to emit log entries.")
                )
            } else {
                ScrollViewReader { proxy in
                    List {
                        ForEach(filtered) { entry in
                            DebugLogEntryRow(entry: entry)
                                .id(entry.id)
                                .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        }
                    }
                    .listStyle(.plain)
                    .onChange(of: store.logEntries.count) {
                        if autoScroll, let first = filtered.first {
                            withAnimation(reduceMotion ? nil : .default) { proxy.scrollTo(first.id, anchor: .top) }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search logs")
        .navigationTitle("Logs Console")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Toggle("Auto-scroll", isOn: $autoScroll)
                    Button(role: .destructive) {
                        store.clearLogs()
                    } label: {
                        Label("Clear Logs", systemImage: "trash")
                    }
                    Button {
                        // Seed demo logs for development preview
                        seedDemoLogs()
                    } label: {
                        Label("Seed Demo Logs", systemImage: "wand.and.stars")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var store: DebugMenuStore
    @State private var selectedCategory: DebugLogEntry.LogCategory = .all
    @State private var searchText = ""
    @State private var autoScroll = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var filtered: [DebugLogEntry] {
        store.logEntries.filter { entry in
            let catMatch = selectedCategory == .all || entry.category == selectedCategory
            let search = searchText.isEmpty || entry.message.localizedCaseInsensitiveContains(searchText)
            return catMatch && search
        }
    }

    private func seedDemoLogs() {
        let l = DebugLogger.shared
        l.log("App did finish launching", level: .info, category: .data)
        l.log("Fetching /api/users", level: .debug, category: .network)
        l.log("200 OK /api/users (124 ms)", level: .info, category: .network)
        l.log("HomeView appeared", level: .verbose, category: .ui)
        l.log("CoreData save succeeded", level: .info, category: .data)
        l.log("Network timeout on /api/feed", level: .warning, category: .network)
        l.log("Unhandled exception in DataManager", level: .error, category: .error)
        l.log("401 Unauthorized — refreshing token", level: .warning, category: .network)
    }
}

private struct DebugLogEntryRow: View {
    let entry: DebugLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: entry.level.icon)
                    .font(.caption2)
                    .foregroundStyle(entry.level.color)
                    .accessibilityHidden(true)
                Text(entry.timestamp, format: .dateTime.hour().minute().second())
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                Text(entry.category.rawValue.uppercased())
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
            Text(entry.message)
                .font(.caption.monospaced())
                .foregroundStyle(entry.level.color)
                .textSelection(.enabled)
        }
        .padding(.vertical, 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.level.rawValue) log, \(entry.category.rawValue): \(entry.message.prefix(100))")
        .accessibilityValue(entry.timestamp.formatted(.dateTime.hour().minute().second()))
    }
}

private struct CategoryChip: View {

    // MARK: Internal

    let cat: DebugLogEntry.LogCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: cat.icon).font(.caption)
                    .accessibilityHidden(true)
                Text(cat.rawValue).font(.caption.bold())
                Text("\(count)")
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .background(isSelected ? Color.white.opacity(0.3) : Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.accentColor : Color(.systemBackground))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .snappy, value: isSelected)
        .accessibilityLabel(cat.rawValue)
        .accessibilityValue(isSelected ? "selected" : "not selected")
        .accessibilityHint("Filters logs by \(cat.rawValue) category")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

}
