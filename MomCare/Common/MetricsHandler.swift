//
//  MetricsHandler.swift
//  MomCare
//
//  Created by Aryan Singh on 29/09/25.
//

import OSLog

#if canImport(MetricKit)
import MetricKit

private let logger: Logger = .init(subsystem: "com.MomCare.MetricsHandler", category: "MetricsHandler")

final class MetricsHandler: NSObject, MXMetricManagerSubscriber {

    // MARK: Lifecycle

    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }

    deinit {
        MXMetricManager.shared.remove(self)
    }

    // MARK: Internal

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            logger.debug("Metric payload received: \(payload)")

            if let cpu = payload.cpuMetrics {
                logger.debug("CPU Metrics: \(cpu)")
            }
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            logger.debug("Diagnostic payload received: \(payload)")

            if let crashes = payload.crashDiagnostics {
                for crash in crashes {
                    logger.debug("Crash Diagnostic: \(crash)")
                }
            }
        }
    }
}
#else
final class MetricsHandler: NSObject {
    override init() {
        super.init()
        Logger(subsystem: "com.MomCare.MetricsHandler", category: "MetricsHandler").warning("MetricKit not available on this platform.")
    }
}
#endif
