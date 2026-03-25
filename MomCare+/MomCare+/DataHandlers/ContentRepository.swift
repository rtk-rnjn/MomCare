import Combine
import Foundation

@MainActor
class ContentRepository {
    static let shared: ContentRepository = .init()

    var authenticationHeaders: [String: String]? {
        AuthenticationService.authorizationHeaders
    }

    func cachedResponse<T: Codable>(from data: T) -> NetworkResponse<T> {
        NetworkResponse(data: data, statusCode: 200)
    }

    func generateDailyInsights() async throws -> NetworkResponse<DailyInsightModel> {
        try await NetworkManager.shared.get(url: Endpoint.generateTips.urlString, headers: authenticationHeaders)
    }

    func generateMealPlan() async throws -> NetworkResponse<MealPlanModel> {
        try await NetworkManager.shared.get(url: Endpoint.generatePlan.urlString, headers: authenticationHeaders)
    }

    func generateUserExercises() async throws -> NetworkResponse<[UserExerciseModel]> {
        try await NetworkManager.shared.get(url: Endpoint.generateExercises.urlString, headers: authenticationHeaders)
    }

    func getOrFetchExercise(id: String) async throws -> NetworkResponse<ExerciseModel> {
        if let data: ExerciseModel = Database.shared[.exerciseModel(id)] {
            return cachedResponse(from: data)
        }

        let networkResponse: NetworkResponse<ExerciseModel> = try await NetworkManager.shared.get(url: Endpoint.fetchExercise.urlString(with: id))

        Database.shared[.exerciseModel(id)] = networkResponse.data
        return networkResponse
    }

    func getOrFetchFoodItem(id: String) async throws -> NetworkResponse<FoodItemModel> {
        if let data: FoodItemModel = Database.shared[.foodModel(id)] {
            return cachedResponse(from: data)
        }

        let networkResponse: NetworkResponse<FoodItemModel> = try await NetworkManager.shared.get(url: Endpoint.fetchFood.urlString(with: id))

        Database.shared[.foodModel(id)] = networkResponse.data
        return networkResponse
    }

    func fetchSongStreamUri(id: String) async throws -> NetworkResponse<ServerMessage> {
        try await NetworkManager.shared.get(url: Endpoint.fetchSongUri.urlString(with: id))
    }

    func fetchExerciseStreamUri(id: String) async throws -> NetworkResponse<ServerMessage> {
        try await NetworkManager.shared.get(url: Endpoint.fetchExerciseUri.urlString(with: id))
    }

    func fetchSongs(for moodType: MoodType) async throws -> NetworkResponse<[SongModel]> {
        try await NetworkManager.shared.get(url: Endpoint.songs.urlString, queryParameters: ["mood": moodType])
    }

    func fetchFoodImage(id: String) async throws -> NetworkResponse<ServerMessage> {
        try await NetworkManager.shared.get(url: Endpoint.fetchFoodImageUri.urlString(with: id))
    }

    func fetchUserExercises(from startDate: Date, to endDate: Date) async throws -> NetworkResponse<[UserExerciseModel]> {
        let startDateTimestamp = startDate.timeIntervalSince1970
        let endDateTimestamp = endDate.timeIntervalSince1970

        let data: Data = try TimestampRange(startTimestamp: startDateTimestamp, endTimestamp: endDateTimestamp).encodeUsingJSONEncoder()

        let url = Endpoint.searchGeneratedExercises.urlString
        return try await NetworkManager.shared.post(url: url, body: data, headers: authenticationHeaders)
    }

    func fetchMealPlans(from startDate: Date, to endDate: Date) async throws -> NetworkResponse<[MealPlanModel]> {
        let startDateTimestamp = startDate.timeIntervalSince1970
        let endDateTimestamp = endDate.timeIntervalSince1970

        let data: Data = try TimestampRange(startTimestamp: startDateTimestamp, endTimestamp: endDateTimestamp).encodeUsingJSONEncoder()

        return try await NetworkManager.shared.post(url: Endpoint.searchGeneratedPlan.urlString, body: data, headers: authenticationHeaders)
    }
}
