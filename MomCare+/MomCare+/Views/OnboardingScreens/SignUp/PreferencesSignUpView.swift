import SwiftUI

struct PreferencesSignUpView: View {

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
        NavigationStack {
            VStack(spacing: 0) {
                progressHeader

                formContent

                finishButton
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $activeSheet) { sheet in
                sheetView(sheet)
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Invalid Information", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService

    @State private var dueDate: Date = .init()

    @State private var allergies: Set<Intolerance> = []
    @State private var conditions: Set<PreExistingCondition> = []
    @State private var dietaryPreferences: Set<DietaryPreference> = []

    @State private var activeSheet: SheetType?

    @State private var showAlert = false
    @State private var alertMessage = ""

    @State private var navigateToDashboard = false

    private var dueDateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let maxDate = calendar.date(
            byAdding: .weekOfYear,
            value: 40,
            to: today
        )!
        return today ... maxDate
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            GeometryReader { geo in
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                    .overlay(
                        Capsule()
                            .fill(MomCareAccent.primary)
                            .frame(width: geo.size.width),
                        alignment: .leading
                    )
            }
            .frame(height: 6)

            Text("Enter or calculate your details to help us create a plan curated just for you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var formContent: some View {
        Group {
            if #available(iOS 16.0, *) {
                Form {
                    dueDateSection
                    selectionSection
                }
                .scrollContentBackground(.hidden)
            } else {
                Form {
                    dueDateSection
                    selectionSection
                }
            }
        }
        .onAppear {
            clampDueDateIfNeeded()
        }
    }

    private var dueDateSection: some View {
        Section {
            DatePicker(
                "Estimated Due Date",
                selection: $dueDate,
                in: dueDateRange,
                displayedComponents: .date
            )
            .listRowBackground(Color(.secondarySystemBackground))
        }
    }

    private var selectionSection: some View {
        Section {
            pickerRow(
                "Allergies / Food Intolerance",
                count: allergies.count
            ) {
                activeSheet = .allergies
            }

            pickerRow(
                "Pre-Existing condition",
                count: conditions.count
            ) {
                activeSheet = .conditions
            }

            pickerRow(
                "Dietary Preference",
                count: dietaryPreferences.count
            ) {
                activeSheet = .diet
            }
        }
    }

    private var finishButton: some View {
        VStack {
            Button {
                Task {
                    await handleFinish()
                }
            } label: {
                Text("Finish")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(MomCareAccent.primary)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .navigationDestination(isPresented: $navigateToDashboard) {
                MomCareMainTabView()
            }
        }
    }

    private func pickerRow(
        _ title: String,
        count: Int,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                Text(count == 0 ? "None" : "\(count) selected")
                    .foregroundStyle(MomCareAccent.primary)

                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(MomCareAccent.primary)
            }
        }
        .tint(.primary)
        .listRowBackground(Color(.secondarySystemBackground))
    }

    @ViewBuilder
    private func sheetView(_ sheet: SheetType) -> some View {
        switch sheet {
        case .allergies:
            MultiSelectPickerView(
                title: "Allergic Ingredients",
                items: Intolerance.allCases.filter { $0 != .none },
                selection: $allergies,
                searchable: true
            )

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
        }
    }

    private func clampDueDateIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let maxDate = calendar.date(
            byAdding: .weekOfYear,
            value: 40,
            to: today
        )!

        if dueDate < today {
            dueDate = today
        } else if dueDate > maxDate {
            dueDate = maxDate
        }
    }

    private func handleFinish() async {
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: dueDate)

        if selectedDate <= today {
            alertMessage = "Estimated due date must be a future date."
            showAlert = true
            return
        }

        let dietaryPreferences: [String] = dietaryPreferences.map(\.rawValue)
        let allergies: [String] = allergies.map(\.rawValue)

        authenticationService.userModel?.foodIntolerances = Array(self.allergies)
        authenticationService.userModel?.dietaryPreferences = Array(self.dietaryPreferences)

        _ = try? await authenticationService.update(dueDateTimestamp: .value(dueDate.timeIntervalSince1970), foodIntolerances: .value(allergies), dietaryPreferences: .value(dietaryPreferences))

        authenticationService.userModel?.dueDateTimestamp = dueDate.timeIntervalSince1970
    }
}

#Preview {
    PreferencesSignUpView()
}
