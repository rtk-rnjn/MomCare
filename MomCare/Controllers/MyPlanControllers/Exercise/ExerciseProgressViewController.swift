//
//  PregnancyProgressController.swift
//  MomCare
//
//  Created by Aryan Singh on 23/07/25.
//

import SwiftUI

class ExerciseProgressViewController: UIHostingController<ExerciseProgressView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: ExerciseProgressView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.delegate = self
    }
    
    func readStepCount() async -> (current: Double, target: Double) {
        let count = await HealthKitHandler.shared.readStepCount()
        let goal = Utils.getStepGoal(week: MomCareUser.shared.user?.pregancyData?.week ?? 1)

        return (Double(count), Double(goal))
    }
    
    func segueToBreathingPlayer() {
        performSegue(withIdentifier: "segueShowBreathingPlayerViewController", sender: nil)
    }
}
