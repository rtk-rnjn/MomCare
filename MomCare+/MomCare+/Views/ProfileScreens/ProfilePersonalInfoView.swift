import SwiftUI
import TipKit

struct ProfilePersonalInfoView: View {
    init(name: String, dateOfBirth: Date, height: Int? = nil, currentWeight: Int? = nil, prePregnancyWeight: Int? = nil) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.currentWeight = currentWeight
        self.prePregnancyWeight = prePregnancyWeight
    }

    // MARK: Internal

    @State var name: String
    @State var dateOfBirth: Date

    @State var height: Int?
    @State var currentWeight: Int?
    @State var prePregnancyWeight: Int?

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Full name")
                        .foregroundStyle(.primary)

                    Spacer()

                    TextField(name, text: $name)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(isEditing ? MomCareAccent.primary : .secondary)
                        .disabled(!isEditing)
                        .accessibilityLabel("Full name")
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    Text("Full name") + Text(": ") + Text(name)
                )

                InfoRowDate(
                    title: "Date of Birth",
                    date: dateOfBirth,
                    isEditing: isEditing
                ) {
                    withAnimation(reduceMotion ? nil : .default) {
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
            } header: {
                Text("Basic Information")
            }

            Section {
                pickerRow("Height", value: Self.measurementFormatter.string(from: Measurement(value: Double(height ?? 0), unit: UnitLength.centimeters))) {
                    activeSheet = .height
                }

                pickerRow("Current Weight", value: Self.measurementFormatter.string(from: Measurement(value: Double(currentWeight ?? 0), unit: UnitMass.kilograms))) {
                    activeSheet = .currentWeight
                }

                pickerRow("Pre Pregnancy Weight", value: Self.measurementFormatter.string(from: Measurement(value: Double(prePregnancyWeight ?? 0), unit: UnitMass.kilograms))) {
                    activeSheet = .prePregnancyWeight
                }
            } header: {
                Text("Measurements")
            } footer: {
                Text("This information will help us provide you with personalized insights and recommendations throughout your pregnancy journey")
                    .font(.footnote)
            }
        }
        .scrollDismissesKeyboard(.immediately)
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

                Task {
                    do {
                        try await makeChanges()
                    } catch {
                        showingAlert = true
                        alertMessage = error.localizedDescription
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
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

    func pickerRow(_ title: LocalizedStringKey, value: String, action: @escaping () -> Void) -> some View {
        Button {
            guard isEditing else {
                return
            }

            action()
        } label: {
            InfoRow(title: title, value: value, isEditing: isEditing)
        }
        .buttonStyle(.plain)
        .accessibilityHint(
            isEditing ? Text("Tap to change ") + Text(title) : Text("")
        )
    }

    func makeChanges() async throws {
        guard let userModel = authenticationService.userModel else {
            return
        }

        let personNameComponentsFormatter = PersonNameComponentsFormatter()
        let firstName = personNameComponentsFormatter.personNameComponents(from: name)?.givenName ?? ""
        let lastName = personNameComponentsFormatter.personNameComponents(from: name)?.familyName ?? ""

        if name != userModel.fullName {
            _ = try await authenticationService.update(
                firstName: .value(firstName),
                lastName: .value(lastName),
            )
            authenticationService.userModel?.firstName = firstName
            authenticationService.userModel?.lastName = lastName
        }

        if dateOfBirth.timeIntervalSince1970 != userModel.dateOfBirthTimestamp {
            _ = try await authenticationService.update(dateOfBirthTimestamp: .value(dateOfBirth.timeIntervalSince1970))
            authenticationService.userModel?.dateOfBirthTimestamp = dateOfBirth.timeIntervalSince1970
        }

        if let height, height != userModel.height {
            _ = try await authenticationService.update(height: .value(height))
            authenticationService.userModel?.height = height
            try? await contentService.sync(heightInCentimeters: Double(height))
        }
        if let currentWeight, currentWeight != userModel.currentWeight {
            _ = try await authenticationService.update(currentWeight: .value(currentWeight))
            authenticationService.userModel?.currentWeight = currentWeight
            try? await contentService.sync(weightInKilograms: Double(currentWeight))
        }
        if let prePregnancyWeight, prePregnancyWeight != userModel.prePregnancyWeight {
            _ = try await authenticationService.update(prePregnancyWeight: .value(prePregnancyWeight))
            authenticationService.userModel?.prePregnancyWeight = prePregnancyWeight
        }
    }

    // MARK: Private

    private enum SheetType: Int, Identifiable {
        case height
        case currentWeight
        case prePregnancyWeight

        // MARK: Internal

        var id: Int {
            rawValue
        }
    }

    private static let measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return formatter
    }()

    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool
    @EnvironmentObject private var authenticationService: MCAuthenticationService
    @EnvironmentObject private var contentService: ContentServiceHandler

    @State private var isEditing = false
    @State private var showDateOfBirthPicker = false

    @State private var activeSheet: SheetType?
    @State private var showingAlert = false
    @State private var alertMessage = ""

    private var allowedDateOfBirthRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        guard let min = calendar.date(byAdding: .year, value: -45, to: now), let max = calendar.date(byAdding: .year, value: -18, to: now) else {
            fatalError(Quote.randomQuote.displayString)
        }

        return min ... max
    }
}

private struct InfoRow: View {
    let title: LocalizedStringKey
    let value: String
    let isEditing: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .foregroundStyle(isEditing ? Color("primaryAppColor") : .secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            Text(title) + Text(": ") + Text(value)
        )
    }
}
