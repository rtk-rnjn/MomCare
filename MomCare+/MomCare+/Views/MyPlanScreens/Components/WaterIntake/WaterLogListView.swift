import SwiftUI
import TipKit

struct WaterLogListView: View {

    // MARK: Internal

    @ObservedObject var store: WaterStore

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    summaryHeader
                    tipsSection
                    logSection
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(Color(hex: "FAE8E4").opacity(0.25))
            .navigationTitle("Today's Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddEntry = true
                    } label: {
                        Label("Add Water Entry", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddEntry) {
                AddWaterEntrySheet(store: store)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $editingEntry) { entry in
                EditWaterEntrySheet(store: store, entry: entry)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                tipIndex = Int.random(in: 0..<WaterStore.waterTips.count)
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var editingEntry: WaterLogEntry?
    @State private var showAddEntry = false
    @State private var tipIndex = 0
    @State private var quoteIndex = 0

    private var summaryHeader: some View {
        HStack(spacing: 0) {
            statPill(icon: "drop.fill", label: "Drank", value: formatMl(store.todayTotal), color: Color(hex: "5B9BD5"))
            pillDivider
            statPill(icon: "target", label: "Goal", value: formatMl(store.dailyTarget), color: Color(hex: "924350").opacity(0.65))
            pillDivider
            statPill(
                icon: store.remaining <= 0 ? "checkmark.circle.fill" : "arrow.up.circle.fill",
                label: store.remaining <= 0 ? "Done! 🌸" : "Left",
                value: store.remaining <= 0 ? "All good" : formatMl(store.remaining),
                color: store.remaining <= 0 ? .green : Color(hex: "924350")
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
        .accessibilityLabel("Water intake summary")
        .accessibilityValue(
            store.remaining <= 0
                ? "Goal met. Drank \(formatMl(store.todayTotal)), goal \(formatMl(store.dailyTarget))"
                : "Drank \(formatMl(store.todayTotal)), goal \(formatMl(store.dailyTarget)), \(formatMl(store.remaining)) remaining"
        )
    }

    private var pillDivider: some View {
        Divider().frame(height: 36).background(Color(hex: "924350").opacity(0.1))
            .accessibilityHidden(true)
    }

    private var tipsSection: some View {
        VStack(spacing: 8) {

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(Color(hex: "924350").opacity(0.65))
                    .font(.subheadline)
                    .padding(.top, 1)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                reduceTransparency ? Color(hex: "FAE8E4") : Color(hex: "FAE8E4").opacity(0.55),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityElement(children: .combine)

            let tip = WaterStore.waterTips[tipIndex]
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: tip.icon)
                    .foregroundColor(Color(hex: "5B9BD5"))
                    .font(.subheadline)
                    .frame(width: 20)
                    .padding(.top, 1)
                    .accessibilityHidden(true)
                Text(tip.tip)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "EAF5FB"),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityElement(children: .combine)
        }
    }

    private var logSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Entries")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(hex: "924350"))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text("\(store.todayLogs.count) today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 2)

            if store.todayLogs.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(store.todayLogs) { entry in
                        logRow(entry: entry)
                        if entry.id != store.todayLogs.last?.id {
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
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "drop.slash")
                .font(.largeTitle.weight(.ultraLight))
                .foregroundStyle(Color(hex: "B8DCF0"))
                .accessibilityHidden(true)
            Text("Nothing logged yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Use the quick-add buttons on the main screen\nto start tracking your intake.")
                .font(.caption)
                .foregroundStyle(Color(.systemGray3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(36)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func statPill(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.caption).foregroundColor(color)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundColor(color)
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
                    .foregroundColor(Color(hex: "5B9BD5"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.formattedAmount)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(hex: "924350"))
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
        .accessibilityHint("Double tap to edit")
        .accessibilityAddTraits(.isButton)
        .onTapGesture { editingEntry = entry }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task { await store.delete(entry: entry) }
            } label: { Label("Delete", systemImage: "trash") }
        }
        .contextMenu {
            Button { editingEntry = entry } label: { Label("Edit", systemImage: "pencil") }
            Divider()
            Button(role: .destructive) {
                Task { await store.delete(entry: entry) }
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

    @ObservedObject var store: WaterStore

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(presets, id: \.self) { p in
                                Button {
                                    amount = p
                                    customText = ""
                                } label: {
                                    Text("\(Int(p))ml")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(amount == p ? .white : Color(hex: "924350"))
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(amount == p ? Color(hex: "924350") : Color(hex: "FAE8E4"),
                                                    in: Capsule())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(Int(p)) millilitres")
                                .accessibilityAddTraits(amount == p ? .isSelected : [])
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    HStack {
                        Text("Custom").foregroundStyle(.secondary)
                        TextField("e.g. 375", text: $customText)
                            .keyboardType(.numberPad).focused($focused).multilineTextAlignment(.trailing)
                            .onChange(of: customText) { _, v in if let d = Double(v) { amount = d } }
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
                            .font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Add Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(Color(hex: "924350"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await store.log(milliliters: amount, at: selectedDate)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold).foregroundColor(Color(hex: "924350")).disabled(amount <= 0)
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    @State private var amount: Double = 250
    @State private var selectedDate: Date = .init()
    @State private var customText = ""
    @FocusState private var focused: Bool

    private let presets: [Double] = [150, 200, 250, 300, 500]

}

struct EditWaterEntrySheet: View {

    // MARK: Lifecycle

    init(store: WaterStore, entry: WaterLogEntry) {
        self.store = store
        self.entry = entry
        _amount = State(initialValue: entry.milliliters)
        _selectedDate = State(initialValue: entry.date)
        _customText = State(initialValue: String(Int(entry.milliliters)))
    }

    // MARK: Internal

    @ObservedObject var store: WaterStore

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
                            .onChange(of: customText) { _, v in if let d = Double(v) { amount = d } }
                        Text("ml").foregroundStyle(.secondary)
                    }
                }
                Section("Date & Time") {
                    DatePicker("When", selection: $selectedDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        Task {
                            await store.delete(entry: entry)
                            await store.log(milliliters: amount, at: selectedDate)
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    @State private var amount: Double
    @State private var selectedDate: Date
    @State private var customText: String

}
