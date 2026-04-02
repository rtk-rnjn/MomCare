import Foundation
import HealthKit

extension ContentServiceHandler {
    func fetchStepCount(for date: Date) async -> Int {
        if date > Date() {
            return 0
        }

        let startDate = Calendar.current.startOfDay(for: date)
        guard let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) else {
            fatalError(Quote.randomQuote.displayString)
        }

        return await withCheckedContinuation { continuation in
            fetchHealthData(quantityTypeIdentifier: .stepCount, unit: .count(), startDate: startDate, endDate: endDate) { count in
                if Calendar.current.isDate(date, inSameDayAs: .init()) {
                    DispatchQueue.main.async {
                        self.stepsToday = count
                    }
                }
                continuation.resume(returning: Int(count))
            }
        }
    }

    func fetchWeeklyStepsProgress(from date: Date = .init()) async -> [StepDataPoint] {
        let range = Utils.weekRange(containing: date)
        var result = [StepDataPoint]()

        for date in range {
            result.append(.init(date: date, steps: await fetchStepCount(for: date)))
        }

        return result
    }

    func calculateTotalCompletionPercentage(for date: Date) async -> Double {
        let exercises = try? await fetchUserExercises(for: date)
        guard let exercises else {
            return 0
        }

        var totalDuration: Double = 0
        var totalCompletedDuration: Double = 0

        for exercise in exercises {
            if let exerciseModel = await exercise.exerciseModel {
                totalDuration += exerciseModel.videoDurationSeconds
                totalCompletedDuration += exercise.videoDurationCompletedSeconds
            }
        }

        guard totalDuration > 0 else {
            return 0
        }

        return min(totalCompletedDuration / totalDuration, 1.0)
    }

    func fetchWeeklyProgress() async {
        let dates = Utils.weekRange(containing: Date())

        await withTaskGroup(of: (Int, Double).self) { group in
            for (index, date) in dates.enumerated() {
                group.addTask {
                    let exercise = await self.calculateTotalCompletionPercentage(for: date)

                    let breathingCompletionDuration: TimeInterval? = try? await self.fetchBreathingCompletionSeconds(for: date)
                    let breathing = await (breathingCompletionDuration ?? 0.0) / self.breathingGoalInSeconds

                    let steps = await Double(await self.fetchStepCount(for: date)) / self.stepsGoal
                    let total = (exercise + breathing + steps) / 3

                    return (index, min(total, 1))
                }
            }

            for await (index, progress) in group {
                weeklyProgress[index].completionPercentage = progress
                weeklyProgress[index].inProgress = false
            }
        }
    }
}
