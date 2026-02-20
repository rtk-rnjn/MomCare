
import Combine
import Foundation

class ContentService {

    // MARK: Internal

    static let shared: ContentService = .init()

    private(set) var dailyInsights: DailyInsightModel?
    private(set) var plan: MyPlanModel?
    private(set) var userExercises: [UserExerciseModel] = []

    func fetchDailyInsights() async throws -> NetworkResponse<DailyInsightModel> {
        if let cachedInsights: DailyInsightModel = await CacheHandler.shared.get(forKey: "dailyInsights") {
            dailyInsights = cachedInsights
            return NetworkResponse<DailyInsightModel>(data: cachedInsights, statusCode: 200, errorMessage: nil)
        }

        let response: NetworkResponse<DailyInsightModel> = try await NetworkManager.shared.get(url: Endpoint.generateTips.urlString, headers: AuthenticationService.authorizationHeaders)
        dailyInsights = response.data

        await CacheHandler.shared.set(response.data as DailyInsightModel?, forKey: "dailyInsights")
        return response
    }

    func fetchMealPlan() async throws -> NetworkResponse<MyPlanModel> {
        if let cachedPlan: MyPlanModel = await CacheHandler.shared.get(forKey: "mealPlan") {
            plan = cachedPlan
            return NetworkResponse<MyPlanModel>(data: cachedPlan, statusCode: 200, errorMessage: nil)
        }

        let response: NetworkResponse<MyPlanModel> = try await NetworkManager.shared.get(url: Endpoint.generatePlan.urlString, headers: AuthenticationService.authorizationHeaders)
        plan = response.data

        await CacheHandler.shared.set(response.data as MyPlanModel?, forKey: "mealPlan")
        return response
    }

    func fetchUserExercises() async throws -> NetworkResponse<[UserExerciseModel]> {
        if let userExercises: [UserExerciseModel] = await CacheHandler.shared.get(forKey: "userExercises") {
            self.userExercises = userExercises
            return NetworkResponse(data: userExercises, statusCode: 200, errorMessage: nil)
        }

        let response: NetworkResponse<[UserExerciseModel]> = try await NetworkManager.shared.get(url: Endpoint.generateExercises.urlString, headers: AuthenticationService.authorizationHeaders)
        userExercises = response.data ?? []
        await CacheHandler.shared.set(response.data as [UserExerciseModel]?, forKey: "userExercises")
        return response
    }

    func fetchExercise(id: String, useCache: Bool = true) async throws -> NetworkResponse<ExerciseModel> {
        if let exercise: ExerciseModel = database[.exercise(id)], useCache {
            return NetworkResponse(data: exercise, statusCode: 200, errorMessage: nil)
        }

        let url = Endpoint.fetchExercise.urlString(with: id)
        let response: NetworkResponse<ExerciseModel> = try await NetworkManager.shared.get(url: url)

        if let exercise = response.data {
            database[.exercise(id)] = exercise
        }
        return response
    }

    func fetchFoodItem(id: String) async throws -> NetworkResponse<FoodItemModel> {
        if let foodItem: FoodItemModel = database[.food(id)] {
            return NetworkResponse(data: foodItem, statusCode: 200, errorMessage: nil)
        }

        let url = Endpoint.fetchFood.urlString(with: id)
        let response: NetworkResponse<FoodItemModel> = try await NetworkManager.shared.get(url: url)
        if let foodItem = response.data {
            database[.food(id)] = foodItem
        }
        return response
    }

    func fetchSongStreamUri(id: String) async throws -> NetworkResponse<ServerMessage> {
        let url = Endpoint.fetchSongUri.urlString(with: id)
        return try await NetworkManager.shared.get(url: url)
    }

    func fetchExerciseStreamUri(id: String) async throws -> NetworkResponse<ServerMessage> {
        let url = Endpoint.fetchExerciseUri.urlString(with: id)
        return try await NetworkManager.shared.get(url: url)
    }

    func fetchSongs(for moodType: MoodType) async throws -> NetworkResponse<[SongModel]> {
        let url = Endpoint.songs.urlString
        return try await NetworkManager.shared.get(url: url, queryParameters: ["mood": moodType])
    }

    func fetchFoodImage(id: String) async throws -> NetworkResponse<ServerMessage> {
        let url = Endpoint.fetchFoodImageUri.urlString(with: id)
        return try await NetworkManager.shared.get(url: url)
    }

    // MARK: Private

    private let database: Database = .init()

}
