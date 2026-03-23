import SwiftUI

private extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var nextDay: Date { Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)! }
}

struct ExerciseHistory: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CompactCalendarView(selectedDate: $selectedDate, isExpanded: $isCalendarExpanded)

                Group {
                    if isLoading && exercises == nil {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading exercise history…")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let errorMessage {
                        ContentUnavailableView(
                            "Couldn’t load exercises",
                            systemImage: "wifi.exclamationmark",
                            description: Text(errorMessage)
                        )
                        .overlay(alignment: .bottom) {
                            Button("Retry") {
                                Task { await load(for: selectedDate) }
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.bottom, 24)
                        }
                    } else if let exercises, exercises.isEmpty {
                        ContentUnavailableView(
                            "No exercises",
                            systemImage: "figure.strengthtraining.traditional",
                            description: Text("Try selecting a different date.")
                        )
                    } else if let exercises {
                        List {
                            Section {
                                ExerciseDaySummaryRow(exercises: exercises)
                            }

                            Section("Exercises") {
                                ForEach(exercises) { userExercise in
                                    ExerciseHistoryRow(userExercise: userExercise)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                        .animation(reduceMotion ? nil : .default, value: exercises)
                        .listStyle(.insetGrouped)
                        .refreshable {
                            await load(for: selectedDate)
                        }
                    } else {
                        // exercises == nil, not loading, no error: treat as empty for date
                        ContentUnavailableView(
                            "No exercises",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("Try selecting a different date.")
                        )
                    }
                }
            }
            .navigationTitle("Exercise History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
            .task(id: selectedDate.startOfDay) {
                await load(for: selectedDate)
            }
        }
    }

    // MARK: Private

    @State private var exercises: [UserExerciseModel]?
    @State private var selectedDate: Date = .init()

    @State private var isCalendarExpanded = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @MainActor
    private func load(for date: Date) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let startDate = date.startOfDay
        let endDate = date.nextDay

        do {
            let response = try await ContentRepository.shared.fetchUserExercises(from: startDate, to: endDate)
            // Keep empty array if the server returns empty; nil means “no response / unknown”
            exercises = response.data
        } catch {
            exercises = nil
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Summary (native row)

private struct ExerciseDaySummaryRow: View {

    // MARK: Internal

    let exercises: [UserExerciseModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 16) {
                metric("Completed", value: "\(completedCount)/\(exercises.count)")
                metric("Time", value: formattedDuration)
                metric("Progress", value: "\(Int(overallProgress * 100))%")
            }

            ProgressView(value: overallProgress) {
                EmptyView()
            }
            .tint(overallProgress >= 1 ? .green : .accentColor)
        }
        .padding(.vertical, 6)
        .task(id: exercises.map(\.id).joined(separator: "|")) {
            await computeStats()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Day summary")
        .accessibilityValue("\(completedCount) of \(exercises.count) exercises completed, \(formattedDuration) total time")
    }

    // MARK: Private

    @State private var completedCount: Int = 0
    @State private var totalSeconds: Double = 0

    private var overallProgress: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(completedCount) / Double(exercises.count)
    }

    private var formattedDuration: String {
        let total = Int(totalSeconds)
        let mins = total / 60
        let secs = total % 60
        if mins > 0 { return "\(mins)m \(secs)s" }
        return "\(secs)s"
    }

    private func metric(_ title: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
    }

    private func computeStats() async {
        var completed = 0
        var duration = 0.0

        for ex in exercises {
            if await ex.isCompleted { completed += 1 }
            duration += ex.videoDurationCompletedSeconds
        }

        await MainActor.run {
            completedCount = completed
            totalSeconds = duration
        }
    }
}

// MARK: - Exercise row (native list row)

private struct ExerciseHistoryRow: View {

    // MARK: Internal

    let userExercise: UserExerciseModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.secondary.opacity(0.12))

                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                } else {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Main text
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(exercise?.name ?? "Loading…")
                        .font(.headline)
                        .foregroundStyle(exercise == nil ? .secondary : .primary)
                        .redacted(reason: exercise == nil ? .placeholder : [])

                    Spacer()

                    StatusBadge(completionPct: completionPct)
                }

                if let level = exercise?.level.rawValue {
                    Text(level)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let parts = exercise?.targetedBodyParts, !parts.isEmpty {
                    Text(parts.joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                ProgressView(value: completionPct)
                    .tint(completionPct >= 1 ? .green : .accentColor)

                Text(durationLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .task(id: userExercise.id) {
            await loadExercise()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(exercise?.name ?? "Exercise")
        .accessibilityValue(completionPct >= 1 ? "Completed" : "\(Int(completionPct * 100)) percent completed")
    }

    // MARK: Private

    @State private var exercise: ExerciseModel?
    @State private var completionPct: Double = 0
    @State private var uiImage: UIImage?

    private var durationLabel: String {
        let watched = Int(userExercise.videoDurationCompletedSeconds)

        guard let exercise else {
            return "\(formattedSeconds(watched)) watched"
        }

        let total = Int(exercise.videoDurationSeconds)
        return "\(formattedSeconds(watched)) of \(formattedSeconds(total))"
    }

    private func formattedSeconds(_ s: Int) -> String {
        let m = s / 60
        let sec = s % 60
        return m > 0 ? "\(m)m \(sec)s" : "\(sec)s"
    }

    private func loadExercise() async {
        let model = await userExercise.exerciseModel
        let pct = await userExercise.completionPercentage
        let image = await model?.image

        await MainActor.run {
            exercise = model
            completionPct = pct
            uiImage = image
        }
    }
}

private struct StatusBadge: View {
    let completionPct: Double

    var body: some View {
        if completionPct >= 1.0 {
            Label("Done", systemImage: "checkmark")
                .labelStyle(.titleAndIcon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.thinMaterial, in: Capsule())
                .accessibilityHidden(true)
        } else {
            Text("\(Int(completionPct * 100))%")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.thinMaterial, in: Capsule())
                .accessibilityHidden(true)
        }
    }
}
