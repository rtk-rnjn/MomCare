import Foundation
import HealthKit

extension ContentServiceHandler {
    func updateBreathingCompletionDuration(duration: TimeInterval) {
        let startOfDate = Calendar.current.startOfDay(for: Date())
        Database.shared[.breathingProgress(startOfDate)] = duration
    }

    func fetchBreathingCompletionDuration(for date: Date) -> TimeInterval {
        if date > Date() {
            return 0
        }

        let startOfDate = Calendar.current.startOfDay(for: date)
        let completionDuration: TimeInterval = Database.shared[.breathingProgress(startOfDate)] ?? 0
        return completionDuration
    }

    func fetchStepCount(for date: Date) async -> Int {
        if date > Date() {
            return 0
        }

        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!

        return await withCheckedContinuation { continuation in
            fetchHealthData(quantityTypeIdentifier: .stepCount, unit: .count(), startDate: startDate, endDate: endDate) { count in
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

    func fetchWeeklyExerciseProgress() async {
        let range = Utils.weekRange(containing: Date())
        var temp = [DayProgress]()

        for date in range {
            let exerciseProgressPercentage = await calculateTotalCompletionPercentage(for: date)
            let breathingProgressPercentage = fetchBreathingCompletionDuration(for: date) / breathingTargetInSeconds
            let stepsProgressPercentage = Double(await fetchStepCount(for: date)) / stepsGoal

            let progress = (exerciseProgressPercentage + breathingProgressPercentage + stepsProgressPercentage) / 3
            temp.append(.init(date: date, completionPercentage: progress))
        }

        weeklyProgress = temp
    }
}
