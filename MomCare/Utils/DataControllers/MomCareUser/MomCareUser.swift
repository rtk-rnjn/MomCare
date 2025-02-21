//
//  MomCareUser.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation

@MainActor
class MomCareUser {

    // MARK: Public

    public static var shared: MomCareUser = .init()

    // MARK: Internal

    let queue: DispatchQueue = .init(label: "MomCareUserQueue")

    var user: User? {
        didSet {
            if oldValue != user {
                updateToDatabase()
            }
        }
    }

    func setCurrentMood(as mood: MoodType) {
        user?.mood = mood
    }

    func updateFromDatabase() {
        queue.async {
            Task {
                await self.fetchUser(from: .database)
            }
        }
    }

    // MARK: Private

    // https://medium.com/@harshaag99/understanding-dispatchqueue-in-swift-c73058df6b37

    func updateToDatabase() {
        queue.async {
            Task {
                await self.updateUser(to: .database)
            }
        }
    }
}
