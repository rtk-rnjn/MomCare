import MetricKit
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.AppDelegate", category: "AppDelegate")


extension AppDelegate: MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            writeMetricsToFile(payload)
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
            writeDiagnosticToFile(payload)
            Task {
                try? await pushDiagnosticMetrics(payload)
            }
        }
    }

    func pushDiagnosticMetrics(_ payload: MXDiagnosticPayload) async throws {
        let data = payload.jsonRepresentation()
        let _: NetworkResponse<Bool> = try await NetworkManager.shared.post(url: Endpoint.diagnosticMetrics.urlString, body: data)
    }

    func writeMetricsToFile(_ payload: MXMetricPayload) {
        let fileName = "metrics_\(Date().timeIntervalSince1970).json"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try payload.jsonRepresentation().write(to: fileURL)
            logger.info("Metrics written to file: \(fileURL.path)")
        } catch {
            logger.error("Failed to write metrics to file: \(error.localizedDescription)")
        }
    }

    func writeDiagnosticToFile(_ payload: MXDiagnosticPayload) {
        let fileName = "diagnostic_\(Date().timeIntervalSince1970).json"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try payload.jsonRepresentation().write(to: fileURL)
            logger.info("Metrics written to file: \(fileURL.path)")
        } catch {
            logger.error("Failed to write metrics to file: \(error.localizedDescription)")
        }
    }
}
