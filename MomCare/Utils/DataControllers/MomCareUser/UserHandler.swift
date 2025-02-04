//
//  UserHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation

extension MomCareUser {
    func createNewUser(_ user: User) -> Bool {
        if MomCareUser.userExists(user) {
            return false
        }

        self.user = user

        saveUser(user)
        return true
    }

    func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "user")
        }
    }

    func getCurrentUser() -> User? {
        guard let currentUser = user,
              let userData = UserDefaults.standard.data(forKey: "user"),
              let savedUser = try? JSONDecoder().decode(User.self, from: userData),
              currentUser.id == savedUser.id else {
            return nil
        }

        user = savedUser
        return savedUser
    }

    static func userExists(_ user: User) -> Bool {
        // TODO: Implement this method
        return false
    }

    func updateUser(with medicalData: UserMedical) {
        user?.medicalData = medicalData
    }
}
