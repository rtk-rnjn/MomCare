//
//  NetworkManager.swift
//  MomCare
//
//  Created by RITIK RANJAN on 06/02/25.
//

import Foundation
import OSLog

/// Logger instance dedicated to network operations.
private let logger: Logger = .init(
    subsystem: "com.MomCare.NetworkManager",
    category: "NetworkManager"
)

/// Supported HTTP methods for API requests.
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

/// Centralized, async-safe network layer for performing RESTful requests.
///
/// `NetworkManager` provides a typed, codable-based API for performing
/// HTTP requests. It automatically:
/// - Builds query strings
/// - Injects authentication tokens from `KeychainHelper`
/// - Retries transient failures (timeouts, 5xx)
/// - Decodes responses into strongly-typed `Codable` models
///
/// Use the shared singleton (`NetworkManager.shared`) for all app-wide network calls.
actor NetworkManager {

    // MARK: Public

    /// Shared singleton instance for global use.
    public static let shared: NetworkManager = .init()

    // MARK: Internal

    /// Performs a GET request and decodes the response.
    ///
    /// - Parameters:
    ///   - url: The endpoint URL string.
    ///   - queryParameters: Optional query string parameters.
    /// - Returns: A decoded object of type `T` or `nil` if the request fails.
    func get<T: Codable & Sendable>(
        url: String,
        queryParameters: [String: Any]? = nil
    ) async -> T? {
        return await request(url: url, method: .GET, queryParameters: queryParameters)
    }

    /// Performs a POST request and decodes the response.
    func post<T: Codable & Sendable>(url: String, queryParameters: [String: Any]? = nil, body: Data) async -> T? {
        return await request(url: url, method: .POST, body: body, queryParameters: queryParameters)
    }

    /// Performs a PUT request and decodes the response.
    func put<T: Codable & Sendable>(url: String, queryParameters: [String: Any]? = nil, body: Data) async -> T? {
        return await request(url: url, method: .PUT, body: body, queryParameters: queryParameters)
    }

    /// Performs a DELETE request.
    ///
    /// - Note: Return type is simplified to `Bool` since many DELETE endpoints
    ///   do not return bodies. Returns `true` if the request succeeded.
    func delete(url: String, queryParameters: [String: Any]? = nil, body: Data) async -> Bool {
        let result: Bool? = await request(url: url, method: .DELETE, body: body, queryParameters: queryParameters)
        return result != nil
    }

    /// Performs a PATCH request and decodes the response.
    func patch<T: Codable & Sendable>(url: String, queryParameters: [String: Any]? = nil, body: Data) async -> T? {
        return await request(url: url, method: .PATCH, body: body, queryParameters: queryParameters)
    }

    /// Fetches server-sent events or newline-delimited JSON objects.
    ///
    /// - Parameters:
    ///   - method: HTTP method (`GET`, `POST`, etc.).
    ///   - url: The endpoint URL string.
    ///   - queryParameters: Optional query parameters.
    ///   - onItem: Closure called for each decoded item of type `T`.
    ///
    /// - Note: This uses a simple `\n` delimiter. Suitable for streaming APIs
    ///   that return NDJSON (newline-delimited JSON).
    func fetchStreamedData<T: Codable & Sendable>(
        _ method: HTTPMethod,
        url: String,
        queryParameters: [String: Any]? = nil,
        onItem: (@Sendable (T) -> Void)? = nil
    ) {
        guard let url = buildURLString(url: url, queryParameters: queryParameters) else {
            fatalError("Invalid URL")
        }

        var reqeust = URLRequest(url: url)
        reqeust.httpMethod = method.rawValue

        let task = URLSession.shared.dataTask(with: reqeust) { data, response, _ in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }

            guard let data, let fullText = String(data: data, encoding: .utf8) else {
                return
            }

            let lines = fullText.split(separator: "\n")
            for line in lines {
                if let jsonData = line.data(using: .utf8) {
                    let item: T? = jsonData.decodeUsingJSONDecoder()
                    if let item {
                        onItem?(item)
                    }
                }
            }
        }
        task.resume()
    }

    // MARK: Private

    /// Builds a `URL` with optional query parameters.
    private func buildURLString(
        url: String = "",
        queryParameters: [String: Any]? = nil
    ) -> URL? {
        var urlString = url

        if let queryParameters, !queryParameters.isEmpty {
            var urlComponents = URLComponents(string: urlString)
            urlComponents?.queryItems = queryParameters.map {
                return URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            urlString = urlComponents?.url?.absoluteString ?? urlString
        }

        return URL(string: urlString)
    }

    /// Prepares and executes a network request with automatic retries and decoding.
    private func request<T: Codable>(
        url: String = "",
        method: HTTPMethod,
        body: Data? = nil,
        queryParameters: [String: Any]? = nil
    ) async -> T? {
        guard let url = buildURLString(url: url, queryParameters: queryParameters) else {
            fatalError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let body {
            request.httpBody = body
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let accessToken = KeychainHelper.get("accessToken") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        logger.debug("Preparing request: method=\(method.rawValue, privacy: .public), url=\(url, privacy: .public), queryParameters=\(String(describing: queryParameters), privacy: .public), body=\(String(describing: body?.count), privacy: .public)")

        return await handleRequest(request)
    }

    /// Executes the request with exponential backoff retry logic.
    private func handleRequest<T: Codable>(
        _ request: URLRequest,
        retryCount: Int = 3,
        delay: TimeInterval = 2.0
    ) async -> T? {
        var attempt = 0

        while attempt <= retryCount {
            do {
                return try await performRequest(request)
            } catch {
                let shouldRetryFlag = shouldRetry(for: error, response: nil)
                attempt += 1

                if shouldRetryFlag && attempt <= retryCount {
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    logger.error("Request failed on attempt \(attempt): \(error.localizedDescription)")
                }
            }
        }

        return nil
    }

    /// Performs the actual request and attempts to decode the response.
    private func performRequest<T: Codable>(_ request: URLRequest) async throws -> T? {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Response is not HTTPURLResponse.")
            return nil
        }

        logger.debug("Received response: statusCode=\(httpResponse.statusCode, privacy: .public), url=\(httpResponse.url?.absoluteString ?? "unknown", privacy: .public)")

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return data.decodeUsingJSONDecoder()
    }

    /// Determines whether a request should be retried based on the error or response.
    private func shouldRetry(for error: (any Error)?, response: HTTPURLResponse?) -> Bool {
        if let urlError = error as? URLError, urlError.code == .timedOut {
            logger.error("Request timed out: \(urlError.localizedDescription)")
            return true
        }

        if let statusCode = response?.statusCode, (502...504).contains(statusCode) {
            logger.error("Server error with status code: \(statusCode)")
            return true
        }

        return false
    }
}
