//
//  TriTrackAddCalendarItemSheetView.swift
//  MomCare
//
//  Created by Aryan singh on 18/02/26.
//

import EventKit
import MapKit
import SwiftUI

struct TriTrackAddCalendarItemSheetView: View {

    // MARK: Internal

    @EnvironmentObject var eventKitHandler: EventKitHandler
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $mode) {
                    ForEach(AddMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)

                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes)
                }

                switch mode {
                case .appointment:
                    appointmentSection
                case .reminder:
                    reminderSection
                }
            }
            .navigationTitle("New")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Dismisses this screen without saving changes")
                    .accessibilityAddTraits(.isButton)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        Text("Save")
                    }
                    .disabled(title.isEmpty)
                    .accessibilityLabel("Save")
                    .accessibilityHint(
                        title.isEmpty ? "Enter a title to enable saving" : "Saves this item"
                    )
                    .accessibilityAddTraits(!title.isEmpty ? .isButton : [])
                }
            }
        }
        .presentationDetents([.medium, .large])
        .sheet(isPresented: $showMapPicker) {
            MapPickerView(selectedMapItem: $selectedMapItem)
                .presentationDetents([.medium])
        }
    }

    // MARK: Private

    @State private var mode: AddMode = .appointment

    @State private var title = ""
    @State private var notes = ""

    @State private var startDate: Date = .init()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var isAllDay = false
    @State private var recurrenceEnabled = false

    @State private var dueDate: Date = .init()
    @State private var selectedAlarmOffset: TimeInterval?

    @State private var selectedMapItem: MKMapItem?
    @State private var showMapPicker = false

    private var appointmentSection: some View {
        Group {
            Section("Schedule") {
                Toggle("All Day", isOn: $isAllDay)

                DatePicker("Start",
                           selection: $startDate,
                           displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])

                if !isAllDay {
                    DatePicker("End",
                               selection: $endDate,
                               displayedComponents: [.date, .hourAndMinute])
                }

                Toggle("Repeat Monthly", isOn: $recurrenceEnabled)
            }

            Section("Location") {
                Button {
                    showMapPicker = true
                } label: {
                    HStack {
                        Image(systemName: "map")
                        Text(selectedMapItem?.name ?? "Select Location")
                            .foregroundColor(selectedMapItem == nil ? .secondary : .primary)
                    }
                }
            }

            alarmSection
        }
    }

    private var reminderSection: some View {
        Group {
            Section("Due Date") {
                DatePicker("Remind Me On",
                           selection: $dueDate,
                           displayedComponents: [.date, .hourAndMinute])
            }

            Toggle("Repeat Monthly", isOn: $recurrenceEnabled)

            alarmSection
        }
    }

    private var alarmSection: some View {
        Section("Alert") {
            Picker("Alert Before", selection: $selectedAlarmOffset) {
                Text("None").tag(TimeInterval?.none)
                Text("15 minutes before").tag(TimeInterval(-900))
                Text("1 hour before").tag(TimeInterval(-3600))
                Text("1 day before").tag(TimeInterval(-86400))
            }
        }
    }

    private func save() {
        switch mode {
        case .appointment:
            var alarm: EKAlarm?
            if let offset = selectedAlarmOffset {
                alarm = EKAlarm(relativeOffset: offset)
            }

            var recurrenceRules: [EKRecurrenceRule]?
            if recurrenceEnabled {
                recurrenceRules = [EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)]
            }

            _ = try? eventKitHandler.createEvent(
                title: title,
                startDate: startDate,
                endDate: isAllDay ? startDate : endDate,
                isAllDay: isAllDay,
                notes: notes,
                recurrenceRules: recurrenceRules,
                location: selectedMapItem?.name,
                structuredLocaltion: selectedMapItem.map {
                    let loc = EKStructuredLocation(title: $0.name ?? "")
                    loc.geoLocation = $0.placemark.location
                    return loc
                },
                alarm: alarm
            )

        case .reminder:
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )

            var rules: [EKRecurrenceRule]?
            if recurrenceEnabled {
                rules = [EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)]
            }

            try? eventKitHandler.createReminder(
                title: title,
                notes: notes,
                dueDateComponents: components,
                recurrenceRules: rules
            )
        }

        dismiss()
    }
}
