//
//  TriTrackModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation
import UIKit

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
