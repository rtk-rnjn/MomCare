import SwiftUI

struct MyPlanExerciseHelpView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    intro
                    weeklyProgressSection
                    Divider()
                    walkingSection
                    Divider()
                    breathingSection
                    Divider()
                    exerciseCardSection
                    Divider()
                    completionSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("How to Use Your Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                        .accessibilityLabel("Close guide")
                        .accessibilityHint("Dismisses this help screen")
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your exercise plan brings together walking, breathing, and guided workouts in one place. This guide explains every card, indicator, and action available.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var weeklyProgressSection: some View {
        LegendSection(title: "Weekly Progress Card", systemImage: "chart.bar.fill") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {

                    LegendRow(
                        badge: DayRingBadge(progress: 1.0, isToday: false),
                        label: "Day ring — completed",
                        description: "A filled ring with a checkmark means all activities for that day are done."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: DayRingBadge(progress: 0.5, isToday: true),
                        label: "Day ring — in progress (today)",
                        description: "The current day's ring fills in real time as you complete activities. The day label appears in black to highlight it."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: DayRingBadge(progress: 0.0, isToday: false),
                        label: "Day ring — not started",
                        description: "An empty ring means no activities were completed on that day."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: ProgressBarBadge(fraction: 0.6, color: Color.CustomColors.mutedRaspberry),
                        label: "Overall progress bar",
                        description: "The bar below the rings shows your combined completion across all exercises, breathing, and walking for the day as a percentage."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: SymbolLegendBadge(systemName: "target", color: Color.CustomColors.mutedRaspberry),
                        label: "Total counter",
                        description: "Shows how many individual activities you have completed out of the total planned for today, including exercises, breathing, and walking."
                    )
                }
            }
        }
    }

    private var walkingSection: some View {
        LegendSection(title: "Walking Card", systemImage: "figure.walk") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {

                    LegendRow(
                        badge: ProgressBarBadge(fraction: 0.45, color: Color(hex: "4A8A62")),
                        label: "Step progress bar",
                        description: "Fills from left to right as your step count rises toward the daily goal. Data is read live from HealthKit."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: SymbolLegendBadge(systemName: "checkmark.circle.fill", color: Color(hex: "4A8A62")),
                        label: "Goal reached",
                        description: "A green \"Done\" label with a checkmark replaces the percentage once your step count meets or exceeds the target."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: PercentBadge(value: "72%", color: Color(hex: "4A8A62")),
                        label: "Live percentage",
                        description: "Shows the percentage of your step goal completed. Updates automatically as new step data arrives from HealthKit."
                    )
                }
            }
        }
    }

    private var breathingSection: some View {
        LegendSection(title: "Breathing Card", systemImage: "lungs.fill") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {

                    LegendRow(
                        badge: LevelBadge(label: "Beginner", color: Color(hex: "4A7A9B")),
                        label: "Difficulty level",
                        description: "Shows the difficulty of the breathing exercise. The guided session is designed to be safe and calming for pregnancy."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: PercentBadge(value: "0%", color: Color(hex: "4A7A9B")),
                        label: "Completion percentage",
                        description: "Tracks how much of the breathing session you have completed today. Progress is saved automatically when you close the session."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: PlayButtonBadge(label: "Start", color: Color(hex: "4A7A9B")),
                        label: "Start / Replay",
                        description: "Tap to begin the guided breathing session. Once completed, the button changes to \"Replay\" if you want to do it again."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: SymbolLegendBadge(systemName: "info.circle.fill", color: Color(hex: "4A7A9B").opacity(0.5)),
                        label: "Info button",
                        description: "Tap the info icon in the top-right corner of the card to read details about the breathing technique and its benefits."
                    )
                }
            }
        }
    }

    private var exerciseCardSection: some View {
        LegendSection(title: "Exercise Cards", systemImage: "figure.strengthtraining.traditional") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {

                    LegendRow(
                        badge: LevelBadge(label: "Moderate", color: Color(hex: "9B6B52")),
                        label: "Difficulty level",
                        description: "Each card shows the exercise level — Beginner, Moderate, or Advanced — beneath the exercise name."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: PercentBadge(value: "50%", color: Color(hex: "9B6B52")),
                        label: "Video completion",
                        description: "Shows how far through the exercise video you watched before closing. Reaching 100% counts the exercise as complete."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: PlayButtonBadge(label: "Start", color: Color(hex: "9B6B52")),
                        label: "Start / Replay",
                        description: "Opens the exercise video player. Close the player when you are done — your progress up to that point is saved automatically."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: ExerciseThumbnailBadge(),
                        label: "Exercise thumbnail",
                        description: "A preview image of the exercise appears in the top-right corner of each card. A placeholder icon is shown while the image loads."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: SymbolLegendBadge(systemName: "info.circle.fill", color: Color(hex: "9B6B52").opacity(0.5)),
                        label: "Info button",
                        description: "Tap the info icon to open a detail sheet with a description of the exercise, target muscles, and safety notes for pregnancy."
                    )
                }
            }
        }
    }

    private var completionSection: some View {
        LegendSection(title: "Completion States", systemImage: "checkmark.seal.fill") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {

                    LegendRow(
                        badge: PercentBadge(value: "100%", color: Color.CustomColors.mutedRaspberry),
                        label: "Fully completed",
                        description: "100% means the full session duration was watched or the step goal was met. The Start button changes to Replay."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: PercentBadge(value: "60%", color: .secondary),
                        label: "Partially completed",
                        description: "Any value between 1% and 99% means the session was started but not finished. You can continue by tapping Start again."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: PercentBadge(value: "0%", color: .secondary),
                        label: "Not started",
                        description: "0% means the activity has not been attempted today."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: SymbolLegendBadge(systemName: "arrow.clockwise", color: .secondary),
                        label: "Pull to refresh",
                        description: "Pull down on the exercise list to fetch a fresh set of exercises from the server. Your existing completion progress is preserved."
                    )
                }
            }
        }
    }
}

private struct LegendSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}

private struct LegendCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
    }
}

private struct LegendRow<Badge: View>: View {
    let badge: Badge
    let label: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            badge
                .frame(width: 50, height: 50)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label). \(description)")
    }
}

private struct LegendDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 64)
            .accessibilityHidden(true)
    }
}

// Mini day ring
private struct DayRingBadge: View {
    let progress: Double
    let isToday: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("Wed")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(isToday ? .black : Color.CustomColors.mutedRaspberry)

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(Color.CustomColors.mutedRaspberry,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                if progress >= 1.0 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color.CustomColors.mutedRaspberry)
                }
            }
            .frame(width: 28, height: 28)
        }
        .frame(width: 50, height: 50)
    }
}

// Mini progress bar
private struct ProgressBarBadge: View {
    let fraction: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.secondary.opacity(0.15))
                Capsule().fill(color).frame(width: geo.size.width * fraction)
            }
        }
        .frame(height: 8)
        .padding(.vertical, 21)
        .frame(width: 50, height: 50)
    }
}

// Symbol icon badge
private struct SymbolLegendBadge: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.title)
            .foregroundStyle(color)
            .frame(width: 50, height: 50)
    }
}

// Percentage text badge
private struct PercentBadge: View {
    let value: String
    let color: Color

    var body: some View {
        Text(value)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .frame(width: 50, height: 50)
    }
}

// Difficulty level label
private struct LevelBadge: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .frame(width: 50, height: 50)
    }
}

// Mini play button
private struct PlayButtonBadge: View {
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "play.fill")
                .font(.system(size: 8))
            Text(label)
                .font(.system(size: 9, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .frame(width: 50, height: 50)
    }
}

// Exercise thumbnail placeholder
private struct ExerciseThumbnailBadge: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(hex: "D4A08A").opacity(0.25))
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title3)
                .foregroundColor(Color(hex: "9B6B52"))
        }
        .frame(width: 50, height: 50)
    }
}

// Mini water drop
private struct WaterDropBadge: View {
    var body: some View {
        ZStack {
            // Simplified drop silhouette
            Image(systemName: "drop.fill")
                .font(.system(size: 30))
                .foregroundColor(Color(hex: "6BAED6").opacity(0.25))

            Image(systemName: "drop.fill")
                .font(.system(size: 30))
                .foregroundColor(Color(hex: "6BAED6"))
                .mask(alignment: .bottom) {
                    Rectangle().frame(height: 12)
                }

            Text("60%")
                .font(.system(size: 7, weight: .bold))
                .foregroundColor(.white)
                .offset(y: 4)
        }
        .frame(width: 50, height: 50)
    }
}

// Quick-add water pills
private struct QuickAddWaterBadge: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                miniPill("+200")
                miniPill("+300")
            }
            HStack(spacing: 3) {
                miniPill("+150")
                miniPill("+500")
            }
        }
        .frame(width: 50, height: 50)
    }

    // MARK: Private

    private func miniPill(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 6, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color(hex: "5B9BD5"), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}
