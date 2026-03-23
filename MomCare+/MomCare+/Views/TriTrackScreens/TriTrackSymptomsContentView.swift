import SwiftData
import SwiftUI

struct TriTrackSymptomsContentView: View {

    // MARK: Internal

    @Binding var selectedDate: Date
    @Query var symptoms: [SymptomModel]

    var body: some View {
        List {
            Section {
                ForEach(filterSymptoms(for: selectedDate)) { symptomModel in
                    TriTrackSymptomRow(
                        symptom: symptomModel,
                        onEdit: {
                            selectedSymptomModel = symptomModel
                        },
                        onDelete: {
                            delete(symptomModel)
                        },
                        onViewDetails: {
                            openDetails(for: symptomModel)
                        }
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            } header: {
                HStack {
                    Text("Symptoms")
                        .font(.headline)

                    Spacer()

                    Text(filterSymptoms(for: selectedDate).count, format: .number)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: filterSymptoms(for: selectedDate).count)
                }
            }
        }
        .listStyle(.plain)
        .sheet(isPresented: $controlState.showingAddSymptomSheet) {
            TriTrackAddEditSymptomSheetView(selectedDate: selectedDate)
                .presentationDetents([.medium, .large])
                .scrollDismissesKeyboard(.immediately)
                .interactiveDismissDisabled(true)
        }
        .sheet(item: $selectedSymptomModel) {
            selectedSymptomModel = nil
        } content: { symptomModel in
            TriTrackAddEditSymptomSheetView(selectedDate: selectedDate, existingSymptom: symptomModel)
                .presentationDetents([.medium, .large])
                .scrollDismissesKeyboard(.immediately)
                .interactiveDismissDisabled(true)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .navigationDestination(isPresented: $showDetail) {
            if let selectedSymptom {
                TriTrackSymptomDetailView(symptom: selectedSymptom)
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "An unexpected error occurred.")
        }
    }

    func filterSymptoms(for date: Date) -> [SymptomModel] {
        symptoms.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func openDetails(for model: SymptomModel) {
        guard
            let id = model.symptomId,
            let symptom = PregnancySymptoms.allSymptoms.first(where: { $0.id == id })
        else { return }

        showDetail = true
        selectedSymptom = symptom
    }

    func delete(_ model: SymptomModel) {
        context.delete(model)
        do {
            try context.save()
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    // MARK: Private

    @State private var selectedSymptomModel: SymptomModel?

    @EnvironmentObject private var controlState: ControlState

    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedSymptom: Symptom?
    @State private var showDetail = false
    @State private var showErrorAlert = false
    @State private var alertMessage: String?

}

struct TriTrackSymptomRow: View {

    // MARK: Internal

    let symptom: SymptomModel
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onViewDetails: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.largeTitle)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
                .onTapGesture(perform: onEdit)

            VStack(alignment: .leading, spacing: 8) {
                Text(symptom.title ?? "Untitled Symptom")
                    .font(.headline)

                if let notes = symptom.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Text("Logged on \(symptom.date, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .onTapGesture(perform: onEdit)

            Spacer()

            Button(action: onViewDetails) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .accessibilityLabel("View details for \(symptom.title ?? "symptom")")
        }
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit Symptom", systemImage: "pencil")
            }

            Divider()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                onViewDetails()
            } label: {
                Label("Details", systemImage: "info.circle")
            }
            .tint(.blue)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(symptom.title ?? "Symptom")
        .accessibilityValue(symptom.notes.flatMap { $0.isEmpty ? nil : $0 } ?? "No notes")
        .accessibilityHint("Double tap to view details, long press for more options")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "View Details") { onViewDetails() }
        .accessibilityAction(named: "Delete") { onDelete() }
    }

    // MARK: Private

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

}
