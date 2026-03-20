import SwiftUI

enum CardDisplayMode: Int, CaseIterable {
    case calories
    case macros
    case micros
}

struct ProgressCardView: View {

    // MARK: Internal

    let plan: MyPlanModel?

    let calorieIntake: Double
    let calorieGoal: Double
    let recommendedCalorieGoal: Double

    let proteinIntake: Double
    let proteinGoal: Double
    let recommendedProteinGoal: Double

    let fatIntake: Double
    let fatGoal: Double
    let recommendedFatGoal: Double

    let carbIntake: Double
    let carbGoal: Double
    let recommendedCarbGoal: Double

    let sugarIntake: Double
    let sugarGoal: Double
    let recommendedSugarGoal: Double

    let sodiumIntake: Double
    let sodiumGoal: Double
    let recommendedSodiumGoal: Double

    var body: some View {
        VStack(spacing: 0) {

            collapsedHeader

            if isExpanded {
                expandedSection
            }
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onTapGesture(perform: experimentalFeatures ? toggleExpansion : {})
        .gesture(pressGesture)
        .accessibilityElement(children: .contain)
        .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand details")
    }

    // MARK: Private

    private enum DragDirection {
        case up
        case down
    }

    @AppStorage(FeatureFlagState.experimentalFeatures.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var experimentalFeatures: Bool = false

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
                withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7)) {
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

    private var calorieProgress: Double {
        guard recommendedCalorieGoal > 0 else { return 0 }
        return min(calorieIntake / recommendedCalorieGoal, 1.0)
    }

    private var collapsedHeader: some View {
        HStack(alignment: .center, spacing: 20) {

            ProgressRingView(
                progress: calorieProgress,
                consumed: calorieIntake,
                target: calorieGoal,
                original: recommendedCalorieGoal,
            )
            .layoutPriority(1)

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
                    consumed: calorieIntake,
                    target: calorieGoal
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
                caloriesTarget: calorieGoal,
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

        let threshold: CGFloat = 30
        let allModes = CardDisplayMode.allCases
        let current = displayMode.rawValue

        if value.translation.height < -threshold {

            dragDirection = .up
            let next = (current + 1) % allModes.count

            withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)) {
                displayMode = CardDisplayMode(rawValue: next) ?? displayMode
            }

        } else if value.translation.height > threshold {

            dragDirection = .down
            let prev = (current - 1 + allModes.count) % allModes.count

            withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)) {
                displayMode = CardDisplayMode(rawValue: prev) ?? displayMode
            }
        }
    }

    private func toggleExpansion() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.75)) {
            isExpanded.toggle()
            if isExpanded {
                displayMode = .macros
            }
        }
    }

}

private struct CaloriesSummaryView: View {

    // MARK: Internal

    let consumed: Double
    let target: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Remaining", systemImage: "flame")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            Text("\(Int(remaining)) \(UnitEnergy.kilocalories.symbol)")
                .font(.title3.weight(.bold))
                .foregroundColor(isOver ? .red : .primary)
                .contentTransition(reduceMotion ? .identity : .numericText(countsDown: true))
                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: remaining)

            if isOver {
                Label("Over by \(Int(consumed - target)) \(UnitEnergy.kilocalories.symbol)", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Text("\(Int(consumed)) of \(Int(target)) consumed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var remaining: Double { max(target - consumed, 0) }
    private var isOver: Bool { consumed > target }

}

private struct ExpandedDetailView: View {

    let caloriesConsumed: Double
    let caloriesTarget: Double
    let plan: MyPlanModel?

    let sugarIntake: Double
    let sugarGoal: Double
    let recommendedSugarGoal: Double

    let sodiumIntake: Double
    let sodiumGoal: Double
    let recommendedSodiumGoal: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Micros")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

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
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                HStack {
                    CalorieStatPill(label: "Consumed", value: caloriesConsumed, color: MomCareAccent.primary)
                    CalorieStatPill(label: "Target", value: caloriesTarget, color: Color(.systemGray3))
                    CalorieStatPill(
                        label: caloriesConsumed > caloriesTarget ? "Over" : "Left",
                        value: abs(caloriesTarget - caloriesConsumed),
                        color: caloriesConsumed > caloriesTarget ? .red : Color(hex: "6E8B6F")
                    )
                }
            }

            Divider()

            if let plan {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meals")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

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
}

private struct CalorieStatPill: View {

    // MARK: Internal

    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(Int(value))")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(color)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: value)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
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
                .foregroundColor(.secondary)
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
                .foregroundColor(.secondary)
                .frame(width: 32, alignment: .trailing)
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(mealType.rawValue.capitalized)
        .accessibilityValue(total == 0 ? "No items" : "\(consumed) of \(total) items consumed")
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var consumed: Int { references.filter(\.isConsumed).count }
    private var total: Int { references.count }
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(consumed) / Double(total)
    }

}

extension MealType: CaseIterable {
    static var allCases: [MealType] { [.breakfast, .lunch, .dinner, .snacks] }

    var iconName: String {
        switch self {
        case .breakfast: return "sun.horizon"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snacks: return "leaf"
        }
    }

    var accentColor: Color {
        switch self {
        case .breakfast: return Color(hex: "E3B34B")
        case .lunch: return Color(hex: "6E8B6F")
        case .dinner: return Color(hex: "A7C0CD")
        case .snacks: return Color(hex: "E07B8A")
        }
    }
}

struct ProgressRingView: View {

    // MARK: Internal

    let progress: Double
    let consumed: Double
    let target: Double
    let original: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(reduceTransparency ? Color(.systemGray4) : Color.secondary.opacity(0.2), lineWidth: 14)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    MomCareAccent.primary,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .linear(duration: 0.5), value: progress)

            VStack(spacing: 2) {
                Group {
                    if showPercentage {
                        Text("\(percentage)%")
                            .contentTransition(reduceMotion ? .identity : .numericText())
                            .transition(.opacity.combined(with: .scale))
                            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: percentage)
                            .font(.title2.weight(.bold))
                    } else {
                        HStack(spacing: 2) {
                            Text(Int(consumed), format: .number)
                                .font(consumed > 999 ? .footnote.weight(.semibold) : .headline)
                                .contentTransition(reduceMotion ? .identity : .numericText())
                                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: Int(consumed))

                            Text("/")
                                .font(consumed > 999 ? .footnote.weight(.semibold) : .headline)

                            Text(Int(original), format: .number)
                                .font(consumed > 999 ? .footnote.weight(.semibold) : .headline)
                                .contentTransition(reduceMotion ? .identity : .numericText())
                                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: Int(consumed))
                        }
                        .transition(.opacity.combined(with: .scale))
                        .font(.headline)
                    }
                }
                .onTapGesture {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8)) {
                        showPercentage.toggle()
                    }
                }

                HStack(spacing: 6) {
                    Text(UnitEnergy.kilocalories.symbol)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if target != original {
                        Text(Int(target - original), format: .number.sign(strategy: .always()))
                            .font(.subheadline)
                            .foregroundStyle(modificationColor)
                    }
                }
            }
        }
        .frame(width: 110, height: 110)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calorie intake")
        .accessibilityValue(showPercentage ? "\(percentage) percent" : "\(Int(consumed)) of \(Int(target)) calories")
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

    private var percentage: Int {
        guard original > 0 else { return 0 }
        return Int((consumed / original) * 100)
    }

    private var targetModification: TargetModification? {
        if target > original { return .increased }
        if target < original { return .decreased }
        return nil
    }

    private var modificationColor: Color {
        switch targetModification {
        case .increased: return .secondary.mix(with: .black, by: 0.2)
        case .decreased: return .secondary.mix(with: .white, by: 0.35)
        case .none: return .secondary
        }
    }
}

struct MacroBarRow: View {

    // MARK: Internal

    let title: String
    let intake: Double?
    let goal: Double?
    let recommendedGoal: Double?
    let color: Color

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
                            .contentTransition(reduceMotion ? .identity : .numericText())
                            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: showPercentage)
                    } else {
                        numericView
                    }
                }
                .onTapGesture {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8)) {
                        showPercentage.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(.primary)
                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: showPercentage)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(reduceTransparency ? Color(.systemGray4) : Color.secondary.opacity(0.2))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * progress)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: progress)
                }
            }
            .frame(height: 14)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(showPercentage ? percentageText : "\(intake ?? 0) consumed out of \(goal ?? 0) goal")
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
        guard let goal, let recommendedGoal else { return nil }

        if goal > recommendedGoal { return .increased }
        if goal < recommendedGoal { return .decreased }

        return nil
    }

    private var modificationColor: Color {
        switch targetModification {
        case .increased: return .secondary.mix(with: .black, by: 0.2)
        case .decreased: return .secondary.mix(with: .white, by: 0.35)
        case .none: return .secondary
        }
    }

    private var progress: Double {
        guard let intake, let recommendedGoal else { return 0 }
        guard recommendedGoal > 0 else { return 0 }
        return min(intake / recommendedGoal, 1.0)
    }

    private var percentageText: String {
        "\(Int(progress * 100))%"
    }

    private var difference: Double {
        guard let intake, let recommendedGoal else { return 0 }
        return intake - recommendedGoal
    }

    private var numericView: some View {
        HStack(spacing: 4) {
            if let intake {
                HStack {
                    Text(intake, format: .number)
                        .contentTransition(reduceMotion ? .identity : .numericText(value: intake))
                        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: intake)

                    if difference > 0 {
                        Text("(\(difference, format: .number.sign(strategy: .always())))")
                            .foregroundColor(.secondary)
                            .contentTransition(reduceMotion ? .identity : .numericText(value: difference))
                            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: difference)
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
                        Text(recommendedGoal, format: .number)
                            .foregroundColor(modificationColor)

                        if targetModification == .increased {
                            Image(systemName: "arrow.up")
                                .font(.caption2.bold())
                                .foregroundColor(modificationColor)
                                .contentTransition(reduceMotion ? .identity : .symbolEffect)
                                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: targetModification)

                        } else if targetModification == .decreased {
                            Image(systemName: "arrow.down")
                                .font(.caption2.bold())
                                .foregroundColor(modificationColor)
                                .contentTransition(reduceMotion ? .identity : .symbolEffect)
                                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: targetModification)
                        }
                    }
                } else {
                    Text(goal, format: .number)
                        .contentTransition(reduceMotion ? .identity : .numericText(value: goal))
                        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: goal)
                }
            } else {
                Text("-")
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: showPercentage)
    }

}
