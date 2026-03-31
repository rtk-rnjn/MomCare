import SwiftUI

struct HealthMetricsSignUpView: View {
    // MARK: Internal

    enum PickerType: Identifiable {
        case height
        case preWeight
        case currentWeight
        case country
        case state

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

                nextButton
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $activePicker) { picker in
                pickerSheet(for: picker)
            }
            .navigationDestination(isPresented: $navigateToThirdStep) {
                PreferencesSignUpView()
            }
        }
        .alert("Missing Information", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: MCAuthenticationService
    @EnvironmentObject private var controlState: ControlState

    @State private var dateOfBirth: Date = .init()
    @State private var height: Int?
    @State private var prePregnancyWeight: Int?
    @State private var currentWeight: Int?

    @State private var selectedCountry: String?
    @State private var selectedState: IndianState?

    @State private var activePicker: PickerType?

    @State private var showAlert = false
    @State private var alertMessage = ""

    @State private var navigateToThirdStep = false

    @State private var isLoading: Bool = false

    private var allowedDOBRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        guard let min = calendar.date(byAdding: .year, value: -45, to: now),
              let max = calendar.date(byAdding: .year, value: -18, to: now) else {
            return now ... now
        }

        return min ... max
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
                            .frame(width: geo.size.width * 0.5),
                        alignment: .leading
                    )
            }
            .frame(height: 6)
            .accessibilityLabel("Step 2 of 3, 50% complete")
            .accessibilityAddTraits(.updatesFrequently)

            Text("Answer a few questions to help us create your profile")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var formContent: some View {
        Group {
            Form {
                dobSection
                measurementSection
                locationSection
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
        }
    }

    private var dobSection: some View {
        Section {
            DatePicker(
                "Date of Birth",
                selection: $dateOfBirth,
                in: allowedDOBRange,
                displayedComponents: .date
            )
            .listRowBackground(Color(.secondarySystemBackground))
        }
    }

    private var locationSection: some View {
        Section {
            pickerRow("Country", value: selectedCountry) {
                activePicker = .country
            }

            if selectedCountry == "India" {
                pickerRow("State", value: selectedState?.rawValue) {
                    activePicker = .state
                }
            }
        }
    }

    private var measurementSection: some View {
        Section {
            pickerRow("Height", value: height.map { "\($0) \(UnitLength.centimeters.symbol)" }) {
                activePicker = .height
            }

            pickerRow("Pre-Pregnancy Weight", value: prePregnancyWeight.map { "\($0) \(UnitMass.kilograms.symbol)" }) {
                activePicker = .preWeight
            }

            pickerRow("Current Weight", value: currentWeight.map { "\($0) \(UnitMass.kilograms.symbol)" }) {
                activePicker = .currentWeight
            }
        }
    }

    private var nextButton: some View {
        VStack {
            Button {
                Task {
                    await handleNext()
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(isLoading)
            .buttonStyle(.borderedProminent)
            .tint(MomCareAccent.primary)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .accessibilityLabel("Next")
            .accessibilityHint("Proceed to the next step")
        }
    }

    private func pickerRow(
        _ title: String,
        value: String?,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                Text(value ?? "None")
                    .foregroundStyle(MomCareAccent.primary)

                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(MomCareAccent.primary)
                    .accessibilityHidden(true)
            }
        }
        .tint(.primary)
        .listRowBackground(Color(.secondarySystemBackground))
        .accessibilityLabel(title)
        .accessibilityValue(value ?? "None")
        .accessibilityHint("Tap to select \(title.lowercased())")
    }

    @ViewBuilder
    private func pickerSheet(for type: PickerType) -> some View {
        switch type {
        case .height:
            ValuePickerSheet(
                title: "Height",
                range: 120 ... 220,
                unit: UnitLength.centimeters,
                selection: $height
            )

        case .preWeight:
            ValuePickerSheet(
                title: "Pre-Pregnancy Weight",
                range: 40 ... 120,
                unit: UnitMass.kilograms,
                selection: $prePregnancyWeight
            )

        case .currentWeight:
            ValuePickerSheet(
                title: "Current Weight",
                range: 40 ... 120,
                unit: UnitMass.kilograms,
                selection: $currentWeight
            )

        case .country:
            CountryPickerView(selectedCountry: $selectedCountry)

        case .state:
            StatePickerView(selectedState: $selectedState)
        }
    }

    private func handleNext() async {
        isLoading = true
        defer { isLoading = false }
        let missingFields = getMissingSelections()

        if !missingFields.isEmpty {
            alertMessage = "\(missingFields.joined(separator: ", ")) are missing."
            showAlert = true
            return
        }

        guard let height, let prePregnancyWeight, let currentWeight else {
            fatalError(Quote.randomQuote.displayString)
        }

        authenticationService.userModel?.height = height
        authenticationService.userModel?.prePregnancyWeight = prePregnancyWeight
        authenticationService.userModel?.currentWeight = currentWeight

        do {
            _ = try await authenticationService.update(dateOfBirthTimestamp: .value(dateOfBirth.timeIntervalSince1970), height: .value(height), prePregnancyWeight: .value(prePregnancyWeight), currentWeight: .value(currentWeight))
        } catch {
            controlState.error = error
        }

        authenticationService.userModel?.dateOfBirthTimestamp = dateOfBirth.timeIntervalSince1970
        navigateToThirdStep = true
    }

    private func getMissingSelections() -> [String] {
        var missing = [String]()

        if height == nil {
            missing.append("Height")
        }
        if prePregnancyWeight == nil {
            missing.append("Pre-Pregnancy Weight")
        }
        if currentWeight == nil {
            missing.append("Current Weight")
        }

        if selectedCountry == nil {
            missing.append("Country")
        } else if selectedCountry == "India", selectedState == nil {
            missing.append("State")
        }

        return missing
    }
}
