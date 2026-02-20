//
//  DietaryPreferenceData.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

public enum DietaryPreference: String, Codable, CaseIterable, Sendable {
    case vegetarian = "Vegetarian"
    case nonVegetarian = "Non-Vegetarian"
    case vegan = "Vegan"
    case pescetarian = "Pescetarian"
    case flexitarian = "Flexitarian"
    case glutenFree = "Gluten-Free"
    case ketogenic = "Ketogenic"
    case highProtein = "High Protein"
    case dairyFree = "Dairy-Free"
    case none
}
