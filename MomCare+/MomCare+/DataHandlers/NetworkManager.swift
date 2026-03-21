import Foundation
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.NetworkManager", category: "Network")

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

struct NetworkResponse<T: Codable>: Codable {
    enum CodingKeys: String, CodingKey {
        case data
        case statusCode
        case errorMessage
    }

    var data: T?
    var statusCode: Int
    var errorMessage: String?
    var responseHeaders: [AnyHashable: Any]?

    var localizedError: (any LocalizedError)? {
        if errorMessage == nil {
            return nil
        }

        return APIErrorResolver.error(from: statusCode)
    }

    var success: Bool {
        return (200...299).contains(statusCode) && errorMessage == nil
    }
}

class NetworkManager {

    // MARK: Internal

    static let shared: NetworkManager = .init()

    private(set) var debugMenuStore: DebugMenuStore?

    func setDebugMenuStore(_ store: DebugMenuStore) {
        debugMenuStore = store
    }

    func get<T: Codable>(
        url: String,
        queryParameters: [String: any Codable]? = nil,
        headers: [String: String]? = nil
    ) async throws -> NetworkResponse<T> {
        try await request(url: url, method: .GET, queryParameters: queryParameters, headers: headers)
    }

    func post<T: Codable>(url: String, queryParameters: [String: any Codable]? = nil, body: Data? = nil, headers: [String: String]? = nil) async throws -> NetworkResponse<T> {
        try await request(url: url, method: .POST, body: body, queryParameters: queryParameters, headers: headers)
    }

    func put<T: Codable>(url: String, queryParameters: [String: any Codable]? = nil, body: Data? = nil, headers: [String: String]? = nil) async throws -> NetworkResponse<T> {
        try await request(url: url, method: .PUT, body: body, queryParameters: queryParameters, headers: headers)
    }

    func delete<T: Codable>(url: String, queryParameters: [String: any Codable]? = nil, body: Data? = nil, headers: [String: String]? = nil) async throws -> NetworkResponse<T> {
        try await request(url: url, method: .DELETE, body: body, queryParameters: queryParameters, headers: headers)
    }

    func patch<T: Codable>(url: String, queryParameters: [String: any Codable]? = nil, body: Data? = nil, headers: [String: String]? = nil) async throws -> NetworkResponse<T> {
        try await request(url: url, method: .PATCH, body: body, queryParameters: queryParameters, headers: headers)
    }

    func fetchStreamedData<T: Codable & CustomStringConvertible>(
        _ method: HTTPMethod,
        url: String,
        queryParameters: [String: any Codable]? = nil,
        headers: [String: String]? = nil,
        onItem: (@Sendable (T) -> Void)? = nil
    ) -> URLSessionDataTask {
        let finalURL = buildURLString(url: url, queryParameters: queryParameters)

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        logger.info("Starting streamed request to \(finalURL.absoluteString) with method \(method.rawValue)")
        DebugLogger.shared.log("Starting streamed request to \(finalURL.absoluteString) with method \(method.rawValue)", level: .info, category: .network)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    logger.error("Error fetching streamed data from \(finalURL.absoluteString): \(error.localizedDescription)")
                    DebugLogger.shared.log("Error fetching streamed data from \(finalURL.absoluteString): \(error.localizedDescription)", level: .error, category: .network)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode <= 400, let data, let fullText = String(data: data, encoding: .utf8) else {
                return
            }

            let lines = fullText.split(separator: "\n")

            for line in lines {
                DispatchQueue.main.async {
                    if let jsonData = line.data(using: .utf8), let item: T = try? jsonData.decodeUsingJSONDecoder() {
                        logger.debug("Received streamed item from \(finalURL.absoluteString): \(item, privacy: .public)")
                        DebugLogger.shared.log("Received streamed item from \(finalURL.absoluteString): \(item)", level: .debug, category: .network)
                        onItem?(item)
                    }
                }
            }
        }
        task.resume()
        return task
    }

    // MARK: Private

    private func buildURLString(
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
            fatalError()
        }

        return url
    }

    private func request<T: Codable>(
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

    private func performRequest<T: Codable>(_ request: URLRequest) async throws -> NetworkResponse<T> {

        let url = request.url?.absoluteString ?? "unknown URL"
        logger.info("Performing \(request.httpMethod ?? "UNKNOWN") request to \(url)")
        DebugLogger.shared.log("Performing \(request.httpMethod ?? "UNKNOWN") request to \(url)", level: .info, category: .network)

        var attempts = 5

        while attempts > 0 {

            let startTime = Date()

            var statusCode: Int?
            var responseBody: String?
            var errorMessage: String?

            defer {
                debugMenuStore?.addNetworkRequest(
                    .init(
                        method: request.httpMethod ?? "UNKNOWN",
                        url: url,
                        statusCode: statusCode,
                        responseTime: Date().timeIntervalSince(startTime),
                        requestBody: request.httpBody.flatMap { String(data: $0, encoding: .utf8) },
                        responseBody: responseBody,
                        error: errorMessage
                    )
                )
            }

            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                statusCode = (response as? HTTPURLResponse)?.statusCode
                responseBody = String(data: data, encoding: .utf8)

                let networkResponse: NetworkResponse<T> = try await handleRequest(
                    response: response,
                    data: data,
                    url: url
                )

                errorMessage = networkResponse.errorMessage

                return networkResponse
            } catch {

                attempts -= 1
                errorMessage = error.localizedDescription

                if let urlError = error as? URLError {

                    switch urlError.code {

                    case .networkConnectionLost, .timedOut, .notConnectedToInternet:

                        logger.warning("Network error occurred for request to \(url): \(urlError.localizedDescription). Retrying... (\(5 - attempts) attempts left)")

                        DebugLogger.shared.log(
                            "Network error occurred for request to \(url): \(urlError.localizedDescription). Retrying... (\(5 - attempts) attempts left)",
                            level: .warning,
                            category: .network
                        )

                        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * (attempts % 5)))

                    default:
                        throw error
                    }
                }

                throw error
            }
        }
    }

    private func handleRequest<T: Codable>(response: URLResponse, data: Data, url: String) async throws -> NetworkResponse<T> {
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid response for request to \(url)")
            DebugLogger.shared.log("Invalid response for request to \(url)", level: .error, category: .network)
            throw URLError(.badServerResponse)
        }

        logger.info("Received response with status code \(httpResponse.statusCode) for request to \(url)")
        DebugLogger.shared.log("Received response with status code \(httpResponse.statusCode) for request to \(url)", level: .info, category: .network)

        if httpResponse.statusCode >= 400, let _: HTTPErrorResponse = try? data.decodeUsingJSONDecoder() {
            throw APIErrorResolver.error(from: httpResponse.statusCode)
        }

        let maybeData: T? = try data.decodeUsingJSONDecoder()
        return NetworkResponse(data: maybeData, statusCode: httpResponse.statusCode)
    }
}
