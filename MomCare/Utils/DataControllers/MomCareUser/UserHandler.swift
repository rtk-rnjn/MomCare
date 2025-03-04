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
        case detail
    }

    let success: Bool
    let modifiedCount: Int
    let detail: String?
}

enum UserDefaultsKey: String {
    case signedUp
    case mongoUserId
    case savedUser
}

enum UserEndpoints {
    static let base = "/user"

    static func createUser() -> String { "\(base)/create" }
    static func fetchUser(with mongoID: String) -> String { "\(base)/fetch/\(mongoID)" }
    static func fetchUserWithEmail(_ email: String) -> String { "\(base)/fetch" }
    static func updateUser(mongoID: String) -> String { "\(base)/update/\(mongoID)" }
}

enum SavepointScope {
    case iPhone
    case database
}

extension MomCareUser {
    private func updateUserToUserDefaults() {
        guard let userData = try? JSONEncoder().encode(user) else { return }
        Utils.save(forKey: .savedUser, withValue: userData)
    }

    private func fetchUserFromUserDefaults() -> User? {
        let savedData: Data? = Utils.get(fromKey: UserDefaultsKey.savedUser.rawValue, withDefaultValue: nil)
        guard let savedData else { return nil }
        return try? JSONDecoder().decode(User.self, from: savedData)
    }

    func createNewUser(_ user: User) async -> Bool {
        guard let body = user.toData() else { return false }
        let response: CreateResponse? = await MiddlewareManager.shared.post(url: UserEndpoints.createUser(), body: body)

        guard let response, response.success else { return false }

        Utils.save(forKey: .mongoUserId, withValue: response.insertedId)

        if response.success {
            await updateUser(to: .iPhone)
        }

        setUser(user)
        updateUserToUserDefaults()

        return response.success
    }

    func isUserSignedUp() -> Bool {
        let isSignedUp: Bool? = Utils.get(fromKey: UserDefaultsKey.signedUp.rawValue, withDefaultValue: false)
        let mongoUserID: String? = Utils.get(fromKey: UserDefaultsKey.mongoUserId.rawValue)
        return (isSignedUp ?? false) && mongoUserID?.isEmpty == nil
    }

    private func fetchUserFromDatabase() async -> Bool {
        let mongoUserID: String? = Utils.get(fromKey: UserDefaultsKey.mongoUserId.rawValue)
        guard let mongoUserID else { return false }

        let user: User? = await MiddlewareManager.shared.get(url: UserEndpoints.fetchUser(with: mongoUserID))
        if let user {
            setUser(user)
        }
        return user != nil
    }

    func fetchUserFromDatabase(with email: String, and password: String) async -> Bool {
        let user: User? = await MiddlewareManager.shared.get(url: UserEndpoints.fetchUserWithEmail(email), queryParameters: ["email": email, "password": password])

        if let user {
            setUser(user)
            await updateUser(to: .iPhone)

            Utils.save(forKey: .mongoUserId, withValue: user.id)
            return true
        }

        return false
    }

    private func updateUserToDatabase() async -> Bool {
        let mongoUserID: String? = Utils.get(fromKey: UserDefaultsKey.mongoUserId.rawValue)
        guard let userData = user?.toData(), let mongoUserID else {
            return false
        }

        guard user?.id == mongoUserID else {
            return false
        }

        let response: UpdateResponse? = await MiddlewareManager.shared.put(url: UserEndpoints.updateUser(mongoID: mongoUserID), body: userData)
        return response?.success ?? false
    }

    func updateUser(to scope: SavepointScope = .iPhone) async {
        switch scope {
        case .iPhone:
            updateUserToUserDefaults()
        case .database:
            if await updateUserToDatabase() {
                updateUserToUserDefaults()
            }
        }
    }

    func fetchUser(from scope: SavepointScope = .iPhone) async -> Bool {
        switch scope {
        case .iPhone:
            let user = fetchUserFromUserDefaults()
            if let user {
                setUser(user)
            }
            return user != nil

        case .database:
            let success = await fetchUserFromDatabase()
            if success {
                await updateUser(to: .iPhone)
            }
            return success
        }
    }
}
