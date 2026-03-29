import SwiftUI

struct ProfileHealthInfoView: View {
    // MARK: Internal

    enum SheetType: Identifiable {
        case allergies
        case conditions
        case diet

        // MARK: Internal

        var id: Int {
            hashValue
        }
    }

    var body: some View {
        List {
            Section {
                InfoRowDate(
                    title: "Due Date",
                    date: authenticationService.userModel?.dueDate ?? Date(),
                    isEditing: isEditing
                ) {
                    if reduceMotion {
                        showDueDatePicker.toggle()
                    } else {
                        withAnimation { showDueDatePicker.toggle() }
                    }
                }
                .onAppear {
                    if let dueDate = authenticationService.userModel?.dueDate {
                        self.dueDate = dueDate
                    }
                }

                if showDueDatePicker {
                    DatePicker(
                        "",
                        selection: $dueDate,
                        in: allowedDueDateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
            } footer: {
                Text("This information helps us provide you with more personalized content and recommendations.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                pickerRow(title: "Dietary Preferences", value: displayCount(dietaryPreferences)) {
                    activeSheet = .diet
                }

                pickerRow(title: "Allergies", value: displayCount(allergies)) {
                    activeSheet = .allergies
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .listStyle(.insetGrouped)
        .navigationTitle("Health Information")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if reduceMotion {
                        isEditing.toggle()
                    } else {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(MomCareAccent.primary)
            }
        }
        .onChange(of: isEditing) {
            if !isEditing {
                showDueDatePicker = false
            }
        }
        .onChange(of: isEditing) {
            if isEditing {
                return
            }
            Task {
                do {
                    if dueDate != authenticationService.userModel?.dueDate {
                        _ = try await authenticationService.update(dueDateTimestamp: .value(dueDate.timeIntervalSince1970))
                        authenticationService.userModel?.dueDateTimestamp = dueDate.timeIntervalSince1970
                    }

                    if !compare(allergies, with: authenticationService.userModel?.foodIntolerances ?? []) {
                        _ = try await authenticationService.update(foodIntolerances: .value(allergies.map { $0.rawValue }))
                        authenticationService.userModel?.foodIntolerances = Array(allergies)
                    }
                    if !compare(dietaryPreferences, with: authenticationService.userModel?.dietaryPreferences ?? []) {
                        _ = try await authenticationService.update(dietaryPreferences: .value(dietaryPreferences.map { $0.rawValue }))
                        authenticationService.userModel?.dietaryPreferences = Array(dietaryPreferences)
                    }
                } catch {
                    controlState.error = error
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .conditions:
                MultiSelectPickerView(
                    title: "Pre-Existing Conditions",
                    items: PreExistingCondition.allCases.filter { $0 != .none },
                    selection: $conditions
                )

            case .diet:
                MultiSelectPickerView(
                    title: "Dietary Preference",
                    items: DietaryPreference.allCases.filter { $0 != .none },
                    selection: $dietaryPreferences
                )

            case .allergies:
                MultiSelectPickerView(
                    title: "Allergic Ingredients",
                    items: Intolerance.allCases.filter { $0 != .none },
                    selection: $allergies,
                    searchable: true
                )
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            dietaryPreferences = Set(authenticationService.userModel?.dietaryPreferences ?? [])
            allergies = Set(authenticationService.userModel?.foodIntolerances ?? [])
        }
    }

    func pickerRow(
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            guard isEditing else {
                return
            }

            action()
        } label: {
            HStack {
                Text(title)

                Spacer()

                Text(value)
                    .foregroundStyle(isEditing ? Color("primaryAppColor") : .secondary)

                if isEditing {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint(isEditing ? "Tap to change \(title)" : "")
    }

    func displayCount<T>(_ set: Set<T>) -> String {
        if set.isEmpty {
            return "None"
        }
        return "\(set.count) Selected"
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

    @EnvironmentObject private var authenticationService: MCAuthenticationService
    @EnvironmentObject private var controlState: ControlState

    @State private var isEditing = false

    @State private var showDueDatePicker = false
    @State private var dueDate: Date = .init()
    @State private var allergies: Set<Intolerance> = []
    @State private var conditions: Set<PreExistingCondition> = []
    @State private var dietaryPreferences: Set<DietaryPreference> = []

    @State private var activeSheet: SheetType?

    private var allowedDueDateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        let max = calendar.date(byAdding: .weekOfYear, value: 40, to: now)!
        return now ... max
    }

    private func compare<T: Hashable>(_ set: Set<T>, with array: [T]) -> Bool {
        set.count == array.count && set == Set(array)
    }
}
