//
//  SymptomsListView.swift
//  MomCare
//
//  Created by Khushi Rana on 14/09/25.
//

import SwiftUI

struct SymptomsListView: View {
    let onSelect: (Symptom?) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var filteredSymptoms: [Symptom] {
        if searchText.isEmpty {
            return PregnancySymptoms.allSymptoms
        } else {
            return PregnancySymptoms.allSymptoms.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
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
                            .foregroundColor(.primary)
                    })
                    .accessibilityLabel("Other symptom")
                    .accessibilityHint("Select this to add a custom symptom not listed")
                }

                Section {
                    ForEach(filteredSymptoms) { symptom in
                        Button(action: {
                            onSelect(symptom)
                            dismiss()
                        }, label: {
                            Text(symptom.name)
                                .foregroundColor(.primary)
                        })
                        .accessibilityLabel(symptom.name)
                        .accessibilityHint("Select this symptom to add to your symptom list")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Select a Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search symptoms")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Closes the symptom selection without selecting a symptom")
                }
            }
        }
    }
}
