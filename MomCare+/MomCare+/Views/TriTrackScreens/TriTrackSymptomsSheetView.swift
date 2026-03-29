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
                    .accessibilityLabel("Other symptom")
                    .accessibilityHint("Double tap to log a custom symptom")
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
                        .accessibilityHint("Double tap to select this symptom")
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .listStyle(.plain)
            .navigationTitle("Select a Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search symptoms")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                    .accessibilityHint("Dismisses without selecting a symptom")
                }
            }
        }
    }

    // MARK: Private

    @State private var searchText = ""
}
