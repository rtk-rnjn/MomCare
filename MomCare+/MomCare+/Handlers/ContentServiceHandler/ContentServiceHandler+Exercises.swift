import Foundation

extension ContentServiceHandler {
    func fetchUserExercises() async throws {
        isFetchingExercises = true
        defer { isFetchingExercises = false }

        _ = try await fetchBreathingCompletionSeconds(for: .init())
        fetchTodaySteps()

        while true {
            do {
                async let fetchExercisesMeta: Void = fetchUserExercisesMeta()
                async let networkResponse: NetworkResponse<[UserExerciseModel]> = MCContentRepository.shared.generateUserExercises()

                userExercises = try await networkResponse.data
                await fetchExercisesMeta

                break
            } catch {
                if error is LongPolling {
                    continue
                }
                throw error
            }
        }
    }

    func fetchUserExercisesMeta() async {
        async let weeklyProgress: Void = fetchWeeklyProgress()
        async let totalCompleted: Int = userExercises.fetchTotalUserExercisesCompleted()
        async let totalDuration: TimeInterval = userExercises.fetchTotalExerciseDuration()

        await weeklyProgress
        totalUserExercisesCompleted = await totalCompleted
        totalExerciseDuration = await totalDuration
    }

    func fetchUserExercises(for date: Date) async throws -> [UserExerciseModel]? {
        if date > Date() {
            return nil
        }

        let startDate = Calendar.current.startOfDay(for: date)
        guard let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) else {
            fatalError(Quote.randomQuote.displayString)
        }

        let networkResponse = try await MCContentRepository.shared.fetchUserExercises(from: startDate, to: endDate)
        return networkResponse.data
    }

    func updateExerciseCompletionDuration(id: String, duration: TimeInterval) async throws {
        _ = try await MCContentRepository.shared.updateExerciseCompletion(userExerciseId: id, duration: duration)

        if let index = userExercises.firstIndex(where: { $0.id == id }) {
            await MainActor.run {
                self.userExercises[index].videoDurationCompletedSeconds = duration
            }
        }
    }
}
