import Combine
import Foundation

actor MCContentRepository {
    static let shared: MCContentRepository = .init()

    var authenticationHeaders: [String: String]? {
        MCAuthenticationService.authorizationHeaders
    }

    func cachedResponse<T: Codable>(from data: T) -> NetworkResponse<T> {
        NetworkResponse(data: data, statusCode: 200)
    }

    func generateDailyInsights() async throws -> NetworkResponse<DailyInsightModel> {
        try await MCNetworkManager.shared.get(url: Endpoint.generateTips.urlString, headers: authenticationHeaders)
    }

    func generateMealPlan() async throws -> NetworkResponse<MealPlanModel> {
        try await MCNetworkManager.shared.get(url: Endpoint.generatePlan.urlString, headers: authenticationHeaders)
    }

    func generateUserExercises() async throws -> NetworkResponse<[UserExerciseModel]> {
        try await MCNetworkManager.shared.get(url: Endpoint.generateExercises.urlString, headers: authenticationHeaders)
    }

    func getOrFetchExercise(id: String) async throws -> NetworkResponse<ExerciseModel> {
        if let data: ExerciseModel = await Database.shared[.exerciseModel(id)] {
            return cachedResponse(from: data)
        }

        let networkResponse: NetworkResponse<ExerciseModel> = try await MCNetworkManager.shared.get(url: Endpoint.fetchExercise.urlString(with: id))

        await MainActor.run {
            Database.shared[.exerciseModel(id)] = networkResponse.data
        }
        return networkResponse
    }

    func getOrFetchFoodItem(id: String) async throws -> NetworkResponse<FoodItemModel> {
        if let data: FoodItemModel = await Database.shared[.foodModel(id)] {
            return cachedResponse(from: data)
        }

        let networkResponse: NetworkResponse<FoodItemModel> = try await MCNetworkManager.shared.get(url: Endpoint.fetchFood.urlString(with: id))

        await MainActor.run {
            Database.shared[.foodModel(id)] = networkResponse.data
        }
        return networkResponse
    }

    func fetchSongStreamUri(id: String) async throws -> NetworkResponse<ServerMessage> {
        try await MCNetworkManager.shared.get(url: Endpoint.fetchSongUri.urlString(with: id))
    }

    func fetchExerciseStreamUri(id: String) async throws -> NetworkResponse<ServerMessage> {
        try await MCNetworkManager.shared.get(url: Endpoint.fetchExerciseUri.urlString(with: id))
    }

    func fetchSongs(for moodType: MoodType) async throws -> NetworkResponse<[SongModel]> {
        try await MCNetworkManager.shared.get(url: Endpoint.songs.urlString, queryParameters: ["mood": moodType])
    }

    func fetchFoodImage(id: String) async throws -> NetworkResponse<ServerMessage> {
        try await MCNetworkManager.shared.get(url: Endpoint.fetchFoodImageUri.urlString(with: id))
    }

    func fetchUserExercises(from startDate: Date, to endDate: Date) async throws -> NetworkResponse<[UserExerciseModel]> {
        let startDateTimestamp = startDate.timeIntervalSince1970
        let endDateTimestamp = endDate.timeIntervalSince1970

        let data: Data = try TimestampRange(startTimestamp: startDateTimestamp, endTimestamp: endDateTimestamp).encodeUsingJSONEncoder()

        let url = Endpoint.searchGeneratedExercises.urlString
        return try await MCNetworkManager.shared.post(url: url, body: data, headers: authenticationHeaders)
    }

    func fetchMealPlans(from startDate: Date, to endDate: Date) async throws -> NetworkResponse<[MealPlanModel]> {
        let startDateTimestamp = startDate.timeIntervalSince1970
        let endDateTimestamp = endDate.timeIntervalSince1970

        let data: Data = try TimestampRange(startTimestamp: startDateTimestamp, endTimestamp: endDateTimestamp).encodeUsingJSONEncoder()

        return try await MCNetworkManager.shared.post(url: Endpoint.searchGeneratedPlan.urlString, body: data, headers: authenticationHeaders)
    }
}
