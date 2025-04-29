//
//  NetworkManager.swift
//  MomCare
//
//  Created by RITIK RANJAN on 06/02/25.
//

import Foundation
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.NetworkManager", category: "Network")
private let endpoint = "http://13.233.139.216:8000"

actor NetworkManager {

    // MARK: Public

    public static let shared: NetworkManager = .init()

    // MARK: Internal

    func get<T: Codable>(url: String, queryParameters: [String: String]? = nil) async -> T? {
        logger.debug("GET request initiated for URL: \(url, privacy: .public) with queryParameters: \(String(describing: queryParameters), privacy: .public)")
        return await request(url: url, method: "GET", queryParameters: queryParameters)
    }

    func post<T: Codable>(url: String, body: Data) async -> T? {
        logger.debug("POST request initiated for URL: \(url, privacy: .public) with body size: \(body.count, privacy: .public) bytes")
        return await request(url: url, method: "POST", body: body)
    }

    func put<T: Codable>(url: String, body: Data) async -> T? {
        logger.debug("PUT request initiated for URL: \(url, privacy: .public) with body size: \(body.count, privacy: .public) bytes")
        return await request(url: url, method: "PUT", body: body)
    }

    func delete(url: String, body: Data) async -> Bool {
        logger.debug("DELETE request initiated for URL: \(url, privacy: .public) with body size: \(body.count, privacy: .public) bytes")
        let result: Bool? = await request(url: url, method: "DELETE", body: body)
        return result != nil
    }

    func patch<T: Codable>(url: String, body: Data) async -> T? {
        logger.debug("PATCH request initiated for URL: \(url, privacy: .public) with body size: \(body.count, privacy: .public) bytes")
        return await request(url: url, method: "PATCH", body: body)
    }

    // MARK: Private

    private func request<T: Codable>(url: String = "", method: String, body: Data? = nil, queryParameters: [String: String]? = nil) async -> T? {
        logger.debug("Preparing request: method=\(method, privacy: .public), url=\(url, privacy: .public), queryParameters=\(String(describing: queryParameters), privacy: .public)")

        var urlString = "\(endpoint)\(url)"

        if let queryParameters, !queryParameters.isEmpty {
            var urlComponents = URLComponents(string: urlString)
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlString = urlComponents?.url?.absoluteString ?? urlString
        }

        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL formed: \(urlString, privacy: .public)")
            fatalError("Oo haseena zulfon waali jaane jahan")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body {
            request.httpBody = body
            logger.debug("Request body set with size: \(body.count, privacy: .public) bytes")
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let accessToken = KeychainHelper.get("accessToken") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            logger.debug("Authorization header set with access token.")
        }

        do {
            logger.debug("Sending request to: \(url.absoluteString, privacy: .public)")
            let (data, response) = try await URLSession.shared.data(for: request)
            logger.debug("Received response for URL: \(url.absoluteString, privacy: .public)")

            guard let response = response as? HTTPURLResponse else {
                logger.error("Response is not HTTPURLResponse.")
                return nil
            }

            logger.debug("Response Status Code: \(response.statusCode, privacy: .public)")

            guard response.statusCode == 200 else {
                logger.error("Request failed with status code: \(response.statusCode, privacy: .public)")
                return nil
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let decodedObject = try decoder.decode(T.self, from: data)
            logger.debug("Successfully decoded response for URL: \(url.absoluteString, privacy: .public)")
            return decodedObject

        } catch {
            logger.error("Request error for URL: \(url.absoluteString, privacy: .public), error: \(String(describing: error), privacy: .public)")
            return nil
        }
    }
}
