import SwiftUI

struct ValuePickerSheet<UnitType: Dimension>: View {

    // MARK: Internal

    let title: String
    let range: ClosedRange<Int>
    let unit: UnitType

    @Binding var selection: Int?

    var body: some View {
        NavigationStack {
            Picker(title, selection: $tempSelection) {
                ForEach(range, id: \.self) { value in
                    Text(formattedString(for: value))
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()

            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        selection = tempSelection
                        dismiss()
                    }
                    .keyboardShortcut(.return)
                }
            }
        }
        .presentationDetents([.medium, .fraction(0.35)])
        .interactiveDismissDisabled(true)
        .onAppear {
            tempSelection = selection ?? range.lowerBound
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    @State private var tempSelection: Int = 0

    private func formattedString(for value: Int) -> String {
        let measurement = Measurement(value: Double(value), unit: unit)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return formatter.string(from: measurement)
    }
}
