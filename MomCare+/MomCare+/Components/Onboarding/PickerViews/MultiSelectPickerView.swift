import SwiftUI

struct MultiSelectPickerView<T>: View where T: Hashable & CaseIterable & RawRepresentable, T.RawValue == String {

    // MARK: Internal

    let title: String
    let items: [T]

    @Binding var selection: Set<T>
    @State var searchable: Bool = false

    var body: some View {
        NavigationView {
            List(filteredItems, id: \.self) { item in
                Button {
                    toggle(item)
                } label: {
                    HStack {
                        Text(item.rawValue.capitalized)
                            .foregroundStyle(.primary)

                        Spacer()

                        if tempSelection.contains(item) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .tint(.primary)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selection = tempSelection
                        dismiss()
                    }
                    .tint(MomCareAccent.primary)
                    .foregroundStyle(.white)
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                tempSelection = selection
            }
            .searchable(text: $searchText, isPresented: $searchable)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @State private var tempSelection: Set<T> = []
    @State private var searchText = ""

    private var filteredItems: [T] {
        guard searchable, !searchText.isEmpty else { return items }
        return items.filter {
            $0.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func toggle(_ item: T) {
        if tempSelection.contains(item) {
            tempSelection.remove(item)
        } else {
            tempSelection.insert(item)
        }
    }
}
