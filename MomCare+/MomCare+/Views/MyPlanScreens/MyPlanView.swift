import SwiftUI
import TipKit

struct MyPlanView: View {
    // MARK: Internal

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $controlState.myPlanSegment) {
                ForEach(MyPlanSegment.allCases) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .accessibilityLabel("Plan type")

            switch controlState.myPlanSegment {
            case .diet:
                MyPlanDietPlanView(tips: dietPlanTips)
            case .exercise:
                MyPlanExercisePlanView()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .background(MomCareAccent.secondary.ignoresSafeArea())
        .navigationTitle("My Plan")
        .navigationBarTitleDisplayMode(forceUseLargeTitle ? .large : .inline)
    }

    // MARK: Private

    @State private var dietPlanTips = TipGroup {
        MomCareTips.DietPlan.ProgressCardSlideOrTapTip()
        MomCareTips.DietPlan.HeaderRowAddTip()
        MomCareTips.DietPlan.ItemRowSlideTip()
    }

    @AppStorage(FeatureFlagState.forceUseLargeTitle.rawValue, store: Database.shared.userDefaults) private var forceUseLargeTitle: Bool = false

    @EnvironmentObject private var controlState: ControlState
}
