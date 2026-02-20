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
    var data: T?
    var statusCode: Int
    var errorMessage: String? = nil
}

class NetworkManager {

    // MARK: Internal

    static let shared: NetworkManager = .init()

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

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    logger.error("Error fetching streamed data from \(finalURL.absoluteString): \(error.localizedDescription)")
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

        var count = 5
        while count > 0 {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                return try await handleRequest(response: response, data: data, url: url)
            } catch {
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .networkConnectionLost, .timedOut, .notConnectedToInternet:
                        logger.warning("Network error occurred for request to \(url): \(urlError.localizedDescription). Retrying... (\(5 - count) attempts left)")
                        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * (count % 5)))
                        count -= 1

                    default:
                        return NetworkResponse(data: nil, statusCode: -1, errorMessage: urlError.localizedDescription)
                    }
                }
            }
        }

        return NetworkResponse(data: nil, statusCode: -1, errorMessage: "Request failed after multiple attempts due to network issues.")
    }

    private func handleRequest<T: Codable>(response: URLResponse, data: Data, url: String) async throws -> NetworkResponse<T> {
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid response for request to \(url)")
            throw URLError(.badServerResponse)
        }

        logger.info("Received response with status code \(httpResponse.statusCode) for request to \(url)")

        if httpResponse.statusCode >= 400 {
            let maybeData: ServerMessage? = try data.decodeUsingJSONDecoder()
            logger.error("Decoded response body. Error detail: \(maybeData?.detail ?? "No detail")")
            return NetworkResponse(data: nil, statusCode: httpResponse.statusCode, errorMessage: maybeData?.detail ?? "Unknown Error")
        }

        let maybeData: T? = try data.decodeUsingJSONDecoder()
        return NetworkResponse(data: maybeData, statusCode: httpResponse.statusCode)
    }
}
