import SwiftUI

struct NutritionProgressCardHelpView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    intro
                    Divider()
                    progressRingSection
                    Divider()
                    adjustedTargetsSection
                    Divider()
                    macroBarsSection
                    Divider()
                    dragGestureSection
                    Divider()
                    expandSection
                    Divider()
                    contextMenuSection
                    Divider()
                    nutritionGraphSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Nutrition Card Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                        .accessibilityLabel("Close guide")
                        .accessibilityHint("Dismisses this help screen")
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The Nutrition Card gives you a live snapshot of today's calories and macros — all from a single glance. This guide explains every visual, gesture, and shortcut available.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var progressRingSection: some View {
        HelpSection(title: "Calorie Ring", systemImage: "circle.dotted") {
            HelpCard {
                VStack(alignment: .leading, spacing: 16) {

                    HelpRow(
                        badge: RingBadge(progress: 0.72, label: "1440\n/2000"),
                        label: "Consumed vs. target",
                        description: "The ring fills clockwise as you log meals. The numbers inside show how many kilocalories you have eaten out of your daily target."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: RingBadge(progress: 0.72, label: "72%"),
                        label: "Tap to switch to percentage",
                        description: "Tap anywhere inside the ring to toggle between the raw consumed/target view and a percentage view. Tap again to switch back."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: RingBadge(progress: 1.0, label: "100%", color: Color(hex: "6E8B6F")),
                        label: "Goal reached",
                        description: "When you hit or exceed your calorie target the ring completes and the fill colour shifts to indicate you've met your goal for the day."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: RingBadge(progress: 1.15, label: "115%", color: Color(hex: "E07B8A")),
                        label: "Over target",
                        description: "If you go over your calorie target, the ring remains full but changes to a soft red to show that you have exceeded your goal. The percentage view makes it easy to see how much you've gone over at a glance (in this example, 15% over target)."
                    )
                }
            }
        }
    }

    private var adjustedTargetsSection: some View {
        HelpSection(title: "Adjusted Targets", systemImage: "slider.horizontal.3") {
            HelpCard {
                VStack(alignment: .leading, spacing: 16) {

                    HelpRow(
                        badge: RingWithDeltaBadge(progress: 0.68, label: "1360\n/2000", deltaLabel: "+200"),
                        label: "Server-expected vs. adjusted calorie target",
                        description: "Your server-expected target is the baseline your plan was built around. When your app adjusts this target — for example after logging exercise or a change in plan — the ring still tracks progress against the new target, but the small label beside the unit shows how much it has shifted up (+) or down (−) from the original."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: MacroWithArrowBadge(label: "Protein", fraction: 0.55, color: Color(hex: "A7C0CD"), arrow: "up"),
                        label: "Macro bar — target increased",
                        description: "When a macro's target has been raised above the server-expected value, an upward arrow appears next to the original target figure. The bar still fills relative to the new (higher) target."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: MacroWithArrowBadge(label: "Fats", fraction: 0.75, color: Color(hex: "E3B34B"), arrow: "down"),
                        label: "Macro bar — target decreased",
                        description: "A downward arrow means the target has been lowered from the server-expected value. The original figure is shown dimmed next to the arrow so you always know your baseline."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: SymbolHelpBadge(systemName: "info.circle", color: .secondary),
                        label: "Why two targets?",
                        description: "Your nutrition plan is generated server-side. The app may raise or lower individual targets day-to-day based on activity, trimester stage, or manual adjustments. The original figure is preserved so you can always see what your plan intended versus what you are working toward today."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: AddedFoodHighlightBadge(),
                        label: "Added food highlight",
                        description: "A soft yellow glow appears behind any food item you added to a meal yourself. Items that were part of your original server-generated plan have no highlight. The glow fades in and out with a smooth animation when items are added or removed."
                    )
                }
            }
        }
    }

    private var macroBarsSection: some View {
        HelpSection(title: "Macro Progress Bars", systemImage: "chart.bar.fill") {
            HelpCard {
                VStack(alignment: .leading, spacing: 16) {

                    HelpRow(
                        badge: MacroBarBadge(label: "Protein", fraction: 0.6, color: Color(hex: "A7C0CD")),
                        label: "Protein",
                        description: "Shows how many grams of protein you have consumed relative to your daily target. The soft blue fill grows left-to-right."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: MacroBarBadge(label: "Carbs", fraction: 0.45, color: Color(hex: "6E8B6F")),
                        label: "Carbs",
                        description: "Carbohydrate intake in grams. The muted green colour distinguishes it from protein at a glance."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: MacroBarBadge(label: "Fats", fraction: 0.8, color: Color(hex: "E3B34B")),
                        label: "Fats",
                        description: "Total fat intake in grams shown in amber. A bar near full capacity means you are close to your fat target."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: SymbolHelpBadge(systemName: "hand.tap.fill", color: .secondary),
                        label: "Tap a bar label to switch view",
                        description: "Tap the consumed/target numbers next to any macro bar to toggle that bar's display between grams and a percentage of your daily target."
                    )
                }
            }
        }
    }

    private var dragGestureSection: some View {
        HelpSection(title: "Swipe to Change View", systemImage: "hand.draw") {
            HelpCard {
                VStack(alignment: .leading, spacing: 16) {

                    HelpRow(
                        badge: SwipeDirectionBadge(direction: .up),
                        label: "Swipe up — next panel",
                        description: "While the card is collapsed, swipe upward on it to advance to the next content panel. The three dot indicators at the bottom show which panel is active."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: SwipeDirectionBadge(direction: .down),
                        label: "Swipe down — previous panel",
                        description: "Swipe downward to go back to the previous panel. The content slides in from the opposite edge with a spring animation."
                    )
                }
            }
        }
    }

    private var expandSection: some View {
        HelpSection(title: "Tap to Expand", systemImage: "rectangle.expand.vertical") {
            HelpCard {
                VStack(alignment: .leading, spacing: 16) {

                    HelpRow(
                        badge: SymbolHelpBadge(systemName: "hand.tap.fill", color: .primary),
                        label: "Tap the card to expand",
                        description: "A single tap anywhere on the card opens the full detail view with a smooth spring animation. Tap again to collapse it."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: SymbolHelpBadge(systemName: "flame.fill", color: Color(hex: "E3B34B")),
                        label: "Calories remaining",
                        description: "The expanded view shows exactly how many kilocalories you have left for the day, or how far over your target you are in red."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: MacroMicroBadge(label: "Sugar", color: Color(hex: "E07B8A")),
                        label: "Sugar & Sodium",
                        description: "Sugar and Sodium bars appear in the expanded section — these are hidden in the collapsed view to keep the card compact."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: MealBreakdownBadge(),
                        label: "Per-meal breakdown",
                        description: "A row for each meal — Breakfast, Lunch, Dinner, Snacks — shows a small progress bar of how many food items in that meal you have marked as consumed."
                    )
                }
            }
        }
    }

    private var contextMenuSection: some View {
        HelpSection(title: "Quick Actions Menu", systemImage: "ellipsis.circle") {
            HelpCard {
                VStack(alignment: .leading, spacing: 16) {

                    HelpRow(
                        badge: SymbolHelpBadge(systemName: "hand.tap.fill", color: .purple),
                        label: "Press and hold the card",
                        description: "Long-press the Nutrition Card to open the quick actions menu. A live preview of today's macro chart appears above the menu."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: SymbolHelpBadge(systemName: "chart.bar.xaxis", color: Color(hex: "1B6CA8")),
                        label: "Show Pretty Graph",
                        description: "Opens the full Nutrition Graph screen where you can browse each vital — Calories, Protein, Carbs, Fats, Sugar, and Sodium — with weekly or monthly charts."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: ContextMenuPreviewBadge(),
                        label: "Context menu preview",
                        description: "The preview thumbnail above the menu shows a grouped bar chart of today's three main macros versus their targets — so you get the insight without even opening the full screen."
                    )
                }
            }
        }
    }

    private var nutritionGraphSection: some View {
        HelpSection(title: "Nutrition Graph Screen", systemImage: "chart.bar.xaxis.ascending") {
            HelpCard {
                VStack(alignment: .leading, spacing: 16) {

                    HelpRow(
                        badge: VitalCardBadge(icon: "flame.fill", color: Color(hex: "E3B34B")),
                        label: "One card per vital",
                        description: "The hub screen lists all six vitals — Calories, Protein, Carbs, Fats, Sugar, Sodium. Each card shows today's value, a progress bar, and your target. Tap any card to open its full chart."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: RangePillsBadge(),
                        label: "Change the time range",
                        description: "Inside each vital's chart screen, use the segmented control at the top to switch between 7 Days, 30 Days, 3 Months, or a custom Calendar range."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: SymbolHelpBadge(systemName: "hand.point.left.fill", color: .secondary),
                        label: "Scroll beyond the visible window",
                        description: "The chart always shows 7 bars at a time. Swipe left or right directly on the chart to scroll through older data — this is built into the chart natively."
                    )

                    HelpDivider()

                    HelpRow(
                        badge: SymbolHelpBadge(systemName: "hand.tap.fill", color: .secondary),
                        label: "Tap a bar for details",
                        description: "Tap any bar in the chart to select it and see its exact value highlighted below the chart. Long-press a bar to copy its value or see it as a percentage of your target."
                    )
                }
            }
        }
    }
}

// MARK: - Section / Card / Row scaffolding

private struct HelpSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}

private struct HelpCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
    }
}

private struct HelpRow<Badge: View>: View {
    let badge: Badge
    let label: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            badge
                .frame(width: 50, height: 50)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label). \(description)")
    }
}

private struct HelpDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 64)
            .accessibilityHidden(true)
    }
}

// MARK: - Badges

private struct RingBadge: View {
    var progress: Double
    var label: String
    var color: Color = MomCareAccent.primary

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(label)
                .font(.caption2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
        .frame(width: 50, height: 50)
    }
}

private struct RingWithDeltaBadge: View {
    var progress: Double
    var label: String
    var deltaLabel: String

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(MomCareAccent.primary, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(label)
                    .font(.caption2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            .frame(width: 42, height: 42)

            Text(deltaLabel)
                .font(.caption2.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 3)
                .padding(.vertical, 1)
                .background(Color(.systemGray5), in: Capsule())
                .offset(x: 4, y: 4)
        }
        .frame(width: 50, height: 50)
    }
}

/// Macro bar badge showing an up or down arrow next to the original target value.
private struct MacroWithArrowBadge: View {
    let label: String
    let fraction: Double
    let color: Color
    let arrow: String // "up" or "down"

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: arrow == "up" ? "arrow.up" : "arrow.down")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule().fill(color).frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 4)
        .frame(width: 50, height: 50)
    }
}

private struct MacroBarBadge: View {
    let label: String
    let fraction: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule().fill(color).frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 4)
        .frame(width: 50, height: 50)
    }
}

private struct SwipeDirectionBadge: View {
    enum Direction { case up, down }

    let direction: Direction

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: direction == .up ? "arrow.up" : "arrow.down")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color(hex: "1B6CA8"))

            Text(direction == .up ? "Swipe up" : "Swipe down")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(width: 50, height: 50)
    }
}

private struct PanelDotsBadge: View {
    let active: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == active ? Color(hex: "1B6CA8") : Color(.systemGray4))
                    .frame(width: i == active ? 14 : 5, height: 5)
            }
        }
        .frame(width: 50, height: 50)
    }
}

private struct SymbolHelpBadge: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.title)
            .foregroundStyle(color)
            .frame(width: 50, height: 50)
    }
}

private struct MacroMicroBadge: View {
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule().fill(color).frame(width: geo.size.width * 0.55)
                }
            }
            .frame(height: 7)
        }
        .padding(.horizontal, 4)
        .frame(width: 50, height: 50)
    }
}

private struct MealBreakdownBadge: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 3) {
            ForEach(meals, id: \.0) { label, frac, color in
                HStack(spacing: 4) {
                    Text(label)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 8)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.systemGray5))
                            Capsule().fill(color).frame(width: geo.size.width * frac)
                        }
                    }
                    .frame(height: 5)
                }
            }
        }
        .padding(.horizontal, 4)
        .frame(width: 50, height: 50)
    }

    // MARK: Private

    private let meals: [(String, Double, Color)] = [
        ("B", 1.0, Color(hex: "E3B34B")),
        ("L", 0.7, Color(hex: "6E8B6F")),
        ("D", 0.4, Color(hex: "A7C0CD")),
        ("S", 0.9, Color(hex: "E07B8A"))
    ]

}

private struct ContextMenuPreviewBadge: View {

    // MARK: Internal

    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            ForEach(bars, id: \.0) { label, frac, color in
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(color)
                        .frame(width: 10, height: 30 * frac)
                    Text(label)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 50, height: 50)
    }

    // MARK: Private

    private let bars: [(String, Double, Color)] = [
        ("P", 0.65, Color(hex: "A7C0CD")),
        ("C", 0.4, Color(hex: "6E8B6F")),
        ("F", 0.8, Color(hex: "E3B34B"))
    ]

}

private struct VitalCardBadge: View {
    let icon: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color.opacity(0.14))
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
        }
        .frame(width: 50, height: 50)
    }
}

private struct RangePillsBadge: View {
    var body: some View {
        HStack(spacing: 2) {
            ForEach(["7D", "30D", "3M"], id: \.self) { label in
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(label == "7D" ? Color(.systemBackground) : Color.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 3)
                    .background(label == "7D" ? Color(hex: "1B6CA8") : Color(.systemGray5),
                                in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
        }
        .frame(width: 50, height: 50)
    }
}

private struct AddedFoodHighlightBadge: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemGray6))

            VStack(spacing: 6) {
                // "Original" row — no highlight
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color(.systemGray5))
                    .frame(height: 10)

                // "Added" row — yellow glow
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.05),
                            Color.yellow.opacity(0.25),
                            Color.yellow.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(Color.yellow.opacity(0.35), lineWidth: 0.5)
                }
                .frame(height: 10)

                // "Original" row — no highlight
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color(.systemGray5))
                    .frame(height: 10)
            }
            .padding(.horizontal, 6)
        }
        .frame(width: 50, height: 50)
    }
}
