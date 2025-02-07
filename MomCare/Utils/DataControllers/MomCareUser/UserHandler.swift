//
//  UserHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation

struct CreateResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case success
        case insertedId = "inserted_id"
    }

    var success: Bool
    var insertedId: String

}

extension MomCareUser {
    func saveUserToUserDefaults(user: User) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: "savedUser")
        }
    }

    func retrieveUserFromUserDefaults() -> User? {
        if let savedUserData = UserDefaults.standard.data(forKey: "savedUser") {
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(User.self, from: savedUserData) {
                return user
            }
        }
        return nil
    }

    func createNewUser(_ user: User) async -> Bool {
        let response: CreateResponse? = await MiddlewareManager.shared.post(url: "/user/create", body: user.toData()!)
        let status = response?.success ?? false

        Utils.save(key: "mongoUserID", value: response?.insertedId ?? "nil")
        return status
    }
}
