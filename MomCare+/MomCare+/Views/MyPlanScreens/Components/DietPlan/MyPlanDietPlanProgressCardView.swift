import SwiftUI
import TipKit

struct MyPlanDietPlanProgressCardView: View {
    // MARK: Internal

    let plan: MealPlanModel?
    let tip: (any Tip)?

    let calorieIntake: Measurement<UnitEnergy>?
    let calorieGoal: Measurement<UnitEnergy>?
    let recommendedCalorieGoal: Measurement<UnitEnergy>?

    let proteinIntake: Measurement<UnitMass>?
    let proteinGoal: Measurement<UnitMass>?
    let recommendedProteinGoal: Measurement<UnitMass>?

    let fatIntake: Measurement<UnitMass>?
    let fatGoal: Measurement<UnitMass>?
    let recommendedFatGoal: Measurement<UnitMass>?

    let carbIntake: Measurement<UnitMass>?
    let carbGoal: Measurement<UnitMass>?
    let recommendedCarbGoal: Measurement<UnitMass>?

    let sugarIntake: Measurement<UnitMass>?
    let sugarGoal: Measurement<UnitMass>?
    let recommendedSugarGoal: Measurement<UnitMass>?

    let sodiumIntake: Measurement<UnitMass>?
    let sodiumGoal: Measurement<UnitMass>?
    let recommendedSodiumGoal: Measurement<UnitMass>?

    var body: some View {
        VStack(spacing: 0) {
            collapsedHeader
                .popoverTip(tip, arrowEdge: .top)

            if isExpanded {
                expandedSection
            }
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onTapGesture(perform: toggleExpansion)
        .gesture(pressGesture)
        .accessibilityElement(children: .contain)
        .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand details")
        .accessibilityAction(.default) { toggleExpansion() }
    }

    // MARK: Private

    private enum CardDisplayMode: Int, CaseIterable {
        case calories
        case macros
        case micros
    }

    private enum DragDirection {
        case up
        case down
    }

    @AppStorage(FeatureFlagState.experimentalFeatures.rawValue, store: Database.shared.userDefaults) private var experimentalFeatures: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var displayMode: CardDisplayMode = .macros
    @State private var isExpanded: Bool = false
    @State private var dragDirection: DragDirection = .up
    @State private var isPressed: Bool = false

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onEnded(handleDragEnd)
    }

    private var pressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0)
            .onChanged { pressing in
                withAnimation(reduceMotion ? nil : .easeInOut) {
                    isPressed = pressing
                }
            }
    }

    private var modeTransition: AnyTransition {
        unsafe .asymmetric(
            insertion: .move(edge: dragDirection == .up ? .bottom : .top)
                .combined(with: .opacity),
            removal: .move(edge: dragDirection == .up ? .top : .bottom)
                .combined(with: .opacity)
        )
    }

    private var collapsedHeader: some View {
        HStack(alignment: .center, spacing: 20) {
            ProgressRingView(
                consumed: calorieIntake,
                target: calorieGoal,
                original: recommendedCalorieGoal,
            )
//            .layoutPriority(1)

            modeContent
        }
        .padding(18)
        .gesture(isExpanded ? nil : dragGesture)
    }

    private var modeContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch displayMode {
            case .calories:
                CaloriesSummaryView(
                    intake: calorieIntake,
                    goal: calorieGoal,
                    recommended: recommendedCalorieGoal
                )

            case .macros:
                macroRows

            case .micros:
                microRows
            }
        }
        .frame(maxWidth: .infinity)
        .transition(modeTransition)
        .id(displayMode)
        .animation(
            reduceMotion ? nil :
                .spring(response: 0.35, dampingFraction: 0.75),
            value: displayMode
        )
    }

    private var macroRows: some View {
        Group {
            MacroBarRow(
                title: "Protein",
                intake: proteinIntake,
                goal: proteinGoal,
                recommendedGoal: recommendedProteinGoal,
                color: Color(hex: "A7C0CD")
            )

            MacroBarRow(
                title: "Carbs",
                intake: carbIntake,
                goal: carbGoal,
                recommendedGoal: recommendedCarbGoal,
                color: Color(hex: "6E8B6F")
            )

            MacroBarRow(
                title: "Fats",
                intake: fatIntake,
                goal: fatGoal,
                recommendedGoal: recommendedFatGoal,
                color: Color(hex: "E3B34B")
            )
        }
    }

    private var microRows: some View {
        Group {
            MacroBarRow(
                title: "Sugar",
                intake: sugarIntake,
                goal: sugarGoal,
                recommendedGoal: recommendedSugarGoal,
                color: Color(hex: "E07B8A")
            )

            MacroBarRow(
                title: "Sodium",
                intake: sodiumIntake,
                goal: sodiumGoal,
                recommendedGoal: recommendedSodiumGoal,
                color: Color(hex: "9B8EC4")
            )
        }
    }

    private var expandedSection: some View {
        VStack {
            Divider()
                .padding(.horizontal, 18)

            ExpandedDetailView(
                caloriesConsumed: calorieIntake,
                caloriesTarget: recommendedCalorieGoal,
                plan: plan,
                sugarIntake: sugarIntake,
                sugarGoal: sugarGoal,
                recommendedSugarGoal: recommendedSugarGoal,
                sodiumIntake: sodiumIntake,
                sodiumGoal: sodiumGoal,
                recommendedSodiumGoal: recommendedSodiumGoal
            )
            .padding(18)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var cardBackground: some View {
        ConcentricRectangle()
            .fill(Color(.systemBackground))
    }

    private func handleDragEnd(_ value: DragGesture.Value) {
        let threshold: CGFloat = 20
        let allModes = CardDisplayMode.allCases
        let current = displayMode.rawValue

        if value.translation.height < -threshold {
            dragDirection = .up
            let next = (current + 1) % allModes.count

            withAnimation(reduceMotion ? nil : .easeInOut) {
                displayMode = CardDisplayMode(rawValue: next) ?? displayMode
            }

        } else if value.translation.height > threshold {
            dragDirection = .down
            let prev = (current - 1 + allModes.count) % allModes.count

            withAnimation(reduceMotion ? nil : .easeInOut) {
                displayMode = CardDisplayMode(rawValue: prev) ?? displayMode
            }
        }
    }

    private func toggleExpansion() {
        withAnimation(reduceMotion ? nil : .easeInOut) {
            isExpanded.toggle()
            if isExpanded {
                displayMode = .macros
            }
        }
    }
}

private struct CaloriesSummaryView: View {
    // MARK: Internal

    let intake: Measurement<UnitEnergy>?
    let goal: Measurement<UnitEnergy>?
    let recommended: Measurement<UnitEnergy>?

    var difference: Double {
        guard let intake, let recommended else {
            return 0
        }

        return intake.converted(to: recommended.unit).value - recommended.value
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Remaining", systemImage: "flame")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(Measurement(value: remaining, unit: UnitEnergy.kilocalories), format: .measurement(width: .wide, usage: .food))
                .font(.title3.weight(.bold))
                .foregroundStyle(isOver ? .red : .primary)
                .contentTransition(reduceMotion ? .identity : .numericText(countsDown: true))
                .animation(reduceMotion ? nil : .easeInOut, value: remaining)
                .accessibilityLabel(isOver ? "Over budget" : "Remaining calories")
                .accessibilityValue(
                    Measurement(value: remaining, unit: UnitEnergy.kilocalories)
                        .formatted(.measurement(width: .wide, usage: .food))
                )

            if isOver {
                let overMeasurement = Measurement(value: abs(difference), unit: UnitEnergy.kilocalories)

                Label(
                    "Over by \(overMeasurement.formatted(.measurement(width: .narrow, usage: .food)))",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.footnote)
                .foregroundStyle(.red)
                .contentTransition(reduceMotion ? .identity : .numericText(value: overMeasurement.value))
                .animation(reduceMotion ? nil : .easeInOut, value: overMeasurement.value)
                .accessibilityLabel(
                    "Exceeded goal by \(overMeasurement.formatted(.measurement(width: .wide, usage: .food)))"
                )
            } else {
                subtitleView
            }
        }
        .animation(reduceMotion ? nil : .snappy, value: difference)
        .accessibilityElement(children: .combine)
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var remaining: Double {
        max(-difference, 0)
    }

    private var isOver: Bool {
        guard let intake, let recommended else {
            return false
        }

        return intake.converted(to: recommended.unit).value > recommended.value
    }

    private var isGoalModified: Bool {
        guard let goal, let recommended else {
            return false
        }

        return goal != recommended
    }

    private var goalText: String {
        goal?.formattedOneDecimal ?? "-"
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let intake, let recommended, let goal {
            if isGoalModified {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 0) {
                        Text(intake, format: .measurement(width: .wide, usage: .food))
                            .contentTransition(reduceMotion ? .identity : .numericText(value: intake.value))
                            .animation(reduceMotion ? nil : .easeInOut, value: intake.value)
                        Text(" of ")
                        Text(recommended, format: .measurement(width: .wide, usage: .food))
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 0) {
                        Text("(")
                        Text(goal, format: .measurement(width: .wide, usage: .food))
                        Text(")")
                        Text(" consumed")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel("\(intake, format: .measurement(width: .wide, usage: .food)) consumed of \(recommended, format: .measurement(width: .wide, usage: .food)) recommended, goal adjusted to \(goal, format: .measurement(width: .wide, usage: .food))")

            } else {
                Text("\(intake, format: .measurement(width: .abbreviated, usage: .food)) of \(goal, format: .measurement(width: .abbreviated, usage: .food)) consumed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(reduceMotion ? .identity : .numericText(value: intake.value))
                    .animation(reduceMotion ? nil : .easeInOut, value: intake.value)
                    .accessibilityLabel("\(intake, format: .measurement(width: .abbreviated, usage: .food)) of \(goal, format: .measurement(width: .abbreviated, usage: .food)) consumed")
            }

        } else {
            Text("No data")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .accessibilityLabel("Calorie data unavailable")
        }
    }
}

private struct ExpandedDetailView: View {
    // MARK: Internal

    let caloriesConsumed: Measurement<UnitEnergy>?
    let caloriesTarget: Measurement<UnitEnergy>?
    let plan: MealPlanModel?

    let sugarIntake: Measurement<UnitMass>?
    let sugarGoal: Measurement<UnitMass>?
    let recommendedSugarGoal: Measurement<UnitMass>?

    let sodiumIntake: Measurement<UnitMass>?
    let sodiumGoal: Measurement<UnitMass>?
    let recommendedSodiumGoal: Measurement<UnitMass>?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Micros")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .accessibilityAddTraits(.isHeader)

                MacroBarRow(
                    title: "Sugar",
                    intake: sugarIntake,
                    goal: sugarGoal,
                    recommendedGoal: recommendedSugarGoal,
                    color: Color(hex: "E07B8A")
                )

                MacroBarRow(
                    title: "Sodium",
                    intake: sodiumIntake,
                    goal: sodiumGoal,
                    recommendedGoal: recommendedSodiumGoal,
                    color: Color(hex: "9B8EC4")
                )
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Calories")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .accessibilityAddTraits(.isHeader)

                HStack {
                    CalorieStatPill(label: "Consumed", value: caloriesConsumed?.value ?? 0, color: MomCareAccent.primary)
                    CalorieStatPill(label: "Target", value: caloriesTarget?.value ?? 0, color: Color(.systemGray3))
                    CalorieStatPill(
                        label: isCalorieConsumedGreaterThanTarget ? "Over" : "Left",
                        value: calorieDifference,
                        color: isCalorieConsumedGreaterThanTarget ? .red : Color(hex: "6E8B6F")
                    )
                }
            }

            Divider()

            if let plan {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meals")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(MealType.allCases, id: \.self) { meal in
                        MealRow(
                            mealType: meal,
                            references: plan[meal]
                        )
                    }
                }
            }
        }
    }

    // MARK: Private

    private var calorieDifference: Double {
        guard let caloriesConsumed, let caloriesTarget else {
            return 0
        }

        let consumedValue = caloriesConsumed.converted(to: caloriesTarget.unit).value
        let targetValue = caloriesTarget.value

        return consumedValue - targetValue
    }

    private var isCalorieConsumedGreaterThanTarget: Bool {
        guard let caloriesConsumed, let caloriesTarget else {
            return false
        }

        return caloriesConsumed > caloriesTarget
    }
}

private struct CalorieStatPill: View {
    // MARK: Internal

    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value, format: .number)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(reduceMotion ? nil : .easeInOut, value: value)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value.formatted(.number))")
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

private struct MealRow: View {
    // MARK: Internal

    let mealType: MealType
    let references: [FoodReferenceModel]

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: mealType.iconName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
                .accessibilityHidden(true)

            Text(mealType.rawValue.capitalized)
                .font(.caption.weight(.medium))
                .frame(width: 70, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                    Capsule()
                        .fill(mealType.accentColor)
                        .frame(width: geo.size.width * progress)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: progress)
                }
            }
            .frame(height: 8)
            .accessibilityHidden(true)

            Text("\(consumed)/\(total)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .trailing)
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(mealType.rawValue.capitalized)
        .accessibilityValue(total == 0 ? "No items" : "\(consumed) of \(total) items consumed")
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var consumed: Int {
        references.filter(\.isConsumed).count
    }

    private var total: Int {
        references.count
    }

    private var progress: Double {
        guard total > 0 else {
            return 0
        }

        return Double(consumed) / Double(total)
    }
}

private struct RingLayout: Layout {
    let lineWidth: CGFloat

    func sizeThatFits(proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        guard let content = subviews.first else {
            return .zero
        }

        let contentSize = content.sizeThatFits(.unspecified)
        let diameter = max(contentSize.width, contentSize.height) + lineWidth * 2
        return CGSize(width: diameter, height: diameter)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        guard let content = subviews.first else {
            return
        }

        let contentSize = content.sizeThatFits(.unspecified)
        let origin = CGPoint(
            x: bounds.midX - contentSize.width / 2,
            y: bounds.midY - contentSize.height / 2
        )
        content.place(at: origin, proposal: ProposedViewSize(contentSize))
    }
}

private struct ProgressRingView: View {
    // MARK: Internal

    let consumed: Measurement<UnitEnergy>?
    let target: Measurement<UnitEnergy>?
    let original: Measurement<UnitEnergy>?

    var body: some View {
        RingLayout(lineWidth: 14) {
            numericPercentageTextView
        }
        .drawingGroup()
        .overlay {
            PercentageRing(ringWidth: 14, percent: progress * 100, backgroundColor: MomCareAccent.primary.opacity(0.15), foregroundColors: [MomCareAccent.primary])
        }
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(Circle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calorie intake")
        .accessibilityValue(
            showPercentage
            ? "\(percentage)%"
            : "\(Int(consumed?.converted(to: target?.unit ?? .kilocalories).value ?? 0)) / \(Int(target?.value ?? 0)) calories"
        )
        .accessibilityHint("Double tap to toggle percentage view")
        .accessibilityAddTraits([.isButton, .updatesFrequently])
        .accessibilityAction(.default) {
            togglePercentageDisplay()
        }
    }

    // MARK: Private

    private enum TargetModification {
        case increased
        case decreased
    }

    @State private var showPercentage = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var progress: Double {
        guard let consumed, let original else {
            return 0
        }

        return consumed.value / original.value
    }

    private var percentage: Int {
        guard let consumed, let original else {
            return 0
        }

        let consumedValue = consumed.converted(to: original.unit).value
        let originalValue = original.value

        guard originalValue > 0 else {
            return 0
        }

        return Int((consumedValue / originalValue) * 100)
    }

    private var difference: Double {
        guard let target, let original else {
            return 0
        }

        return (target - original).value
    }

    private var targetModification: TargetModification? {
        guard let target, let original else {
            return nil
        }

        if target > original {
            return .increased
        }
        if target < original {
            return .decreased
        }
        return nil
    }

    private var modificationColor: Color {
        switch targetModification {
        case .increased: .secondary.mix(with: .black, by: 0.2)
        case .decreased: .secondary.mix(with: .white, by: 0.35)
        case .none: .secondary
        }
    }

    private var consumedValue: Double? {
        consumed?.value
    }

    private var goalValue: Double? {
        original?.value
    }

    private var useCompactFont: Bool {
        (consumedValue ?? 0) > 999
    }

    private var valueFont: Font {
        useCompactFont ? .subheadline.weight(.semibold) : .headline
    }

    private var numericPercentageTextView: some View {
        VStack(spacing: 2) {
            Group {
                if showPercentage {
                    ZStack {
                        Text("\(percentage)%")
                            .font(.title2.weight(.bold))
                            .contentTransition(reduceMotion ? .identity : .numericText())
                            .animation(
                                reduceMotion ? nil : .easeInOut,
                                value: percentage
                            )

                        Text("999%")
                            .font(.title2.weight(.bold))
                            .hidden()

                        Text("9,999/9,999")
                            .font(.headline)
                            .hidden()
                    }

                } else {
                    ZStack {
                        HStack(spacing: 2) {
                            animatedNumber(consumedValue)
                            Text("/").font(valueFont)
                            animatedNumber(goalValue)
                        }

                        // Thanks chatgpt for this hack,
                        // this makes the cirlce big enough
                        Text("999%")
                            .font(.title2.weight(.bold))
                            .hidden()

                        Text("9,999/9,999")
                            .font(.headline)
                            .hidden()
                    }
                }
            }
            .transition(.opacity.combined(with: .scale))
            .onTapGesture {
                togglePercentageDisplay()
            }
            .accessibilityHint(showPercentage ? "Double tap to show value" : "Double tap to show percentage")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default) {
                togglePercentageDisplay()
            }

            HStack(spacing: 6) {
                Text(UnitEnergy.kilocalories.symbol)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if difference != 0 {
                    Text(Int(difference), format: .number.sign(strategy: .always()))
                        .font(.subheadline)
                        .foregroundStyle(modificationColor)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: difference)
                }
            }
            .animation(reduceMotion ? nil : .easeInOut, value: difference)
        }
    }

    private func animatedNumber(_ value: Double?) -> some View {
        Group {
            if let value {
                Text(value, format: .number)
            } else {
                Text("-")
            }
        }
        .font(valueFont)
        .contentTransition(reduceMotion ? .identity : .numericText())
        .animation(
            reduceMotion ? nil : .easeInOut,
            value: value
        )
    }

    private func togglePercentageDisplay() {
        withAnimation(reduceMotion ? nil : .easeInOut) {
            showPercentage.toggle()
        }
    }
}

private struct MacroBarRow: View {
    // MARK: Internal

    let title: String
    let intake: Measurement<UnitMass>?
    let goal: Measurement<UnitMass>?
    let recommendedGoal: Measurement<UnitMass>?
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)

                Spacer()

                Group {
                    if showPercentage {
                        Text(percentageText)
                            .contentTransition(reduceMotion ? .identity : .numericText())
                            .animation(reduceMotion ? nil : .easeInOut, value: showPercentage)
                    } else {
                        numericView
                    }
                }
                .onTapGesture {
                    togglePercentageDisplay()
                }
                .accessibilityHint(showPercentage ? "Double tap to show value" : "Double tap to show percentage")
                .accessibilityAddTraits(.isButton)
                .accessibilityAction(.default) {
                    togglePercentageDisplay()
                }
                .font(.caption)
                .foregroundStyle(.primary)
                .animation(reduceMotion ? nil : .easeInOut, value: showPercentage)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(reduceTransparency ? Color(.systemGray4) : Color.secondary.opacity(0.2))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * min(recommendedProgress, 1.0))
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: recommendedProgress)
                }
            }
            .frame(height: 14)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(
            showPercentage
            ? percentageText
            : {
                guard let intake, let goal else {
                    return "No intake or goal data"
                }

                let convertedIntake = intake.converted(to: goal.unit)

                let intakeText = convertedIntake.formatted(.measurement(width: .wide))
                let goalText = goal.formatted(.measurement(width: .wide))

                return "\(intakeText) consumed out of \(goalText) goal"
            }()
        )
        .accessibilityHint("Double tap to toggle percentage view")
        .accessibilityAddTraits([.isButton, .updatesFrequently])
    }

    // MARK: Private

    private enum TargetModification {
        case increased
        case decreased
    }

    @State private var showPercentage = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var targetModification: TargetModification? {
        guard let goal, let recommendedGoal else {
            return nil
        }

        if goal > recommendedGoal {
            return .increased
        }
        if goal < recommendedGoal {
            return .decreased
        }

        return nil
    }

    private var modificationColor: Color {
        switch targetModification {
        case .increased: .secondary.mix(with: .black, by: 0.2)
        case .decreased: .secondary.mix(with: .white, by: 0.35)
        case .none: .secondary
        }
    }

    private var recommendedProgress: Double {
        guard let intake, let recommendedGoal else {
            return 0
        }

        let intakeValue = intake.converted(to: recommendedGoal.unit).value
        let goalValue = recommendedGoal.value

        guard goalValue > 0 else {
            return 0
        }

        return intakeValue / goalValue
    }

    private var percentageText: String {
        "\(Int(recommendedProgress * 100))%"
    }

    private var difference: Double {
        guard let intake, let recommendedGoal else {
            return 0
        }

        let intakeValue = intake.converted(to: recommendedGoal.unit).value
        let goalValue = recommendedGoal.value

        return intakeValue - goalValue
    }

    private var numericView: some View {
        HStack(spacing: 4) {
            if let intake {
                HStack {
                    Text(intake.formattedOneDecimal)
                        .contentTransition(reduceMotion ? .identity : .numericText(value: intake.value))
                        .animation(reduceMotion ? nil : .easeInOut, value: intake.value)

                    if difference > 0 {
                        Text("(\(difference, format: .number.sign(strategy: .always())))")
                            .foregroundStyle(.secondary)
                            .contentTransition(reduceMotion ? .identity : .numericText(value: difference))
                            .animation(reduceMotion ? nil : .easeInOut, value: difference)
                    }
                }
                .animation(reduceMotion ? nil : .easeInOut, value: difference > 0)
            } else {
                Text("-")
            }

            Text("/")

            if let goal {
                if let recommendedGoal, targetModification != nil {
                    HStack {
                        Text(recommendedGoal.formattedOneDecimal)
                            .foregroundStyle(modificationColor)

                        if targetModification == .increased {
                            Image(systemName: "arrow.up")
                                .font(.caption2.bold())
                                .foregroundStyle(modificationColor)
                                .contentTransition(reduceMotion ? .identity : .symbolEffect)
                                .animation(reduceMotion ? nil : .easeInOut, value: targetModification)

                        } else if targetModification == .decreased {
                            Image(systemName: "arrow.down")
                                .font(.caption2.bold())
                                .foregroundStyle(modificationColor)
                                .contentTransition(reduceMotion ? .identity : .symbolEffect)
                                .animation(reduceMotion ? nil : .easeInOut, value: targetModification)
                        }
                    }
                } else {
                    Text(goal.formattedOneDecimal)
                        .contentTransition(reduceMotion ? .identity : .numericText(value: goal.value))
                        .animation(reduceMotion ? nil : .easeInOut, value: goal.value)
                }
            } else {
                Text("-")
            }
        }
        .animation(reduceMotion ? nil : .easeInOut, value: showPercentage)
    }

    private func togglePercentageDisplay() {
        withAnimation(reduceMotion ? nil : .easeInOut) {
            showPercentage.toggle()
        }
    }
}
