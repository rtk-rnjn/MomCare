import Foundation

extension UserExerciseModel {
    var exerciseModel: ExerciseModel? {
        get async {
            guard let networkResponse = try? await ContentRepository.shared.getOrFetchExercise(id: exerciseId) else {
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
            await completionPercentage >= 0.99
        }
    }

    var url: URL? {
        get async {
            let networkResponse = try? await ContentRepository.shared.fetchExerciseStreamUri(id: exerciseId)
            if let networkResponse {
                return URL(string: networkResponse.data.detail)
            }

            return nil
        }
    }
}

extension [UserExerciseModel] {
    var totalVideoDurationCompletedSeconds: TimeInterval {
        reduce(0) { $0 + $1.videoDurationCompletedSeconds }
    }

    func fetchTotalUserExercisesCompleted() async -> Int {
        await withTaskGroup(of: Bool.self) { group in
            for userExercise in self {
                group.addTask {
                    await userExercise.isCompleted
                }
            }

            var count = 0
            for await completed in group where completed {
                count += 1
            }

            return count
        }
    }

    func fetchTotalExerciseDuration() async -> TimeInterval {
        await withTaskGroup(of: TimeInterval.self) { group in
            for userExercise in self {
                group.addTask {
                    await userExercise.exerciseModel?.videoDurationSeconds ?? 0
                }
            }

            var total: TimeInterval = 0
            for await duration in group {
                total += duration
            }

            return total
        }
    }
}
