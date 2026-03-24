import SwiftUI


struct MyPlanDietPlanHistory: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CompactCalendarView(selectedDate: $selectedDate, isExpanded: $controlState.showingExpandedCalendar)

                    if isLoading, plan == nil {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading meal plan…")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let plan {
                        List {
                            FoodReferenceSection(type: .breakfast, items: plan.breakfast)
                            FoodReferenceSection(type: .lunch, items: plan.lunch)
                            FoodReferenceSection(type: .snacks, items: plan.snacks)
                            FoodReferenceSection(type: .dinner, items: plan.dinner)
                        }
                        .listStyle(.insetGrouped)
                        .refreshable {
                            await loadPlan(for: selectedDate)
                        }
                    } else if let errorMessage {
                        ContentUnavailableView(
                            "Couldn’t load meal plan",
                            systemImage: "wifi.exclamationmark",
                            description: Text(errorMessage)
                        )
                        .overlay(alignment: .bottom) {
                            Button("Retry") {
                                Task { await loadPlan(for: selectedDate) }
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.bottom, 24)
                        }
                    } else {
                        ContentUnavailableView(
                            "No meal plan",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("Try selecting a different date.")
                        )
                    }
            }
            .navigationTitle("Meal Plan History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(reduceMotion ? nil : .easeInOut) {
                            controlState.showingExpandedCalendar.toggle()
                        }
                    } label: {
                        Image(systemName: "calendar")
                            .font(.body)
                            .foregroundColor(Color.CustomColors.mutedRaspberry)
                            .symbolEffect(.bounce, value: controlState.showingExpandedCalendar)
                    }
                    .accessibilityLabel(controlState.showingExpandedCalendar ? "Collapse calendar" : "Expand calendar")
                    .accessibilityIdentifier("expandCalendarButton")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedDate = Date()
                    } label: {
                        Image(systemName: "\(Calendar.current.component(.day, from: Date())).calendar")
                            .font(.body)
                            .foregroundColor(Color.CustomColors.mutedRaspberry)
                    }
                    .accessibilityLabel("Jump to today")
                    .accessibilityIdentifier("jumpToTodayButton")
                }
            }
            .task(id: selectedDate.startOfDay) {
                await loadPlan(for: selectedDate)
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var controlState: ControlState

    @State private var plan: MealPlanModel?
    @State private var selectedDate: Date = .init()

    @State private var isLoading = false
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    @MainActor
    private func loadPlan(for date: Date) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let startDate = date.startOfDay
        let endDate = date.nextDay

        do {
            let networkResponse = try await ContentRepository.shared.fetchMealPlans(from: startDate, to: endDate)
            plan = networkResponse.data.first
        } catch {
            plan = nil
            errorMessage = error.localizedDescription
        }
    }
}


private struct ProgressPill: View {
    let consumed: Int
    let total: Int
    let tint: Color

    var body: some View {
        let complete = total > 0 && consumed == total

        Text("\(consumed)/\(total)")
            .font(.caption.weight(.semibold))
            .foregroundStyle(complete ? tint : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.thinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(complete ? tint.opacity(0.35) : Color.secondary.opacity(0.25), lineWidth: 1)
            )
            .accessibilityLabel("Progress")
            .accessibilityValue("\(consumed) of \(total) consumed")
    }
}

private struct FoodReferenceRow: View {
    // MARK: Internal

    let ref: FoodReferenceModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: ref.isConsumed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(ref.isConsumed ? Color.green : Color.secondary)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                if let food {
                    Text(food.name)
                        .font(.body)
                        .foregroundStyle(ref.isConsumed ? .secondary : .primary)
                        .strikethrough(ref.isConsumed, color: .secondary)
                } else if isLoadingFood {
                    Text("Loading…")
                        .foregroundStyle(.secondary)
                        .redacted(reason: .placeholder)
                } else {
                    Text("Food")
                        .foregroundStyle(.secondary)
                        .redacted(reason: .placeholder)
                }

                if ref.count > 1 {
                    Text("Qty \(ref.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .task(id: ref.foodId) {
            // Avoid repeatedly hammering if the view refreshes.
            guard food == nil else {
                return
            }

            isLoadingFood = true
            defer { isLoadingFood = false }
            food = await ref.food
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(food?.name ?? "Food item")
        .accessibilityValue(ref.isConsumed ? "Consumed" : "Not consumed")
    }

    // MARK: Private

    @State private var food: FoodItemModel?
    @State private var isLoadingFood = false
}


private struct FoodReferenceSection: View {
    // MARK: Internal

    let type: MealType
    let items: [FoodReferenceModel]

    var body: some View {
        Section {
            DisclosureGroup(isExpanded: $isExpanded) {
                if items.isEmpty {
                    ContentUnavailableView(
                        "Nothing planned",
                        systemImage: "fork.knife",
                        description: Text("No items in \(type.rawValue.lowercased()).")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    ForEach(items) { item in
                        FoodReferenceRow(ref: item)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: type.iconName)
                        .foregroundStyle(type.accentColor)

                    Text(type.rawValue.capitalized)
                        .font(.headline)

                    Spacer()

                    ProgressPill(consumed: consumedCount, total: items.count, tint: type.accentColor)
                }
            }
        }
    }

    // MARK: Private

    @State private var isExpanded: Bool = true

    private var consumedCount: Int {
        items.filter(\.isConsumed).count
    }
}
