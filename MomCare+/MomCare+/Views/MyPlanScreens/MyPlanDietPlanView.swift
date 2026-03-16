import SwiftUI
import TipKit

struct MealSection: Identifiable {
    let id: UUID = .init()
    let title: String
    var items: [FoodReferenceModel]

    var isCompleted: Bool {
        items.allSatisfy(\.isConsumed)
    }
}

struct SwipeMealsTip: Tip {
    var title: Text {
        Text("Swipe to Act on Meals")
    }

    var message: Text? {
        Text("Swipe right on a food item to mark it as consumed, or swipe left to delete it from your plan.")
    }

    var image: Image? {
        Image(systemName: "hand.draw")
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
                    TipView(swipeTip, arrowEdge: .top)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    MealTimelineCardView()
                        .padding(.horizontal, 0)
                        .padding(.top, 4)
                        .padding(.bottom, 50)
                }
                .refreshable {
                    HapticsHandler.impact(.medium)
                    try? await contentServiceHandler.fetchMealPlan()
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

    private let swipeTip = SwipeMealsTip()

}
