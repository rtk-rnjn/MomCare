import SwiftUI
import HealthKit
import Combine

enum VitalTimeRange: String, CaseIterable, Identifiable {
    case week = "7D"
    case month = "30D"
    case quarter = "3M"

    // MARK: Internal

    var id: String { rawValue }

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .quarter: return 91
        }
    }

    var bucketComponent: Calendar.Component {
        switch self {
        case .week: return .day
        case .month: return .day
        case .quarter: return .weekOfYear
        }
    }
}

enum VitalKind: String, CaseIterable, Identifiable {
    case calories = "Calories"
    case protein = "Protein"
    case carbs = "Carbs"
    case fats = "Fats"
    case sugar = "Sugar"
    case sodium = "Sodium"

    // MARK: Internal

    var id: String { rawValue }

    var hkIdentifier: HKQuantityTypeIdentifier {
        switch self {
        case .calories: return .dietaryEnergyConsumed
        case .protein: return .dietaryProtein
        case .carbs: return .dietaryCarbohydrates
        case .fats: return .dietaryFatTotal
        case .sugar: return .dietarySugar
        case .sodium: return .dietarySodium
        }
    }

    nonisolated var unit: HKUnit {
        switch self {
        case .calories: return .kilocalorie()
        case .sodium: return .gramUnit(with: .milli)
        default: return .gram()
        }
    }

    var unitLabel: String {
        switch self {
        case .calories: return UnitEnergy.kilocalories.symbol
        case .sodium: return UnitMass.milligrams.symbol
        default: return UnitMass.grams.symbol
        }
    }

    var color: Color {
        switch self {
        case .calories: return Color(hex: "E3B34B")
        case .protein: return Color(hex: "A7C0CD")
        case .carbs: return Color(hex: "6E8B6F")
        case .fats: return Color(hex: "F4A460")
        case .sugar: return Color(hex: "E07B8A")
        case .sodium: return Color(hex: "9B8EC4")
        }
    }

    var sfSymbol: String {
        switch self {
        case .calories: return "flame.fill"
        case .protein: return "bolt.fill"
        case .carbs: return "leaf.fill"
        case .fats: return "drop.fill"
        case .sugar: return "cube.fill"
        case .sodium: return "saltshaker.fill"
        }
    }

    var description: String {
        switch self {
        case .calories:
            return "Total dietary energy consumed. Balancing intake with your target helps manage weight and energy levels throughout the day."
        case .protein:
            return "Essential for muscle repair and growth. Aim for your daily target to support recovery, especially after exercise."
        case .carbs:
            return "Your body's primary fuel source. Complex carbs provide steady energy; refined ones cause rapid spikes."
        case .fats:
            return "Healthy fats support brain function and hormone production. Focus on unsaturated sources like nuts and avocado."
        case .sugar:
            return "Tracks total dietary sugars. High intake is linked to energy crashes and metabolic strain — aim to stay under your target."
        case .sodium:
            return "Important for fluid balance and nerve function. Excess sodium can raise blood pressure over time."
        }
    }

    var insight: String {
        switch self {
        case .calories: return "Consistent daily intake close to your target helps maintain stable energy."
        case .protein: return "Higher protein days often align with workout days — keep that pattern."
        case .carbs: return "Look for spikes on weekends — common with social eating."
        case .fats: return "A gradual downward trend suggests improving food quality choices."
        case .sugar: return "Reducing sugar in drinks has the biggest single-day impact."
        case .sodium: return "Most excess sodium comes from processed foods, not added salt."
        }
    }
}

struct DailyDataPoint: Identifiable {
    let id: UUID = .init()
    let date: Date
    let label: String
    let value: Double
}

@MainActor
final class VitalHistoryStore: ObservableObject {

    // MARK: Internal

    @Published var points: [DailyDataPoint] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    nonisolated static func formatLabel(date: Date, component: Calendar.Component) -> String {
        switch component {
        case .weekOfYear:
            return weekFormatter.string(from: date)
        default:
            return dayFormatter.string(from: date)
        }
    }

    func load(
        kind: VitalKind,
        startDate: Date,
        endDate: Date,
        bucketComponent: Calendar.Component = .day
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let quantityType = HKQuantityType.quantityType(forIdentifier: kind.hkIdentifier) else {
            errorMessage = "HealthKit type unavailable."
            return
        }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))
        guard let end else {
            errorMessage = "Failed to calculate end date from \(endDate)."
            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        let anchorComponents: DateComponents
        switch bucketComponent {
        case .weekOfYear:

            anchorComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: start)
        default:
            anchorComponents = DateComponents(hour: 0, minute: 0, second: 0)
        }

        let anchorDate = calendar.nextDate(
            after: Date.distantPast,
            matching: anchorComponents,
            matchingPolicy: .nextTime
        ) ?? start

        var intervalComponents = DateComponents()
        switch bucketComponent {
        case .weekOfYear: intervalComponents.weekOfYear = 1
        default: intervalComponents.day = 1
        }

        let result: (points: [DailyDataPoint], error: String?) = await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: anchorDate,
                intervalComponents: intervalComponents
            )

            query.initialResultsHandler = { _, collection, error in
                guard error == nil, let collection else {
                    continuation.resume(returning: ([], error?.localizedDescription ?? "Unknown error"))
                    return
                }

                var pts = [DailyDataPoint]()

                unsafe collection.enumerateStatistics(from: start, to: end) { stats, _ in
                    let value = stats.sumQuantity()?.doubleValue(for: kind.unit) ?? 0
                    let label = VitalHistoryStore.formatLabel(date: stats.startDate, component: bucketComponent)
                    pts.append(.init(date: stats.startDate, label: label, value: value))

                }

                continuation.resume(returning: (pts, nil))
            }

            self.healthStore.execute(query)
        }

        errorMessage = result.error
        points = result.points
    }

    func load(kind: VitalKind, range: VitalTimeRange) async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let start = calendar.date(byAdding: .day, value: -(range.days - 1), to: today) else {
            errorMessage = "Failed to calculate start date for \(range.days) day range."
            return
        }
        let end = today

        await load(kind: kind, startDate: start, endDate: end, bucketComponent: range.bucketComponent)
    }

    // MARK: Private

    private nonisolated static let weekFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return fmt
    }()

    private nonisolated static let dayFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "M/d"
        return fmt
    }()

    private let healthStore: HKHealthStore = .init()

}
