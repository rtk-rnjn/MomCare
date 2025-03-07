//
//  StaticData.swift
//  MomCare
//
//  Created by Ritik Ranjan on 10/01/25.
//

import Foundation

import UIKit

struct FrontPageImage {

    // MARK: Lifecycle

    init(imageName: String, heading: String) {
        self.imageName = imageName
        self.heading = heading
    }

    // MARK: Internal

    var imageName: String
    var heading: String

    var image: UIImage? {
        UIImage(named: imageName)
    }

}

enum FrontPageData {
    public static let images: [FrontPageImage] = [
        .init(imageName: "Image", heading: "Personalised plans curated just for you"),
        .init(imageName: "Image 1", heading: "Receive insights for every trimester"),
        .init(imageName: "Image 2", heading: "Track your progress effortlessly"),
        .init(imageName: "Image 3", heading: "Never miss a moment with reminders")
    ]

    public static func getImage(at indexPath: IndexPath) -> UIImage? {
        return images[indexPath.row].image
    }

    public static func getHeading(at indexPath: IndexPath) -> String {
        return images[indexPath.row].heading
    }
}

enum CountryData {
    public static let countryCodes: [String: String] = [
        "91": "India"
        // https://pastebin.com/raw/AE0Q8cJM
    ]
}
