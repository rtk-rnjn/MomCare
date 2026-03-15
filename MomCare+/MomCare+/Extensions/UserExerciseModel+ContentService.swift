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
            await completionPercentage >= 0.99
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
}
