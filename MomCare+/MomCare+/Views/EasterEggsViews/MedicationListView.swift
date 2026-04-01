// MedicationListView.swift
// Medication Reminders — List + Detail views
// Native NavigationStack push transitions, HealthKit + UNUserNotificationCenter integration
// Accessibility: Reduce Motion, VoiceOver, Dynamic Type, colorblind-safe

import HealthKit
import SwiftUI
import UserNotifications

// MARK: - Notification Model

struct ScheduledDose: Identifiable {
    let id: UUID
    let medicationName: String
    let nickname: String
    let form: MedicationForm
    let quantity: Double
    let unit: StrengthUnit
    let strength: String
    let fireDate: Date
    let notificationIdentifier: String
    let notes: String
}

// Group of doses for a single medication
struct MedicationReminder: Identifiable {
    let id: UUID
    let medicationName: String
    let nickname: String
    let form: MedicationForm
    let strength: String
    let unit: StrengthUnit
    let notes: String
    var upcomingDoses: [ScheduledDose]

    var nextDose: ScheduledDose? {
        upcomingDoses.sorted { $0.fireDate < $1.fireDate }.first
    }

    var isAsNeeded: Bool {
        upcomingDoses.isEmpty
    }
}

// MARK: - View Model

@MainActor
@Observable
final class MedicationReminderViewModel {
    // MARK: Internal

    enum ReminderFilter: String, CaseIterable, Identifiable {
        case upcoming = "Upcoming"
        case all = "All"
        case asNeeded = "As Needed"

        // MARK: Internal

        var id: String {
            rawValue
        }

        var symbol: String {
            switch self {
            case .upcoming: "clock.fill"
            case .all: "list.bullet"
            case .asNeeded: "hand.raised.fill"
            }
        }
    }

    var reminders: [MedicationReminder] = []
    var isLoading = false
    var errorMessage: String?
    var selectedFilter: ReminderFilter = .upcoming

    var filteredReminders: [MedicationReminder] {
        switch selectedFilter {
        case .upcoming: reminders.filter { !$0.isAsNeeded }
        case .all: reminders
        case .asNeeded: reminders.filter { $0.isAsNeeded }
        }
    }

    // Next 7 days doses across all medications, sorted chronologically
    var next7DaysDoses: [ScheduledDose] {
        let now = Date()
        let week = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        return reminders
            .flatMap { $0.upcomingDoses }
            .filter { $0.fireDate >= now && $0.fireDate <= week }
            .sorted { $0.fireDate < $1.fireDate }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            reminders = try await fetchFromNotificationCenter()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteDose(identifier: String) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        await load()
    }

    func deleteMedication(_ reminder: MedicationReminder) async {
        let ids = reminder.upcomingDoses.map { $0.notificationIdentifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        await load()
    }

    // MARK: Private

    // Parse pending UNNotificationRequests back into our model
    private func fetchFromNotificationCenter() async throws -> [MedicationReminder] {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus != .denied else {
            throw NSError(domain: "Notifications", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Notification access denied. Enable it in Settings."])
        }

        let pending = await center.pendingNotificationRequests()
        // Group by medication name (prefix of identifier)
        var groups = [String: [UNNotificationRequest]]()
        for req in pending where req.identifier.hasPrefix("med-") {
            // identifier format: med-{name}-{doseUUID}
            let parts = req.identifier.components(separatedBy: "-")
            if parts.count >= 2 {
                let key = parts.dropLast().joined(separator: "-")
                groups[key, default: []].append(req)
            }
        }

        var result = [MedicationReminder]()
        for (_, requests) in groups {
            guard let first = requests.first else {
                continue
            }

            let info = first.content.userInfo
            let medName = (info["medicationName"] as? String) ?? first.content.title.replacingOccurrences(of: "💊 ", with: "")
            let formRaw = info["form"] as? String ?? "Tablet"
            let form = MedicationForm.allCases.first { $0.displayName == formRaw } ?? .tablet
            let strength = info["strength"] as? String ?? ""
            let unitRaw = info["unit"] as? String ?? "mg"
            let unit = StrengthUnit.allCases.first { $0.displayName == unitRaw } ?? .mg
            let notes = (info["notes"] as? String) ?? ""
            let nickname = info["nickname"] as? String ?? ""

            let doses: [ScheduledDose] = requests.compactMap { req in
                guard let trigger = req.trigger as? UNCalendarNotificationTrigger,
                      let next = trigger.nextTriggerDate() else {
                          return nil
                      }

                // Parse quantity from body: "Take 2 tablet"
                let body = req.content.body
                let qty = parseQuantity(from: body) ?? 1.0

                return ScheduledDose(
                    id: UUID(),
                    medicationName: medName,
                    nickname: nickname,
                    form: form,
                    quantity: qty,
                    unit: unit,
                    strength: strength,
                    fireDate: next,
                    notificationIdentifier: req.identifier,
                    notes: notes
                )
            }

            result.append(MedicationReminder(
                id: UUID(),
                medicationName: medName,
                nickname: nickname.isEmpty ? medName : nickname,
                form: form,
                strength: strength,
                unit: unit,
                notes: notes,
                upcomingDoses: doses.sorted { $0.fireDate < $1.fireDate }
            ))
        }

        // Also inject as-needed stubs from HealthKit metadata if available
        // (In production, query HKUserAnnotatedMedication here)

        return result.sorted { $0.medicationName < $1.medicationName }
    }

    private func parseQuantity(from body: String) -> Double? {
        // "Take 2 tablet" → 2.0
        let parts = body.components(separatedBy: " ")
        if parts.count >= 2, let qty = Double(parts[1]) {
            return qty
        }
        return nil
    }
}

// MARK: - Root List View

struct MedicationListView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else if viewModel.reminders.isEmpty {
                    emptyView
                } else {
                    listContent
                }
            }
            .navigationTitle("My Medications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .navigationDestination(for: MedicationReminder.self) { reminder in
                MedicationDetailView(reminder: reminder, viewModel: viewModel)
            }
            .navigationDestination(for: String.self) { route in
                if route == "timeline" {
                    UpcomingTimelineView(doses: viewModel.next7DaysDoses)
                } else if route == "add" {
                    AddMedicationView()
                }
            }
        }
        .task { await viewModel.load() }
    }

    // MARK: Private

    @State private var viewModel: MedicationReminderViewModel = .init()
    @State private var path: NavigationPath = .init()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                path.append("add")
            } label: {
                Image(systemName: "plus.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 22))
            }
            .accessibilityLabel("Add new medication")
        }

        ToolbarItem(placement: .topBarLeading) {
            Button {
                path.append("timeline")
            } label: {
                Image(systemName: "calendar.day.timeline.left")
                    .font(.system(size: 18))
            }
            .accessibilityLabel("View timeline")
        }
    }

    // MARK: List Content

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                // Filter Picker
                filterBar
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // Upcoming Today banner
                if !viewModel.next7DaysDoses.isEmpty, viewModel.selectedFilter != .asNeeded {
                    Section {
                        UpcomingBannerCard(doses: viewModel.next7DaysDoses) {
                            path.append("timeline")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    } header: {
                        SectionHeader(title: "Next 7 Days", symbol: "calendar.badge.clock")
                    }
                }

                // Medications
                Section {
                    VStack(spacing: 10) {
                        ForEach(viewModel.filteredReminders) { reminder in
                            MedicationCard(reminder: reminder)
                                .onTapGesture {
                                    path.append(reminder)
                                }
                                .transition(unsafe reduceMotion ? .opacity : .asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: viewModel.filteredReminders.map { $0.id })
                } header: {
                    SectionHeader(title: "Medications · \(viewModel.filteredReminders.count)", symbol: "pills.fill")
                }
            }
        }
        .refreshable {
            await viewModel.load()
        }
    }

    // MARK: Filter Bar

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(MedicationReminderViewModel.ReminderFilter.allCases) { filter in
                FilterChip(
                    title: filter.rawValue,
                    symbol: filter.symbol,
                    isSelected: viewModel.selectedFilter == filter
                ) {
                    withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.selectedFilter = filter
                    }
                }
            }
        }
    }

    // MARK: States

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.3)
            Text("Loading medications…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Medications", systemImage: "pills")
        } description: {
            Text("Tap + to add your first medication and set up reminders.")
        } actions: {
            Button {
                path.append("add")
            } label: {
                Label("Add Medication", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func errorView(_ msg: String) -> some View {
        ContentUnavailableView {
            Label("Unable to Load", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text(msg)
        } actions: {
            Button("Try Again") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Upcoming Banner Card

struct UpcomingBannerCard: View {
    // MARK: Internal

    let doses: [ScheduledDose]
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: "clock.badge.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 3) {
                    if let next = nextDose {
                        Text("Next: \(next.medicationName)")
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                        Text(next.fireDate.formatted(.relative(presentation: .named, unitsStyle: .wide)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if todayCount > 0 {
                        Text("\(todayCount) dose\(todayCount == 1 ? "" : "s") today")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.accentColor)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Upcoming doses. \(todayCount) today. Tap to view timeline.")
    }

    // MARK: Private

    private var nextDose: ScheduledDose? {
        doses.first
    }

    private var todayCount: Int {
        doses.filter { Calendar.current.isDateInToday($0.fireDate) }.count
    }
}

// MARK: - Medication Card

struct MedicationCard: View {
    let reminder: MedicationReminder

    var body: some View {
        HStack(spacing: 14) {
            // Form icon with colorblind-safe shape
            ZStack {
                BadgeShapeView(shape: reminder.form.badgeShape, isSelected: true)
                Image(systemName: reminder.form.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(reminder.medicationName)
                        .font(.headline)
                        .lineLimit(1)

                    if !reminder.nickname.isEmpty, reminder.nickname != reminder.medicationName {
                        Text("· \(reminder.nickname)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Text("\(reminder.strength)\(reminder.unit.displayName) · \(reminder.form.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if reminder.isAsNeeded {
                    AsNeededBadge()
                } else if let next = reminder.nextDose {
                    NextDoseBadge(date: next.fireDate)
                }
            }

            Spacer()

            // Dose count badge
            if !reminder.isAsNeeded {
                VStack(spacing: 2) {
                    Text("\(reminder.upcomingDoses.count)")
                        .font(.headline.monospacedDigit())
                    Text("doses")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityLabel("\(reminder.upcomingDoses.count) upcoming doses")
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reminder.medicationName), \(reminder.strength)\(reminder.unit.displayName) \(reminder.form.displayName)\(reminder.isAsNeeded ? ", as needed" : ", \(reminder.upcomingDoses.count) upcoming doses")")
        .accessibilityHint("Tap to view details")
    }
}

struct AsNeededBadge: View {
    var body: some View {
        Label("As Needed", systemImage: "hand.raised.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.orange)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.orange.opacity(0.12), in: Capsule())
            .overlay(Capsule().strokeBorder(Color.orange.opacity(0.25), lineWidth: 1))
    }
}

struct NextDoseBadge: View {
    // MARK: Internal

    let date: Date

    var body: some View {
        HStack(spacing: 4) {
            // Urgency shape indicator (not color-only)
            if isSoon {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Color.orange)
            } else {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
            }
            Text(date.formatted(.relative(presentation: .named, unitsStyle: .abbreviated)))
                .font(.caption.weight(.medium))
                .foregroundStyle(isSoon ? Color.orange : Color.accentColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            (isSoon ? Color.orange : Color.accentColor).opacity(0.1),
            in: Capsule()
        )
    }

    // MARK: Private

    private var isSoon: Bool {
        date.timeIntervalSinceNow < 3600 && date.timeIntervalSinceNow > 0
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let symbol: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.accentColor.opacity(0.12) : Color(.secondarySystemGroupedBackground),
                    in: Capsule()
                )
                .overlay(
                    Capsule().strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) filter\(isSelected ? ", selected" : "")")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Detail View

struct MedicationDetailView: View {
    // MARK: Internal

    let reminder: MedicationReminder
    let viewModel: MedicationReminderViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero Card
                heroCard
                    .padding(.horizontal)
                    .padding(.top, 8)

                if reminder.isAsNeeded {
                    // As Needed state
                    ContentUnavailableView {
                        Label("As Needed", systemImage: "hand.raised.fill")
                    } description: {
                        Text("No scheduled reminders. You've configured this medication to be taken as needed.")
                    }
                    .padding(.horizontal)
                } else {
                    // Schedule sections
                    VStack(alignment: .leading, spacing: 0) {
                        SectionHeader(title: "Upcoming Reminders", symbol: "bell.fill")

                        VStack(spacing: 20) {
                            ForEach(groupedDoses, id: \.0) { day, doses in
                                DaySection(day: day, doses: doses, form: reminder.form) { identifier in
                                    Task { await viewModel.deleteDose(identifier: identifier) }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }

                // Notes
                if !reminder.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        SectionHeader(title: "Notes", symbol: "note.text")
                        Text(reminder.notes)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemGroupedBackground),
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(.horizontal)
                    }
                }

                // Delete medication
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Remove Medication", systemImage: "trash")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(.red)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
                .accessibilityLabel("Remove all reminders for \(reminder.medicationName)")
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(reminder.medicationName)
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog(
            "Remove \(reminder.medicationName)?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Remove All Reminders", role: .destructive) {
                Task { await viewModel.deleteMedication(reminder) }
            }
        } message: {
            Text("All scheduled notifications for this medication will be cancelled.")
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showDeleteConfirm = false

    private var sortedDoses: [ScheduledDose] {
        reminder.upcomingDoses.sorted { $0.fireDate < $1.fireDate }
    }

    private var groupedDoses: [(String, [ScheduledDose])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sortedDoses) { dose -> String in
            if calendar.isDateInToday(dose.fireDate) {
                return "Today"
            }
            if calendar.isDateInTomorrow(dose.fireDate) {
                return "Tomorrow"
            }
            return dose.fireDate.formatted(.dateTime.weekday(.wide).month().day())
        }
        // Preserve chronological order of keys
        let orderedKeys = sortedDoses.map { dose -> String in
            if calendar.isDateInToday(dose.fireDate) {
                return "Today"
            }
            if calendar.isDateInTomorrow(dose.fireDate) {
                return "Tomorrow"
            }
            return dose.fireDate.formatted(.dateTime.weekday(.wide).month().day())
        }
.uniqued()
        return orderedKeys.compactMap { key in
            grouped[key].map { (key, $0) }
        }
    }

    // MARK: Hero Card

    private var heroCard: some View {
        HStack(spacing: 16) {
            ZStack {
                BadgeShapeView(shape: reminder.form.badgeShape, isSelected: true)
                Image(systemName: reminder.form.symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 5) {
                if !reminder.nickname.isEmpty, reminder.nickname != reminder.medicationName {
                    Text(reminder.nickname)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }

                Text("\(reminder.strength)\(reminder.unit.displayName)")
                    .font(.title2.bold())

                Text(reminder.form.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if reminder.isAsNeeded {
                    AsNeededBadge()
                } else {
                    Text("\(reminder.upcomingDoses.count)")
                        .font(.title.bold().monospacedDigit())
                        .foregroundStyle(Color.accentColor)
                    Text("reminders")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 1.5)
        )
    }
}

// MARK: - Day Section

struct DaySection: View {
    let day: String
    let doses: [ScheduledDose]
    let form: MedicationForm
    let onDelete: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if day == "Today" {
                    Image(systemName: "star.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                }
                Text(day)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(day == "Today" ? Color.accentColor : Color.primary)
                Spacer()
                Text("\(doses.count) dose\(doses.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(doses.enumerated()), id: \.element.id) { idx, dose in
                    DoseRow(dose: dose, form: form, isLast: idx == doses.count - 1, onDelete: {
                        onDelete(dose.notificationIdentifier)
                    })
                }
            }
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - Dose Row

struct DoseRow: View {
    // MARK: Internal

    let dose: ScheduledDose
    let form: MedicationForm
    let isLast: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Time column
                VStack(alignment: .trailing, spacing: 2) {
                    Text(timeLabel)
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(isSoon ? Color.orange : Color.primary)
                        .contentTransition(.numericText())
                }
                .frame(width: 72, alignment: .trailing)

                // Shape indicator (colorblind-safe: dot shape varies by urgency)
                ZStack {
                    if isSoon {
                        // Diamond for urgent
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                            .rotationEffect(.degrees(45))
                    } else if isUpcoming {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 10, height: 10)
                    } else {
                        Circle()
                            .strokeBorder(Color.secondary.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 10, height: 10)
                    }
                }
                .frame(width: 14)

                VStack(alignment: .leading, spacing: 2) {
                    Text(qtyLabel)
                        .font(.subheadline)
                    if isSoon {
                        Text("Coming up soon")
                            .font(.caption)
                            .foregroundStyle(Color.orange)
                    }
                }

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.secondary.opacity(0.6))
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove \(timeLabel) reminder")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(timeLabel), take \(qtyLabel)\(isSoon ? ", coming up soon" : "")")

            if !isLast {
                Divider()
                    .padding(.leading, 100)
            }
        }
    }

    // MARK: Private

    private var timeLabel: String {
        dose.fireDate.formatted(date: .omitted, time: .shortened)
    }

    private var qtyLabel: String {
        let q = dose.quantity
        let qty = unsafe q == q.rounded() ? String(Int(q)) : String(format: "%.1f", q)
        return "\(qty) \(form.displayName.lowercased())"
    }

    private var isUpcoming: Bool {
        dose.fireDate > Date()
    }

    private var isSoon: Bool {
        dose.fireDate.timeIntervalSinceNow < 3600 && isUpcoming
    }
}

// MARK: - Timeline View

struct UpcomingTimelineView: View {
    // MARK: Internal

    let doses: [ScheduledDose]

    var body: some View {
        ScrollView {
            if doses.isEmpty {
                ContentUnavailableView(
                    "No Upcoming Doses",
                    systemImage: "calendar.badge.checkmark",
                    description: Text("No reminders scheduled in the next 7 days.")
                )
                .padding(.top, 60)
            } else {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(groupedByDay, id: \.0) { day, dayDoses in
                        Section {
                            VStack(spacing: 0) {
                                ForEach(Array(dayDoses.enumerated()), id: \.element.id) { idx, dose in
                                    TimelineDoseRow(dose: dose, isFirst: idx == 0, isLast: idx == dayDoses.count - 1)
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground),
                                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        } header: {
                            SectionHeader(
                                title: day,
                                symbol: day == "Today" ? "star.fill" : "calendar"
                            )
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("7-Day Timeline")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: Private

    private var groupedByDay: [(String, [ScheduledDose])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: doses) { dose -> String in
            if calendar.isDateInToday(dose.fireDate) {
                return "Today"
            }
            if calendar.isDateInTomorrow(dose.fireDate) {
                return "Tomorrow"
            }
            return dose.fireDate.formatted(.dateTime.weekday(.wide).month().day())
        }
        let orderedKeys = doses.map { dose -> String in
            if calendar.isDateInToday(dose.fireDate) {
                return "Today"
            }
            if calendar.isDateInTomorrow(dose.fireDate) {
                return "Tomorrow"
            }
            return dose.fireDate.formatted(.dateTime.weekday(.wide).month().day())
        }
.uniqued()
        return orderedKeys.compactMap { key in grouped[key].map { (key, $0) } }
    }
}

struct TimelineDoseRow: View {
    // MARK: Internal

    let dose: ScheduledDose
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(spacing: 14) {
            // Timeline spine
            VStack(spacing: 0) {
                Rectangle()
                    .fill(isFirst ? Color.clear : Color.accentColor.opacity(0.2))
                    .frame(width: 2)
                    .frame(height: 18)

                ZStack {
                    if isSoon {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                            .rotationEffect(.degrees(45))
                    } else {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 10, height: 10)
                    }
                }

                Rectangle()
                    .fill(isLast ? Color.clear : Color.accentColor.opacity(0.2))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 20)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(dose.medicationName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)

                    let qty = unsafe dose.quantity == dose.quantity.rounded() ? String(Int(dose.quantity)) : String(format: "%.1f", dose.quantity)
                    Text("Take \(qty) \(dose.form.displayName.lowercased()) · \(dose.strength)\(dose.unit.displayName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(dose.fireDate.formatted(date: .omitted, time: .shortened))
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(isSoon ? Color.orange : Color.primary)
                    if isSoon {
                        Text("Soon")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.orange)
                    }
                }
            }
            .padding(.vertical, 12)

            // Form shape badge
            ZStack {
                BadgeShapeView(shape: dose.form.badgeShape, isSelected: true)
                Image(systemName: dose.form.symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 30, height: 30)
            .padding(.trailing, 2)
        }
        .padding(.horizontal, 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(dose.medicationName) at \(dose.fireDate.formatted(date: .omitted, time: .shortened))\(isSoon ? ", coming up soon" : "")")

        if !isLast {
            Divider().padding(.leading, 48)
        }
    }

    // MARK: Private

    private var isSoon: Bool {
        dose.fireDate.timeIntervalSinceNow < 3600 && dose.fireDate > Date()
    }
}

// MARK: - Helpers

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

extension MedicationReminder: Hashable {
    static func == (lhs: MedicationReminder, rhs: MedicationReminder) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
