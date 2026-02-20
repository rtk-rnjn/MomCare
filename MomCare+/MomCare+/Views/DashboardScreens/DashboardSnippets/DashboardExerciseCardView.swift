import SwiftUI

struct DashboardExerciseCard: View {

    // MARK: Internal

    let minutes: Double
    let calories: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 18) {
                ExerciseRow(color: .red, icon: "figure.walk", value: "\(Int(healthKitHandler.currentSteps)) Steps")
                ExerciseRow(color: .green, icon: "timer", value: "\(Int(minutes)) Min")
                ExerciseRow(color: .orange, icon: "flame.fill", value: "\(Int(calories)) Kcal")
            }

            Spacer()

            ActivityRingView(
                move: healthKitHandler.stepsProgress,
                exercise: exerciseProgress,
                stand: standProgress
            )
            .frame(width: 130, height: 130)
        }
        .padding(16)
        .padding(.leading, 3)
        .background(Color("secondaryAppColor"))
        .dashboardCardStyle()
        .task {
            await healthKitHandler.fetchTotalDuration()
            let completedDuration = healthKitHandler.userExercises.reduce(0) { $0 + $1.videoDurationCompletedSeconds }

            exerciseProgress = healthKitHandler.totalExerciseDuration / completedDuration
        }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

    @State private var exerciseProgress: Double = 0
    @State private var standProgress: Double = 0

}

struct ExerciseRow: View {
    let color: Color
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
                    .accessibilityHidden(true)
            }

            Text(value)
                .font(.title3)
                .fontWeight(.regular)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: value)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(value)
    }
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
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Activity rings")
        .accessibilityValue("Steps \(Int(move * 100))%, exercise \(Int(exercise * 100))%, stand \(Int(stand * 100))%")
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var animatedMove: Double = 0
    @State private var animatedExercise: Double = 0
    @State private var animatedStand: Double = 0

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
