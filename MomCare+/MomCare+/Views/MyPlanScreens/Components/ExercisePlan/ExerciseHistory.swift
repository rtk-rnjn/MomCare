import SwiftUI

struct ExerciseHistory: View {

    // MARK: Internal

    @State var exercises: [UserExerciseModel]?
    @State var selectedDate: Date = .init()

    var body: some View {
        NavigationStack {
            CompactCalendarView(selectedDate: $selectedDate, isExpanded: $isCalendarExpanded)

            Group {
                if let exercises {
                    if exercises.isEmpty {
                        ContentUnavailableView(
                            "No exercises found for this date.",
                            systemImage: "figure.strengthtraining.traditional",
                            description: Text("Try selecting a different date.")
                        )
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 14) {
                                // Summary banner
                                ExerciseDaySummaryCard(exercises: exercises)

                                // One card per exercise
                                ForEach(exercises) { userExercise in
                                    ExerciseHistoryCard(userExercise: userExercise)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                        }
                    }
                } else {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ContentUnavailableView(
                            "No exercises found for this date.",
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
                    Button(role: .cancel) { dismiss() }
                }
            }
            .onChange(of: selectedDate) {
                Task { await load() }
            }
            .task { await load() }
        }
    }

    // MARK: Private

    @State private var isCalendarExpanded = false
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        let startDate = Calendar.current.startOfDay(for: selectedDate)
        guard let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) else { return }

        let response = try? await ContentService.shared.fetchUserExercises(from: startDate, to: endDate)

        if let data = response?.data, !data.isEmpty {
            exercises = data
        } else {
            exercises = nil
        }
    }
}

// Shows a quick at-a-glance completion stat for the selected day.

private struct ExerciseDaySummaryCard: View {

    // MARK: Internal

    let exercises: [UserExerciseModel]

    var body: some View {
        HStack(spacing: 0) {
            summaryPill(
                icon: "checkmark.circle.fill",
                label: "Completed",
                value: "\(completedCount)/\(exercises.count)",
                color: Color.CustomColors.mutedRaspberry
            )

            Divider().frame(height: 36)

            summaryPill(
                icon: "clock.fill",
                label: "Total time",
                value: formattedMinutes,
                color: Color(hex: "9B6B52")
            )

            Divider().frame(height: 36)

            summaryPill(
                icon: "flame.fill",
                label: "Progress",
                value: "\(Int(overallProgress * 100))%",
                color: Color(hex: "4A7A9B")
            )
        }
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Day summary: \(completedCount) of \(exercises.count) exercises completed, \(formattedMinutes) total time, \(Int(overallProgress * 100)) percent progress")
        .task { await computeStats() }
    }

    // MARK: Private

    @State private var completedCount: Int = 0
    @State private var totalMinutes: Double = 0

    private var overallProgress: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(completedCount) / Double(exercises.count)
    }

    private var formattedMinutes: String {
        let mins = Int(totalMinutes) / 60
        let secs = Int(totalMinutes) % 60
        if mins > 0 { return "\(mins)m \(secs)s" }
        return "\(secs)s"
    }
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private func summaryPill(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundColor(color)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: value)

            Text(label).font(.caption2).foregroundStyle(.secondary)
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
        completedCount = completed
        totalMinutes = duration
    }

}

// One card per UserExerciseModel — loads ExerciseModel async.

private struct ExerciseHistoryCard: View {

    // MARK: Internal

    let userExercise: UserExerciseModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {

                // ── Text column ───────────────────────────────────────
                VStack(alignment: .leading, spacing: 6) {

                    // Level
                    if let level = exercise?.level {
                        Text(level.rawValue)
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(width: 56, height: 12)
                    }

                    // Name
                    if let name = exercise?.name {
                        Text(name)
                            .font(.title3.weight(.bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(width: 120, height: 18)
                    }

                    // Targeted body parts
                    if let parts = exercise?.targetedBodyParts, !parts.isEmpty {
                        Text(parts.joined(separator: " · "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    // Duration watched / total
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(durationLabel)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }

                Spacer()

                // ── Right column: thumbnail + ring ────────────────────
                VStack(alignment: .trailing, spacing: 8) {
                    // Thumbnail
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(hex: "F0D5C8"))

                        if let uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        } else {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.title2)
                                .foregroundColor(Color(hex: "9B6B52"))
                        }
                    }
                    .frame(width: 72, height: 72)

                    // Completion ring
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.15), lineWidth: 4)
                        Circle()
                            .trim(from: 0, to: completionPct)
                            .stroke(
                                completionPct >= 1.0 ? Color(hex: "4A8A62") : Color.CustomColors.mutedRaspberry,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.6), value: completionPct)

                        if completionPct >= 1.0 {
                            Image(systemName: "checkmark")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(Color(hex: "4A8A62"))
                        } else {
                            Text("\(Int(completionPct * 100))%")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(Color.CustomColors.mutedRaspberry)
                        }
                    }
                    .frame(width: 36, height: 36)
                }
            }

            // ── Progress bar ──────────────────────────────────────────
            if exercise != nil {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.12))
                        Capsule()
                            .fill(
                                completionPct >= 1.0
                                    ? Color(hex: "4A8A62")
                                    : Color.CustomColors.mutedRaspberry
                            )
                            .frame(width: geo.size.width * completionPct)
                            .animation(.easeInOut(duration: 0.6), value: completionPct)
                    }
                }
                .frame(height: 6)
                .padding(.top, 14)
            }

            // ── Tags ──────────────────────────────────────────────────
            if let tags = exercise?.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2.weight(.medium))
                                .foregroundColor(Color(hex: "9B6B52"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Color(hex: "F0D5C8"),
                                    in: Capsule()
                                )
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: Color(hex: "9B6B52").opacity(0.07), radius: 8, x: 0, y: 4)
        .task { await loadExercise() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(exercise.map { "\($0.name), \($0.level.rawValue)" } ?? "Exercise")
        .accessibilityValue(
            completionPct >= 1.0
                ? "Completed"
                : "\(Int(completionPct * 100)) percent completed"
        )
    }

    // MARK: Private

    @State private var exercise: ExerciseModel?
    @State private var uiImage: UIImage?
    @State private var completionPct: Double = 0

    private var durationLabel: String {
        guard let exercise else {
            return "\(Int(userExercise.videoDurationCompletedSeconds))s watched"
        }
        let watched = Int(userExercise.videoDurationCompletedSeconds)
        let total = Int(exercise.videoDurationSeconds)
        return "\(formattedSeconds(watched)) of \(formattedSeconds(total))"
    }

    private func formattedSeconds(_ s: Int) -> String {
        let m = s / 60; let sec = s % 60
        return m > 0 ? "\(m)m \(sec)s" : "\(sec)s"
    }

    private func loadExercise() async {
        exercise = await userExercise.exerciseModel
        completionPct = await userExercise.completionPercentage
        uiImage = await exercise?.image
    }
}
