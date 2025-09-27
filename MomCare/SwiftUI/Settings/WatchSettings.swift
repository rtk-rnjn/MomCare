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
                Label(connector.session.isReachable ? "Watch Reachable" : "Watch Not Reachable",
                      systemImage: connector.session.isReachable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(connector.session.isReachable ? .green : .red)

                HStack {
                    Text("Activation State")
                    Spacer()
                    Text(stateText(connector.session.activationState))
                }
            }

            Section("Actions") {
                Button("Ping Watch") {
                    connector.ping()
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
