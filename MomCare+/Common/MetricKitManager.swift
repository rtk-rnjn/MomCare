//
//  MetricKitManager.swift
//  MomCare
//
//  Created by Aryan singh on 19/02/26.
//

import MetricKit

final class MetricKitManager: NSObject, MXMetricManagerSubscriber {

    // MARK: Lifecycle

    override private init() {
        super.init()
        MXMetricManager.shared.add(self)
    }

    // MARK: Internal

    static let shared: MetricKitManager = .init()

    /// Called daily
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            print("Received metrics:")
            print(payload)
        }
    }

    /// Called when crash/hang diagnostics available
    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            print("Received diagnostics:")
            print(payload)
        }
    }
}
