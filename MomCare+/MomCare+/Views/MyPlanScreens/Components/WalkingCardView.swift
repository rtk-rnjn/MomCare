

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

                    Text("Walking")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                Spacer()

                if healthKitHandler.currentSteps >= healthKitHandler.targetSteps {
                    Label("Done", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color(hex: "4A8A62"))
                } else {
                    Text("\(Int(healthKitHandler.stepsProgress))%")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color(hex: "4A8A62"))
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(healthKitHandler.currentSteps))")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    Text("Steps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(healthKitHandler.targetSteps))")
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
                        .fill(Color.secondary.opacity(0.15))

                    Capsule()
                        .fill(Color(hex: "4A8A62"))
                        .frame(width: geo.size.width * progress)
                        .animation(.easeInOut(duration: 0.8), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: "D4EDDA"))
        )
        .shadow(color: Color(hex: "4A8A62").opacity(0.08), radius: 8, x: 0, y: 4)
        .task {
            progress = Double(healthKitHandler.currentSteps) / Double(healthKitHandler.targetSteps)
            progress = min(progress, 1)
            percentCompleted = Int(progress * 100)
        }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler
    @State private var progress: Double = 0
    @State private var percentCompleted: Int = 0

}
