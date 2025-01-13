//
//  File.swift
//  MomCare
//
//  Created by Ritik Ranjan on 10/01/25.
//

import Foundation
import UIKit

struct Image {
    var imageName: String
    var heading: String
    
    var image: UIImage? {
        UIImage(named: imageName)
    }
    
    init(imageName: String, heading: String) {
        self.imageName = imageName
        self.heading = heading
    }
}

class FrontPageData {
    static var images: [Image] = [
        .init(imageName: "FrontImage 1", heading: "Personalised plans curated just for you"),
        .init(imageName: "FrontImage 2", heading: "Receive insights for every trimester"),
        .init(imageName: "FrontImage 3", heading: "Track your progress effortlessly"),
        .init(imageName: "FrontImage 4", heading: "Never miss a moment with reminders"),
    ]
}
