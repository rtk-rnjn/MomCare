import Foundation
import OSLog
import UIKit

private let logger: Logger = MomCareLogger.network

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

struct LongPollingResponse: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case status
        case taskIdentifier = "task_id"
        case detail
        case retryAfterSeconds = "retry_after_seconds"
    }

    let status: String
    let taskIdentifier: String
    let detail: String
    let retryAfterSeconds: Double
}

struct NetworkResponse<T: Codable & Sendable>: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case data
        case statusCode
    }

    let data: T
    let statusCode: Int
}

actor MCNetworkManager {
    // MARK: Internal

    nonisolated static let shared: MCNetworkManager = .init()

    nonisolated func get<T: Codable & Sendable>(
        url: String,
        queryParameters: [String: any Codable]? = nil,
        headers: [String: String]? = nil
    ) async throws -> NetworkResponse<T> {
        try await request(url: url, method: .GET, queryParameters: queryParameters, headers: headers)
    }

    nonisolated func post<T: Codable & Sendable>(url: String, queryParameters: [String: any Codable]? = nil, body: Data? = nil, headers: [String: String]? = nil) async throws -> NetworkResponse<T> {
        try await request(url: url, method: .POST, body: body, queryParameters: queryParameters, headers: headers)
    }

    nonisolated func put<T: Codable & Sendable>(url: String, queryParameters: [String: any Codable]? = nil, body: Data? = nil, headers: [String: String]? = nil) async throws -> NetworkResponse<T> {
        try await request(url: url, method: .PUT, body: body, queryParameters: queryParameters, headers: headers)
    }

    nonisolated func delete<T: Codable & Sendable>(url: String, queryParameters: [String: any Codable]? = nil, body: Data? = nil, headers: [String: String]? = nil) async throws -> NetworkResponse<T> {
        try await request(url: url, method: .DELETE, body: body, queryParameters: queryParameters, headers: headers)
    }

    nonisolated func patch<T: Codable & Sendable>(url: String, queryParameters: [String: any Codable]? = nil, body: Data? = nil, headers: [String: String]? = nil) async throws -> NetworkResponse<T> {
        try await request(url: url, method: .PATCH, body: body, queryParameters: queryParameters, headers: headers)
    }

    func fetchStreamedData<T: Codable & Sendable>(
        _ method: HTTPMethod,
        url: String,
        queryParameters: [String: any Codable]? = nil,
        headers: [String: String]? = nil
    ) -> AsyncThrowingStream<T, any Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let finalURL = buildURLString(url: url, queryParameters: queryParameters)

                    var request = URLRequest(url: finalURL)
                    request.httpMethod = method.rawValue
                    headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

                    logger.info("Starting streamed request to \(finalURL.absoluteString)")

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode <= 400 else {
                        throw URLError(.badServerResponse)
                    }

                    for try await line in bytes.lines {
                        guard let jsonData = line.data(using: .utf8) else {
                            continue
                        }

                        if let item: T = try jsonData.decodeUsingJSONDecoder() {
                            logger.debug("Stream item: \(String(describing: item))")

                            continuation.yield(item)
                        }
                    }

                    continuation.finish()

                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: Private

    @MainActor
    private var isNetworkHapticsEnabled: Bool {
        let key = FeatureFlagState.networkHaptics.rawValue
        let userDefaults = UserDefaults(suiteName: "group.MomCare")

        return userDefaults?.bool(forKey: key) ?? false
    }

    nonisolated private func buildURLString(
        url: String = "",
        queryParameters: [String: any Codable]? = nil
    ) -> URL {
        var urlString = url

        if let queryParameters, !queryParameters.isEmpty {
            var urlComponents = URLComponents(string: urlString)
            urlComponents?.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            urlString = urlComponents?.url?.absoluteString ?? urlString
        }

        guard let url = URL(string: urlString) else {
            fatalError(Quote.randomQuote.displayString)
        }

        return url
    }

    nonisolated private func request<T: Codable & Sendable>(
        url: String = "",
        method: HTTPMethod,
        body: Data? = nil,
        queryParameters: [String: any Codable]? = nil,
        headers: [String: String]? = nil
    ) async throws -> NetworkResponse<T> {
        let url = buildURLString(url: url, queryParameters: queryParameters)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let body {
            request.httpBody = body
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        return try await performRequest(request)
    }

    nonisolated private func retryHandler(_ error: any Error, _ url: String, _ attempts: Int) async throws {
        guard let urlError = error as? URLError else {
            await MainActor.run {
                if isNetworkHapticsEnabled {
                    HapticsHandler.notification(.error)
                }
            }
            throw error
        }

        switch urlError.code {
        case .badURL, .unknown:
            logger.warning("Non-retriable network error occurred for request to \(url): \(urlError.localizedDescription).")

        case .cancelled:
            logger.warning("Request to \(url) was cancelled.")

        case .networkConnectionLost, .notConnectedToInternet, .timedOut:
            logger.warning("Network error occurred for request to \(url): \(urlError.localizedDescription).")

            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * (attempts % 5)))

            await MainActor.run {
                if isNetworkHapticsEnabled {
                    HapticsHandler.notification(.warning)
                }
            }

        default:
            logger.warning("Unexpected network error occurred for request to \(url): \(urlError.localizedDescription). Not retrying.")
            await MainActor.run {
                if isNetworkHapticsEnabled {
                    HapticsHandler.notification(.error)
                }
            }
            throw error
        }
    }

    private func performRequest<T: Codable & Sendable>(_ request: URLRequest) async throws -> NetworkResponse<T> {
        let url = request.url?.absoluteString ?? "unknown URL"
        logger.info("Performing \(request.httpMethod ?? "UNKNOWN") request to \(url)")

        do {
            var attempts = 5

            while attempts > 0 {
                do {
                    let (data, response) = try await URLSession.shared.data(for: request)
                    return try await handleRequest(response: response, data: data, url: url)
                } catch {
                    attempts -= 1
                    try await retryHandler(error, url, attempts)
                }
            }
        } catch {
            logger.error("Failed to perform request to \(url): \(error.localizedDescription)")
            if error is URLError {
                await MainActor.run {
                    if isNetworkHapticsEnabled {
                        HapticsHandler.notification(.error)
                    }
                }
            } else {
                throw error
            }
        }

        throw APIErrorResolver.error(from: -1)
    }

    nonisolated private func handleRequest<T: Codable & Sendable>(response: URLResponse, data: Data, url: String) async throws -> NetworkResponse<T> {
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid response for request to \(url)")

            throw URLError(.badServerResponse)
        }

        logger.info("Received response with status code \(httpResponse.statusCode) for request to \(url)")

        if httpResponse.statusCode >= 400 {
            await MainActor.run { if isNetworkHapticsEnabled {
                HapticsHandler.notification(.error)
            } }

            if let errorResponse: HTTPErrorResponse = try? data.decodeUsingJSONDecoder() {
                let osLogMessage = errorResponse.detail.toOSLogMessageString()
                logger.error("HTTP Exception: \(osLogMessage)")
                throw APIErrorResolver.error(from: httpResponse.statusCode, with: errorResponse)
            }

            throw APIErrorResolver.error(from: httpResponse.statusCode, with: nil)
        }

        if let longPolling: LongPollingResponse = try? data.decodeUsingJSONDecoder() {
            logger.info("Received long polling response for request to \(url): status=\(longPolling.status), taskIdentifier=\(longPolling.taskIdentifier, privacy: .public), detail=\(longPolling.detail, privacy: .public), retryAfterSeconds=\(longPolling.retryAfterSeconds)")

            throw APIErrorResolver.longPollingResponse(longPolling)
        }

        let maybeData: T = try data.decodeUsingJSONDecoder()
        await MainActor.run { if isNetworkHapticsEnabled {
            HapticsHandler.notification(.success)
        } }
        return NetworkResponse(data: maybeData, statusCode: httpResponse.statusCode)
    }
}
