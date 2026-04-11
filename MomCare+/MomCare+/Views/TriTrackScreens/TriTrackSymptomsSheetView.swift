import SwiftUI

struct TriTrackSymptomsSheetView: View {
    // MARK: Internal

    let onSelect: (Symptom?) -> Void

    @Environment(\.dismiss) var dismiss

    var filteredSymptoms: [Symptom] {
        if searchText.isEmpty {
            PregnancySymptoms.allSymptoms
        } else {
            PregnancySymptoms.allSymptoms.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        onSelect(nil)
                        dismiss()
                    }, label: {
                        Text("Other")
                            .foregroundStyle(.primary)
                    })
                    .accessibilityLabel(String(localized: "a11y_other_symptom_label"))
                    .accessibilityHint(String(localized: "a11y_log_custom_symptom_hint"))
                }

                Section {
                    ForEach(filteredSymptoms) { symptom in
                        Button(action: {
                            onSelect(symptom)
                            dismiss()
                        }, label: {
                            Text(symptom.name)
                                .foregroundStyle(.primary)
                        })
                        .accessibilityHint(String(localized: "a11y_select_symptom_hint"))
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .listStyle(.plain)
            .navigationTitle("Select a Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search symptoms")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MCCancelButton {
                        dismiss()
                    }
                    .accessibilityHint(String(localized: "a11y_dismiss_no_selection_hint"))
                }
            }
        }
    }

    // MARK: Private

    @State private var searchText = ""
}
