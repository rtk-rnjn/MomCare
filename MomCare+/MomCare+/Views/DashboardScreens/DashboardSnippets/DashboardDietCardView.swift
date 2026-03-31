import Foundation
import SwiftUI

struct DashboardDietCardView: View {
    // MARK: Internal

    let consumed: Double
    let goal: Double
    let recommended: Double

    var body: some View {
        Group {
            if experimentalUI {
                experimentedBody
            } else {
                productionBody
            }
        }
        .padding(16)
        .background(Color("secondaryAppColor"))
        .dashboardCardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calorie intake")
        .accessibilityValue("\(Int(consumed)) of \(Int(recommended)) calories consumed, \(Int(animatedProgress * 100)) percent")
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

    @AppStorage(FeatureFlagState.experimentalUI.rawValue, store: Database.shared.userDefaults) private var experimentalUI: Bool = false

    @State private var animatedProgress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var progress: Double {
        guard recommended > 0 else {
            return 0
        }

        return min(consumed / recommended, 1)
    }

    private var differenceText: String {
        let difference = goal - recommended
        guard difference != 0 else {
            return ""
        }

        return " (\(difference.formatted(.number.sign(strategy: .always()))))"
    }

    private var productionBody: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(MomCareAccent.primary)
                        .frame(width: 35, height: 35)

                    Image(systemName: "fork.knife")
                        .foregroundStyle(.white)
                }
                .accessibilityHidden(true)

                Text("\(Int(consumed)) / \(Int(recommended)) \(UnitEnergy.kilocalories.symbol)")
                    .font(.title3.weight(.regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .allowsTightening(true)
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeInOut, value: goal)
            }
            .layoutPriority(1)
            Spacer()

            VStack(spacing: 6) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.headline)
                    .fontWeight(.semibold)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(reduceTransparency ? Color(.systemGray4) : Color.gray.opacity(0.2))
                            .frame(height: 8)

                        Capsule()
                            .fill(MomCareAccent.primary)
                            .frame(
                                width: geo.size.width * max(animatedProgress, 0),
                                height: 8
                            )
                            .animation(reduceMotion ? nil : .easeInOut(duration: 0.9), value: abs(animatedProgress))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 8)
            }
        }
    }

    private var experimentedBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(consumed))")
                    .font(.title.weight(.bold))
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeInOut, value: consumed)

                Text("/ \(Int(recommended)) kcal\(differenceText)")
                    .font(.subheadline.weight(.regular))
                    .foregroundStyle(.secondary)
                    .animation(reduceMotion ? nil : .easeInOut, value: recommended)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.12))
                        .frame(height: 2)

                    Rectangle()
                        .fill(MomCareAccent.primary)
                        .frame(width: geo.size.width * max(animatedProgress, 0), height: 2)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.9), value: animatedProgress)
                }
            }
            .frame(height: 2)

            HStack {
                Image(systemName: "fork.knife")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                Text("\(Int(animatedProgress * 100))% of daily goal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeInOut, value: animatedProgress)
            }
        }
    }
}
