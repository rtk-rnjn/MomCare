//
//  MongoManager.swift
//  MomCare
//
//  Created by RITIK RANJAN on 05/02/25.
//

import Foundation
import MongoKitten

class MongoManager {
    var cluster: MongoCluster?
    var database: MongoDatabase? {
        return cluster?["MomCare"]
    }

    init?(username: String, password: String, appName: String = "Cluster0") {
        let uri = "mongodb+srv://\(username):\(password)@cluster0.ogajw.mongodb.net/?retryWrites=true&w=majority&appName=\(appName)"
        Task {
            do {
                cluster = try await MongoCluster(
                    connectingTo: ConnectionSettings(uri),
                    allowFailure: false
                )
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

}
