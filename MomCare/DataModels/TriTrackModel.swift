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

    var imageUri: String?
    var babyImageUri: String?

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

    var image: UIImage? {
        get async {
            return await UIImage().fetchImage(from: imageUri)
        }
    }

    var babyImage: UIImage? {
        guard let babyImageUri else {
            return nil
        }
        return UIImage(named: babyImageUri)
    }
}
