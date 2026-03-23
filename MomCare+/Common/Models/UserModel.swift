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
    var height: Int?
    var prePregnancyWeight: Int?
    var currentWeight: Int?
    var dueDateTimestamp: TimeInterval?

    var foodIntolerances: [Intolerance] = []
    var dietaryPreferences: [DietaryPreference] = []

    var isProfileComplete: Bool {
        guard dateOfBirthTimestamp != nil && dueDateTimestamp != nil else {
            return false
        }

        return true
    }

    var pregnancyProgress: PregnancyProgress {
        Utils.progress(fromDueDate: Date(timeIntervalSince1970: dueDateTimestamp ?? 0))
    }

    var dueDate: Date? {
        if let dueDateTimestamp {
            return Date(timeIntervalSince1970: dueDateTimestamp)
        }
        return nil
    }

    var dateOfBirth: Date? {
        get {
            if let dateOfBirthTimestamp {
                return Date(timeIntervalSince1970: dateOfBirthTimestamp)
            }
            return nil
        }
        set {
            dateOfBirthTimestamp = newValue?.timeIntervalSince1970
        }
    }

    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""

        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }

    func pregnancyProgress(withReferenceDate referenceDate: Date = .init()) -> PregnancyProgress {
        Utils.progress(fromDueDate: Date(timeIntervalSince1970: dueDateTimestamp ?? 0), today: referenceDate)
    }
}
