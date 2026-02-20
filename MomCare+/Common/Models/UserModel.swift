import Combine
import Foundation

enum HealthProfileType: String {
    case preExistingCondition
    case intolerance
    case dietaryPreference
}

struct UserModel: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case _id
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case dateOfBirthTimestamp = "date_of_birth_timestamp"
        case height
        case prePregnancyWeight = "pre_pregnancy_weight"
        case currentWeight = "current_weight"
        case dueDateTimestamp = "due_date_timestamp"
        case foodIntolerances = "food_intolerances"
        case dietaryPreferences = "dietary_preferences"
    }

    var _id: String

    var firstName: String?
    var lastName: String?

    var phoneNumber: String?
    var dateOfBirthTimestamp: TimeInterval?
    var height: Double?
    var prePregnancyWeight: Double?
    var currentWeight: Double?
    var dueDateTimestamp: TimeInterval?

    var foodIntolerances: [Intolerance] = []
    var dietaryPreferences: [DietaryPreference] = []

    var isProfileComplete: Bool {
        guard let _ = dateOfBirthTimestamp, let _ = dueDateTimestamp else {
            return false
        }

        return true
    }

    var pregnancyProgress: DashboardPregnancyProgress {
        Utils.progress(fromDueDate: Date(timeIntervalSince1970: dueDateTimestamp ?? 0))
    }

    var dueDate: Date? {
        if let dueDateTimestamp {
            return Date(timeIntervalSince1970: dueDateTimestamp)
        }
        return nil
    }

    var dateOfBirth: Date? {
        if let dateOfBirthTimestamp {
            return Date(timeIntervalSince1970: dateOfBirthTimestamp)
        }
        return nil
    }

    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""

        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}
