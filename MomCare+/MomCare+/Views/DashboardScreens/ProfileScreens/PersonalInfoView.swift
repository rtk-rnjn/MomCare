

import SwiftUI

struct PersonalInfoView: View {

    // MARK: Internal

    enum SheetType: Identifiable {
        case height
        case currentWeight
        case preWeight

        // MARK: Internal

        var id: Int {
            hashValue
        }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(MomCareAccent.primary)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section {
                ProfileEditableTextRow(title: "Name", text: $name, isEditing: isEditing, displayText: authenticationService.userModel?.fullName)

                InfoRowDate(
                    title: "Date of Birth",
                    date: dob,
                    isEditing: isEditing
                ) {
                    withAnimation {
                        showDOBPicker.toggle()
                    }
                }

                if showDOBPicker {
                    DatePicker(
                        "",
                        selection: $dob,
                        in: allowedDOBRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
            }

            Section {
                pickerRow("Height", value: valueText(height, "cm")) {
                    activeSheet = .height
                }

                pickerRow("Current Weight", value: valueText(currentWeight, "kg")) {
                    activeSheet = .currentWeight
                }

                pickerRow("Pre Pregnancy Weight", value: valueText(preWeight, "kg")) {
                    activeSheet = .preWeight
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Personal Information")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation {
                        isEditing.toggle()

                        if !isEditing {
                            showDOBPicker = false
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(MomCareAccent.primary)
            }
        }

        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .height:
                ValuePickerSheet(
                    title: "Height",
                    range: 100 ... 220,
                    unit: "cm",
                    selection: $height
                )

            case .currentWeight:
                ValuePickerSheet(
                    title: "Current Weight",
                    range: 30 ... 150,
                    unit: "kg",
                    selection: $currentWeight
                )

            case .preWeight:
                ValuePickerSheet(
                    title: "Pre Pregnancy Weight",
                    range: 30 ... 150,
                    unit: "kg",
                    selection: $preWeight
                )
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var showDOBPicker = false

    @State private var name: String = "Not Set"
    @State private var dob: Date = .init()

    @State private var height: Double?
    @State private var currentWeight: Double?
    @State private var preWeight: Double?

    @State private var activeSheet: SheetType?

}

private extension PersonalInfoView {
    func pickerRow(_ title: String, value: String, action: @escaping () -> Void) -> some View {
        Button {
            guard isEditing else { return }
            action()
        } label: {
            InfoRow(title: title, value: value, isEditing: isEditing)
        }
        .buttonStyle(.plain)
    }

    func valueText(_ value: Double?, _ unit: String) -> String {
        guard let value else { return "Not Set" }
        return unit.isEmpty ? "\(Int(value))" : "\(Int(value)) \(unit)"
    }

    private var allowedDOBRange: ClosedRange<Date> {
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
