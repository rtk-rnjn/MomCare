enum DietaryPreference: String, Codable, CaseIterable, Sendable {
    case vegetarian = "veg"
    case nonVegetarian = "non-veg"
    case vegan
    case pescetarian = "Pescetarian"
    case flexitarian = "Flexitarian"
    case glutenFree = "Gluten-Free"
    case ketogenic = "Ketogenic"
    case highProtein = "High Protein"
    case dairyFree = "Dairy-Free"
    case none
}
