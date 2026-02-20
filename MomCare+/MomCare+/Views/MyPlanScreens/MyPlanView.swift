import SwiftUI

struct MyPlanView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedSegment) {
                ForEach(MyPlanSegment.allCases) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.white)
                UISegmentedControl.appearance().backgroundColor = UIColor(Color.CustomColors.mutedRaspberry)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.CustomColors.mutedRaspberry)], for: .selected)
            }

            if selectedSegment == .diet {
                MyPlanDietPlanView()
            } else {
                MyPlanExercisePlanView()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .background(MomCareAccent.secondary.ignoresSafeArea())
        .navigationTitle("My Plan")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let networkResponse = try? await ContentService.shared.fetchUserExercises(), let userExercises = networkResponse.data {
                healthKitHandler.userExercises = userExercises
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

    @State private var selectedSegment: MyPlanSegment = .diet

}
