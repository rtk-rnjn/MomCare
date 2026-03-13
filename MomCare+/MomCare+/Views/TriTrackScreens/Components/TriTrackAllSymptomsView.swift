import SwiftUI
import SwiftData

struct TriTrackAllSymptomsView: View {

    // MARK: Internal

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(grouped.enumerated()), id: \.element.date) { index, section in
                    let isPast = section.date < today
                    let isToday = Calendar.current.isDate(section.date, inSameDayAs: today)

                    Section {
                        ForEach(section.symptoms) { model in
                            SymptomRow(model: model, isPast: isPast, showDetails: showDetails)
                                .onTapGesture {
                                    selectedSymptomModel = model
                                }
                        }
                    } header: {
                        SymptomSectionHeader(date: section.date, isToday: isToday, isPast: isPast)
                    }
                    .id(index)
                }
            }
            .listStyle(.plain)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Symptom History")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedSymptomModel) { item in
                if let symptom = PregnancySymptoms.allSymptoms.first(where: { $0.id == item.symptomId }) {
                    TriTrackSymptomDetailView(symptom: symptom)
                }
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "Search symptoms or notes…")
            .searchToolbarBehavior(.minimize)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.snappy) { showDetails.toggle() }
                    } label: {
                        Label(
                            showDetails ? "Compact" : "Detailed",
                            systemImage: showDetails ? "list.bullet" : "list.bullet.below.rectangle"
                        )
                    }
                }
            }
            .overlay {
                if grouped.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Symptoms Logged" : "No Results",
                        systemImage: searchText.isEmpty ? "cross.case" : "magnifyingglass",
                        description: searchText.isEmpty ? Text("Start logging symptoms to see them here.") : Text("No symptoms match \(searchText).")
                    )
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let idx = todaySectionIndex {
                        proxy.scrollTo(idx, anchor: .top)
                    }
                }
            }
        }
    }

    // MARK: Private

    @State private var selectedSymptomModel: SymptomModel?

    @Query(sort: \SymptomModel.date, order: .forward) private var symptomModels: [SymptomModel]
    @State private var showDetails = true
    @State private var searchText = ""

    private let today = Calendar.current.startOfDay(for: Date())

    private var grouped: [(date: Date, symptoms: [SymptomModel])] {
        let filtered = searchText.isEmpty ? symptomModels : symptomModels.filter {
            let symptomName = PregnancySymptoms.allSymptoms.first { $0.id == $0.id }?.name ?? ""
            return ($0.title ?? "").localizedCaseInsensitiveContains(searchText)
                || ($0.notes ?? "").localizedCaseInsensitiveContains(searchText)
                || symptomName.localizedCaseInsensitiveContains(searchText)
        }
        let dict = Dictionary(grouping: filtered) {
            Calendar.current.startOfDay(for: $0.date)
        }
        return dict
            .map { (date: $0.key, symptoms: $0.value.sorted { $0.date < $1.date }) }
            .sorted { $0.date < $1.date }
    }

    private var todaySectionIndex: Int? {
        grouped.firstIndex { Calendar.current.isDate($0.date, inSameDayAs: today) }
            ?? grouped.firstIndex { $0.date >= today }
    }

}

struct SymptomSectionHeader: View {
    let date: Date
    let isToday: Bool
    let isPast: Bool

    var body: some View {
        HStack(spacing: 10) {
            if isToday {
                Text("TODAY")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.pink, in: Capsule())
            }

            Text(date.formatted(
                Date.FormatStyle()
                    .weekday(.wide)
                    .day()
                    .month(.wide)
            ))
            .font(.headline)
            .textCase(nil)
            .foregroundStyle(isPast && !isToday ? .secondary : .primary)
        }
        .padding(.vertical, 2)
    }
}

struct SymptomRow: View {

    // MARK: Internal

    let model: SymptomModel
    let isPast: Bool
    let showDetails: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            // Dot + line
            VStack(spacing: 0) {
                Circle()
                    .fill(isPast ? Color.pink.opacity(0.8) : Color.pink)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(Color.pink, lineWidth: isPast ? 1.5 : 0))
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1)
            }
            .padding(.top, 5)

            VStack(alignment: .leading, spacing: showDetails ? 5 : 0) {

                // Title
                HStack(spacing: 6) {
                    Text(displayTitle)
                        .font(.headline)
                        .foregroundStyle(isPast ? .secondary : .primary)
                    Spacer()
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 8, height: 8)
                        .opacity(isPast ? 0.8 : 1)
                }

                if showDetails {

                    // Time
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundStyle(.pink)
                        Text(model.date.formatted(date: .omitted, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Trimester badges
                    if let trimesters = symptom?.trimesters, !trimesters.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(trimesters, id: \.self) { trimester in
                                Text(trimester)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.pink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color.pink.opacity(0.12)))
                                    .overlay(Capsule().stroke(Color.pink.opacity(0.3), lineWidth: 1))
                            }
                        }
                    }

                    // User notes
                    if let notes = model.notes, !notes.isEmpty {
                        HStack(alignment: .top, spacing: 5) {
                            Image(systemName: "note.text")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .padding(.vertical, showDetails ? 8 : 6)
        }
        .opacity(isPast ? 0.8 : 1.0)
    }

    // MARK: Private

    private var symptom: Symptom? {
        guard let id = model.symptomId else { return nil }
        return PregnancySymptoms.allSymptoms.first { $0.id == id }
    }

    private var displayTitle: String {
        symptom?.name ?? model.title ?? "Unknown Symptom"
    }

}
