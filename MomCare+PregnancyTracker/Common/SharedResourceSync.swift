//

//  SharedResourceSync.swift

//  MomCare

//

//  Created by Ritik Ranjan on 25/07/25.

//

import Foundation

enum SharedResourceSync {

    static func fetchFromUserDefaults() -> User? {

        if let data = UserDefaults(suiteName: "group.MomCare")?.value(forKey: "user") as? Data {

            return try? PropertyListDecoder().decode(User.self, from: data)

        }

        return nil

    }

    static func getPregnancyData() -> (week: Int, day: Int, trimester: String)? { // swiftlint:disable:this large_tuple

        let user = fetchFromUserDefaults()

        return user?.pregancyData

    }

    static func getWeek() -> Int {

        return getPregnancyData()?.week ?? 0

    }

    static func getDay() -> Int {

        return getPregnancyData()?.day ?? 0

    }

}
