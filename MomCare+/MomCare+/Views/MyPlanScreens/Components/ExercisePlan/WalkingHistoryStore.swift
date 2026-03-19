import SwiftUI
import Combine

struct StepDataPoint: Identifiable {
    let id: UUID = .init()
    let date: Date
    let steps: Int

    var shortLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE"
        return fmt.string(from: date)
    }

}

@MainActor
final class WalkingHistoryStore: ObservableObject {

    @Published var selectedDateSteps: Int = 0
    @Published var rangePoints: [StepDataPoint] = []
    @Published var isLoadingDay = false
    @Published var isLoadingRange = false

    var goal: Int = 4200 // synced from ContentServiceHandler.targetSteps

    // Stats derived from rangePoints
    var average: Int {
        guard !rangePoints.isEmpty else { return 0 }
        return rangePoints.reduce(0) { $0 + $1.steps } / rangePoints.count
    }

    var maximum: Int { rangePoints.map(\.steps).max() ?? 0 }

    var totalForRange: Int { rangePoints.reduce(0) { $0 + $1.steps } }

    var goalMetCount: Int {
        rangePoints.filter { $0.steps >= goal }.count
    }

    func loadDay(date: Date, handler: ContentServiceHandler) async {
        isLoadingDay = true
        defer { isLoadingDay = false }
        selectedDateSteps = await handler.fetchStepCount(for: date)
    }

    func loadRange(
        anchor: Date,
        handler: ContentServiceHandler
    ) async {
        isLoadingRange = true
        defer { isLoadingRange = false }

        let calendar = Calendar.current
        _ = calendar.startOfDay(for: Date())

        let days: [Date]

        let weekday = calendar.component(.weekday, from: anchor)
        let mondayOff = -(weekday == 1 ? 6 : weekday - 2)
        let monday = calendar.date(byAdding: .day, value: mondayOff, to: calendar.startOfDay(for: anchor))!
        days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }

        // Fetch each day concurrently
        let results: [StepDataPoint] = await withTaskGroup(of: StepDataPoint.self) { group in
            for day in days {
                group.addTask {
                    let steps = await handler.fetchStepCount(for: day)
                    return StepDataPoint(date: day, steps: steps)
                }
            }
            var pts = [StepDataPoint]()
            for await pt in group {
                pts.append(pt)
            }
            return pts.sorted { $0.date < $1.date }
        }

        rangePoints = results
    }
}
