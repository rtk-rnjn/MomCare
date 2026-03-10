import SwiftUI
import WatchConnectivity

struct MomCareWatchView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section("Status") {
                Label(connector.session?.isReachable == true ? "Watch Reachable" : "Watch Not Reachable",
                      systemImage: connector.session?.isReachable == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(connector.session?.isReachable == true ? .green : .red)

                HStack {
                    Text("Activation State")
                    Spacer()
                    Text(stateText(connector.session?.activationState ?? .notActivated))
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

    private var connector: WatchConnector = .shared

    private func stateText(_ state: WCSessionActivationState) -> String {
        switch state {
        case .notActivated: return "Not Activated"
        case .inactive: return "Inactive"
        case .activated: return "Activated"
        @unknown default: return "Unknown"
        }
    }
}
