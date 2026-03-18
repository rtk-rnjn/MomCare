import SwiftUI
import FSCalendar

private extension Color {
    static let planBg: Color = .init(red: 0.95, green: 0.96, blue: 0.97)
    static let planSurface: Color = .white
    static let planAccent: Color = .init(red: 0.22, green: 0.53, blue: 0.98)
    static let planAccentSoft = Color(red: 0.22, green: 0.53, blue: 0.98).opacity(0.10)
    static let planGreen: Color = .init(red: 0.13, green: 0.75, blue: 0.48)
    static let planLabel: Color = .init(red: 0.09, green: 0.09, blue: 0.12)
    static let planMuted: Color = .init(red: 0.54, green: 0.54, blue: 0.59)
    static let planBorder: Color = .init(red: 0.88, green: 0.88, blue: 0.91)
}

private struct FoodReferenceRow: View {

    // MARK: Internal

    let ref: FoodReferenceModel

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(ref.isConsumed ? Color.planGreen.opacity(0.10) : Color.planBg)
                    .frame(width: 30, height: 30)
                Circle()
                    .stroke(ref.isConsumed ? Color.planGreen : Color.planBorder, lineWidth: 1.5)
                    .frame(width: 30, height: 30)
                if ref.isConsumed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.planGreen)
                }
            }

            if let foodName = food?.name {
                Text(foodName.capitalized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(ref.isConsumed ? Color.planMuted : Color.planLabel)
                    .strikethrough(ref.isConsumed, color: Color.planMuted)
            } else {
                ProgressView()
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .task {
            food = await ref.food
        }
    }

    // MARK: Private

    @State private var food: FoodItemModel?

}

private struct MealSectionCard: View {

    // MARK: Internal

    let meta: MealType
    let items: [FoodReferenceModel]

    var body: some View {
        VStack(spacing: 0) {

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {

                    Text(meta.rawValue.capitalized)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.planLabel)

                    Spacer()

                    Text("\(consumedCount)/\(items.count)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(isComplete ? Color.planGreen : Color.planMuted)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(isComplete ? Color.planGreen.opacity(0.10) : Color.planBg)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(
                                isComplete ? Color.planGreen.opacity(0.25) : Color.planBorder,
                                lineWidth: 1
                            )
                        )

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.planMuted)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if !isExpanded {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.planBg).frame(height: 3)
                        Rectangle()
                            .frame(width: geo.size.width * progress, height: 3)
                            .animation(.easeOut(duration: 0.7), value: progress)
                    }
                }
                .frame(height: 3)
            }

            if isExpanded {
                if items.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.planBorder)
                        Text("Nothing planned yet")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.planMuted)
                    }
                    .padding(.vertical, 18)
                    .transition(.opacity)
                } else {
                    VStack(spacing: 0) {
                        ForEach(items) { reference in
                            FoodReferenceRow(ref: reference)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .background(Color.planSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: Private

    @State private var isExpanded = true

    private var consumedCount: Int { items.filter(\.isConsumed).count }
    private var progress: CGFloat {
        guard !items.isEmpty else { return 0 }
        return CGFloat(consumedCount) / CGFloat(items.count)
    }

    private var isComplete: Bool { !items.isEmpty && consumedCount == items.count }

}

struct DietPlanHistory: View {

    // MARK: Internal

    @State var plan: MyPlanModel?
    @State var selectedDate: Date = .init()

    var body: some View {
        NavigationStack {
            CompactCalendarView(selectedDate: $selectedDate, isExpanded: $isCalendarExpanded)
            Group {
                if let plan {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            MealSectionCard(meta: .breakfast, items: plan.breakfast)
                            MealSectionCard(meta: .lunch, items: plan.lunch)
                            MealSectionCard(meta: .snacks, items: plan.snacks)
                            MealSectionCard(meta: .dinner, items: plan.dinner)

                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)

                    }
                } else {
                    if isLoading {
                        ProgressView()
                    } else {
                        ContentUnavailableView("No meal plan found for this date.", image: "calendar.badge.exclamationmark", description: Text("Try selecting a different date."))
                    }
                }
            }
            .navigationTitle("Meal Plan History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedDate) {
                isLoading = true
                defer { isLoading = false }

                Task {
                    let startDate = Calendar.current.startOfDay(for: selectedDate)
                    let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!

                    let networkResponse = try? await ContentService.shared.fetchMealPlans(from: startDate, to: endDate)
                    if let mealPlan = networkResponse?.data?.first {
                        plan = mealPlan
                    } else {
                        plan = nil
                    }
                }
            }
        }
    }

    // MARK: Private

    @State private var isLoading = false

    @State private var isCalendarExpanded = false
    @Environment(\.dismiss) private var dismiss

}
