import SwiftUI

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
                MyPlanDietPlanView()
            case .exercise:
                MyPlanExercisePlanView()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .background(MomCareAccent.secondary.ignoresSafeArea())
        .navigationTitle("My Plan")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState
}
