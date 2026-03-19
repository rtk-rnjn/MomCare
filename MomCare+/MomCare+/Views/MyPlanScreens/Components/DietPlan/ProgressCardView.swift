import SwiftUI

enum CardDisplayMode: Int, CaseIterable {
    case calories
    case macros
    case micros

    // MARK: Internal

    var label: String {
        switch self {
        case .calories: return "Calories"
        case .macros: return "Macros"
        case .micros: return "Micros"
        }
    }
}

struct ProgressCardView: View {

    // MARK: Internal

    let caloriesConsumed: Double
    let caloriesTarget: Double

    let originalCaloriesTarget: Double // this is server expected target

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
        .onTapGesture(perform: !experimentalFeatures ? toggleExpansion : {})
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

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
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
        guard caloriesTarget > 0 else { return 0 }
        return min(caloriesConsumed / caloriesTarget, 1.0)
    }

    private var collapsedHeader: some View {
        HStack(alignment: .center, spacing: 20) {

            ProgressRingView(
                progress: calorieProgress,
                consumed: caloriesConsumed,
                target: caloriesTarget,
                original: originalCaloriesTarget,
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
                    consumed: caloriesConsumed,
                    target: caloriesTarget
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
                consumed: contentServiceHandler.nurtitionConsumedTotals?.proteinMass,
                target: contentServiceHandler.nutritionTargetTotals?.proteinMass,
                originalTarget: contentServiceHandler.originalNutritionTargetTotals?.proteinMass,
                color: Color(hex: "A7C0CD")
            )

            MacroBarRow(
                title: "Carbs",
                consumed: contentServiceHandler.nurtitionConsumedTotals?.carbsMass,
                target: contentServiceHandler.nutritionTargetTotals?.carbsMass,
                originalTarget: contentServiceHandler.originalNutritionTargetTotals?.carbsMass,
                color: Color(hex: "6E8B6F")
            )

            MacroBarRow(
                title: "Fats",
                consumed: contentServiceHandler.nurtitionConsumedTotals?.fatsMass,
                target: contentServiceHandler.nutritionTargetTotals?.fatsMass,
                originalTarget: contentServiceHandler.originalNutritionTargetTotals?.fatsMass,
                color: Color(hex: "E3B34B")
            )
        }
    }

    private var microRows: some View {
        Group {
            MacroBarRow(
                title: "Sugar",
                consumed: contentServiceHandler.nurtitionConsumedTotals?.sugarMass,
                target: contentServiceHandler.nutritionTargetTotals?.sugarMass,
                originalTarget: contentServiceHandler.originalNutritionTargetTotals?.sugarMass,
                color: Color(hex: "E07B8A")
            )

            MacroBarRow(
                title: "Sodium",
                consumed: contentServiceHandler.nurtitionConsumedTotals?.sodiumMass,
                target: contentServiceHandler.nutritionTargetTotals?.sodiumMass,
                originalTarget: contentServiceHandler.originalNutritionTargetTotals?.sodiumMass,
                color: Color(hex: "9B8EC4")
            )
        }
    }

    private var expandedSection: some View {
        VStack {
            Divider()
                .padding(.horizontal, 18)

            ExpandedDetailView(
                caloriesConsumed: caloriesConsumed,
                caloriesTarget: caloriesTarget,
                plan: contentServiceHandler.myPlanModel
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
                .contentTransition(.numericText())

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

    private var remaining: Double { max(target - consumed, 0) }
    private var isOver: Bool { consumed > target }

}

private struct ExpandedDetailView: View {

    // MARK: Internal

    let caloriesConsumed: Double
    let caloriesTarget: Double
    let plan: MyPlanModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Micros")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                MacroBarRow(
                    title: "Sugar",
                    consumed: contentServiceHandler.nurtitionConsumedTotals?.sugarMass,
                    target: contentServiceHandler.nutritionTargetTotals?.sugarMass,
                    originalTarget: contentServiceHandler.originalNutritionTargetTotals?.sugarMass,
                    color: Color(hex: "E07B8A")
                )
                MacroBarRow(
                    title: "Sodium",
                    consumed: contentServiceHandler.nurtitionConsumedTotals?.sodiumMass,
                    target: contentServiceHandler.nutritionTargetTotals?.sodiumMass,
                    originalTarget: contentServiceHandler.originalNutritionTargetTotals?.sodiumMass,
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

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler

}

private struct CalorieStatPill: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(Int(value))")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(color)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
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
                            .contentTransition(.numericText())
                            .transition(.opacity.combined(with: .scale))
                            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: percentage)
                            .font(.title2.weight(.bold))
                    } else {
                        HStack(spacing: 2) {
                            Text(Int(consumed), format: .number)
                                .font(consumed > 999 ? .footnote.weight(.semibold) : .headline)
                                .contentTransition(.numericText())
                                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: Int(consumed))

                            Text("/")
                                .font(consumed > 999 ? .footnote.weight(.semibold) : .headline)

                            Text(Int(original), format: .number)
                                .font(consumed > 999 ? .footnote.weight(.semibold) : .headline)
                                .contentTransition(.numericText())
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
                        Text("\(target > original ? "+" : "-")\(Int(abs(target - original)))")
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

    @State private var showPercentage = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var percentage: Int {
        guard target > 0 else { return 0 }
        return Int((consumed / target) * 100)
    }
    
    private enum TargetModification {
        case increased, decreased
        var displaySymbol: String {
            switch self {
            case .increased: return "+"
            case .decreased: return "-"
            }
        }
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
        case .none:      return .secondary
        }
    }
}

struct MacroBarRow: View {

    // MARK: Internal

    let title: String
    let consumed: Measurement<UnitMass>?
    let target: Measurement<UnitMass>?
    let originalTarget: Measurement<UnitMass>?
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
                                if targetModification != nil {
                                    HStack {
                                        Text(originalTarget?.formattedOneDecimal ?? "-")
                                            .foregroundColor(modificationColor)
                                        if targetModification == .increased {
                                            Image(systemName: "arrow.up")
                                                .font(.caption2.bold())
                                                .foregroundColor(modificationColor)
                                        } else if targetModification == .decreased {
                                            Image(systemName: "arrow.down")
                                                .font(.caption2.bold())
                                                .foregroundColor(modificationColor)
                                        }
                                    }
                                } else {
                                    Text(target.formattedOneDecimal)
                                }
                            } else {
                                Text("-")
                            }
                        }
                        .contentTransition(.numericText())
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
        .accessibilityValue(showPercentage ? percentageText : "\(consumed?.formattedOneDecimal ?? "-") of \(target?.formattedOneDecimal ?? "-")")
        .accessibilityHint("Double tap to toggle percentage view")
        .accessibilityAddTraits([.isButton, .updatesFrequently])
    }

    // MARK: Private

    private enum TargetModification {
        case increased, decreased
    }

    @State private var showPercentage = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var targetModification: TargetModification? {
        guard let target, let originalTarget else { return nil }
        let targetValue = target.converted(to: originalTarget.unit).value
        let originalValue = originalTarget.value
        if targetValue > originalValue { return .increased }
        if targetValue < originalValue { return .decreased }
        return nil
    }

    private var modificationColor: Color {
        switch targetModification {
        case .increased: return .secondary.mix(with: .black, by: 0.2)
        case .decreased: return .secondary.mix(with: .white, by: 0.35)
        case .none:      return .secondary
        }
    }

    private var progress: Double {
        guard let consumed, let target else { return 0 }
        let consumedValue = consumed.converted(to: target.unit).value
        let targetValue = target.value
        guard targetValue > 0 else { return 0 }
        return min(consumedValue / targetValue, 1.0)
    }

    private var percentageText: String {
        "\(Int(progress * 100))%"
    }
}
