//
//  FoodIntoleranceData.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

public enum Intolerance: String, Codable, CaseIterable, Sendable, Hashable {
    case banana
    case beef
    case beans
    case blackEyedPeas = "black-eyed peas"
    case breadfruit
    case cashew
    case chicken
    case chickpeas
    case chili
    case clams
    case coconut
    case crab
    case dairy
    case duck
    case eggs
    case fish
    case fishRoe = "fish roe"
    case garlic
    case gluten
    case kokum
    case lactose
    case mackerel
    case mango
    case meat
    case mungBeans = "mung beans"
    case mushrooms
    case mussels
    case mutton
    case nuts
    case peanuts
    case pork
    case prawns
    case rawMango = "raw mango"
    case rice
    case riceFlour = "rice flour"
    case seafood
    case sesame
    case shark
    case shellfish
    case shrimp
    case silkworm
    case soy
    case soybean
    case spices
    case sugar
    case tamarind
    case tapioca
    case vinegar

    case none
}
