//
//  ContentView.swift
//  MomCare+ Watch Watch App
//
//  Created by Aryan Singh on 17/09/25.
//

import SwiftUI

struct ContentView: View {
    var watcher: WatchObserver = .shared

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "applewatch")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(.tint)

            if watcher.pongReceived {
                Text("⌚️ Running")
                    .foregroundColor(.green)
            } else {
                Text("⌚️ Waiting")
                    .foregroundColor(.secondary)
            }

            Button("Ping") {
                WatchConnector.shared.ping()
            }
        }
        .padding()
    }
}
