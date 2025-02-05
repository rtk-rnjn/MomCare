//
//  MomCareUser.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation

class MomCareUser {

    // MARK: Lifecycle

    private init() {
        updateFromDatabase()

        // TODO: Remove this
        _ = getCurrentUser()
    }

    // MARK: Public

    public private(set) var diet: UserDiet = .shared
    public private(set) var exercise: UserExercise = .shared

    // MARK: Internal

    static var shared: MomCareUser = .init()

    var user: User?

    func setCurrentMood(as mood: MoodType) {
        user?.mood = mood
    }

    func updateToDatabase() {
        UserDiet.shared.updateToDatabase()
        UserExercise.shared.updateToDatabase()
    }

    // MARK: Private

    private func updateFromDatabase() {
        UserDiet.shared.updateFromDatabase()
        UserExercise.shared.updateFromDatabase()
    }

}
