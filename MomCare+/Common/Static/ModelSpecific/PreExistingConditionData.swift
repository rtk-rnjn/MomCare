//
//  PreExistingConditionData.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

enum PreExistingCondition: String, Codable, CaseIterable, Sendable {
    case diabetes = "Diabetes"
    case hypertension = "Hypertension"
    case pcos = "PCOS"
    case anemia = "Anemia"
    case asthma = "Asthma"
    case heartDisease = "Heart Disease"
    case kidneyDisease = "Kidney Disease"
    case none
}
