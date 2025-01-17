//
//  Moods.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import Foundation
import UIKit

struct Mood {
    let image: UIImage
    let name: String
}

class AllMoods {
    static var moods: [Mood] = [
        Mood(image: UIImage(named: "Happy")!, name: "Happy"),
        Mood(image: UIImage(named: "Sad")!, name: "Sad"),
        Mood(image: UIImage(named: "Stressed")!, name: "Stressed"),
        Mood(image: UIImage(named: "Angry")!, name: "Angry")
    ]
}
