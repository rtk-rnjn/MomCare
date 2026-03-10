//
//  TriTrackSymptomsContentView.swift
//  MomCare+
//
//  Created by Aryan singh on 15/02/26.
//

import SwiftData
import SwiftUI

struct TriTrackSymptomsContentView: View {

    // MARK: Internal

    @Binding var selectedDate: Date
    @Query var symptoms: [SymptomModel]

    var body: some View {
        VStack(spacing: 16) {
            if filterSymptoms(for: selectedDate).isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(filterSymptoms(for: selectedDate)) { symptomModel in
                        SymptomRow(
                            symptom: symptomModel,
                            onInfo: {
                                openDetails(for: symptomModel)
                            },
                            onDelete: {
                                delete(symptomModel)
                            }
                        )
                    }
                }
            }
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
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            Text("Track Your Symptoms")
                .font(.headline)

            Text("Log how you're feeling each day to share with your healthcare provider.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                controlState.showingAddEventSheet = true
            } label: {
                Label("Log Symptom", systemImage: "plus")
                    .font(.body.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.CustomColors.mutedRaspberry)
            .sheet(isPresented: $controlState.showingAddEventSheet) {
                TriTrackAddSymptomSheetView()
            }
            .disabled(!Calendar.current.isDate(selectedDate, inSameDayAs: Date()))
            .accessibilityLabel("Log symptom")
            .accessibilityHint("Opens a form to log a new symptom for today")
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

        selectedSymptom = symptom
        showDetail = true
    }

    func delete(_ model: SymptomModel) {
        context.delete(model)
        try? context.save()
    }

    // MARK: Private

    @EnvironmentObject private var controlState: ControlState

    @Environment(\.modelContext) private var context

    @State private var selectedSymptom: Symptom?
    @State private var showDetail = false

}

struct SymptomRow: View {
    let symptom: SymptomModel
    var onInfo: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "heart.text.square")
                .font(.system(size: 24))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(symptom.title ?? "Untitled Symptom")
                    .font(.headline)

                if let notes = symptom.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button(action: onInfo) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .accessibilityLabel("View details for \(symptom.title ?? "symptom")")
            .frame(minWidth: 44, minHeight: 44)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .contextMenu {
            Button {
                onInfo()
            } label: {
                Label("View Details", systemImage: "info.circle")
            }

            Divider()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(symptom.title ?? "Symptom")
        .accessibilityValue(symptom.notes.flatMap { $0.isEmpty ? nil : $0 } ?? "No notes")
        .accessibilityHint("Double tap to view details, long press for more options")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "View Details") { onInfo() }
        .accessibilityAction(named: "Delete") { onDelete() }
    }
}
