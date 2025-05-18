//
//  TriTrackModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation
import UIKit

struct TrimesterData: Codable {
    var weekNumber: Int
    var dayNumber: Int? = nil
    var quote: String? = nil

    var leftImageUri: String? = nil
    var rightImageUri: String? = nil

    var babyHeightInCentimeters: Double? = nil
    var babyWeightInKilograms: Double? = nil

    var babyTipText: String
    var momTipText: String

    var trimesterNumber: Int {
        switch weekNumber {
        case 1...13:
            return 1
        case 14...27:
            return 2
        case 28...40:
            return 3
        default:
            return 0
        }
    }

    var leftImage: UIImage? {
        get async {
            return await UIImage().fetchImage(from: leftImageUri)
        }
    }

    var rightImage: UIImage? {
        get async {
            return await UIImage().fetchImage(from: rightImageUri)
        }
    }

}
