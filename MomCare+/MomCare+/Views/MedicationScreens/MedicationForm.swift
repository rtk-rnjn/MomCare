import Foundation

enum MedicationForm: String, CaseIterable, Identifiable {
    case capsule
    case tablet
    case liquid
    case topical
    case cream
    case device
    case drops
    case foam
    case gel
    case inhaler
    case injection
    case lotion
    case ointment
    case patch
    case powder
    case spray
    case suppository

    // MARK: Internal

    var id: String {
        rawValue
    }

    var displayName: String {
        rawValue.capitalized
    }

    var symbol: String {
        switch self {
        case .capsule: "capsule.fill"
        case .tablet: "circle.fill"
        case .liquid: "drop.fill"
        case .topical: "hand.raised.fill"
        case .cream: "humidity.fill"
        case .device: "medical.thermometer.fill"
        case .drops: "drop.halffull"
        case .foam: "bubbles.and.sparkles.fill"
        case .gel: "drop.degreesign.fill"
        case .inhaler: "lungs.fill"
        case .injection: "syringe.fill"
        case .lotion: "hands.and.sparkles.fill"
        case .ointment: "bandage.fill"
        case .patch: "square.fill"
        case .powder: "aqi.medium"
        case .spray: "aqi.low"
        case .suppository: "oval.fill"
        }
    }

    var badgeShape: MedicationBadgeShape {
        switch self {
        case .capsule, .drops, .foam, .tablet: .circle
        case .gel, .liquid, .lotion, .ointment: .diamond
        case .cream, .patch, .powder, .topical: .square
        case .device, .inhaler, .injection, .spray: .triangle
        case .suppository: .hexagon
        }
    }
}

enum MedicationBadgeShape {
    case circle
    case diamond
    case square
    case triangle
    case hexagon
}

enum MedicationStrengthUnit: String, CaseIterable, Identifiable {
    case mg
    case mcg
    case g
    case mL
    case percent

    // MARK: Internal

    var id: String {
        rawValue
    }

    var rawValue: String {
        if let dimension {
            dimension.symbol
        } else {
            "%"
        }
    }

    var dimension: Dimension? {
        switch self {
        case .mg:
            UnitMass.milligrams
        case .mcg:
            UnitMass.micrograms
        case .g:
            UnitMass.grams
        case .mL:
            UnitVolume.milliliters
        case .percent:
            nil
        }
    }
}

enum MedicationScheduleType: String, CaseIterable, Identifiable {
    case everyDay = "Every Day"
    case cyclicalSchedule = "Cyclical Schedule"
    case specificDaysOfWeek = "Specific Days of Week"
    case specificDays = "Specific Days"

    case asNeeded = "As Needed"

    // MARK: Internal

    var id: String {
        rawValue
    }

    var help: String {
        switch self {
        case .everyDay:
            "Take dose at the same time"
        case .cyclicalSchedule:
            "Take every day for 21 days and pause for 7 days"
        case .specificDaysOfWeek:
            "On Mondays, On Weekdays"
        case .specificDays:
            "Every other day, Every 3 days"
        case .asNeeded:
            "Take only when needed"
        }
    }
}

struct CyclicalSchedule {
    static let typical: CyclicalSchedule = .init(daysOn: 21, daysOff: 7)

    let daysOn: Int
    let daysOff: Int
}

struct DayInterval {
    static let everyOtherDay: DayInterval = .init(every: 2)
    static let everyThreeDays: DayInterval = .init(every: 3)

    let every: Int
}

struct MedicationInterval {
    let scheduleType: MedicationScheduleType
    let cyclicalSchedule: CyclicalSchedule?
    let daysOfWeek: Set<Int>?
    let dayInterval: DayInterval?
    let times: [DateComponents]?

    let startDate: Date?
    let endDate: Date?
}

extension MedicationInterval {
    static func everyDay(times: [DateComponents], startDate: Date? = nil, endDate: Date? = nil) -> Self {
        .init(scheduleType: .everyDay,
              cyclicalSchedule: nil,
              daysOfWeek: nil,
              dayInterval: nil,
              times: times,
              startDate: startDate,
              endDate: endDate
        )
    }

    static func cyclical(_ schedule: CyclicalSchedule, times: [DateComponents], startDate: Date? = nil, endDate: Date? = nil) -> Self {
        .init(scheduleType: .cyclicalSchedule,
              cyclicalSchedule: schedule,
              daysOfWeek: nil,
              dayInterval: nil,
              times: times,
              startDate: startDate,
              endDate: endDate
        )
    }

    static func specificDaysOfWeek(_ days: Set<Int>, times: [DateComponents], startDate: Date? = nil, endDate: Date? = nil) -> Self {
        .init(scheduleType: .specificDaysOfWeek,
              cyclicalSchedule: nil,
              daysOfWeek: days,
              dayInterval: nil,
              times: times,
              startDate: startDate,
              endDate: endDate
        )
    }

    static func specificDays(_ interval: DayInterval, times: [DateComponents], startDate: Date? = nil, endDate: Date? = nil) -> Self {
        .init(scheduleType: .specificDays,
              cyclicalSchedule: nil,
              daysOfWeek: nil,
              dayInterval: interval,
              times: times,
              startDate: startDate,
              endDate: endDate
        )
    }

    static let asNeeded: MedicationInterval = .init(
        scheduleType: .asNeeded,
        cyclicalSchedule: nil,
        daysOfWeek: nil,
        dayInterval: nil,
        times: nil,
        startDate: nil,
        endDate: nil
    )
}
