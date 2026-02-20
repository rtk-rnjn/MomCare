//
//  TriTrackSymptomsSheetView.swift
//  MomCare
//
//  Created by Aryan singh on 18/02/26.
//

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
                            .foregroundColor(.primary)
                    })
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
                }
            }
        }
    }

    // MARK: Private

    @State private var searchText = ""

}
