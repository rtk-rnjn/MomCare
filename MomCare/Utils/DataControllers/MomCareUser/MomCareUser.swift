//
//  MomCareUser.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation

class MomCareUser {

    @MainActor static var shared: MomCareUser = .init()

    let queue: DispatchQueue = .init(label: "MomCareUserQueue")

    var user: User? {
        didSet {
            updateToDatabase()
        }
        willSet {
            user?.updatedAt = Date()
        }
    }

    func setCurrentMood(as mood: MoodType) {
        user?.mood = mood
    }

    // https://medium.com/@harshaag99/understanding-dispatchqueue-in-swift-c73058df6b37

    func updateToDatabase() {
        queue.async {
            Task {
                await self.updateUser(to: .database)
            }
        }
    }

    func updateFromDatabase() {
        queue.async {
            Task {
                await self.fetchUser(from: .database)
            }
        }
    }

}
