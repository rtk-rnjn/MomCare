//
//  TrimesterData.swift
//  MomCare
//
//  Created by Ritik Ranjan on 15/01/25.
//

import Foundation
import UIKit

struct TrimesterData {
    let trimesterNumber: Int
    let weekNumber: Int
    let dayNumber: Int
    
    let quote: String
    
    let leftImageName: String
    var leftImage: UIImage? {
        UIImage(named: leftImageName)
    }
    
    let rightImageName: String
    var rightImage: UIImage? {
        UIImage(named: rightImageName)
    }
    
    let babyHeightInCentimeters: Double
    let babyWeightInKilograms: Double
    
    let babyTipText: String
    let momTipText: String
}
