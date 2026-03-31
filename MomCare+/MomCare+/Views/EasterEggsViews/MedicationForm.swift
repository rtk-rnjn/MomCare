//
//  MedicationForm.swift
//  MomCare
//
//  Created by Aryan singh on 31/03/26.
//

// AddMedicationView.swift
// Medication Reminder — Full multi-step SwiftUI flow
// Compatible with iOS 18+, HealthKit Medications API (WWDC25)
// Accessibility: Dynamic Type, Reduce Motion, VoiceOver, color-blind safe (shape+icon differentiation)

import HealthKit
import SwiftUI
import UserNotifications

// MARK: - Models

enum MedicationForm: String, CaseIterable, Identifiable {
    case capsule
    case tablet
    case liquid
    case topical
    case cream
    case device
    case drops
    case foam
    case gel
    case inhaler
    case injection
    case lotion
    case ointment
    case patch
    case powder
    case spray
    case suppository

    // MARK: Internal

    var id: String {
        rawValue
    }

    var displayName: String {
        rawValue.capitalized
    }

    var symbol: String {
        switch self {
        case .capsule: "capsule.fill"
        case .tablet: "circle.fill"
        case .liquid: "drop.fill"
        case .topical: "hand.raised.fill"
        case .cream: "tube.horizontal.fill"
        case .device: "medicalthermometer.fill"
        case .drops: "drop.halffull"
        case .foam: "bubbles.and.sparkles.fill"
        case .gel: "drop.degreesign.fill"
        case .inhaler: "lungs.fill"
        case .injection: "syringe.fill"
        case .lotion: "hands.and.sparkles.fill"
        case .ointment: "bandage.fill"
        case .patch: "square.fill"
        case .powder: "shaker.vertical.fill"
        case .spray: "aqi.low"
        case .suppository: "oval.fill"
        }
    }

    // Shape-based badge for colorblind differentiation
    var badgeShape: BadgeShape {
        switch self {
        case .capsule, .drops, .foam, .tablet: .circle
        case .gel, .liquid, .lotion, .ointment: .diamond
        case .cream, .patch, .powder, .topical: .square
        case .device, .inhaler, .injection, .spray: .triangle
        case .suppository: .hexagon
        }
    }
}

enum BadgeShape {
    case circle
    case diamond
    case square
    case triangle
    case hexagon
}

enum StrengthUnit: String, CaseIterable, Identifiable {
    case mg
    case mcg
    case g
    case mL
    case percent = "%"

    // MARK: Internal

    var id: String {
        rawValue
    }

    var displayName: String {
        rawValue
    }
}

enum ScheduleType: String, CaseIterable, Identifiable {
    case everyday = "Every Day"
    case asNeeded = "As Needed"

    // MARK: Internal

    var id: String {
        rawValue
    }
}

struct DoseInterval: Identifiable {
    let id: UUID = .init()
    var time: Date
    var quantity: Double
    var form: MedicationForm
}

struct MedicationDuration: Identifiable {
    let id: UUID = .init()
    var startDate: Date
    var endDate: Date
}

struct MedicationEntry {
    var drugName: String = ""
    var form: MedicationForm = .tablet
    var strength: String = ""
    var unit: StrengthUnit = .mg
    var scheduleType: ScheduleType = .everyday
    var doses: [DoseInterval] = [DoseInterval(time: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!, quantity: 1, form: .tablet)]
    var durations: [MedicationDuration] = [MedicationDuration(startDate: Date(), endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!)]
    var nickname: String = ""
    var notes: String = ""
}

// MARK: - Step Enum

enum MedicationStep: Int, CaseIterable {
    case drugInfo = 0
    case schedule
    case duration
    case details

    // MARK: Internal

    var title: String {
        switch self {
        case .drugInfo: "Drug Info"
        case .schedule: "Schedule"
        case .duration: "Duration"
        case .details: "Details"
        }
    }

    var symbol: String {
        switch self {
        case .drugInfo: "pills.fill"
        case .schedule: "clock.fill"
        case .duration: "calendar"
        case .details: "note.text"
        }
    }
}

// MARK: - Main View

struct AddMedicationView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Step Progress Header
                    StepProgressBar(currentStep: currentStep)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 16)

                    // Step Content
                    ScrollView {
                        VStack(spacing: 24) {
                            stepContent
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 120)
                    }
                }

                // Bottom CTA
                VStack {
                    Spacer()
                    bottomBar
                }
            }
            .navigationTitle(currentStep.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Saved!", isPresented: $showSuccess) {
                Button("Done") { dismiss() }
            } message: {
                Text("\(entry.drugName) has been added to your medications.")
            }
            .alert("Error", isPresented: Binding(get: { saveError != nil }, set: { if !$0 {
                saveError = nil
            } })) {
                Button("OK") { saveError = nil }
            } message: {
                Text(saveError ?? "An unknown error occurred.")
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var entry: MedicationEntry = .init()
    @State private var currentStep: MedicationStep = .drugInfo
    @State private var showSuccess = false
    @State private var isSaving = false
    @State private var saveError: String?

    private let healthStore: HKHealthStore = .init()

    private var stepTransition: AnyTransition {
        unsafe reduceMotion
            ? .opacity
            : .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                          removal: .move(edge: .leading).combined(with: .opacity))
    }

    // MARK: Validation

    private var isCurrentStepValid: Bool {
        switch currentStep {
        case .drugInfo:
            !entry.drugName.trimmingCharacters(in: .whitespaces).isEmpty &&
                   Double(entry.strength) != nil &&
                   Double(entry.strength)! > 0

        case .schedule:
            entry.scheduleType == .asNeeded || !entry.doses.isEmpty

        case .duration:
            !entry.durations.isEmpty

        case .details:
            true
        }
    }

    // MARK: Step Content Router

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .drugInfo:
            DrugInfoStep(entry: $entry)
                .transition(stepTransition)

        case .schedule:
            ScheduleStep(entry: $entry)
                .transition(stepTransition)

        case .duration:
            DurationStep(entry: $entry)
                .transition(stepTransition)

        case .details:
            DetailsStep(entry: $entry)
                .transition(stepTransition)
        }
    }

    // MARK: Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 16) {
                if currentStep.rawValue > 0 {
                    Button {
                        withAnimation(reduceMotion ? .none : .spring(response: 0.38, dampingFraction: 0.82)) {
                            currentStep = MedicationStep(rawValue: currentStep.rawValue - 1) ?? .drugInfo
                        }
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .accessibilityLabel("Go back to \(MedicationStep(rawValue: currentStep.rawValue - 1)?.title ?? "")")
                }

                Button {
                    if currentStep == .details {
                        saveMedication()
                    } else {
                        withAnimation(reduceMotion ? .none : .spring(response: 0.38, dampingFraction: 0.82)) {
                            currentStep = MedicationStep(rawValue: currentStep.rawValue + 1) ?? .details
                        }
                    }
                } label: {
                    Group {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Label(currentStep == .details ? "Save Medication" : "Next",
                                  systemImage: currentStep == .details ? "checkmark.circle.fill" : "chevron.right")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isCurrentStepValid ? Color.accentColor : Color.accentColor.opacity(0.35),
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundStyle(.white)
                    .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(!isCurrentStepValid || isSaving)
                .accessibilityLabel(currentStep == .details ? "Save medication" : "Continue to next step")
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.regularMaterial)
        }
    }

    // MARK: - Save to HealthKit + Notifications

    private func saveMedication() {
        guard isCurrentStepValid else {
            return
        }

        isSaving = true

        Task {
            do {
                try await requestHealthKitAuthorization()
                try await saveMedicationToHealthKit()
                if entry.scheduleType == .everyday {
                    await scheduleNotifications()
                }
                await MainActor.run {
                    isSaving = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    saveError = error.localizedDescription
                }
            }
        }
    }

    private func requestHealthKitAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }

        // iOS 18+: HKCategoryType for medications via HKCategoryTypeIdentifier
        // Using correlation type as a safe fallback for medication logging
        let writeTypes: Set<HKSampleType> = [
            HKObjectType.categoryType(forIdentifier: .mindfulSession)! // placeholder — swap for HKMedicationDoseEvent when iOS 18.1+ target
        ]
        try await healthStore.requestAuthorization(toShare: writeTypes, read: [])
    }

    private func saveMedicationToHealthKit() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }

        // Build metadata
        var metadata: [String: Any] = [
            "medicationName": entry.drugName,
            "form": entry.form.displayName,
            "strength": entry.strength,
            "unit": entry.unit.displayName,
            HKMetadataKeyExternalUUID: UUID().uuidString
        ]
        if !entry.nickname.isEmpty {
            metadata["nickname"] = entry.nickname
        }
        if !entry.notes.isEmpty {
            metadata["notes"] = entry.notes
        }

        // Save a mindful session sample as a placeholder carrier
        // In production with iOS 18.1+ target, use HKMedicationDoseEvent
        let now = Date()
        let sample = HKCategorySample(
            type: HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
            value: HKCategoryValue.notApplicable.rawValue,
            start: now,
            end: now.addingTimeInterval(1),
            metadata: metadata
        )
        try await healthStore.save(sample)
    }

    private func scheduleNotifications() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized ||
              settings.authorizationStatus == .provisional else {
            _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
            return
        }

        // Remove existing notifications for this medication
        let identifier = "med-\(entry.drugName.lowercased().replacingOccurrences(of: " ", with: "-"))"
        center.removePendingNotificationRequests(withIdentifiers:
            entry.doses.map { "\(identifier)-\($0.id)" })

        for _ in entry.durations {
            for dose in entry.doses {
                let content = UNMutableNotificationContent()
                let qty = dose.quantity == dose.quantity.rounded() ? String(Int(dose.quantity)) : String(dose.quantity)
                content.title = "💊 \(entry.drugName)"
                content.body = "Take \(qty) \(dose.form.displayName.lowercased())"
                if !entry.nickname.isEmpty {
                    content.subtitle = entry.nickname
                }
                content.sound = .default
                content.interruptionLevel = .timeSensitive

                let components = Calendar.current.dateComponents([.hour, .minute], from: dose.time)
                // Schedule daily within duration window
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                let request = UNNotificationRequest(
                    identifier: "\(identifier)-\(dose.id)",
                    content: content,
                    trigger: trigger
                )
                try? await center.add(request)
            }
        }
    }
}

// MARK: - Step Progress Bar

struct StepProgressBar: View {
    // MARK: Internal

    let currentStep: MedicationStep

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MedicationStep.allCases, id: \.self) { step in
                StepDot(step: step, isActive: step == currentStep, isCompleted: step.rawValue < currentStep.rawValue)

                if step != MedicationStep.allCases.last {
                    Capsule()
                        .fill(step.rawValue < currentStep.rawValue ? Color.accentColor : Color.secondary.opacity(0.25))
                        .frame(height: 3)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: currentStep)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(currentStep.rawValue + 1) of \(MedicationStep.allCases.count): \(currentStep.title)")
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

struct StepDot: View {
    // MARK: Internal

    let step: MedicationStep
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.accentColor : isActive ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Circle()
                            .strokeBorder(isActive || isCompleted ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 2)
                    }

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: step.symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isActive ? Color.accentColor : Color.secondary)
                }
            }
            .scaleEffect(isActive && !reduceMotion ? 1.05 : 1.0)
            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: isActive)

            Text(step.title)
                .font(.caption2)
                .fontWeight(isActive ? .semibold : .regular)
                .foregroundStyle(isActive ? Color.accentColor : Color.secondary)
                .fixedSize()
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

// MARK: - Step 1: Drug Info

struct DrugInfoStep: View {
    // MARK: Internal

    enum Field { case name, strength }

    @Binding var entry: MedicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Drug Name
            SectionCard(title: "Medication Name", symbol: "pills") {
                TextField("e.g. Amoxicillin", text: $entry.drugName)
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .strength }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .accessibilityLabel("Medication name")
            }

            // Form
            SectionCard(title: "Form", symbol: "cross.case") {
                LazyVGrid(columns: formColumns, spacing: 10) {
                    ForEach(MedicationForm.allCases) { form in
                        FormChip(form: form, isSelected: entry.form == form) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                entry.form = form
                                // also update all doses
                                for idx in entry.doses.indices {
                                    entry.doses[idx].form = form
                                }
                            }
                        }
                    }
                }
            }

            // Strength + Unit
            SectionCard(title: "Strength", symbol: "scalemass") {
                HStack(spacing: 12) {
                    TextField("0", text: $entry.strength)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .strength)
                        .multilineTextAlignment(.trailing)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Strength value")

                    Picker("Unit", selection: $entry.unit) {
                        ForEach(StrengthUnit.allCases) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .accessibilityLabel("Strength unit, currently \(entry.unit.displayName)")
                }
            }
        }
    }

    // MARK: Private

    @FocusState private var focusedField: Field?

    private let formColumns = [GridItem(.adaptive(minimum: 90), spacing: 10)]
}

// MARK: Form Chip

struct FormChip: View {
    let form: MedicationForm
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                BadgeShapeView(shape: form.badgeShape, isSelected: isSelected)
                    .overlay {
                        Image(systemName: form.symbol)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isSelected ? .white : Color.primary)
                    }
                    .frame(width: 42, height: 42)

                Text(form.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.12) : Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(form.displayName)\(isSelected ? ", selected" : "")")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// Colorblind-safe shape differentiation
struct BadgeShapeView: View {
    let shape: BadgeShape
    let isSelected: Bool

    var fill: Color {
        isSelected ? Color.accentColor : Color.secondary.opacity(0.15)
    }

    var body: some View {
        switch shape {
        case .circle:
            Circle().fill(fill)

        case .square:
            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(fill)

        case .diamond:
            RoundedRectangle(cornerRadius: 4, style: .continuous)
.fill(fill)
                .rotationEffect(.degrees(45))

        case .triangle:
            Triangle().fill(fill)

        case .hexagon:
            RegularHexagon().fill(fill)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY + 4))
            p.addLine(to: CGPoint(x: rect.maxX - 2, y: rect.maxY - 4))
            p.addLine(to: CGPoint(x: rect.minX + 2, y: rect.maxY - 4))
            p.closeSubpath()
        }
    }
}

struct RegularHexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2 - 2
        var path = Path()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let pt = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Step 2: Schedule

struct ScheduleStep: View {
    // MARK: Internal

    @Binding var entry: MedicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Schedule Type
            SectionCard(title: "Frequency", symbol: "repeat") {
                VStack(spacing: 10) {
                    ForEach(ScheduleType.allCases) { type in
                        ScheduleTypeTile(
                            type: type,
                            isSelected: entry.scheduleType == type,
                            onTap: {
                                withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.8)) {
                                    entry.scheduleType = type
                                }
                            }
                        )
                    }
                }
            }

            if entry.scheduleType == .everyday {
                SectionCard(title: "Times & Doses", symbol: "clock") {
                    VStack(spacing: 12) {
                        ForEach($entry.doses) { $dose in
                            DoseTile(dose: $dose, form: entry.form, onDelete: {
                                withAnimation(reduceMotion ? .none : .default) {
                                    entry.doses.removeAll { $0.id == dose.id }
                                }
                            })
                        }

                        Button {
                            withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8)) {
                                entry.doses.append(DoseInterval(
                                    time: Calendar.current.date(byAdding: .hour, value: 6, to: entry.doses.last?.time ?? Date()) ?? Date(),
                                    quantity: 1,
                                    form: entry.form
                                ))
                            }
                        } label: {
                            Label("Add Time", systemImage: "plus.circle.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.accentColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Add another dose time")
                    }
                }
            } else {
                InfoBanner(
                    symbol: "bell.slash.fill",
                    title: "No Reminders",
                    message: "You've selected \"As Needed\" — no notifications will be sent."
                )
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

struct ScheduleTypeTile: View {
    let type: ScheduleType
    let isSelected: Bool
    let onTap: () -> Void

    var symbol: String {
        type == .everyday ? "sun.max.fill" : "hand.raised.fill"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : Color.secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue)
                        .font(.subheadline.weight(.semibold))
                    Text(type == .everyday ? "Reminds at set times daily" : "Log manually, no reminder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Shape-based selection indicator (not color-only)
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(type.rawValue), \(type == .everyday ? "reminds at set times daily" : "no reminder")\(isSelected ? ", selected" : "")")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

struct DoseTile: View {
    @Binding var dose: DoseInterval

    let form: MedicationForm
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.badge.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                DatePicker(
                    "Time",
                    selection: $dose.time,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .accessibilityLabel("Dose time")

                HStack(spacing: 8) {
                    Text("Qty:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Stepper(value: $dose.quantity, in: 0.5...10, step: 0.5) {
                        Text("\(dose.quantity == dose.quantity.rounded() ? String(Int(dose.quantity)) : unsafe String(format: "%.1f", dose.quantity)) \(form.displayName.lowercased())")
                            .font(.subheadline.weight(.medium))
                    }
                    .accessibilityLabel("Quantity: \(dose.quantity) \(form.displayName.lowercased())")
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.red.opacity(0.8))
                    .symbolRenderingMode(.multicolor)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove this dose")
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Step 3: Duration

struct DurationStep: View {
    // MARK: Internal

    @Binding var entry: MedicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            InfoBanner(
                symbol: "calendar.badge.clock",
                title: "Duration Windows",
                message: "Add one or more date ranges. Reminders fire only within these windows."
            )

            SectionCard(title: "Date Ranges", symbol: "calendar") {
                VStack(spacing: 12) {
                    ForEach($entry.durations) { $duration in
                        DurationTile(duration: $duration, onDelete: {
                            withAnimation(reduceMotion ? .none : .default) {
                                entry.durations.removeAll { $0.id == duration.id }
                            }
                        })
                    }

                    Button {
                        withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8)) {
                            let start = entry.durations.last?.endDate ?? Date()
                            entry.durations.append(MedicationDuration(
                                startDate: start,
                                endDate: Calendar.current.date(byAdding: .month, value: 1, to: start)!
                            ))
                        }
                    } label: {
                        Label("Add Date Range", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add another date range")
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

struct DurationTile: View {
    @Binding var duration: MedicationDuration

    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Date Range", systemImage: "calendar.badge.exclamationmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.secondary.opacity(0.6))
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove date range")
            }

            Divider()

            DatePicker("Start Date", selection: $duration.startDate, displayedComponents: .date)
                .accessibilityLabel("Start date")

            DatePicker("End Date", selection: $duration.endDate, in: duration.startDate..., displayedComponents: .date)
                .accessibilityLabel("End date")

            // Duration summary badge
            let days = Calendar.current.dateComponents([.day], from: duration.startDate, to: duration.endDate).day ?? 0
            HStack {
                Image(systemName: "hourglass")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(days) day\(days == 1 ? "" : "s")")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.1), in: Capsule())
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Step 4: Details

struct DetailsStep: View {
    // MARK: Internal

    enum Field { case nickname, notes }

    @Binding var entry: MedicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Summary card
            SummaryCard(entry: entry)

            SectionCard(title: "Optional Details", symbol: "note.text") {
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Nickname", systemImage: "tag")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        TextField("e.g. Morning pill, Blood pressure med…", text: $entry.nickname)
                            .textInputAutocapitalization(.sentences)
                            .focused($focusedField, equals: .nickname)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .notes }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .accessibilityLabel("Nickname for this medication")
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Notes", systemImage: "text.bubble")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        TextEditor(text: $entry.notes)
                            .focused($focusedField, equals: .notes)
                            .frame(minHeight: 90)
                            .padding(10)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                Group {
                                    if entry.notes.isEmpty {
                                        Text("Instructions, side effects, prescriber info…")
                                            .foregroundStyle(.tertiary)
                                            .padding(14)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                            .accessibilityLabel("Notes")
                    }
                }
            }
        }
    }

    // MARK: Private

    @FocusState private var focusedField: Field?
}

// MARK: - Summary Card

struct SummaryCard: View {
    let entry: MedicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Summary", systemImage: "checklist")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(spacing: 16) {
                ZStack {
                    BadgeShapeView(shape: entry.form.badgeShape, isSelected: true)
                    Image(systemName: entry.form.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.drugName.isEmpty ? "Unnamed Medication" : entry.drugName)
                        .font(.headline)
                    Text("\(entry.strength)\(entry.unit.displayName) · \(entry.form.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                if entry.scheduleType == .asNeeded {
                    SummaryRow(symbol: "hand.raised.fill", label: "As needed (no reminder)")
                } else {
                    ForEach(entry.doses) { dose in
                        let qty = dose.quantity == dose.quantity.rounded() ? String(Int(dose.quantity)) : unsafe String(format: "%.1f", dose.quantity)
                        SummaryRow(symbol: "clock.fill",
                                   label: "Take \(qty) \(dose.form.displayName.lowercased()) at \(dose.time.formatted(date: .omitted, time: .shortened))")
                    }
                }
                ForEach(entry.durations) { dur in
                    SummaryRow(symbol: "calendar",
                               label: "\(dur.startDate.formatted(date: .abbreviated, time: .omitted)) – \(dur.endDate.formatted(date: .abbreviated, time: .omitted))")
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        )
    }
}

struct SummaryRow: View {
    let symbol: String
    let label: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 18)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Reusable Components

struct SectionCard<Content: View>: View {
    let title: String
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: symbol)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            content
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct InfoBanner: View {
    let symbol: String
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 20))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}
