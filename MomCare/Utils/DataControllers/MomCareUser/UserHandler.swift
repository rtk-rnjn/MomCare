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

    let success: Bool
    let insertedId: String

}

struct UpdateResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case success
        case modifiedCount = "modified_count"
    }

    let success: Bool
    let modifiedCount: String

}

enum UserDefaultsKey: String {
    case signedUp
    case mongoUserID
    case savedUser
}

enum UserEndpoints {
    static let base = "/user"

    static func createUser() -> String { "\(base)/create" }
    static func fetchUser(mongoID: String) -> String { "\(base)/fetch/\(mongoID)" }
    static func updateUser(mongoID: String) -> String { "\(base)/update/\(mongoID)" }
}

enum SavepointScope {
    case locally
    case database
}

extension MomCareUser {
    private func updateUserToUserDefaults() {
        guard let userData = try? JSONEncoder().encode(user) else { return }
        Utils.save(key: UserDefaultsKey.savedUser.rawValue, value: userData)
    }

    private func fetchUserFromUserDefaults() -> User? {
        let savedData: Data? = Utils.get(key: UserDefaultsKey.savedUser.rawValue, defaultValue: nil)
        guard let savedData else { return nil }
        return try? JSONDecoder().decode(User.self, from: savedData)
    }

    func createNewUser(_ user: User) async -> Bool {
        guard let body = user.toData() else { return false }
        let response: CreateResponse? = await MiddlewareManager.shared.post(url: UserEndpoints.createUser(), body: body)

        if let insertedId = response?.insertedId {
            Utils.save(key: UserDefaultsKey.mongoUserID.rawValue, value: insertedId)
        }
        let success = response?.success ?? false
        if success {
            self.user = user
        }

        return success
    }

    func isUserSignedUp() -> Bool {
        let isSignedUp: Bool? = Utils.get(key: UserDefaultsKey.signedUp.rawValue, defaultValue: false)
        let mongoUserID: String? = Utils.get(key: UserDefaultsKey.mongoUserID.rawValue)
        return (isSignedUp ?? false) && mongoUserID?.isEmpty == false
    }

    private func fetchUserFromDatabase() async -> Bool {
        let mongoUserID: String? = Utils.get(key: UserDefaultsKey.mongoUserID.rawValue)
        guard let mongoUserID else { return false }

        user = await MiddlewareManager.shared.get(url: UserEndpoints.fetchUser(mongoID: mongoUserID))
        return user != nil
    }

    private func updateUserToDatabase() async -> Bool {
        let mongoUserID: String? = Utils.get(key: UserDefaultsKey.mongoUserID.rawValue)
        guard let userData = user?.toData(), let mongoUserID else {
            return false
        }

        let response: UpdateResponse? = await MiddlewareManager.shared.put(url: UserEndpoints.updateUser(mongoID: mongoUserID), body: userData)
        return response?.success ?? false
    }

    func updateUser(to scope: SavepointScope = .locally) async {
        switch scope {
        case .locally:
            updateUserToUserDefaults()
        case .database:
            if await updateUserToDatabase() {
                updateUserToUserDefaults()
            }
        }
    }

    func fetchUser(from scope: SavepointScope = .locally) async {
        switch scope {
        case .locally:
            user = fetchUserFromUserDefaults()
        case .database:
            if await fetchUserFromDatabase() {
                await updateUser(to: .locally)
            }
        }
    }
}
