import SwiftUI
import TipKit

struct WaterLogListView: View {
    // MARK: Internal

    @Binding var selectedDate: Date

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    summaryHeader
                    logSection
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(Color(hex: "FAE8E4").opacity(0.25))
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    MCAddButton {
                        showAddEntry = true
                    }
                }
            }
            .sheet(isPresented: $showAddEntry) {
                AddWaterEntrySheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $editingEntry) { entry in
                EditWaterEntrySheet(entry: entry)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentService: ContentServiceHandler

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var editingEntry: WaterLogEntry?
    @State private var showAddEntry = false

    private var navigationTitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "Water Intake - \(formatter.string(from: selectedDate))"
    }

    private var remaining: Double {
        let remaining = contentService.waterIntakeGoalInMilliliters - contentService.waterIntakeTodayInMilliliters
        return min(0, remaining)
    }

    private var accessibilityValue: String {
        let todayTotal = contentService.waterIntakeTodayInMilliliters
        let todayGoal = contentService.waterIntakeGoalInMilliliters

        return remaining <= 0 ? "Goal met. Drank \(formatMl(todayTotal)), goal \(formatMl(todayGoal))" : "Drank \(formatMl(todayTotal)), goal \(formatMl(todayGoal)), \(formatMl(remaining)) remaining"
    }

    private var summaryHeader: some View {
        HStack(spacing: 0) {
            statPill(icon: "drop.fill", label: "Drank", value: formatMl(contentService.waterIntakeTodayInMilliliters), color: Color(hex: "5B9BD5"))
            pillDivider
            statPill(icon: "target", label: "Goal", value: formatMl(contentService.waterIntakeGoalInMilliliters), color: Color(hex: "924350").opacity(0.65))
            pillDivider
            statPill(
                icon: remaining <= 0 ? "checkmark.circle.fill" : "arrow.up.circle.fill",
                label: remaining <= 0 ? "Done! 🌸" : "Left",
                value: remaining <= 0 ? "All good" : formatMl(remaining),
                color: remaining <= 0 ? .green : Color(hex: "924350")
            )
        }
        .padding(.vertical, 14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(hex: "924350").opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color(hex: "924350").opacity(0.05), radius: 8, x: 0, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "a11y_water_intake_summary_label"))
        .accessibilityValue(accessibilityValue)
    }

    private var pillDivider: some View {
        Divider()
            .frame(height: 36)
            .background(Color(hex: "924350").opacity(0.1))
            .accessibilityHidden(true)
    }

    private var logSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Entries")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(hex: "924350"))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text("\(contentService.queryWaterIntakeEntries.count) today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 2)

            VStack(spacing: 0) {
                ForEach(contentService.queryWaterIntakeEntries) { entry in
                    logRow(entry: entry)
                    if entry.id != contentService.queryWaterIntakeEntries.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(hex: "924350").opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color(hex: "924350").opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .onAppear {
            contentService.fetchWaterIntake(for: selectedDate)
        }
    }

    private func statPill(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.caption).foregroundStyle(color)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func logRow(entry: WaterLogEntry) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "EAF5FB"))
                    .frame(width: 34, height: 34)
                Image(systemName: "drop.fill")
                    .font(.footnote)
                    .foregroundStyle(Color(hex: "5B9BD5"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.formattedAmount)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(hex: "924350"))
                Text(entry.formattedDateTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "pencil")
                .font(.caption)
                .foregroundStyle(Color(.systemGray4))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.formattedAmount) at \(entry.formattedDateTime)")
        .accessibilityHint(String(localized: "a11y_edit_entry_hint"))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default) { editingEntry = entry }
        .onTapGesture { editingEntry = entry }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task { try? await contentService.deleteWaterIntake(entry) }
            } label: { Label("Delete", systemImage: "trash") }
        }
        .contextMenu {
            Button { editingEntry = entry } label: { Label("Edit", systemImage: "pencil") }
            Divider()
            Button(role: .destructive) {
                Task { try? await contentService.deleteWaterIntake(entry) }
            } label: { Label("Delete", systemImage: "trash") }
        }
    }

    private func formatMl(_ ml: Double) -> String {
        let measurement = ml >= 1000 ? Measurement(value: ml / 1000, unit: UnitVolume.liters) : Measurement(value: ml, unit: UnitVolume.milliliters)

        return measurement.formatted(.measurement(
                width: .abbreviated,
                numberFormatStyle: ml >= 1000
                    ? .number.precision(.fractionLength(1))
                    : .number.precision(.fractionLength(0))
            )
        )
    }
}

struct AddWaterEntrySheet: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            amountPanelView
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    HStack {
                        Text("Custom").foregroundStyle(.secondary)
                        TextField("e.g. 375", text: $customText)
                            .keyboardType(.numberPad)
                            .focused($focused)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: customText) { _, v in
                                if let d = Double(v) {
                                    amount = d
                                }
                            }
                        Text("ml").foregroundStyle(.secondary)
                    }
                }

                Section("Date & Time") {
                    DatePicker("When", selection: $selectedDate, in: ...Date(),
                               displayedComponents: [.date, .hourAndMinute])
                    .tint(Color(hex: "924350"))
                }

                Section {
                    HStack {
                        Spacer()
                        Text("Adding \(Int(amount)) ml")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Add Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(Color(hex: "924350"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            _ = try? await contentService.logWaterIntake(milliliters: amount, at: selectedDate)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "924350"))
                    .disabled(amount <= 0)
                }
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentService: ContentServiceHandler

    @Environment(\.dismiss) private var dismiss

    @State private var amount: Double = 250
    @State private var selectedDate: Date = .init()
    @State private var customText = ""
    @FocusState private var focused: Bool

    private let presets: [Double] = [150, 200, 250, 300, 500]

    private var amountPanelView: some View {
        ForEach(presets, id: \.self) { p in
            Button {
                amount = p
                customText = ""
            } label: {
                Text("\(Int(p))ml")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(amount == p ? .white : Color(hex: "924350"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(amount == p ? Color(hex: "924350") : Color(hex: "FAE8E4"),
                                in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(unsafe String(format: String(localized: "a11y_water_amount_ml_label"), Int(p)))
            .accessibilityAddTraits(amount == p ? .isSelected : [])
        }
    }
}

struct EditWaterEntrySheet: View {
    // MARK: Lifecycle

    init(entry: WaterLogEntry) {
        self.entry = entry
        _amount = State(initialValue: entry.milliliters)
        _selectedDate = State(initialValue: entry.date)
        _customText = State(initialValue: String(Int(entry.milliliters)))
    }

    // MARK: Internal

    let entry: WaterLogEntry

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    HStack {
                        Text("Millilitres").foregroundStyle(.secondary)
                        Spacer()
                        TextField("Amount", text: $customText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: customText) { _, v in if let d = Double(v) {
                                amount = d
                            } }
                        Text("ml").foregroundStyle(.secondary)
                    }
                }
                Section("Date & Time") {
                    DatePicker("When", selection: $selectedDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    MCSaveButton {
                        Task {
                            try? await contentService.deleteWaterIntake(entry)
                            _ = try? await contentService.logWaterIntake(milliliters: amount, at: selectedDate)
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentService: ContentServiceHandler
    @Environment(\.dismiss) private var dismiss

    @State private var amount: Double
    @State private var selectedDate: Date
    @State private var customText: String
}
