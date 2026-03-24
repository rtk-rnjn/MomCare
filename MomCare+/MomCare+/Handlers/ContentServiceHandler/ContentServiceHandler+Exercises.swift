import Foundation

extension ContentServiceHandler {
    func fetchUserExercises() async throws {
        isFetchingExercises = true
        defer { isFetchingExercises = false }

        let networkResponse = try await ContentRepository.shared.generateUserExercises()
        userExercises = networkResponse.data

        await fetchUserExercisesMeta()
    }

    func fetchUserExercisesMeta() async {
        await fetchWeeklyExerciseProgress()
        totalUserExercisesCompleted = await userExercises.fetchTotalUserExercisesCompleted()
        totalExerciseDuration = await userExercises.fetchTotalExerciseDuration()
    }

    func fetchUserExercises(for date: Date) async throws -> [UserExerciseModel]? {
        if date > Date() {
            return nil
        }

        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!

        let networkResponse = try await ContentRepository.shared.fetchUserExercises(from: startDate, to: endDate)
        return networkResponse.data
    }

    func updateExerciseCompletionDuration(id: String, duration: TimeInterval) async throws {
        _ = try await ContentRepository.shared.updateExerciseCompletion(userExerciseId: id, duration: duration)

        if let index = userExercises.firstIndex(where: { $0.id == id }) {
            await MainActor.run {
                self.userExercises[index].videoDurationCompletedSeconds = duration
            }
        }
    }
}
