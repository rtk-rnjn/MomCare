import SwiftUI

struct MedicationView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CompactCalendarView(selectedDate: $selectedDate, isExpanded: $controlState.showingExpandedCalendar)
                ContentUnavailableView.search
            }
            .sheet(isPresented: $showAddMedicationView) {
                AddMedicationView()
            }
            .navigationTitle("Medications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton {
                        dismiss()
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        withAnimation(reduceMotion ? nil : .easeInOut) {
                            controlState.showingExpandedCalendar.toggle()
                        }
                    } label: {
                        Image(systemName: "calendar")
                            .font(.body)
                            .foregroundStyle(Color.CustomColors.mutedRaspberry)
                            .symbolEffect(.bounce, value: controlState.showingExpandedCalendar)
                    }
                    .accessibilityLabel(controlState.showingExpandedCalendar ? String(localized: "a11y_collapse_calendar_label") : String(localized: "a11y_expand_calendar_label"))
                    .accessibilityIdentifier("expandCalendarButton")

                    Button {
                        selectedDate = Date()
                    } label: {
                        Label {
                            Text("Today")
                        } icon: {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "\(Calendar.current.component(.day, from: Date())).calendar")
                            }
                        }
                    }
                    .accessibilityLabel(String(localized: "a11y_jump_to_today_label"))
                    .accessibilityIdentifier("jumpToTodayButton")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    MCAddButton {
                        showAddMedicationView = true
                    }
                }
            }
        }
    }

    // MARK: Private

    @State private var selectedDate: Date = .init()
    @State private var showAddMedicationView: Bool = false
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

struct AddMedicationView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("e.g., Paracetamol", text: $medicationName)
                        .focused($isMedicationNameFocused)
                        .onAppear {
                            isMedicationNameFocused = true
                        }
                } header: {
                    Text("Medication Name")
                        .font(.headline)
                } footer: {
                    Text("Try to be specific with the medication name, it will help for better logging and insights.")
                        .font(.footnote)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { name in
                MedicationTypeSelectionView(medicationName: name)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    NavigationLink(value: medicationName) {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(MomCareAccent.primary)
                    .controlSize(.large)
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @State private var medicationName: String = ""
    @FocusState private var isMedicationNameFocused: Bool
}

struct MedicationTypeSelectionView: View {
    let medicationName: String

    var body: some View {
        Form {
            Section {
                ForEach(MedicationForm.allCases) { form in
                    NavigationLink(value: form) {
                        Label(form.displayName, systemImage: form.symbol)
                    }
                }
            } header: {
                Text("Select Medication Type")
                    .font(.headline)
            } footer: {
                Text("Choose the type of medication you are taking.")
                    .font(.footnote)
            }
        }
        .navigationDestination(for: MedicationForm.self) { form in
            AddMedicationStrengthView(medicationName: medicationName, medicationForm: form)
        }
        .navigationTitle("Medication Type")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddMedicationStrengthView: View {
    // MARK: Internal

    let medicationName: String
    let medicationForm: MedicationForm

    var body: some View {
        Form {
            Section {
                TextField("Add Stregnth", text: $strength)
                    .focused($isStrengthFieldFocused)
                    .keyboardType(.numberPad)
                    .submitLabel(.done)
                    .onSubmit {
                        isStrengthFieldFocused = false
                    }
                    .onAppear {
                        isStrengthFieldFocused = true
                    }
            } header: {
                Text("Strength")
                    .font(.headline)
            }

            Section {
                ForEach(MedicationStrengthUnit.allCases) { unit in
                    Button {
                        selectedUnit = unit
                    } label: {
                        Label {
                            Text(unit.rawValue)
                        } icon: {
                            if selectedUnit == unit {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Add Strength")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showMedicationScheduleView) {
            AddMedicationScheduleView(
                medicationName: medicationName,
                medicationForm: medicationForm,
                strength: strength,
                strengthUnit: selectedUnit
            )
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Next") {
                    showMedicationScheduleView = true
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(MomCareAccent.primary)
                .controlSize(.large)
            }
        }
    }

    // MARK: Private

    @State private var strength: String = ""
    @State private var selectedUnit: MedicationStrengthUnit = .mg
    @State private var showMedicationScheduleView: Bool = false

    @FocusState private var isStrengthFieldFocused: Bool
}

struct AddMedicationScheduleView: View {
    // MARK: Internal

    let medicationName: String
    let medicationForm: MedicationForm
    let strength: String
    let strengthUnit: MedicationStrengthUnit

    var body: some View {
        Form {
            Section {
                ForEach(MedicationScheduleType.allCases) { type in
                    Button {
                        withAnimation {
                            scheduleType = type
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.rawValue)
                                    .foregroundStyle(.primary)
                                Text(type.help)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if scheduleType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.quaternary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("When will you take this?")
            }

            if scheduleType != .asNeeded {
                scheduleTypeView

                Section {
                    ForEach(times.indices, id: \.self) { index in
                        DatePicker(
                            "Dose \(index + 1)",
                            selection: $times[index],
                            displayedComponents: .hourAndMinute
                        )
                    }
                    .onDelete { indexSet in
                        guard times.count > 1 else {
                            return
                        }

                        times.remove(atOffsets: indexSet)
                    }

                    Button {
                        let lastTime = times.last ?? Date()
                        let nextTime = Calendar.current.date(byAdding: .hour, value: 8, to: lastTime) ?? lastTime
                        times.append(nextTime)
                    } label: {
                        Label("Add Time", systemImage: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                } header: {
                    Text("Time\(times.count > 1 ? "s" : "")")
                } footer: {
                    Text("Swipe left on a time to remove it.")
                        .font(.caption)
                }

                Section {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)

                    Toggle("Set End Date", isOn: $hasEndDate)

                    if hasEndDate {
                        DatePicker(
                            "End Date",
                            selection: $endDate,
                            in: startDate...,
                            displayedComponents: .date
                        )
                    }
                } header: {
                    Text("Duration")
                }
            }
        }
        .navigationTitle("Set a Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if scheduleType != .asNeeded {
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink {
                        MedicationReviewView(
                            medicationName: medicationName,
                            medicationForm: medicationForm,
                            strength: strength,
                            strengthUnit: strengthUnit,
                            interval: buildInterval()
                        )
                    } label: {
                        Text("Review")
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(MomCareAccent.primary)
                    .controlSize(.large)
                }
            } else {
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink {
                        MedicationReviewView(
                            medicationName: medicationName,
                            medicationForm: medicationForm,
                            strength: strength,
                            strengthUnit: strengthUnit,
                            interval: .asNeeded
                        )
                    } label: {
                        Text("Review")
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(MomCareAccent.primary)
                    .controlSize(.large)
                }
            }
        }
    }

    // MARK: Private

    @State private var scheduleType: MedicationScheduleType = .everyDay
    @State private var times: [Date] = [Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()]
    @State private var selectedDaysOfWeek: Set<Int> = [2, 3, 4, 5, 6] // Mon–Fri
    @State private var daysOn: Int = 21
    @State private var daysOff: Int = 7
    @State private var dayInterval: Int = 2
    @State private var startDate: Date = .init()
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var hasEndDate: Bool = false

    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    private var selectedDaysOfWeekSummary: String {
        let sorted = selectedDaysOfWeek.sorted()
        let names = sorted.map { weekdaySymbols[$0 - 1] }
        return names.formatted(.list(type: .and))
    }

    @ViewBuilder
    private var scheduleTypeView: some View {
        switch scheduleType {
        case .everyDay:
            EmptyView()

        case .specificDaysOfWeek:
            Section {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(1...7, id: \.self) { day in
                        let isSelected = selectedDaysOfWeek.contains(day)
                        Button {
                            if isSelected {
                                guard selectedDaysOfWeek.count > 1 else {
                                    return
                                }

                                selectedDaysOfWeek.remove(day)
                            } else {
                                selectedDaysOfWeek.insert(day)
                            }
                        } label: {
                            Text(weekdaySymbols[day - 1].prefix(1))
                                .font(.system(size: 14, weight: .medium))
                                .frame(width: 36, height: 36)
                                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                                .foregroundStyle(isSelected ? .white : .primary)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Days of the Week")
            } footer: {
                Text(selectedDaysOfWeekSummary)
                    .font(.caption)
            }

        case .cyclicalSchedule:
            Section {
                Stepper("Days on: \(daysOn)", value: $daysOn, in: 1...365)
                Stepper("Days off: \(daysOff)", value: $daysOff, in: 1...365)
            } header: {
                Text("Cycle")
            } footer: {
                Text("Take for \(daysOn) day\(daysOn == 1 ? "" : "s"), then pause for \(daysOff) day\(daysOff == 1 ? "" : "s"), and repeat.")
                    .font(.caption)
            }

        case .specificDays:
            Section {
                Stepper(
                    dayInterval == 2 ? "Every other day" : "Every \(dayInterval) days",
                    value: $dayInterval,
                    in: 2...30
                )
            } header: {
                Text("Interval")
            } footer: {
                Text("Take once every \(dayInterval) days starting from the start date.")
                    .font(.caption)
            }

        case .asNeeded:
            EmptyView()
        }
    }

    private func buildInterval() -> MedicationInterval {
        let timesAsComponents: [DateComponents] = times.map {
            Calendar.current.dateComponents([.hour, .minute], from: $0)
        }
        let end = hasEndDate ? endDate : nil

        switch scheduleType {
        case .everyDay:
            return .everyDay(times: timesAsComponents, startDate: startDate, endDate: end)

        case .cyclicalSchedule:
            return .cyclical(
                CyclicalSchedule(daysOn: daysOn, daysOff: daysOff),
                times: timesAsComponents,
                startDate: startDate,
                endDate: end
            )

        case .specificDaysOfWeek:
            return .specificDaysOfWeek(selectedDaysOfWeek, times: timesAsComponents, startDate: startDate, endDate: end)

        case .specificDays:
            return .specificDays(DayInterval(every: dayInterval), times: timesAsComponents, startDate: startDate, endDate: end)

        case .asNeeded:
            return .asNeeded
        }
    }
}

struct MedicationReviewView: View {
    // MARK: Internal

    let medicationName: String
    let medicationForm: MedicationForm
    let strength: String
    let strengthUnit: MedicationStrengthUnit
    let interval: MedicationInterval

    var body: some View {
        Form {
            Section("Medication") {
                LabeledContent("Name", value: medicationName)
                LabeledContent("Form", value: medicationForm.displayName)
                if !strength.isEmpty {
                    LabeledContent("Strength", value: "\(strength) \(strengthUnit.rawValue)")
                }
            }

            Section("Schedule") {
                LabeledContent("Type", value: interval.scheduleType.rawValue)

                if let times = interval.times, !times.isEmpty {
                    LabeledContent("Time\(times.count > 1 ? "s" : "")") {
                        VStack(alignment: .trailing, spacing: 2) {
                            ForEach(times.indices, id: \.self) { i in
                                if let date = Calendar.current.date(from: times[i]) {
                                    Text(date, style: .time)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }

                if let start = interval.startDate {
                    LabeledContent("Starts", value: start.formatted(date: .abbreviated, time: .omitted))
                }

                if let end = interval.endDate {
                    LabeledContent("Ends", value: end.formatted(date: .abbreviated, time: .omitted))
                }

                if let cyclical = interval.cyclicalSchedule {
                    LabeledContent("Cycle", value: "\(cyclical.daysOn) on / \(cyclical.daysOff) off")
                }

                if let days = interval.daysOfWeek {
                    let symbols = Calendar.current.shortWeekdaySymbols
                    let names = days.sorted().map { symbols[$0 - 1] }.formatted(.list(type: .and))
                    LabeledContent("Days", value: names)
                }

                if let di = interval.dayInterval {
                    LabeledContent("Interval", value: di.every == 2 ? "Every other day" : "Every \(di.every) days")
                }
            }

            Section("Details") {
                TextField("Nickname (optional)", text: $medicineNickName)

                TextField("Notes (optional)", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    // Save medication and dismiss the entire sheet
                    dismiss()
                } label: {
                    Text("Save Medication")
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(MomCareAccent.primary)
                .controlSize(.large)
            }
        }
    }

    // MARK: Private

    @State private var medicineNickName: String = ""
    @State private var notes: String = ""

    @Environment(\.dismiss) private var dismiss
}
