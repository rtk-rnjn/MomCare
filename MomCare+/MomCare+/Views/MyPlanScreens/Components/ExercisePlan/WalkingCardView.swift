import SwiftUI
import TipKit

struct WalkingCardView: View {
    // MARK: Internal

    let stepsToday: Double
    let stepsGoal: Double

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color(hex: "4A8A62"))
                        .accessibilityHidden(true)

                    Text("Walking")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }

                Spacer()

                if stepsToday >= stepsGoal {
                    Label("Done", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "4A8A62"))
                } else {
                    HStack {
                        Text(percentCompleted, format: .number.precision(.fractionLength(2)))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(hex: "4A8A62"))
                            .contentTransition(reduceMotion ? .identity : .numericText(value: percentCompleted))
                            .animation(reduceMotion ? nil : .easeInOut(duration: 0.8), value: percentCompleted)

                        Text("%")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(hex: "4A8A62"))
                    }
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(stepsToday))")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    Text("Steps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(stepsGoal))")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("Goal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(reduceTransparency ? Color(.systemGray4) : Color.secondary.opacity(0.15))

                    Capsule()
                        .fill(Color(hex: "4A8A62"))
                        .frame(width: geo.size.width * progress)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.8), value: progress)
                }
            }
            .frame(height: 8)
            .accessibilityHidden(true)
        }
        .popoverTip(tip, arrowEdge: .top)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: "D4EDDA"))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Walking")
        .accessibilityValue(
            stepsToday >= stepsGoal
                ? "Goal completed, \(Int(stepsToday)) steps"
                : "\(Int(stepsToday)) of \(Int(stepsGoal)) steps, \(Int(progress * 100)) percent"
        )
        .accessibilityAddTraits(.updatesFrequently)
        .onAppear { updateProgress() }
        .onChange(of: stepsToday) { updateProgress() }
        .onChange(of: stepsGoal) { updateProgress() }
    }

    // MARK: Private

    @State private var progress: Double = 0
    @State private var percentCompleted: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let tip = MomCareTips.ExercisePlan.WalkingCardTapTip()

    private func updateProgress() {
        guard stepsGoal > 0 else {
            progress = 0
            percentCompleted = 0
            return
        }

        progress = min(Double(stepsToday) / Double(stepsGoal), 1.0)
        percentCompleted = progress * 100
    }
}
