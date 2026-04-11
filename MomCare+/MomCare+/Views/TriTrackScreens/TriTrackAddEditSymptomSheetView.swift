import SwiftData
import SwiftUI

struct TriTrackAddEditSymptomSheetView: View {
    // MARK: Internal

    let selectedDate: Date

    @State var existingSymptom: SymptomModel?

    var body: some View {
        NavigationStack {
            Form {
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
                    .accessibilityHint(String(localized: "a11y_symptom_picker_hint"))
                    .accessibilityIdentifier("selectSymptomButton")
                }

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
            .navigationTitle(existingSymptom == nil ? "New Symptom" : "Edit Symptom")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton {
                        dismiss()
                    }
                    .accessibilityLabel(String(localized: "Cancel"))
                    .accessibilityHint(String(localized: "a11y_dismiss_hint"))
                    .accessibilityAddTraits(.isButton)
                }

                ToolbarItem(placement: .confirmationAction) {
                    MCDoneButton {
                        saveOrEdit()
                    }
                    .disabled(title.isEmpty)
                    .accessibilityLabel(String(localized: "a11y_save_symptom_label"))
                    .accessibilityHint(String(localized: "a11y_save_symptom_hint"))
                    .accessibilityAddTraits(.isButton)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled(true)
        .scrollDismissesKeyboard(.immediately)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "An unexpected error occurred.")
        }
        .sheet(isPresented: $showSymptomPicker) {
            TriTrackSymptomsSheetView { symptom in
                selectedSymptom = symptom
                if symptom == nil {
                    title = ""
                }
            }
            .presentationDetents([.medium, .large])
            .interactiveDismissDisabled(true)
            .scrollDismissesKeyboard(.immediately)
        }
        .onAppear {
            populate()
        }
    }

    // MARK: Private

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var contentService: ContentServiceHandler

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var showErrorAlert = false
    @State private var alertMessage: String?

    @State private var selectedSymptom: Symptom?
    @State private var showSymptomPicker = false

    private func saveOrEdit() {
        if existingSymptom == nil {
            let date: Date = if Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                .init()
            } else {
                selectedDate
            }

            let model = SymptomModel(date: date, symptomId: selectedSymptom?.id, title: title, notes: notes)
            Task {
                try? await contentService.saveSymptom(model)
            }
            modelContext.insert(model)

        } else {
            guard let id = existingSymptom?.id else {
                alertMessage = "Failed to find the symptom entry to update."
                showErrorAlert = true
                return
            }

            let model = FetchDescriptor<SymptomModel>(predicate: #Predicate { $0.id == id })
            guard let existingSymptom = try? modelContext.fetch(model).first else {
                alertMessage = "Failed to find the symptom entry to update."
                showErrorAlert = true
                return
            }

            existingSymptom.title = title
            existingSymptom.notes = notes
            existingSymptom.symptomId = selectedSymptom?.id
        }

        do {
            try modelContext.save()
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
            return
        }
        dismiss()
    }

    private func populate() {
        guard let existingSymptom else {
            return
        }

        title = existingSymptom.title ?? ""
        notes = existingSymptom.notes ?? ""
        if let symptomId = existingSymptom.symptomId {
            selectedSymptom = PregnancySymptoms.allSymptoms.first { $0.id == symptomId }
        }
    }
}
