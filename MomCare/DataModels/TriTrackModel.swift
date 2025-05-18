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
    var dayNumber: Int?
    var quote: String?

    var leftImageUri: String?
    var rightImageUri: String?

    var babyHeightInCentimeters: Double?
    var babyWeightInGrams: Double?

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
