

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
        }
        .alert("Missing Information", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .task {
            _ = await authenticationService.autoLogin()
        }
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService

    @State private var dateOfBirth: Date = .init()
    @State private var height: Double?
    @State private var prePregnancyWeight: Double?
    @State private var currentWeight: Double?

    @State private var selectedCountry: String?
    @State private var selectedState: IndianState?

    @State private var activePicker: PickerType?

    @State private var showAlert = false
    @State private var alertMessage = ""

    @State private var navigateToThirdStep = false

    private var allowedDOBRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        let min = calendar.date(byAdding: .year, value: -45, to: now)!
        let max = calendar.date(byAdding: .year, value: -18, to: now)!
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

            Text("Answer a few questions to help us create your profile")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var formContent: some View {
        Group {
            if #available(iOS 16.0, *) {
                Form {
                    dobSection
                    measurementSection
                    locationSection
                }
                .scrollContentBackground(.hidden)
            } else {
                Form {
                    dobSection
                    measurementSection
                    locationSection
                }
            }
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

    private var measurementSection: some View {
        Section {
            pickerRow("Height", value: height.map { "\($0) cm" }) {
                activePicker = .height
            }

            pickerRow("Pre-Pregnancy Weight", value: prePregnancyWeight.map { "\($0) kg" }) {
                activePicker = .preWeight
            }

            pickerRow("Current Weight", value: currentWeight.map { "\($0) kg" }) {
                activePicker = .currentWeight
            }
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

    private var nextButton: some View {
        VStack {
            Button {
                Task {
                    await handleNext()
                }
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(MomCareAccent.primary)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .navigationDestination(isPresented: $navigateToThirdStep) {
                PreferencesSignUpView()
            }
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
            }
        }
        .tint(.primary)
        .listRowBackground(Color(.secondarySystemBackground))
    }

    @ViewBuilder
    private func pickerSheet(for type: PickerType) -> some View {
        switch type {
        case .height:
            ValuePickerSheet(
                title: "Height",
                range: 120 ... 220,
                unit: "cm",
                selection: $height
            )

        case .preWeight:
            ValuePickerSheet(
                title: "Pre-Pregnancy Weight",
                range: 40 ... 120,
                unit: "kg",
                selection: $prePregnancyWeight
            )

        case .currentWeight:
            ValuePickerSheet(
                title: "Current Weight",
                range: 40 ... 120,
                unit: "kg",
                selection: $currentWeight
            )

        case .country:
            CountryPickerView(selectedCountry: $selectedCountry)
        case .state:
            StatePickerView(selectedState: $selectedState)
        }
    }

    private func handleNext() async {
        let missingFields = getMissingSelections()

        if !missingFields.isEmpty {
            alertMessage = "\(missingFields.joined(separator: ", ")) are missing."
            showAlert = true
            return
        }

        guard let height, let prePregnancyWeight, let currentWeight else {
            fatalError()
        }

        authenticationService.userModel?.height = height
        authenticationService.userModel?.prePregnancyWeight = prePregnancyWeight
        authenticationService.userModel?.currentWeight = currentWeight

        _ = try? await authenticationService.update(dateOfBirthTimestamp: .value(dateOfBirth.timeIntervalSince1970), height: .value(height), prePregnancyWeight: .value(prePregnancyWeight), currentWeight: .value(currentWeight))

        authenticationService.userModel?.dateOfBirthTimestamp = dateOfBirth.timeIntervalSince1970
        navigateToThirdStep = true
    }

    private func getMissingSelections() -> [String] {
        var missing = [String]()

        if height == nil { missing.append("Height") }
        if prePregnancyWeight == nil { missing.append("Pre-Pregnancy Weight") }
        if currentWeight == nil { missing.append("Current Weight") }

        if selectedCountry == nil {
            missing.append("Country")
        } else if selectedCountry == "India", selectedState == nil {
            missing.append("State")
        }

        return missing
    }
}
