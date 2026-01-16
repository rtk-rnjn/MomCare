//
//  OpenAllAppointments.swift
//  Intents
//
//  Created by Aryan Singh on 19/09/25.
//

import AppIntents

struct OpenAllAppointments: AppIntent {
    @available(iOS 16, *)
    static var title: LocalizedStringResource { "Show Upcoming Appointment" }

    @available(iOS 16.0, *)
    @MainActor
    func perform() async throws -> some IntentResult {
        let appointment = EventKitHandler.shared.fetchUpcomingAppointment()
        if let appointment {
            return .result(value: "\(appointment.title)")
        } else {
            return .result(value: "No upcoming appointments found.")
        }

    }
}
