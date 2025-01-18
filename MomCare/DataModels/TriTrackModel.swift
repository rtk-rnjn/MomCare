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
    var videoLink: String?
    
    var allDay: Bool = false
    var startDate: Date = Date()
    var endDate: Date?
    
    var travelTime: TimeInterval?
    var alertBefore: TimeInterval?
    var repeatAfter: TimeInterval?
}

struct TriTrackReminder {
    var title: String
    var notes: String?
    
    var duration: TimeInterval?
    
    var repeatAfter: TimeInterval?
}

struct TriTrackSymptoms {
    var title: String
    var notes: String?
    
    var atTime: Date?
}
