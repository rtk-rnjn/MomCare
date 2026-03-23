import SwiftUI
import Foundation

struct DashboardDietCardView: View {

    // MARK: Internal

    let consumed: Double
    let goal: Double

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(MomCareAccent.primary)
                        .frame(width: 35, height: 35)

                    Image(systemName: "fork.knife")
                        .foregroundColor(.white)
                }
                .accessibilityHidden(true)

                Text("\(Int(consumed)) / \(Int(goal)) \(UnitEnergy.kilocalories.symbol)")
                    .font(.title3.weight(.regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeInOut, value: goal)
            }

            Spacer()

            Label("\(Int(animatedProgress * 100))%", systemImage: "flame")
                .font(.title3.weight(.regular))
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(reduceMotion ? nil : .easeInOut, value: animatedProgress)
        }
        .padding(16)
        .background(Color("secondaryAppColor"))
        .dashboardCardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calorie intake")
        .accessibilityValue("\(Int(consumed)) of \(Int(goal)) calories consumed, \(Int(animatedProgress * 100)) percent")
        .accessibilityAddTraits([.isButton, .updatesFrequently])
        .accessibilityHint("Double tap to view diet plan")
        .accessibilityIdentifier("dashboardDietCard")
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeInOut) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.9)) {
                animatedProgress = newValue
            }
        }
    }

    // MARK: Private

    @State private var animatedProgress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(consumed / goal, 1)
    }
}
