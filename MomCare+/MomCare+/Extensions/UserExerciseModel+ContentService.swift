import Foundation

extension UserExerciseModel {
    var exerciseModel: ExerciseModel? {
        get async {
            guard let networkResponse = try? await ContentService.shared.fetchExercise(id: exerciseId) else {
                return nil
            }
            return networkResponse.data
        }
    }

    var completionPercentage: Double {
        get async {
            guard let exerciseModel = await exerciseModel else { return 0 }
            guard exerciseModel.videoDurationSeconds > 0 else { return 0 }
            return min(videoDurationCompletedSeconds / exerciseModel.videoDurationSeconds, 1.0)
        }
    }

    var isCompleted: Bool {
        get async {
            await completionPercentage >= 1.0
        }
    }

    var url: URL? {
        get async {
            let networkResponse = try? await ContentService.shared.fetchExerciseStreamUri(id: exerciseId)
            if let networkResponse, let urlString = networkResponse.data?.detail {
                return URL(string: urlString)
            }

            return nil
        }
    }

    static func totalCompletion(from userExercises: [UserExerciseModel]) async -> Int {
        await withTaskGroup(of: Bool.self) { group in
            for exercise in userExercises {
                group.addTask {
                    await exercise.isCompleted
                }
            }

            var count = 0

            for await result in group where result {
                count += 1
            }

            return count
        }
    }

    static func totalDurationCompletion(from userExercises: [UserExerciseModel]) async -> TimeInterval {
        await withTaskGroup(of: TimeInterval.self) { group in
            for exercise in userExercises {
                group.addTask {
                    let percentage = await exercise.completionPercentage
                    guard let exerciseModel = await exercise.exerciseModel else { return 0 }
                    return percentage * exerciseModel.videoDurationSeconds
                }
            }

            var totalDuration: TimeInterval = 0

            for await duration in group {
                totalDuration += duration
            }

            return totalDuration
        }
    }

    static func totalDurationCompletionPercent(from userExercises: [UserExerciseModel]) async -> Double {
        let totalDuration = await totalDurationCompletion(from: userExercises)
        let totalPossibleDuration = await withTaskGroup(of: TimeInterval.self) { group in
            for exercise in userExercises {
                group.addTask {
                    guard let exerciseModel = await exercise.exerciseModel else { return 0 }
                    return exerciseModel.videoDurationSeconds
                }
            }

            var total: TimeInterval = 0

            for await duration in group {
                total += duration
            }

            return total
        }

        guard totalPossibleDuration > 0 else { return 0 }
        return min(totalDuration / totalPossibleDuration, 1.0)
    }

}
