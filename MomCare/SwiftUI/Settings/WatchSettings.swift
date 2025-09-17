//
//  WatchSettings.swift
//  MomCare
//
//  Created by Aryan Singh on 17/09/25.
//

import SwiftUI
import WatchConnectivity

struct WatchSettingsView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section("Status") {
                Label(connector.isReachable ? "Watch Reachable" : "Watch Not Reachable",
                      systemImage: connector.isReachable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(connector.isReachable ? .green : .red)

                HStack {
                    Text("Activation State")
                    Spacer()
                    Text(stateText(connector.activationState))
                }
            }

            Section("Actions") {
                Button("Ping Watch") {
                    connector.pingWatch()
                }
            }
        }
        .navigationTitle("Watch Settings")
    }

    // MARK: Private

    @ObservedObject private var connector: WatchConnector = .shared

    private func stateText(_ state: WCSessionActivationState) -> String {
        switch state {
        case .notActivated: return "Not Activated"
        case .inactive: return "Inactive"
        case .activated: return "Activated"
        @unknown default: return "Unknown"
        }
    }
}
