import SwiftUI
import TipKit

struct MyPlanView: View {
    // MARK: Internal

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $controlState.myPlanSegment) {
                ForEach(MyPlanSegment.allCases) { segment in
                    Text(LocalizedStringKey(stringLiteral: segment.rawValue)).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .accessibilityLabel("Plan type")

            switch controlState.myPlanSegment {
            case .diet:
                MyPlanDietPlanView(currentTip: currentTip)
            case .exercise:
                MyPlanExercisePlanView()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .background(MomCareAccent.secondary.ignoresSafeArea())
        .navigationTitle(AppTab.myPlan.title)
        .navigationBarTitleDisplayMode(forceUseLargeTitle ? .large : .inline)
    }

    // MARK: Private

    @AppStorage(FeatureFlagState.forceUseLargeTitle.rawValue, store: Database.shared.userDefaults) private var forceUseLargeTitle: Bool = false

    @EnvironmentObject private var controlState: ControlState

    @available(iOS 18.0, *)
    private var dietPlanTips: TipGroup {
        TipGroup {
            MomCareTips.DietPlan.ProgressCardSlideOrTapTip()
            MomCareTips.DietPlan.HeaderRowAddTip()
            MomCareTips.DietPlan.ItemRowSlideTip()
        }
    }

    private var currentTip: (any Tip)? {
        if #available(iOS 18.0, *) {
            dietPlanTips.currentTip
        } else {
            nil
        }
    }
}
