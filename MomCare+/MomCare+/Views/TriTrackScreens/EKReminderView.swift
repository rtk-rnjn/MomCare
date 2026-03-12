import SwiftUI
import EventKit

struct EKReminderView: View {

    // MARK: Internal

    // MARK: Repeat State

    enum RepeatRule: String, CaseIterable {
        case never
        case daily
        case weekly
        case monthly
        case custom
    }

    enum EndRepeat {
        case never
        case onDate
    }

    @State var reminder: EKReminder

    var repeatUnitText: (EKRecurrenceFrequency, Int) -> String = { unit, frequency in
        let unitString: String
        switch unit {
        case .daily: unitString = "day"
        case .weekly: unitString = "week"
        case .monthly: unitString = "month"
        default: unitString = "period"
        }
        return frequency == 1 ? unitString : "\(unitString)s"
    }

    var isCompleted: Bool { reminder.isCompleted }

    var priorityTitle: String {
        switch priority {
        case 1: return "High"
        case 5: return "Medium"
        case 9: return "Low"
        default: return "None"
        }
    }

    var priorityColor: Color {
        switch priority {
        case 1: return .red
        case 5: return .orange
        case 9: return .yellow
        default: return .secondary
        }
    }

    var body: some View {
        NavigationStack {
            List {
                titleSection
                dueDateSection
                prioritySection
                repeatSection
                notesSection
                completionSection
                deleteSection
            }
            .scrollIndicators(.hidden)
            .listStyle(.insetGrouped)
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: populateState)
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "An unexpected error occurred.")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        if hasChanges {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .confirmationDialog("Are you sure you want to discard your changes?", isPresented: $showDiscardAlert, titleVisibility: .visible) {
                        Button("Discard Changes", role: .destructive) {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        saveChanges()
                    }
                }
            }
        }
    }

    var titleSection: some View {
        Section {
            HStack(spacing: 14) {
                Button { toggleCompletion() } label: {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isCompleted ? .green : Color(.tertiaryLabel))
                }

                TextField("Title", text: $title)
                    .onChange(of: title) { hasChanges = true }
                    .strikethrough(isCompleted)
            }

        } header: { Text("Title") }
    }

    var dueDateSection: some View {
        Section {
            DatePicker(
                "Due Date",
                selection: Binding(
                    get: { dueDate ?? Date() },
                    set: {
                        dueDate = $0
                        hasChanges = true
                    }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }

    var prioritySection: some View {
        Section {
            Picker("Priority", selection: $priority) {
                Text("None").tag(0)
                Text("Low").tag(9)
                Text("Medium").tag(5)
                Text("High").tag(1)
            }
        }
    }

    var repeatSection: some View {
        Section {
            Picker("Repeat", selection: $repeatRule) {
                Text("Never").tag(RepeatRule.never)
                Divider()
                Text("Daily").tag(RepeatRule.daily)
                Text("Weekly").tag(RepeatRule.weekly)
                Text("Monthly").tag(RepeatRule.monthly)
                Divider()
                Text("Custom").tag(RepeatRule.custom)
            }

            if repeatRule == .custom {
                Picker("Frequency", selection: $repeatUnit) {
                    Text("Daily").tag(EKRecurrenceFrequency.daily)
                    Text("Weekly").tag(EKRecurrenceFrequency.weekly)
                    Text("Monthly").tag(EKRecurrenceFrequency.monthly)
                }

                HStack {
                    Text("Every")

                    Spacer()

                    TextField(
                        "",
                        text: Binding(
                            get: { String(repeatFrequency) },
                            set: { value in
                                repeatFrequency = Int(value) ?? 1
                            }
                        )
                    )
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                }
            }

            if repeatRule != .never {
                Section {
                    Picker("End Repeat", selection: $endRepeat) {
                        Text("Never").tag(EndRepeat.never)
                        Divider()
                        Text("On Date").tag(EndRepeat.onDate)
                    }

                    if endRepeat == .onDate {
                        DatePicker(
                            "End Date",
                            selection: Binding(
                                get: { endDate ?? Date() },
                                set: { endDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }
            }
        }
    }

    var notesSection: some View {
        Section("Notes") {
            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .onChange(of: notes) { hasChanges = true }
        }
    }

    var completionSection: some View {
        Section {
            Button {
                toggleCompletion()
            } label: {
                Label(
                    isCompleted ? "Mark as Incomplete" : "Mark as Completed",
                    systemImage: isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle"
                )
                .foregroundStyle(isCompleted ? .orange : .green)
            }
        }
    }

    var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete Reminder", systemImage: "trash")
            }
            .confirmationDialog("Delete Reminder? This action can not be undone.", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    deleteReminder()
                }
            }
        }
    }

    func populateState() {
        title = reminder.title ?? ""
        notes = reminder.notes ?? ""
        dueDate = reminder.dueDateComponents?.date
        priority = reminder.priority
        if let rules = reminder.recurrenceRules, let firstRule = rules.first {
            switch firstRule.frequency {
            case .daily: repeatRule = .daily
            case .weekly: repeatRule = .weekly
            case .monthly: repeatRule = .monthly
            default: repeatRule = .custom
            }

            if firstRule.interval > 1 {
                repeatRule = .custom
            }

            if repeatRule == .custom {
                repeatUnit = firstRule.frequency
                repeatFrequency = firstRule.interval

                if let end = firstRule.recurrenceEnd, let endDate = end.endDate {
                    endRepeat = .onDate
                    self.endDate = endDate
                } else {
                    endRepeat = .never
                }
            }
        } else {
            repeatRule = .never
        }
    }

    func saveChanges() {
        reminder.title = title
        reminder.notes = notes.isEmpty ? nil : notes
        reminder.priority = priority

        if let dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
        }

        switch repeatRule {
        case .never:
            reminder.recurrenceRules = nil
        case .custom:
            let rule = EKRecurrenceRule(
                recurrenceWith: repeatUnit,
                interval: repeatFrequency,
                end: endRepeat == .onDate ? EKRecurrenceEnd(end: endDate ?? Date()) : nil
            )
            reminder.recurrenceRules = [rule]

        default:
            let frequency: EKRecurrenceFrequency
            switch repeatRule {
            case .daily: frequency = .daily
            case .weekly: frequency = .weekly
            case .monthly: frequency = .monthly
            default: fatalError()
            }
            let rule = EKRecurrenceRule(
                recurrenceWith: frequency,
                interval: 1,
                end: endRepeat == .onDate ? EKRecurrenceEnd(end: endDate ?? Date()) : nil
            )
            reminder.recurrenceRules = [rule]
        }

        do {
            reminder = try eventKitHandler.updateReminder(reminder)
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
            return
        }

        dismiss()
    }

    func toggleCompletion() {
        do {
            let updatedReminder = try eventKitHandler.markReminder(complete: !isCompleted, reminder: reminder)
            performAnimated {
                reminder = updatedReminder
            }
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    func deleteReminder() {
        do {
            try eventKitHandler.deleteReminder(reminder)
            dismiss()
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    func performAnimated(_ action: () -> Void) {
        if reduceMotion {
            action()
        } else {
            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.85)) {
                action()
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: Editable State

    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate: Date?
    @State private var priority = 0

    @State private var repeatRule: RepeatRule = .never
    @State private var repeatFrequency = 1
    @State private var repeatUnit: EKRecurrenceFrequency = .weekly

    @State private var endRepeat: EndRepeat = .never
    @State private var endDate: Date?

    @State private var showDeleteConfirm = false
    @State private var showDiscardAlert = false
    @State private var hasChanges = false
    @State private var showErrorAlert = false
    @State private var alertMessage: String?

}
