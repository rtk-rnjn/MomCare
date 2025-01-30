//
//  UserModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation

enum Country: String {
    case india
}

enum PreExistingCondition {
    case diabetes
    case hypertension
    case pcos
    case anemia
    case asthma
    case heartDisease
    case kidneyDisease
}

enum Intolerance: String, Codable {
    case gluten
    case lactose
    case egg
    case seafood
    case soy
    case dairy
    case wheat
}

enum DietaryPreference {
    case vegetarian
    case nonVegetarian
    case vegan
    case pescetarian
    case flexitarian
    case glutenFree
    case ketogenic
    case highProtein
    case dairyFree
}

public enum MoodType: String {
   case happy = "Happy"
   case sad = "Sad"
   case stressed = "Stressed"
   case angry = "Angry"
}

struct User {
    var id: UUID = .init()

    var firstName: String
    var lastName: String?

    var fullName: String {
        let fullName = "\(firstName) \(lastName ?? "")"
        return fullName.trimmingCharacters(in: .whitespaces)
    }

    var emailAddress: String
    var password: String

    var countryCode: String = "+91"
    var phoneNumber: String

    var userMedical: UserMedical?

    var mood: MoodType?
}

struct UserMedical {
    var dateOfBirth: Date
    var height: Double
    var prePregnancyWeight: Double
    var currentWeight: Double

    var country: Country = .india

    var dueDate: Date?
    var preExistingConditions: [PreExistingCondition] = []
    var foodIntolerances: [Intolerance] = []

    var dietaryPreferences: [DietaryPreference] = []
}

enum PickerOptions {
    case height
    case prePregnancyWeight
    case currentWeight
    case country
}

class MomCareUser {
    public private(set) var diet: UserDiet = .shared
    public private(set) var exercise: UserExercise = .shared
    public private(set) var user: User?

    public private(set) var reminders: [TriTrackReminder] = []
    public private(set) var events: [TriTrackEvent] = []

    public private(set) var symptoms: [TriTrackSymptom] = []

    static var shared: MomCareUser = .init()

    private init() {
        updateFromDatabase()
    }

    func setCurrentMood(as mood: MoodType) {
    }

    private func updateFromDatabase() {
        UserDiet.shared.updateFromDatabase()
        UserExercise.shared.updateFromDatabase()
    }

    func updateToDatabase() {
        UserDiet.shared.updateToDatabase()
        UserExercise.shared.updateToDatabase()
    }

    func addReminder(_ reminder: TriTrackReminder) {
        reminders.append(reminder)
    }

    func addEvent(_ event: TriTrackEvent) {
        events.append(event)
    }

    func addSymptom(_ symptom: TriTrackSymptom) {
        symptoms.append(symptom)
    }
}

var countryList: [String] = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Anguilla", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia &amp; Herzegovina", "Botswana", "Brazil", "British Virgin Islands", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Cape Verde", "Cayman Islands", "Chad", "Chile", "China", "Colombia", "Congo", "Cook Islands", "Costa Rica", "Cote D Ivoire", "Croatia", "Cruise Ship", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Estonia", "Ethiopia", "Falkland Islands", "Faroe Islands", "Fiji", "Finland", "France", "French Polynesia", "French West Indies", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea Bissau", "Guyana", "Haiti", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya", "Kuwait", "Kyrgyz Republic", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Mauritania", "Mauritius", "Mexico", "Moldova", "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Namibia", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Norway", "Oman", "Pakistan", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russia", "Rwanda", "Saint Pierre &amp; Miquelon", "Samoa", "San Marino", "Satellite", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "South Africa", "South Korea", "Spain", "Sri Lanka", "St Kitts &amp; Nevis", "St Lucia", "St Vincent", "St. Lucia", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor L'Este", "Togo", "Tonga", "Trinidad &amp; Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks &amp; Caicos", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "Uruguay", "Uzbekistan", "Venezuela", "Vietnam", "Virgin Islands (US)", "Yemen", "Zambia", "Zimbabwe"]
