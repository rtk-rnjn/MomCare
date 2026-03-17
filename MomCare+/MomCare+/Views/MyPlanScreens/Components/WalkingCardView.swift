import SwiftUI

struct WalkingCardView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .font(.title3.weight(.medium))
                        .foregroundColor(Color(hex: "4A8A62"))
                        .accessibilityHidden(true)

                    Text("Walking")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                Spacer()

                if contentServiceHandler.currentSteps >= contentServiceHandler.targetSteps {
                    Label("Done", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color(hex: "4A8A62"))
                } else {
                    HStack {
                        Text(percentCompleted, format: .number.precision(.fractionLength(2)))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color(hex: "4A8A62"))
                            .contentTransition(reduceMotion ? .identity : .numericText(value: percentCompleted))
                            .onAppear { percentCompleted = contentServiceHandler.stepsProgress }
                            .onChange(of: contentServiceHandler.stepsProgress) { _, newValue in percentCompleted = newValue }
                            .animation(reduceMotion ? nil : .easeInOut(duration: 0.8), value: percentCompleted)

                        Text("%")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color(hex: "4A8A62"))
                    }
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(contentServiceHandler.currentSteps))")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    Text("Steps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(contentServiceHandler.targetSteps))")
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text("Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: "D4EDDA"))
        )
        .shadow(color: Color(hex: "4A8A62").opacity(0.08), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Walking")
        .accessibilityValue(
            contentServiceHandler.currentSteps >= contentServiceHandler.targetSteps
                ? "Goal completed, \(Int(contentServiceHandler.currentSteps)) steps"
                : "\(Int(contentServiceHandler.currentSteps)) of \(Int(contentServiceHandler.targetSteps)) steps, \(Int(contentServiceHandler.stepsProgress * 100)) percent"
        )
        .accessibilityAddTraits(.updatesFrequently)
        .task { updateProgress() }
        .onChange(of: contentServiceHandler.currentSteps) { updateProgress() }
        .onChange(of: contentServiceHandler.targetSteps) { updateProgress() }
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @State private var progress: Double = 0
    @State private var percentCompleted: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private func updateProgress() {
        progress = Double(contentServiceHandler.currentSteps) / Double(contentServiceHandler.targetSteps)
        percentCompleted = progress * 100
    }

}
