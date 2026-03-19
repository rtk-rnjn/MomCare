import SwiftUI
import Charts

struct NutritionGraphRootView: View {

    // MARK: Internal

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
                                .environmentObject(contentServiceHandler)
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
                                    .spring(response: 0.45, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.055),
                                value: appeared
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    @State private var appeared = false

    private var summaryStrip: some View {
        let consumed = contentServiceHandler.nurtitionConsumedTotals?.calories ?? 0
        let target = contentServiceHandler.nutritionTargetTotals?.calories ?? 0
        let remaining = max(target - consumed, 0)
        let isOver = consumed > target

        return HStack(spacing: 0) {
            summaryPill(
                label: "Consumed",
                value: "\(Int(consumed)) \(UnitEnergy.kilocalories.symbol)",
                color: Color(hex: "E3B34B"),
                icon: "flame.fill"
            )

            Divider().frame(height: 36)

            summaryPill(
                label: isOver ? "Over by" : "Remaining",
                value: "\(Int(isOver ? consumed - target : remaining)) \(UnitEnergy.kilocalories.symbol)",
                color: isOver ? .red : Color(hex: "6E8B6F"),
                icon: isOver ? "exclamationmark.triangle.fill" : "leaf.fill"
            )

            Divider().frame(height: 36)

            summaryPill(
                label: "Target",
                value: "\(Int(target)) \(UnitEnergy.kilocalories.symbol)",
                color: Color(.systemGray3),
                icon: "target"
            )
        }
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calorie summary")
        .accessibilityValue(
            "Consumed \(Int(consumed)) kilocalories. \(isOver ? "Over by" : "Remaining") \(Int(isOver ? consumed - target : remaining)) kilocalories. Target \(Int(target)) kilocalories."
        )
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
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
    }

    private func todayValue(for kind: VitalKind) -> Double {
        let t = contentServiceHandler.nurtitionConsumedTotals
        switch kind {
        case .calories: return t?.calories ?? 0
        case .protein: return t?.protein ?? 0
        case .carbs: return t?.carbs ?? 0
        case .fats: return t?.fats ?? 0
        case .sugar: return t?.sugar ?? 0
        case .sodium: return t?.sodium ?? 0
        }
    }

    private func targetValue(for kind: VitalKind) -> Double {
        let g = contentServiceHandler.nutritionTargetTotals
        switch kind {
        case .calories: return g?.calories ?? 0
        case .protein: return g?.protein ?? 0
        case .carbs: return g?.carbs ?? 0
        case .fats: return g?.fats ?? 0
        case .sugar: return g?.sugar ?? 0
        case .sodium: return g?.sodium ?? 0
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

struct MacroChartPreview: View {

    // MARK: Internal

    let protein: Double
    let carbs: Double
    let fats: Double
    let proteinTarget: Double
    let carbsTarget: Double
    let fatsTarget: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Macros")
                .font(.headline.weight(.bold))
                .padding(.horizontal, 20)
                .padding(.top, 20)

            Chart(bars) { bar in
                BarMark(
                    x: .value("Macro", bar.label),
                    y: .value("Grams", bar.consumed),
                    width: .ratio(0.4)
                )
                .foregroundStyle(bar.color)
                .cornerRadius(6)
                .accessibilityLabel(bar.label)
                .accessibilityValue("\(Int(bar.consumed)) grams consumed, target \(Int(bar.target)) grams")

                RuleMark(
                    xStart: .value("Macro", bar.label),
                    xEnd: .value("Macro", bar.label),
                    y: .value("Target", bar.target)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [4]))
                .foregroundStyle(bar.color.opacity(0.45))
                .annotation(position: .top, alignment: .center) {
                    Text("\(Int(bar.target))g")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(bar.color.opacity(0.7))
                }
                .accessibilityHidden(true)
            }
            .chartXAxis {
                AxisMarks { _ in AxisValueLabel().font(.caption.weight(.medium)) }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4, dash: [3]))
                        .foregroundStyle(Color(.systemGray4))
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(Int(v))g").font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(height: 200)
            .padding(.horizontal, 20)

            HStack(spacing: 16) {
                ForEach(bars) { bar in
                    HStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 2).fill(bar.color).frame(width: 12, height: 12)
                        Text(bar.label).font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: 320)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: Private

    private struct Bar: Identifiable {
        let id: UUID = .init()
        let label: String
        let consumed: Double
        let target: Double
        let color: Color
    }

    private var bars: [Bar] { [
        .init(label: "Protein", consumed: protein, target: proteinTarget, color: Color(hex: "A7C0CD")),
        .init(label: "Carbs", consumed: carbs, target: carbsTarget, color: Color(hex: "6E8B6F")),
        .init(label: "Fats", consumed: fats, target: fatsTarget, color: Color(hex: "F4A460"))
    ] }

}

struct NutritionCardSection: View {

    // MARK: Internal

    var body: some View {
        ProgressCardView(
            caloriesConsumed: contentServiceHandler.nurtitionConsumedTotals?.calories ?? 0,
            caloriesTarget: contentServiceHandler.nutritionTargetTotals?.calories ?? 0,
            originalCaloriesTarget: contentServiceHandler.originalNutritionTargetTotals?.calories ?? 0
        )
        .containerShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
        .contextMenu {
            Button {
                showGraph = true
            } label: {
                Label("Show Pretty Graph", systemImage: "chart.bar.xaxis")
            }
        } preview: {
            MacroChartPreview(
                protein: contentServiceHandler.nurtitionConsumedTotals?.protein ?? 0,
                carbs: contentServiceHandler.nurtitionConsumedTotals?.carbs ?? 0,
                fats: contentServiceHandler.nurtitionConsumedTotals?.fats ?? 0,
                proteinTarget: contentServiceHandler.nutritionTargetTotals?.protein ?? 0,
                carbsTarget: contentServiceHandler.nutritionTargetTotals?.carbs ?? 0,
                fatsTarget: contentServiceHandler.nutritionTargetTotals?.fats ?? 0
            )
        }
        .fullScreenCover(isPresented: $showGraph) {
            NutritionGraphRootView()
                .environmentObject(contentServiceHandler)
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @State private var showGraph = false

}
