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

    // TODO: Backend currently supports a maximum of 3 dietary preferences. Add a backend ticket/issue ID here for future follow-up.
    // case pescetarian = "Pescetarian"
    // case flexitarian = "Flexitarian"
    // case glutenFree = "Gluten-Free"
    // case ketogenic = "Ketogenic"
    // case highProtein = "High Protein"
    // case dairyFree = "Dairy-Free"
    case none
}
