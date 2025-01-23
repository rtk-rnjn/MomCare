//
//  TriTrackModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation

struct TriTrackEvent {
    var title: String
    var location: String?

    var allDay: Bool = false
    var startDate: Date
    var endDate: Date?

    var travelTime: TimeInterval?
    var alertBefore: TimeInterval?
    var repeatAfter: TimeInterval?
}

struct TriTrackReminder {
    var title: String
    var date: Date = Date()
    var notes: String?

    var repeatAfter: TimeInterval?
}

struct TriTrackSymptom {
    var title: String
    var notes: String?

    var atTime: Date
}
