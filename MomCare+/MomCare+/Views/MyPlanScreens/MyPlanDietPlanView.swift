import Charts
import SwiftUI
import TipKit

struct MyPlanDietPlanView: View {
    // MARK: Internal

    let currentTip: (any Tip)?

    var body: some View {
        VStack(spacing: 12) {
            MyPlanDietPlanProgressCardView(
                plan: contentServiceHandler.myPlanModel,
                tip: currentTip as? MomCareTips.DietPlan.ProgressCardSlideOrTapTip,

                calorieIntake: contentServiceHandler.nutritionIntakeTotals?.energy,
                calorieGoal: contentServiceHandler.nutritionGoalTotals?.energy,
                recommendedCalorieGoal: contentServiceHandler.recommendedNutritionGoalTotals?.energy,

                proteinIntake: contentServiceHandler.nutritionIntakeTotals?.proteinMass,
                proteinGoal: contentServiceHandler.nutritionGoalTotals?.proteinMass,
                recommendedProteinGoal: contentServiceHandler.recommendedNutritionGoalTotals?.proteinMass,

                fatIntake: contentServiceHandler.nutritionIntakeTotals?.fatsMass,
                fatGoal: contentServiceHandler.nutritionGoalTotals?.fatsMass,
                recommendedFatGoal: contentServiceHandler.recommendedNutritionGoalTotals?.fatsMass,

                carbIntake: contentServiceHandler.nutritionIntakeTotals?.carbsMass,
                carbGoal: contentServiceHandler.nutritionGoalTotals?.carbsMass,
                recommendedCarbGoal: contentServiceHandler.recommendedNutritionGoalTotals?.carbsMass,

                sugarIntake: contentServiceHandler.nutritionIntakeTotals?.sugarMass,
                sugarGoal: contentServiceHandler.nutritionGoalTotals?.sugarMass,
                recommendedSugarGoal: contentServiceHandler.recommendedNutritionGoalTotals?.sugarMass,

                sodiumIntake: contentServiceHandler.nutritionIntakeTotals?.sodiumMass,
                sodiumGoal: contentServiceHandler.nutritionGoalTotals?.sodiumMass,
                recommendedSodiumGoal: contentServiceHandler.recommendedNutritionGoalTotals?.sodiumMass
            )
            .containerShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)
            .contextMenu {
                Button {
                    showGraph = true
                } label: {
                    Label("View in Graph", systemImage: "chart.bar.xaxis")
                }
            }

            MyPlanDietPlanMealTimelineCardView(
                plan: contentServiceHandler.myPlanModel,
                addFoodItemTip: currentTip as? MomCareTips.DietPlan.HeaderRowAddTip,
                slideFoodItemRowTip: currentTip as? MomCareTips.DietPlan.ItemRowSlideTip
            )
                .refreshable {
                    do {
                        try await contentServiceHandler.fetchMealPlan()
                    } catch {
                        controlState.error = error
                    }
                }

                .padding(.bottom, 8)
                .frame(maxHeight: .infinity)
                .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                .padding(.horizontal, 16)
        }
        .padding(.top, 8)
        .fullScreenCover(isPresented: $showGraph) {
            NutritionGraphRootView(
                calorieIntake: contentServiceHandler.nutritionIntakeTotals?.energy ?? .init(value: 0, unit: .kilocalories),
                calorieGoal: contentServiceHandler.recommendedNutritionGoalTotals?.energy ?? .init(value: 0, unit: .kilocalories),
                nutritionIntakeTotals: contentServiceHandler.nutritionIntakeTotals,
                nutritionGoalTotals: contentServiceHandler.recommendedNutritionGoalTotals
            )
        }
        .fullScreenCover(isPresented: $showWaterLog) {
            WaterLogView()
        }
        .fullScreenCover(isPresented: $showHistory) {
            MyPlanDietPlanHistory()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
                .accessibilityLabel("Meal plan history")
                .accessibilityHint("Opens your meal plan history")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if experimentalFeatures {
                        Button {
                            showWaterLog = true
                        } label: {
                            Label("Water Intake Log", systemImage: "drop.fill")
                        }

                        Divider()
                    }

                    Button {
                        showHelp = true
                    } label: {
                        Label("Guide", systemImage: "questionmark.circle")
                    }

                } label: {
                    Image(systemName: "ellipsis")
                        .accessibilityHidden(true)
                }
                .accessibilityLabel("More options")
            }
        }
        .sheet(isPresented: $showHelp) {
            MyPlanDietPlanGuideView()
        }
    }

    // MARK: Private

    @State private var showGraph = false
    @State private var showWaterLog = false
    @State private var showHelp = false
    @State private var showHistory = false

    @AppStorage(FeatureFlagState.experimentalFeatures.rawValue, store: Database.shared.userDefaults) private var experimentalFeatures: Bool = false

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState
}

private struct NutritionGraphRootView: View {
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
                    MCCancelButton { dismiss() }
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
                .foregroundStyle(color)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(reduceMotion ? nil : .easeInOut, value: value)
        }
        .frame(maxWidth: .infinity)
    }

    private func todayValue(for kind: VitalKind) -> Double {
        switch kind {
        case .calories: nutritionIntakeTotals?.calories ?? 0
        case .protein: nutritionIntakeTotals?.protein ?? 0
        case .carbs: nutritionIntakeTotals?.carbs ?? 0
        case .fats: nutritionIntakeTotals?.fats ?? 0
        case .sugar: nutritionIntakeTotals?.sugar ?? 0
        case .sodium: nutritionIntakeTotals?.sodium ?? 0
        }
    }

    private func targetValue(for kind: VitalKind) -> Double {
        switch kind {
        case .calories: nutritionGoalTotals?.calories ?? 0
        case .protein: nutritionGoalTotals?.protein ?? 0
        case .carbs: nutritionGoalTotals?.carbs ?? 0
        case .fats: nutritionGoalTotals?.fats ?? 0
        case .sugar: nutritionGoalTotals?.sugar ?? 0
        case .sodium: nutritionGoalTotals?.sodium ?? 0
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
                    .foregroundStyle(kind.color)
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
                        .foregroundStyle(kind.color)
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
        guard targetValue > 0 else {
            return 0
        }

        return min(todayValue / targetValue, 1.0)
    }

    private var progressLabel: String {
        "\(Int(progress * 100))%"
    }

    private func formattedValue(_ v: Double) -> String {
        if kind == .calories || kind == .sodium {
            v.formatted(.number.precision(.fractionLength(0)))
        } else {
            v.formatted(.number.precision(.fractionLength(1)))
        }
    }
}

private struct VitalDetailView: View {
    // MARK: Internal

    let kind: VitalKind
    let todayValue: Double
    let targetValue: Double

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                todayHeader
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(reduceMotion ? nil : .easeInOut, value: appeared)

                descriptionCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(
                        reduceMotion ? nil : .easeInOut.delay(0.05),
                        value: appeared
                    )

                chartSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(
                        reduceMotion ? nil : .easeInOut.delay(0.10),
                        value: appeared
                    )

                insightCard
                    .opacity(appeared ? 1 : 0)
                    .animation(
                        reduceMotion ? nil : .easeInOut.delay(0.15),
                        value: appeared
                    )

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color(.systemBackground))
        .navigationTitle(kind.rawValue)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await reload()
            withAnimation(reduceMotion ? nil : .easeInOut) {
                appeared = true
            }
        }
        .onChange(of: selectedRange) {
            Task { await reload() }
        }
    }

    // MARK: Private

    @StateObject private var store: VitalHistoryStore = .init()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    @State private var selectedRange: VitalTimeRange = .week
    @State private var appeared = false

    @State private var selectedPoint: DailyDataPoint?

    private var chartHeight: CGFloat {
        220
    }

    private var visibleDomain: Int {
        min(store.points.count, 7)
    }

    private var barWidth: MarkDimension {
        selectedRange == .quarter ? .ratio(0.5) : .ratio(0.6)
    }

    private var xAxisValues: [String] {
        let all = store.points.map(\.label)
        guard all.count > 14 else {
            return all
        }

        let step = all.count / 7
        return stride(from: 0, to: all.count, by: step).map { all[$0] }
    }

    private var todayHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(kind.color.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: kind.sfSymbol)
                    .font(.title2)
                    .foregroundStyle(kind.color)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(formattedValue(todayValue))")
                        .font(.title.weight(.bold))
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: todayValue)
                    Text(kind.unitLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.systemGray5))
                        Capsule()
                            .fill(kind.color)
                            .frame(width: geo.size.width * min(todayValue / max(targetValue, 1), 1.0))
                    }
                }
                .frame(height: 5)
                .padding(.top, 2)
                .accessibilityHidden(true)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Target")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text("\(formattedValue(targetValue))")
                    .font(.headline.weight(.semibold))
                Text(kind.unitLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            kind.color.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(kind.color.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(kind.rawValue) today")
        .accessibilityValue(
            targetValue > 0
                ? "\(formattedValue(todayValue)) \(kind.unitLabel), target \(formattedValue(targetValue)) \(kind.unitLabel), \(Int(min(todayValue / targetValue, 1.0) * 100)) percent"
                : "\(formattedValue(todayValue)) \(kind.unitLabel)"
        )
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("About \(kind.rawValue)", systemImage: "info.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(kind.color)

            Text(kind.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Range", selection: $selectedRange) {
                ForEach(VitalTimeRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)

            ZStack {
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: chartHeight)

                } else if store.points.isEmpty {
                    emptyChartPlaceholder

                } else {
                    chart
                }
            }
            .frame(height: chartHeight)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: store.isLoading)

            if let pt = selectedPoint {
                HStack {
                    Text(pt.label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(formattedValue(pt.value)) \(kind.unitLabel)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(kind.color)
                }
                .padding(.horizontal, 4)
                .transition(unsafe reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.95)))
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var chart: some View {
        Chart(store.points) { pt in
            BarMark(
                x: .value("Date", pt.label),
                y: .value(kind.unitLabel, appeared ? pt.value : 0),
                width: barWidth
            )
            .foregroundStyle(
                pt.id == selectedPoint?.id
                ? kind.color
                : kind.color.opacity(0.7)
            )
            .cornerRadius(5)
            .accessibilityLabel(pt.label)
            .accessibilityValue(
                "\(formattedValue(pt.value)) \(kind.unitLabel)\(pt.id == selectedPoint?.id ? ", selected" : "")"
            )
            .annotation(position: .overlay) {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if reduceMotion {
                            selectedPoint = selectedPoint?.id == pt.id ? nil : pt
                        } else {
                            withAnimation(.easeInOut) {
                                selectedPoint = selectedPoint?.id == pt.id ? nil : pt
                            }
                        }
                    }
                    .contextMenu {
                        Text("\(pt.label): \(formattedValue(pt.value)) \(kind.unitLabel)")
                            .font(.caption)

                        Divider()

                        Button {
                            selectedPoint = pt
                        } label: {
                            Label("Select this day", systemImage: "hand.point.up.fill")
                        }

                        if targetValue > 0 {
                            let pct = Int((pt.value / targetValue) * 100)
                            Button {} label: {
                                Label("\(pct)% of daily target", systemImage: "target")
                            }
                            .disabled(true)
                        }

                        Button {
                            UIPasteboard.general.string = "\(formattedValue(pt.value)) \(kind.unitLabel)"
                        } label: {
                            Label("Copy value", systemImage: "doc.on.doc")
                        }
                    }
            }

            if pt.id == selectedPoint?.id, differentiateWithoutColor {
                PointMark(
                    x: .value("Date", pt.label),
                    y: .value(kind.unitLabel, pt.value)
                )
                .symbol(.asterisk)
                .symbolSize(30)
                .foregroundStyle(kind.color)
                .accessibilityHidden(true)
            }

            if targetValue > 0 {
                RuleMark(y: .value("Target", targetValue))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                    .foregroundStyle(kind.color.opacity(0.4))
                    .annotation(position: .trailing, alignment: .center) {
                        Text("Target")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(kind.color.opacity(0.6))
                    }
            }
        }
        .chartXAxis {
            AxisMarks(values: xAxisValues) { _ in
                AxisValueLabel()
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4, dash: [4]))
                    .foregroundStyle(Color(.systemGray4))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(formattedValue(v))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: visibleDomain)
        .animation(
            reduceMotion ? nil : .easeInOut,
            value: appeared
        )
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.3),
            value: store.points.count
        )
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.largeTitle)
                .foregroundStyle(Color(.systemGray3))
            Text("No data for this period")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Log meals in Health to see your \(kind.rawValue.lowercased()) history here.")
                .font(.caption)
                .foregroundStyle(Color(.systemGray3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: chartHeight)
    }

    private var insightCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.subheadline)
                .foregroundStyle(.orange)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text("Tip")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)

                Text(kind.insight)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            Color.orange.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.orange.opacity(0.15), lineWidth: 1)
        )
    }

    private func reload() async {
        await store.load(kind: kind, range: selectedRange)
    }

    private func formattedValue(_ v: Double) -> String {
        if kind == .calories {
            v.formatted(.number.precision(.fractionLength(0)))

        } else if kind == .sodium {
            v >= 1000
                ? v.formatted(.number.precision(.fractionLength(1)))
                : v.formatted(.number.precision(.fractionLength(0)))

        } else {
            v.formatted(.number.precision(.fractionLength(1)))
        }
    }
}
