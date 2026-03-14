import SwiftUI

struct MealTimelineCardView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 0) {
            HeaderRow(section: MealSection(title: "Breakfast", items: healthKitHandler.myPlanModel?.breakfast ?? []), hideTopLine: true, hideBottomLine: false, mealType: .breakfast) { consumed in
                do {
                    try await healthKitHandler.markFoodsAs(consumed: !consumed, mealType: .breakfast)
                } catch {
                    alertMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }

            ForEach(healthKitHandler.myPlanModel?.breakfast ?? []) { item in
                ItemRow(
                    item: item,
                    hideTopLine: false,
                    hideBottomLine: false,
                    onToggle: { consumed in
                        do {
                            try await healthKitHandler.markFoodAs(consumed: !consumed, in: .breakfast, foodReference: item)
                        } catch {
                            alertMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    },
                    onDelete: {
                        do {
                            try await healthKitHandler.markFoodAs(consumed: false, in: .breakfast, foodReference: item)
                            try await healthKitHandler.removeFoodFromPlan(foodId: item.foodId, mealType: .breakfast)
                        } catch {
                            alertMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                )
            }

            HeaderRow(section: MealSection(title: "Lunch", items: healthKitHandler.myPlanModel?.lunch ?? []), hideTopLine: false, hideBottomLine: false, mealType: .lunch) { consumed in
                do {
                    try await healthKitHandler.markFoodsAs(consumed: !consumed, mealType: .lunch)
                } catch {
                    alertMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }

            ForEach(healthKitHandler.myPlanModel?.lunch ?? []) { item in
                ItemRow(
                    item: item,
                    hideTopLine: false,
                    hideBottomLine: false,
                    onToggle: { consumed in
                        do {
                            try await healthKitHandler.markFoodAs(consumed: !consumed, in: .lunch, foodReference: item)
                        } catch {
                            alertMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    },
                    onDelete: {
                        do {
                            try await healthKitHandler.markFoodAs(consumed: false, in: .lunch, foodReference: item)
                            try await healthKitHandler.removeFoodFromPlan(foodId: item.foodId, mealType: .lunch)
                        } catch {
                            alertMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                )
            }

            HeaderRow(section: MealSection(title: "Snacks", items: healthKitHandler.myPlanModel?.snacks ?? []), hideTopLine: false, hideBottomLine: false, mealType: .snacks) { consumed in
                do {
                    try await healthKitHandler.markFoodsAs(consumed: !consumed, mealType: .snacks)
                } catch {
                    alertMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }

            ForEach(healthKitHandler.myPlanModel?.snacks ?? []) { item in
                ItemRow(
                    item: item,
                    hideTopLine: false,
                    hideBottomLine: false,
                    onToggle: { consumed in
                        do {
                            try await healthKitHandler.markFoodAs(consumed: !consumed, in: .snacks, foodReference: item)
                        } catch {
                            alertMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    },
                    onDelete: {
                        do {
                            try await healthKitHandler.markFoodAs(consumed: false, in: .snacks, foodReference: item)
                            try await healthKitHandler.removeFoodFromPlan(foodId: item.foodId, mealType: .snacks)
                        } catch {
                            alertMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                )
            }

            HeaderRow(section: MealSection(title: "Dinner", items: healthKitHandler.myPlanModel?.dinner ?? []), hideTopLine: false, hideBottomLine: healthKitHandler.myPlanModel?.dinner.isEmpty ?? true, mealType: .dinner) { consumed in
                do {
                    try await healthKitHandler.markFoodsAs(consumed: !consumed, mealType: .dinner)
                } catch {
                    alertMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }

            ForEach(healthKitHandler.myPlanModel?.dinner ?? []) { item in
                ItemRow(
                    item: item,
                    hideTopLine: false,
                    hideBottomLine: false,
                    onToggle: { consumed in
                        do {
                            try await healthKitHandler.markFoodAs(consumed: !consumed, in: .dinner, foodReference: item)
                        } catch {
                            alertMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    },
                    onDelete: {
                        do {
                            try await healthKitHandler.markFoodAs(consumed: false, in: .dinner, foodReference: item)
                            try await healthKitHandler.removeFoodFromPlan(foodId: item.foodId, mealType: .dinner)
                        } catch {
                            alertMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "An unexpected error occurred.")
        }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler
    @State private var showErrorAlert = false
    @State private var alertMessage: String?

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
                    try? await healthKitHandler.fetchMealPlan(makeNetworkCall: false)
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
                .presentationDetents([.large])
                .interactiveDismissDisabled(true)
        }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

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
                    try? await healthKitHandler.fetchMealPlan(makeNetworkCall: false)
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
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contentShape(Rectangle())
        .modifier(MealContextMenu(item: item, food: food, onToggle: onToggle, onDelete: onDelete))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(food?.name.capitalized ?? "Food item"), \(item.count) serving, \(food?.calories.formattedOneDecimal ?? "")"
        )
        .accessibilityValue(item.isConsumed ? "consumed" : "not consumed")
        .accessibilityHint("Long press for more options")
        .task {
            food = await item.food
        }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

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

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

    @ViewBuilder
    private var menuButtons: some View {
        Button {
            Task {
                await onToggle(item.isConsumed)
                try? await healthKitHandler.fetchMealPlan()
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
//                Image(systemName: item.imageName)
//                    .font(.system(size: 32, weight: .regular))
//                    .foregroundColor(.secondary)
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
