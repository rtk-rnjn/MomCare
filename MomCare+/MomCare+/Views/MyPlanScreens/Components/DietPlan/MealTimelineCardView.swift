import SwiftUI

struct MealTimelineCardView: View {

    // MARK: Internal

    var body: some View {
        List {
            mealSection(
                title: "Breakfast",
                items: contentServiceHandler.myPlanModel?.breakfast ?? [],
                originalItems: contentServiceHandler.myPlanModel?.originalBreakfast ?? [],
                mealType: .breakfast
            )
            mealSection(
                title: "Lunch",
                items: contentServiceHandler.myPlanModel?.lunch ?? [],
                originalItems: contentServiceHandler.myPlanModel?.originalLunch ?? [],
                mealType: .lunch
            )
            mealSection(
                title: "Snacks",
                items: contentServiceHandler.myPlanModel?.snacks ?? [],
                originalItems: contentServiceHandler.myPlanModel?.originalSnacks ?? [],
                mealType: .snacks
            )
            mealSection(
                title: "Dinner",
                items: contentServiceHandler.myPlanModel?.dinner ?? [],
                originalItems: contentServiceHandler.myPlanModel?.originalDinner ?? [],
                mealType: .dinner
            )
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

    @ViewBuilder
    private func mealSection(title: String, items: [FoodReferenceModel], originalItems: [FoodReferenceModel], mealType: MealType) -> some View {
        Section {
            HeaderRow(
                section: MealSection(title: title, items: items),
                hideTopLine: title == "Breakfast",
                hideBottomLine: title == "Dinner" && items.isEmpty,
                mealType: mealType
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

            ForEach(items) { item in
                ItemRow(
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
                .background {
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.05),
                            Color.yellow.opacity(0.15),
                            Color.yellow.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .opacity(originalItems.contains(where: { $0.id == item.id }) ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: originalItems)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.top, 0)
                .listRowInsets(.bottom, 0)
            }
        }
        .listSectionSpacing(0)
    }
}

private struct HeaderRow: View {

    // MARK: Internal

    let section: MealSection
    let hideTopLine: Bool
    let hideBottomLine: Bool
    let mealType: MealType
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
                    try? await contentServiceHandler.fetchMealPlan(makeNetworkCall: false)
                }
            }
            .accessibilityLabel(section.isCompleted ? "Mark \(section.title) as not completed" : "Mark \(section.title) as completed")
            .accessibilityAddTraits(.isButton)

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
                    .foregroundColor(MomCareAccent.primary)
            }
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

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler

    @State private var showSearchFoodSheet = false
    @State private var selectedFood: FoodItemModel?

}

private struct ItemRow: View {

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
                    try? await contentServiceHandler.fetchMealPlan(makeNetworkCall: false)
                }
            }
            .accessibilityLabel(item.isConsumed ? "Mark as not consumed" : "Mark as consumed")
            .accessibilityAddTraits(.isButton)

            FoodThumbnail(foodReferenceModel: item)
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
                .foregroundColor(.secondary)
            }

            Spacer()
        }
        .frame(height: 66)
        .contentShape(Rectangle())
        .modifier(MealContextMenu(item: item, food: food, onToggle: onToggle, onDelete: onDelete))
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                HapticsHandler.notification(item.isConsumed ? .warning : .success)
                Task {
                    await onToggle(item.isConsumed)
                    try? await contentServiceHandler.fetchMealPlan(makeNetworkCall: false)
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
                HapticsHandler.notification(.warning)
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
            HapticsHandler.notification(item.isConsumed ? .warning : .success)
            Task {
                await onToggle(item.isConsumed)
                try? await contentServiceHandler.fetchMealPlan(makeNetworkCall: false)
            }
        }
        .accessibilityAction(named: "Delete") {
            HapticsHandler.notification(.warning)
            Task { await onDelete() }
        }
        .task {
            food = await item.food
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
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

    @State var foodReferenceModel: FoodReferenceModel

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
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 54, height: 54)
        .task {
            let networkResponse = try? await ContentService.shared.fetchFoodImage(id: foodReferenceModel.foodId)
            if let uri = networkResponse?.data?.detail {
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

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler

    @ViewBuilder
    private var menuButtons: some View {
        Button {
            HapticsHandler.notification(item.isConsumed ? .warning : .success)
            Task {
                await onToggle(item.isConsumed)
                try? await contentServiceHandler.fetchMealPlan()
            }
        } label: {
            Label(
                item.isConsumed ? "Mark as Not Consumed" : "Mark as Consumed",
                systemImage: item.isConsumed ? "xmark.circle" : "checkmark.circle"
            )
        }

        Divider()

        Button(role: .destructive) {
            HapticsHandler.notification(.warning)
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

                FoodThumbnail(foodReferenceModel: item)
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
            .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 6) {
                Text(food.name.capitalized).font(.headline).lineLimit(1)
                Text("\(item.count) Serving").font(.caption).foregroundColor(.secondary)
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
            Text(label).font(.caption2).foregroundColor(.secondary)
            Text(value).font(.caption2.weight(.semibold))
        }
    }
}

enum CircleStyle {
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

struct TimelineCircle: View {
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
                    .foregroundColor(.white)
            }
        }
    }
}

struct MealSection: Identifiable {
    let id: UUID = .init()
    let title: String
    var items: [FoodReferenceModel]

    var isCompleted: Bool {
        items.allSatisfy(\.isConsumed)
    }
}
