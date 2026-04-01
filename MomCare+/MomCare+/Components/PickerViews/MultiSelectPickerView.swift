import SwiftUI

struct MultiSelectPickerView<T: Hashable & CaseIterable & RawRepresentable>: View where T.RawValue == String {
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

                        if temporarySelections.contains(item) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .tint(.primary)
                .accessibilityLabel(item.rawValue.capitalized)
                .accessibilityValue(temporarySelections.contains(item) ? "Selected" : "Not selected")
                .accessibilityHint("Double tap to toggle selection")
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        selection = temporarySelections
                        dismiss()
                    }
                    .tint(MomCareAccent.primary)
                    .foregroundStyle(.white)
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                temporarySelections = selection
            }
            .searchable(text: $searchText, isPresented: $searchable)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @State private var temporarySelections: Set<T> = []
    @State private var searchText = ""

    private var filteredItems: [T] {
        guard searchable, !searchText.isEmpty else {
            return items
        }

        return items.filter {
            $0.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func toggle(_ item: T) {
        if temporarySelections.contains(item) {
            temporarySelections.remove(item)
        } else {
            temporarySelections.insert(item)
        }
    }
}
