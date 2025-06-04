//
//  NetworkManager.swift
//  MomCare
//
//  Created by RITIK RANJAN on 06/02/25.
//

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

actor NetworkManager {

    // MARK: Public

    public static let shared: NetworkManager = .init()

    // MARK: Internal

    func get<T: Codable>(url: String, queryParameters: [String: Any]? = nil) async -> T? {
        return await request(url: url, method: .GET, queryParameters: queryParameters)
    }

    func post<T: Codable>(url: String, body: Data) async -> T? {
        return await request(url: url, method: .POST, body: body)
    }

    func put<T: Codable>(url: String, body: Data) async -> T? {
        return await request(url: url, method: .PUT, body: body)
    }

    func delete(url: String, body: Data) async -> Bool {
        let result: Bool? = await request(url: url, method: .DELETE, body: body)
        return result != nil
    }

    func patch<T: Codable>(url: String, body: Data) async -> T? {
        return await request(url: url, method: .PATCH, body: body)
    }

    func fetchStreamedData<T: Codable>(_ method: HTTPMethod, url: String, queryParameters: [String: Any]? = nil, onItem: (@Sendable (T) -> Void)? = nil) {
        var urlString = url

        if let queryParameters, !queryParameters.isEmpty {
            var urlComponents = URLComponents(string: urlString)
            urlComponents?.queryItems = queryParameters.map {
                return URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            urlString = urlComponents?.url?.absoluteString ?? urlString
        }

        guard let url = URL(string: urlString) else {
            fatalError("Oo haseena zulfon waali jaane jahan")
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
                    let item: T? = jsonData.decode()
                    if let item {
                        onItem?(item)
                    }
                }
            }
        }
        task.resume()
    }

    // MARK: Private

    private var delimiter: String = "\n"

    private func request<T: Codable>(url: String = "", method: HTTPMethod, body: Data? = nil, queryParameters: [String: Any]? = nil) async -> T? {
        var urlString = url

        if let queryParameters, !queryParameters.isEmpty {
            var urlComponents = URLComponents(string: urlString)
            urlComponents?.queryItems = queryParameters.map {
                return URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            urlString = urlComponents?.url?.absoluteString ?? urlString
        }

        guard let url = URL(string: urlString) else {
            fatalError("Oo haseena zulfon waali jaane jahan")
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
                    return nil
                }
            }
        }

        return nil
    }

    private func performRequest<T: Codable>(_ request: URLRequest) async throws -> T? {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Response is not HTTPURLResponse.")
            return nil
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return data.decode()
    }

    private func shouldRetry(for error: Error?, response: HTTPURLResponse?) -> Bool {
        if let urlError = error as? URLError, urlError.code == .timedOut {
            return true
        }

        if let statusCode = response?.statusCode, (502...504).contains(statusCode) {
            return true
        }

        return false
    }
}
