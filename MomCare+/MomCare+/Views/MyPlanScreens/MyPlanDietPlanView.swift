import SwiftUI

struct MealSection: Identifiable {
    let id: UUID = .init()
    let title: String
    var items: [FoodReferenceModel]

    var isCompleted: Bool {
        items.allSatisfy(\.isConsumed)
    }
}

struct MyPlanDietPlanView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 12) {
            ProgressCardView(
                caloriesConsumed: contentServiceHandler.nurtitionConsumedTotals?.calories ?? 0,
                caloriesTarget: contentServiceHandler.nutritionTargetTotals?.calories ?? 0
            )
            .containerShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    MealTimelineCardView()
                        .padding(.horizontal, 0)
                        .padding(.top, 8)
                        .padding(.bottom, 50)
                }
            }
            .frame(maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
            .padding(.horizontal, 16)
        }
        .padding(.top, 8)
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler

}
