import SwiftData
import SwiftUI

struct TriTrackAddSymptomSheetView: View {

    // MARK: Internal

    @Environment(\.modelContext) var modelContext

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Symptom Selection

                Section("Symptom") {
                    Button {
                        showSymptomPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "cross.case.fill")
                                .foregroundStyle(.pink)
                                .accessibilityHidden(true)

                            Text(selectedSymptom?.name ?? "Select Symptom")
                                .foregroundStyle(
                                    selectedSymptom == nil ? .secondary : .primary
                                )

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityLabel(selectedSymptom.map { "Selected symptom: \($0.name)" } ?? "Select symptom")
                    .accessibilityHint("Opens symptom picker")
                    .accessibilityIdentifier("selectSymptomButton")
                }

                // MARK: Details

                Section("Details") {
                    TextField("Title", text: $title)
                        .onChange(of: selectedSymptom) { _, newValue in
                            if let symptom = newValue {
                                title = symptom.name
                            }
                        }

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3 ... 6)
                }

                // MARK: Info Preview (if predefined symptom)

                if let symptom = selectedSymptom {
                    Section("About This Symptom") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(symptom.whatIsIt)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)

                            NavigationLink("View Full Details") {
                                TriTrackSymptomDetailView(symptom: symptom)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Symptom")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Dismisses this screen without saving changes")
                    .accessibilityAddTraits(.isButton)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        save()
                    }
                    .disabled(title.isEmpty)
                    .accessibilityLabel("Save symptom")
                    .accessibilityHint("Saves the symptom entry to your log")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled(true)
        .sheet(isPresented: $showSymptomPicker) {
            TriTrackSymptomsSheetView { symptom in
                selectedSymptom = symptom
                if symptom == nil {
                    title = ""
                }
            }
            .presentationDetents([.medium, .large])
            .interactiveDismissDisabled(true)
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var notes: String = ""

    @State private var selectedSymptom: Symptom?
    @State private var showSymptomPicker = false

    private func save() {
        let loggedDate = Date()

        let model = SymptomModel(date: loggedDate, symptomId: selectedSymptom?.id, title: title, notes: notes)
        modelContext.insert(model)
        try? modelContext.save()
        dismiss()
    }
}
