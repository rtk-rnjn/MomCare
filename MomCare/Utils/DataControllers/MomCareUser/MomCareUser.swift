//
//  MomCareUser.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation


class MomCareUser {
    public private(set) var diet: UserDiet = .shared
    public private(set) var exercise: UserExercise = .shared

    var user: User?

    static var shared: MomCareUser = .init()

    private init() {
        updateFromDatabase()
        
        // TODO: Remove this
        _ = getCurrentUser()
    }

    func setCurrentMood(as mood: MoodType) {
        user?.mood = mood
    }

    private func updateFromDatabase() {
        UserDiet.shared.updateFromDatabase()
        UserExercise.shared.updateFromDatabase()
    }

    func updateToDatabase() {
        UserDiet.shared.updateToDatabase()
        UserExercise.shared.updateToDatabase()
    }
}
