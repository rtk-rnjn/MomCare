import Foundation
import SwiftUI

struct DashboardDietCardView: View {
    // MARK: Internal

    let consumed: Double
    let goal: Double
    let recommended: Double

    var body: some View {
        productionBody
        .padding(16)
        .background(Color("secondaryAppColor"))
        .dashboardCardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "a11y_calorie_intake_label"))
        .accessibilityValue("\(Int(consumed)) of \(Int(recommended)) calories consumed, \(Int(animatedProgress * 100)) percent")
        .accessibilityAddTraits([.isButton, .updatesFrequently])
        .accessibilityHint(String(localized: "a11y_diet_card_hint"))
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
        guard recommended > 0 else {
            return 0
        }

        return min(consumed / recommended, 1)
    }

    private var productionBody: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .imageScale(.medium)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(MomCareAccent.primary, in: Circle())
                    .accessibilityHidden(true)

                HStack(spacing: 4) {
                    Text(consumed, format: .number.precision(.fractionLength(0)))
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: consumed)

                    Text("/")

                    Text(recommended, format: .number.precision(.fractionLength(0)))
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: recommended)

                    Text(UnitEnergy.kilocalories.symbol)
                }
                .font(.title3.weight(.regular))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
            }
            .layoutPriority(1)

            Spacer()

            VStack(spacing: 6) {
                Text(animatedProgress, format: .percent.precision(.fractionLength(2)))
                    .font(.headline.weight(.semibold))
                    .contentTransition(reduceMotion ? .identity : .numericText(countsDown: false))
                    .animation(reduceMotion ? nil : .easeInOut, value: animatedProgress)

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
}
