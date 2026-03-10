import MetricKit
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.MetricKitManager", category: "MetricKitManager")

final class MetricKitManager: NSObject, MXMetricManagerSubscriber {

    // MARK: Lifecycle

    override private init() {
        super.init()
        MXMetricManager.shared.add(self)
        logger.info("MetricKitManager initialized and subscribed to MetricKit updates.")
    }

    // MARK: Internal

    static let shared: MetricKitManager = .init()

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            Task {
                try? await self.pushDailyMetrics(payload)
            }
        }
    }

    func pushDailyMetrics(_ payload: MXMetricPayload) async throws {
        let data = payload.jsonRepresentation()
        let _: NetworkResponse<Bool> = try await NetworkManager.shared.post(url: Endpoint.dailyMetrics.urlString, body: data)
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            Task {
                try? await pushDiagnosticMetrics(payload)
            }
        }
    }

    func pushDiagnosticMetrics(_ payload: MXDiagnosticPayload) async throws {
        let data = payload.jsonRepresentation()
        let _: NetworkResponse<Bool> = try await NetworkManager.shared.post(url: Endpoint.diagnosticMetrics.urlString, body: data)
    }
}
