//
//  Intents.swift
//  Intents
//
//  Created by Aryan singh on 15/02/26.
//

import AppIntents

struct Intents: AppIntent {
    static var title: LocalizedStringResource {
        "Intents"
    }

    func perform() async throws -> some IntentResult {
        .result()
    }
}
