import SwiftUI

struct StatePickerView: View {

    // MARK: Internal

    @Binding var selectedState: IndianState?

    var body: some View {
        NavigationView {
            List(filteredStates) { state in
                Button {
                    selectedState = state
                    dismiss()
                } label: {
                    Text(state.rawValue)
                        .foregroundStyle(.primary)
                }
            }
            .tint(.primary)
            .searchable(text: $searchText)
            .navigationTitle("Select State")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private let states: [IndianState] = IndianState.allCases

    private var filteredStates: [IndianState] {
        searchText.isEmpty ? states : states.filter { $0.rawValue.localizedCaseInsensitiveContains(searchText) }
    }
}
