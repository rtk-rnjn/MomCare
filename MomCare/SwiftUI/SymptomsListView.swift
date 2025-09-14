//
//  SymptomsListView.swift
//  MomCare
//
//  Created by Khushi Rana on 14/09/25.
//

import SwiftUI

struct SymptomListView: View {
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
                        }) {
                            Text("Other")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Section {
                        ForEach(filteredSymptoms) { symptom in
                            Button(action: {
                                onSelect(symptom) 
                                dismiss()
                            }) {
                                Text(symptom.name)
                                    .foregroundColor(.primary)
                            }
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
    }
