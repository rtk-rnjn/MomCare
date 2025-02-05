//
//  MongoHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 05/02/25.
//

import Foundation
import MongoSwift
import NIOPosix

class MongoHandler {
    let client: MongoClient
    let elg: MultiThreadedEventLoopGroup

    init?() {
        elg = MultiThreadedEventLoopGroup(numberOfThreads: ProcessInfo.processInfo.activeProcessorCount)

        do {
            client = try MongoClient("mongodb://localhost:27017", using: elg)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    deinit {
        try? client.syncClose()
        cleanupMongoSwift()

        try? elg.syncShutdownGracefully()
    }
}
