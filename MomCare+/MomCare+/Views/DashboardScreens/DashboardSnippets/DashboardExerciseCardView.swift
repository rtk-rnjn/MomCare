import SwiftUI

struct DashboardExerciseCard: View {

    // MARK: Internal

    let calories: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 18) {
                ExerciseRow(color: .red, icon: "figure.walk", value: "\(Int(contentServiceHandler.currentSteps)) Steps")
                ExerciseRow(color: .green, icon: "timer", value: displaySeconds)
                ExerciseRow(color: .orange, icon: "flame.fill", value: "\(Int(calories)) Kcal")
            }

            Spacer()

            ActivityRingView(
                move: contentServiceHandler.stepsProgress,
                exercise: exerciseProgress,
                stand: standProgress
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
        .onAppear {
            displaySeconds = formatSeconds(contentServiceHandler.totalUserExercisesCompletionDuration)

            updateExerciseProgress()
        }
        .onChange(of: contentServiceHandler.userExercises) {
            displaySeconds = formatSeconds(contentServiceHandler.totalUserExercisesCompletionDuration)

            updateExerciseProgress()
        }
    }

    // MARK: Private

    @State private var displaySeconds: String?

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler

    @State private var exerciseProgress: Double = 0
    @State private var standProgress: Double = 0

    private func formatSeconds(_ seconds: Double) -> String {
        let duration = Measurement(value: seconds, unit: UnitDuration.seconds)

        let totalSeconds = Int(duration.value)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60

        if minutes == 0 {
            return "\(remainingSeconds) sec"
        }

        return remainingSeconds == 0 ? "\(minutes) min" : "\(minutes) min, \(remainingSeconds) sec"

    }

    private func updateExerciseProgress() {
        if contentServiceHandler.totalUserExercisesDuration > 0 {
            exerciseProgress = contentServiceHandler.totalUserExercisesCompletionDuration / contentServiceHandler.totalUserExercisesDuration
        } else {
            exerciseProgress = 0
        }
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
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: value)
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

    let move: Double
    let exercise: Double
    let stand: Double

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)

            let outer = size / 2
            let middle = outer - ringWidth - spacing
            let inner = middle - ringWidth - spacing

            ZStack {
                Circle()
                    .stroke(Color.red.opacity(0.15), lineWidth: ringWidth)
                    .frame(width: outer * 2, height: outer * 2)

                Circle()
                    .stroke(Color.green.opacity(0.15), lineWidth: ringWidth)
                    .frame(width: middle * 2, height: middle * 2)

                Circle()
                    .stroke(Color.orange.opacity(0.15), lineWidth: ringWidth)
                    .frame(width: inner * 2, height: inner * 2)

                ring(progress: animatedMove, color: .red, size: outer * 2)

                ring(progress: animatedExercise, color: .green, size: middle * 2)

                ring(progress: animatedStand, color: .orange, size: inner * 2)
            }
            .frame(width: size, height: size)
            .onAppear {
                animateRings()
            }
            .onChange(of: move) { animateRings() }
            .onChange(of: exercise) { animateRings() }
            .onChange(of: stand) { animateRings() }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Activity rings")
            .accessibilityValue("Move \(Int(move * 100)) percent, Exercise \(Int(exercise * 100)) percent, Stand \(Int(stand * 100)) percent")
            .accessibilityAddTraits(.updatesFrequently)
        }
    }

    // MARK: Private

    @State private var animatedMove: Double = 0
    @State private var animatedExercise: Double = 0
    @State private var animatedStand: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let ringWidth: CGFloat = 14
    private let spacing: CGFloat = 2

    private func ring(progress: Double, color: Color, size: CGFloat) -> some View {
        Circle()
            .trim(from: 0, to: clamp(progress))
            .stroke(color, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: size, height: size)
    }

    private func animateRings() {
        if reduceMotion {
            animatedMove = move
            animatedExercise = exercise
            animatedStand = stand
        } else {
            withAnimation(.easeInOut(duration: 0.9)) {
                animatedMove = move
                animatedExercise = exercise
                animatedStand = stand
            }
        }
    }

    private func clamp(_ value: Double) -> Double {
        max(0, min(value, 1))
    }
}
