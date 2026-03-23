import SwiftUI

struct DashboardExerciseCard: View {

    // MARK: Internal

    let stepsToday: Int
    let caloriesBurnedToday: Int
    let exerciseDurationToday: TimeInterval

    let stepsGoalProgress: Double
    let caloriesGoalProgress: Double
    let exerciseGoalProgress: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 18) {
                ExerciseRow(color: .red, icon: "figure.walk", value: "\(stepsToday) steps")
                ExerciseRow(color: .green, icon: "timer", value: formatSeconds(exerciseDurationToday))
                ExerciseRow(color: .orange, icon: "flame.fill", value: formatCalorie(Double(caloriesBurnedToday)))
            }

            Spacer()

            ActivityRingView(
                stepsGoalProgress: stepsGoalProgress,
                exerciseGoalProgress: exerciseGoalProgress,
                caloriesGoalProgress: caloriesGoalProgress
            )
            .frame(width: 130, height: 130)
        }
        .padding(16)
        .padding(.leading, 3)
        .background(Color("secondaryAppColor"))
        .dashboardCardStyle()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Exercise activity")
        .accessibilityIdentifier("dashboardExerciseCard")
    }

    // MARK: Private

    private func formatCalorie(_ calorie: Double) -> String {
        let measurement = Measurement(value: calorie, unit: UnitEnergy.kilocalories)

        return measurement.formatted(
            .measurement(
                width: .wide,
                usage: .food,
                numberFormatStyle: .number.precision(.fractionLength(0))
            )
        )
    }

    private func formatSeconds(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .dropLeading

        return formatter.string(from: seconds) ?? ""
    }

}

struct ExerciseRow: View {

    // MARK: Internal

    let color: Color
    let icon: String
    let value: String?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.caption.weight(.bold))
            }
            .accessibilityHidden(true)

            if let value {
                Text(value)
                    .font(.title3)
                    .fontWeight(.regular)
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeInOut, value: value)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
                    .accessibilityLabel("Loading \(icon) data")
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(value ?? "Loading")
        .accessibilityAddTraits(.updatesFrequently)
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

struct ActivityRingView: View {

    // MARK: Internal

    let stepsGoalProgress: Double
    let exerciseGoalProgress: Double
    let caloriesGoalProgress: Double

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)

            let outer = size / 2
            let middle = outer - ringWidth - spacing
            let inner = middle - ringWidth - spacing

            ZStack {
                PercentageRing(ringWidth: ringWidth, percent: stepsGoalProgress * 100, backgroundColor: Color.red.opacity(0.15), foregroundColors: [.red])
                    .frame(width: outer * 2, height: outer * 2)

                PercentageRing(ringWidth: ringWidth, percent: exerciseGoalProgress * 100, backgroundColor: Color.green.opacity(0.15), foregroundColors: [.green])
                    .frame(width: middle * 2, height: middle * 2)

                PercentageRing(ringWidth: ringWidth, percent: caloriesGoalProgress * 100, backgroundColor: Color.orange.opacity(0.15), foregroundColors: [.orange])
                    .frame(width: inner * 2, height: inner * 2)

            }
            .frame(width: size, height: size)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Activity rings")
            .accessibilityValue("Steps goal is \(Int(stepsGoalProgress * 100)) percent complete, exercise goal is \(Int(exerciseGoalProgress * 100)) percent complete, and stand goal is \(Int(caloriesGoalProgress * 100)) percent complete.")
            .accessibilityAddTraits(.updatesFrequently)
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let ringWidth: CGFloat = 14
    private let spacing: CGFloat = 2
}
