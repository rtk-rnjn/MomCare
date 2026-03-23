import SwiftUI
import Charts

struct NutritionGraphRootView: View {

    // MARK: Internal

    let calorieIntake: Measurement<UnitEnergy>
    let calorieGoal: Measurement<UnitEnergy>

    let nutritionIntakeTotals: NutritionTotals?
    let nutritionGoalTotals: NutritionTotals?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    summaryStrip
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 20)

                    LazyVStack(spacing: 12) {
                        ForEach(Array(VitalKind.allCases.enumerated()), id: \.element.id) { index, kind in
                            NavigationLink {
                                VitalDetailView(
                                    kind: kind,
                                    todayValue: todayValue(for: kind),
                                    targetValue: targetValue(for: kind)
                                )
                            } label: {
                                VitalCardRow(
                                    kind: kind,
                                    todayValue: todayValue(for: kind),
                                    targetValue: targetValue(for: kind)
                                )
                            }
                            .buttonStyle(.plain)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 14)
                            .animation(
                                reduceMotion ? nil :
                                    .easeInOut
                                    .delay(Double(index) * 0.055),
                                value: appeared
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                withAnimation(reduceMotion ? nil : .easeInOut) {
                    appeared = true
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    @State private var appeared = false

    private var summaryStrip: some View {
        let remaining = calorieGoal - calorieIntake
        let isOver = calorieIntake > calorieGoal

        return HStack(spacing: 0) {
            summaryPill(
                label: "Consumed",
                value: calorieIntake.formatted(.measurement(width: .abbreviated, usage: .food)),
                color: Color(hex: "E3B34B"),
                icon: "flame.fill"
            )

            Divider()

            summaryPill(
                label: isOver ? "Over by" : "Remaining",
                value: (isOver ? calorieIntake - calorieGoal : remaining).formatted(.measurement(width: .abbreviated, usage: .food)),
                color: isOver ? .red : Color(hex: "6E8B6F"),
                icon: isOver ? "exclamationmark.triangle.fill" : "leaf.fill"
            )

            Divider()

            summaryPill(
                label: "Target",
                value: calorieGoal.formatted(.measurement(width: .abbreviated, usage: .food)),
                color: Color(.systemGray3),
                icon: "target"
            )
        }
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calorie summary")
        .accessibilityValue({
            let intake = calorieIntake.formatted(.measurement(width: .wide, usage: .food))
            let goal = calorieGoal.formatted(.measurement(width: .wide, usage: .food))
            let delta = (isOver ? calorieIntake - calorieGoal : remaining)
                .formatted(.measurement(width: .wide, usage: .food))

            return "\(intake) consumed. \(isOver ? "Over by" : "Remaining") \(delta). Goal \(goal)."
        }())
    }

    private func summaryPill(label: String, value: String, color: Color, icon: String) -> some View {
        VStack(spacing: 3) {
            if differentiateWithoutColor {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
            }
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundColor(color)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(reduceMotion ? nil : .easeInOut, value: value)
        }
        .frame(maxWidth: .infinity)
    }

    private func todayValue(for kind: VitalKind) -> Double {
        switch kind {
        case .calories: return nutritionIntakeTotals?.calories ?? 0
        case .protein: return nutritionIntakeTotals?.protein ?? 0
        case .carbs: return nutritionIntakeTotals?.carbs ?? 0
        case .fats: return nutritionIntakeTotals?.fats ?? 0
        case .sugar: return nutritionIntakeTotals?.sugar ?? 0
        case .sodium: return nutritionIntakeTotals?.sodium ?? 0
        }
    }

    private func targetValue(for kind: VitalKind) -> Double {
        switch kind {
        case .calories: return nutritionGoalTotals?.calories ?? 0
        case .protein: return nutritionGoalTotals?.protein ?? 0
        case .carbs: return nutritionGoalTotals?.carbs ?? 0
        case .fats: return nutritionGoalTotals?.fats ?? 0
        case .sugar: return nutritionGoalTotals?.sugar ?? 0
        case .sodium: return nutritionGoalTotals?.sodium ?? 0
        }
    }
}

private struct VitalCardRow: View {

    // MARK: Internal

    let kind: VitalKind
    let todayValue: Double
    let targetValue: Double

    var body: some View {
        HStack(spacing: 14) {

            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(kind.color.opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: kind.sfSymbol)
                    .font(.title3.weight(.medium))
                    .foregroundColor(kind.color)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(kind.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(formattedValue(todayValue)) \(kind.unitLabel)")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(kind.color)
                        .monospacedDigit()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.systemGray5))
                        Capsule()
                            .fill(kind.color)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 6)
                .accessibilityHidden(true)

                HStack {
                    Text(progressLabel + " of daily target")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Target: \(formattedValue(targetValue)) \(kind.unitLabel)")
                        .font(.caption)
                        .foregroundStyle(Color(.systemGray3))
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(.systemGray3))
                .accessibilityHidden(true)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind.rawValue)
        .accessibilityValue(
            targetValue > 0
                ? "\(formattedValue(todayValue)) \(kind.unitLabel), \(progressLabel) of target"
                : "\(formattedValue(todayValue)) \(kind.unitLabel)"
        )
        .accessibilityHint("Double tap to view detailed history")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: Private

    private var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(todayValue / targetValue, 1.0)
    }

    private var progressLabel: String {
        "\(Int(progress * 100))%"
    }

    private func formattedValue(_ v: Double) -> String {
        if kind == .calories || kind == .sodium {
            return v.formatted(.number.precision(.fractionLength(0)))
        } else {
            return v.formatted(.number.precision(.fractionLength(1)))
        }
    }
}
