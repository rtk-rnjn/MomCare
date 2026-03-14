import SwiftUI

struct InitialsAvatar: View {

    let name: String

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.dropFirst().first?.prefix(1) ?? ""
        return (first + last).uppercased()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(MomCareAccent.primary.opacity(0.2))

            Text(initials)
                .font(.title3.weight(.semibold))
                .foregroundColor(MomCareAccent.primary)
        }
    }
}

struct ProfilePersonalInfoView: View {

    // MARK: Internal

    enum SheetType: Identifiable {
        case height
        case currentWeight
        case prePregnancyWeight

        // MARK: Internal

        var id: Int {
            hashValue
        }
    }

    @State var name: String
    @State var dateOfBirth: Date

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    InitialsAvatar(name: authenticationService.userModel?.fullName ?? "-")
                        .frame(width: 80, height: 80)
                        .foregroundColor(MomCareAccent.primary)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section {
                ProfileEditableTextRow(title: "Full name", text: $name, isEditing: isEditing, displayText: authenticationService.userModel?.fullName ?? "Not Set")

                InfoRowDate(
                    title: "Date of Birth",
                    date: authenticationService.userModel?.dateOfBirth ?? dateOfBirth,
                    isEditing: isEditing
                ) {
                    withAnimation {
                        showDateOfBirthPicker.toggle()
                    }
                }

                if showDateOfBirthPicker {
                    DatePicker(
                        "",
                        selection: $dateOfBirth,
                        in: allowedDateOfBirthRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
            }

            Section {
                pickerRow("Height", value: measurementFormatter.string(from: Measurement(value: authenticationService.userModel?.height ?? 0, unit: UnitLength.centimeters))) {
                    activeSheet = .height
                }

                pickerRow("Current Weight", value: measurementFormatter.string(from: Measurement(value: authenticationService.userModel?.currentWeight ?? 0, unit: UnitMass.kilograms))) {
                    activeSheet = .currentWeight
                }

                pickerRow("Pre Pregnancy Weight", value: measurementFormatter.string(from: Measurement(value: authenticationService.userModel?.prePregnancyWeight ?? 0, unit: UnitMass.kilograms))) {
                    activeSheet = .prePregnancyWeight
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Personal Information")
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
                showDateOfBirthPicker = false
            }
        }
        .onChange(of: isEditing) {
            if isEditing {
                return
            }

            Task {
                do {
                    try await makeChanges()
                } catch {
                    showingAlert = true
                    alertMessage = error.localizedDescription
                }

            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .height:
                ValuePickerSheet(
                    title: "Height",
                    range: 100 ... 220,
                    unit: UnitLength.centimeters,
                    selection: $height
                )

            case .currentWeight:
                ValuePickerSheet(
                    title: "Current Weight",
                    range: 30 ... 150,
                    unit: UnitMass.kilograms,
                    selection: $currentWeight
                )

            case .prePregnancyWeight:
                ValuePickerSheet(
                    title: "Pre Pregnancy Weight",
                    range: 30 ... 150,
                    unit: UnitMass.kilograms,
                    selection: $prePregnancyWeight
                )
            }
        }
    }

    func pickerRow(_ title: String, value: String, action: @escaping () -> Void) -> some View {
        Button {
            guard isEditing else { return }
            action()
        } label: {
            InfoRow(title: title, value: value, isEditing: isEditing)
        }
        .buttonStyle(.plain)
    }

    func makeChanges() async throws {
        if name != authenticationService.userModel?.fullName {
            let firstName = name.split(separator: " ").first.map(String.init) ?? ""
            let lastName = name.split(separator: " ").dropFirst().first.map(String.init) ?? ""

            _ = try await authenticationService.update(
                firstName: .value(firstName),
                lastName: .value(lastName),
            )
            authenticationService.userModel?.firstName = firstName
            authenticationService.userModel?.lastName = lastName
        }

        if dateOfBirth.timeIntervalSince1970 != authenticationService.userModel?.dateOfBirthTimestamp {
            _ = try await authenticationService.update(dateOfBirthTimestamp: .value(dateOfBirth.timeIntervalSince1970))
            authenticationService.userModel?.dateOfBirthTimestamp = dateOfBirth.timeIntervalSince1970
        }

        if let height, height != authenticationService.userModel?.height {
            _ = try await authenticationService.update(height: .value(height))
            authenticationService.userModel?.height = height
        }
        if let currentWeight, currentWeight != authenticationService.userModel?.currentWeight {
            _ = try await authenticationService.update(currentWeight: .value(currentWeight))
            authenticationService.userModel?.currentWeight = currentWeight
        }
        if let prePregnancyWeight, prePregnancyWeight != authenticationService.userModel?.prePregnancyWeight {
            _ = try await authenticationService.update(prePregnancyWeight: .value(prePregnancyWeight))
            authenticationService.userModel?.prePregnancyWeight = prePregnancyWeight
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

    @EnvironmentObject private var authenticationService: AuthenticationService
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var showDateOfBirthPicker = false

    @State private var height: Double?
    @State private var currentWeight: Double?
    @State private var prePregnancyWeight: Double?

    @State private var activeSheet: SheetType?
    @State private var showingAlert = false
    @State private var alertMessage = ""

    private var measurementFormatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return formatter
    }

    private var allowedDateOfBirthRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        let min = calendar.date(byAdding: .year, value: -45, to: now)!
        let max = calendar.date(byAdding: .year, value: -18, to: now)!
        return min ... max
    }

    private var allowedDueDateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        let max = calendar.date(byAdding: .weekOfYear, value: 40, to: now)!
        return now ... max
    }
}
