import SwiftUI

struct ProgressCardView: View {

    // MARK: Internal

    let caloriesConsumed: Double
    let caloriesTarget: Double

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ProgressRingView(
                progress: calorieProgress,
                consumed: caloriesConsumed,
                target: caloriesTarget
            )
            .layoutPriority(1)

            VStack(alignment: .leading, spacing: 12) {
                MacroBarRow(
                    title: "Protein",
                    consumed: healthKitHandler.nurtitionConsumedTotals?.proteinMass,
                    target: healthKitHandler.nutritionTargetTotals?.proteinMass,
                    color: Color(hex: "A7C0CD")
                )

                MacroBarRow(
                    title: "Carbs",
                    consumed: healthKitHandler.nurtitionConsumedTotals?.carbsMass,
                    target: healthKitHandler.nutritionTargetTotals?.carbsMass,
                    color: Color(hex: "6E8B6F")
                )

                MacroBarRow(
                    title: "Fats",
                    consumed: healthKitHandler.nurtitionConsumedTotals?.fatsMass,
                    target: healthKitHandler.nutritionTargetTotals?.fatsMass,
                    color: Color(hex: "E3B34B")
                )
            }
        }
        .padding(18)
        .background {
            if #available(iOS 26.0, *) {
                ConcentricRectangle()
                    .fill(Color(.systemBackground))
            } else {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

    private var calorieProgress: Double {
        guard caloriesTarget > 0 else { return 0 }
        return min(caloriesConsumed / caloriesTarget, 1.0)
    }

}

struct ProgressRingView: View {

    // MARK: Internal

    let progress: Double
    let consumed: Double
    let target: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 14)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    MomCareAccent.primary,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: progress)

            VStack(spacing: 2) {
                Group {
                    if showPercentage {
                        Text("\(percentage)%")
                            .contentTransition(.numericText())
                            .transition(.opacity.combined(with: .scale))
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: percentage)
                            .font(.system(size: 24, weight: .bold, design: .default))
                    } else {
                        HStack(spacing: 2) {
                            Text(Int(consumed), format: .number)
                                .contentTransition(.numericText())
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: Int(consumed))

                            Text("/")

                            Text(Int(target), format: .number)
                        }
                        .transition(.opacity.combined(with: .scale))
                        .font(.headline)
                    }
                }

                Text("Kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 110, height: 110)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showPercentage.toggle()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calorie progress ring")
        .accessibilityValue("\(Int(consumed)) of \(Int(target)) kilocalories, \(percentage) percent")
        .accessibilityHint("Tap to toggle between amount and percentage")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: Private

    @State private var showPercentage = false

    private var percentage: Int {
        guard target > 0 else { return 0 }
        return Int((consumed / target) * 100)
    }

}

struct MacroBarRow: View {

    // MARK: Internal

    let title: String
    let consumed: Measurement<UnitMass>?
    let target: Measurement<UnitMass>?
    let color: Color

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)

                Spacer()

                Group {
                    if showPercentage {
                        Text(percentageText)
                            .contentTransition(.numericText())
                    } else {
                        HStack(spacing: 4) {
                            if let consumed {
                                Text(consumed.formattedOneDecimal)
                            } else {
                                Text("-")
                            }

                            Text("/")

                            if let target {
                                Text(target.formattedOneDecimal)
                            } else {
                                Text("-")
                            }
                        }
                        .contentTransition(.numericText())
                    }
                }
                .font(.caption)
                .foregroundColor(.primary)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showPercentage)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))

                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * progress)
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
            }
            .frame(height: 14)
            .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showPercentage.toggle()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(
            consumed != nil
                ? "\(consumed!.formattedOneDecimal) of \(target?.formattedOneDecimal ?? "-"), \(percentageText)"
                : "No data"
        )
        .accessibilityHint("Tap to toggle between amount and percentage")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: Private

    @State private var showPercentage = false

    // MARK: - Computed

    private var progress: Double {
        guard let consumed, let target else {
            return 0
        }

        let consumedValue = consumed.converted(to: target.unit).value
        let targetValue = target.value

        guard targetValue > 0 else { return 0 }

        return min(consumedValue / targetValue, 1.0)
    }

    private var percentageText: String {
        "\(Int(progress * 100))%"
    }

}
