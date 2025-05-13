//
//  MomCareAgents.swift
//  MomCare
//
//  Created by RITIK RANJAN on 05/03/25.
//

import Foundation

struct Tip: Codable, Sendable {
    var todaysFocus: String
    var dailyTip: String
    
    enum CodingKeys: String, CodingKey {
        case todaysFocus = "todays_focus"
        case dailyTip = "daily_tip"
    }
}
    

class MomCareAgents {
    
    public static var shared: MomCareAgents = .init()
    
    public private(set) var cachedPlan: MyPlan?
    public private(set) var cachedTips: Tip?

    func fetchPlan(from userMedical: UserMedical) async -> MyPlan {
        if let cachedPlan {
            return cachedPlan
        }

        let plan: MyPlan? = await NetworkManager.shared.get(url: "/plan")
        guard let plan else {
            return MyPlan()
        }
        
        self.cachedPlan = plan
        return plan
    }
    
    @discardableResult
    func fetchTips(from user: User) async -> Tip {
        if let cachedTips {
            return cachedTips
        }

        let tips: Tip? = await NetworkManager.shared.get(url: "/plan/tips")
        guard let tips else {
            return Tip(todaysFocus: "Unable to fetch Today's Focus from the server", dailyTip: "Unable to fetch Daily Tip from the server")
        }
        
        self.cachedTips = tips
        return tips
    }
}
