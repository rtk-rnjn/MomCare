import SwiftUI

struct ValuePickerSheet<UnitType: Dimension>: View {

    // MARK: Internal

    let title: String
    let range: ClosedRange<Int>
    let unit: UnitType

    @Binding var selection: Double?

    var body: some View {
        NavigationStack {
            VStack {
                Picker(title, selection: bindingValue) {
                    ForEach(range, id: \.self) { value in
                        HStack {
                            Text("\(value)")
                                .font(.title2.weight(.semibold))
                            Text(unit.symbol)
                                .foregroundStyle(.secondary)
                        }
                        .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        dismiss()
                    }
                    .tint(MomCareAccent.primary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    private var bindingValue: Binding<Int> {
        Binding<Int>(
            get: { Int(selection ?? Double(range.lowerBound)) },
            set: { selection = Double($0) }
        )
    }

}
