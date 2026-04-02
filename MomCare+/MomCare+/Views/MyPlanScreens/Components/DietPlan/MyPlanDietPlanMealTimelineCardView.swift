import SwiftUI
import TipKit

struct MyPlanDietPlanMealTimelineCardView: View {
    // MARK: Internal

    let plan: MealPlanModel?
    let addFoodItemTip: (any Tip)?
    let slideFoodItemRowTip: (any Tip)?

    var body: some View {
        List {
            mealSection(
                title: "Breakfast",
                items: plan?.breakfast ?? [],
                originalItems: plan?.originalBreakfast ?? [],
                mealType: .breakfast
            )
            mealSection(
                title: "Lunch",
                items: plan?.lunch ?? [],
                originalItems: plan?.originalLunch ?? [],
                mealType: .lunch
            )
            mealSection(
                title: "Snacks",
                items: plan?.snacks ?? [],
                originalItems: plan?.originalSnacks ?? [],
                mealType: .snacks
            )
            mealSection(
                title: "Dinner",
                items: plan?.dinner ?? [],
                originalItems: plan?.originalDinner ?? [],
                mealType: .dinner
            )
            Section {
                Color.clear.padding(.vertical)
            }
        }
        .listStyle(.inset)
        .listSectionSpacing(0)
        .listRowSpacing(0)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .scrollBounceBehavior(.basedOnSize)
        .environment(\.defaultMinListRowHeight, 0)
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private func mealSection(title: String, items: [FoodReferenceModel], originalItems: [FoodReferenceModel], mealType: MealType) -> some View {
        Section {
            MealTimelineHeaderRow(
                section: MealSection(title: title, items: items),
                hideTopLine: title == "Breakfast",
                hideBottomLine: title == "Dinner" && items.isEmpty,
                mealType: mealType,
                tip: addFoodItemTip
            ) { consumed in
                do {
                    try await contentServiceHandler.markFoodsAs(consumed: !consumed, mealType: mealType)
                } catch {
                    controlState.error = error
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.top, 0)
            .listRowInsets(.bottom, 0)

            if contentServiceHandler.isFetchingMealPlan {
                HStack(alignment: .center) {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.top, 0)
                .listRowInsets(.bottom, 0)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Loading meal items")
            } else {
                ForEach(items) { item in
                    MealTimelineFoodItemRow(
                        item: item,
                        hideTopLine: false,
                        hideBottomLine: item.id == items.last?.id && title == "Dinner",
                        onToggle: { consumed in
                            do {
                                try await contentServiceHandler.markFoodAs(consumed: !consumed, in: mealType, foodReference: item)
                            } catch {
                                controlState.error = error
                            }
                        },
                        onDelete: {
                            do {
                                try await contentServiceHandler.markFoodAs(consumed: false, in: mealType, foodReference: item)
                                try await contentServiceHandler.removeFoodFromPlan(foodId: item.foodId, mealType: mealType)
                            } catch {
                                controlState.error = error
                            }
                        }
                    )
                    .popoverTip(slideFoodItemRowTip, arrowEdge: .top)
                    .background {
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.01),
                                Color.yellow.opacity(0.10),
                                Color.yellow.opacity(0.15),
                                Color.yellow.opacity(0.10),
                                Color.yellow.opacity(0.01)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .ignoresSafeArea()
                        .opacity(originalItems.contains(where: { $0.id == item.id }) ? 0 : 1)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: originalItems)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.top, 0)
                    .listRowInsets(.bottom, 0)
                }
            }
        }
        .listSectionSpacing(0)
    }
}

private struct MealTimelineHeaderRow: View {
    // MARK: Internal

    let section: MealSection
    let hideTopLine: Bool
    let hideBottomLine: Bool
    let mealType: MealType
    let tip: (any Tip)?
    let onToggle: (Bool) async -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            TimelineLine(
                isChecked: section.isCompleted,
                style: .header,
                hideTop: hideTopLine,
                hideBottom: hideBottomLine
            )
            .onTapGesture {
                Task {
                    await onToggle(section.isCompleted)
                }
            }
            .accessibilityLabel(section.isCompleted ? "Mark \(section.title) as not completed" : "Mark \(section.title) as completed")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default) {
                Task {
                    await onToggle(section.isCompleted)
                }
            }

            Text(section.title)
                .font(.title3.weight(.semibold))
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Menu {
                Button {
                    showSearchFoodSheet = true
                } label: {
                    Label("Add Food Item", systemImage: "plus")
                }

            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.title3)
                    .foregroundStyle(MomCareAccent.primary)
            }
            .popoverTip(tip, arrowEdge: .trailing)
            .accessibilityLabel("Add food to \(section.title)")
            .frame(minWidth: 44, minHeight: 44)
        }
        .frame(height: 66)
        .contentShape(Rectangle())
        .sheet(isPresented: $showSearchFoodSheet) {
            MyPlanFoodItemSearchView(mealType: mealType)
                .presentationDetents([.medium, .large])
                .interactiveDismissDisabled(true)
                .scrollDismissesKeyboard(.immediately)
        }
    }

    // MARK: Private

    @State private var showSearchFoodSheet = false
}

private struct MealTimelineFoodItemRow: View {
    // MARK: Internal

    var item: FoodReferenceModel
    let hideTopLine: Bool
    let hideBottomLine: Bool
    let onToggle: (Bool) async -> Void
    let onDelete: () async -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            TimelineLine(
                isChecked: item.isConsumed,
                style: .item,
                hideTop: hideTopLine,
                hideBottom: hideBottomLine
            )
            .onTapGesture {
                Task {
                    await onToggle(item.isConsumed)
                }
            }
            .accessibilityLabel(item.isConsumed ? "Mark as not consumed" : "Mark as consumed")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default) {
                Task {
                    await onToggle(item.isConsumed)
                }
            }

            FoodThumbnail(foodIdentifier: item.foodId)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(food?.name.capitalized ?? "Food Item")
                    .font(.headline)

                HStack(spacing: 4) {
                    Text("\(item.count) Serving")
                    Text("•")
                    Text(food?.calories.formattedOneDecimal ?? "")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .frame(height: 66)
        .contentShape(Rectangle())
        .modifier(MealContextMenu(item: item, food: food, onToggle: onToggle, onDelete: onDelete))
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                Task {
                    await onToggle(item.isConsumed)
                }
            } label: {
                Label(
                    item.isConsumed ? "Undo" : "",
                    systemImage: item.isConsumed ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(item.isConsumed ? .orange : .green)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                Task { await onDelete() }
            } label: {
                Label("", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(food?.name.capitalized ?? "Food item"), \(item.count) serving, \(food?.calories.formattedOneDecimal ?? "")"
        )
        .accessibilityValue(item.isConsumed ? "consumed" : "not consumed")
        .accessibilityHint("Long press for more options.")
        .accessibilityAction(named: item.isConsumed ? "Undo" : "Consume") {
            Task {
                await onToggle(item.isConsumed)
            }
        }
        .accessibilityAction(named: "Delete") {
            Task { await onDelete() }
        }
        .task {
            food = await item.food
        }
    }

    // MARK: Private

    @State private var food: FoodItemModel?
}

private struct TimelineLine: View {
    let isChecked: Bool
    var style: CircleStyle = .item
    var hideTop: Bool = false
    var hideBottom: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(hideTop ? Color.clear : Color.secondary.opacity(0.3))
                    .frame(width: 1.5)

                Rectangle()
                    .fill(hideBottom ? Color.clear : Color.secondary.opacity(0.3))
                    .frame(width: 1.5)
            }

            TimelineCircle(isChecked: isChecked, style: style)
        }
        .frame(width: 28)
    }
}

struct FoodThumbnail: View {
    // MARK: Internal

    let foodIdentifier: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.secondary.opacity(0.15))

            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
            } else {
                Image(systemName: "carrot.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 54, height: 54)
        .task {
            let networkResponse = try? await MCContentRepository.shared.fetchFoodImage(id: foodIdentifier)
            if let uri = networkResponse?.data.detail {
                uiImage = try? await UIImage.getOrFetch(from: uri)
            }
        }
    }

    // MARK: Private

    @State private var uiImage: UIImage?
}

private struct MealContextMenu: ViewModifier {
    // MARK: Internal

    let item: FoodReferenceModel
    let food: FoodItemModel?
    let onToggle: (Bool) async -> Void
    let onDelete: () async -> Void

    func body(content: Content) -> some View {
        content
            .contextMenu {
                menuButtons
            } preview: {
                if let food {
                    NutritionPreview(item: item, food: food)
                }
            }
    }

    // MARK: Private

    @ViewBuilder
    private var menuButtons: some View {
        Button {
            Task {
                await onToggle(item.isConsumed)
            }
        } label: {
            Label(
                item.isConsumed ? "Mark as Not Consumed" : "Mark as Consumed",
                systemImage: item.isConsumed ? "xmark.circle" : "checkmark.circle"
            )
        }

        Divider()

        Button(role: .destructive) {
            Task { await onDelete() }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

private struct NutritionPreview: View {
    // MARK: Internal

    let item: FoodReferenceModel
    let food: FoodItemModel

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.secondary.opacity(0.12))

                FoodThumbnail(foodIdentifier: item.foodId)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 6) {
                Text(food.name.capitalized).font(.headline).lineLimit(1)
                Text("\(item.count) Serving").font(.caption).foregroundStyle(.secondary)
                Divider()
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 3) {
                        nutrientLabel("Cal", food.calories.formattedNoDecimal)
                        nutrientLabel("Protein", food.protein.formattedOneDecimal)
                        nutrientLabel("Carbs", food.carbs.formattedOneDecimal)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        nutrientLabel("Fats", food.fats.formattedOneDecimal)
                        nutrientLabel("Sugar", food.sugar.formattedOneDecimal)
                        nutrientLabel("Sodium", food.sodium.formattedNoDecimal)
                    }
                }
            }
        }
        .padding(14)
        .frame(width: 320)
    }

    // MARK: Private

    private func nutrientLabel(_ label: String, _ value: String) -> some View {
        HStack(spacing: 4) {
            Text(label).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.caption2.weight(.semibold))
        }
    }
}

private enum CircleStyle {
    case header
    case item

    // MARK: Internal

    var size: CGFloat {
        self == .header ? 22 : 16
    }

    var maskSize: CGFloat {
        size + 4
    }

    var strokeWidth: CGFloat {
        self == .header ? 2 : 1.5
    }

    var checkmarkFont: Font {
        self == .header ? .caption.bold() : .caption2.bold()
    }
}

private struct TimelineCircle: View {
    let isChecked: Bool
    var style: CircleStyle = .header

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: style.maskSize, height: style.maskSize)

            Circle()
                .stroke(MomCareAccent.primary, lineWidth: style.strokeWidth)
                .frame(width: style.size, height: style.size)

            if isChecked {
                Circle()
                    .fill(MomCareAccent.primary)
                    .frame(width: style.size, height: style.size)

                Image(systemName: "checkmark")
                    .font(style.checkmarkFont)
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct MealSection: Identifiable {
    let id: UUID = .init()
    let title: String
    var items: [FoodReferenceModel]

    var isCompleted: Bool {
        items.allSatisfy(\.isConsumed)
    }
}
