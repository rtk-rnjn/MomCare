//
//  MomCareUser.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation

class MomCareUser {

    @MainActor static var shared: MomCareUser = .init()

    var user: User? {
        didSet {
            updateToDatabase()
        }
    }

    func setCurrentMood(as mood: MoodType) {
        user?.mood = mood
    }

    func updateToDatabase() {
        DispatchQueue.global().async {
            Task {
                await self.updateUser(to: .database)
            }
        }
    }

    func updateFromDatabase() {
        DispatchQueue.global().async {
            Task {
                await self.fetchUser(from: .database)
            }
        }
    }

}
