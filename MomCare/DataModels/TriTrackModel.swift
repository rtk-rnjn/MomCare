//
//  TriTrackModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation
import UIKit
import EventKit

struct TriTrackEvent: Codable {
    var title: String
    var location: String?

    var allDay: Bool = false
    var startDate: Date
    var endDate: Date?

    var travelTime: TimeInterval?
    var alertBefore: TimeInterval?
    var repeatAfter: TimeInterval?
}

struct TriTrackReminder: Codable {
    var title: String
    var date: Date = .init()
    var notes: String?

    var repeatAfter: TimeInterval?
}

struct TriTrackSymptom: Codable {
    var title: String
    var notes: String?

    var atTime: Date
}

struct TrimesterData: Codable {
    let trimesterNumber: Int
    let weekNumber: Int
    let dayNumber: Int
    let quote: String

    let leftImageName: String
    let rightImageName: String
    let babyHeightInCentimeters: Double
    let babyWeightInKilograms: Double

    let babyTipText: String
    let momTipText: String

    var leftImage: UIImage? {
        UIImage(named: leftImageName)
    }

    var rightImage: UIImage? {
        UIImage(named: rightImageName)
    }

}
