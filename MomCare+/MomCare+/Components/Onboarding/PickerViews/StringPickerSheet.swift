

import SwiftUI

struct StringPickerSheet: View {

    // MARK: Internal

    let title: String
    let options: [String]

    @Binding var selection: String?

    var body: some View {
        NavigationView {
            Picker(title, selection: Binding(
                get: { selection ?? options.first ?? "" },
                set: { selection = $0 }
            )) {
                ForEach(options, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .tint(MomCareAccent.primary)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .presentationDetents([.medium])
        .interactiveDismissDisabled(true)
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

}
