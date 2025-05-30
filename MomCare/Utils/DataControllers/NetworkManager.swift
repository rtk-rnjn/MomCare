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
        return await request(url: url, method: "GET", queryParameters: queryParameters)
    }

    func post<T: Codable>(url: String, body: Data) async -> T? {
        return await request(url: url, method: "POST", body: body)
    }

    func put<T: Codable>(url: String, body: Data) async -> T? {
        return await request(url: url, method: "PUT", body: body)
    }

    func delete(url: String, body: Data) async -> Bool {
        let result: Bool? = await request(url: url, method: "DELETE", body: body)
        return result != nil
    }

    func patch<T: Codable>(url: String, body: Data) async -> T? {
        return await request(url: url, method: "PATCH", body: body)
    }

    func fetchStreamedData<T: Codable>(_ method: HTTPMethod, url: String, queryParameters: [String: Any]? = nil, onItem: @escaping (T) -> Void, onError: ((Error) -> Void)? = nil) {
        var urlString = "\(endpoint)\(url)"

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

        let task = URLSession.shared.dataTask(with: reqeust) { data, response, error in
            if let error {
                onError?(error)
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                onError?(NSError(domain: "Response is not HTTPURLResponse", code: 0, userInfo: nil))
                return
            }

            guard let data, let fullText = String(data: data, encoding: .utf8) else {
                onError?(NSError(domain: "No data", code: 0, userInfo: nil))
                return
            }

            let lines = fullText.split(separator: "\n")
            for line in lines {
                if let jsonData = line.data(using: .utf8) {
                    do {
                        let item = try JSONDecoder().decode(T.self, from: jsonData)
                        DispatchQueue.main.async {
                            onItem(item)
                        }
                    } catch {
                        onError?(error)
                    }
                }
            }
        }
        task.resume()

    }

    // MARK: Private

    private var delimiter: String = "\n"

    private func request<T: Codable>(url: String = "", method: String, body: Data? = nil, queryParameters: [String: Any]? = nil) async -> T? {
        var urlString = "\(endpoint)\(url)"

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
        request.httpMethod = method
        if let body {
            request.httpBody = body
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let accessToken = KeychainHelper.get("accessToken") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        do {
            logger.debug("Preparing request: method=\(method, privacy: .public), url=\(url, privacy: .public), queryParameters=\(String(describing: queryParameters), privacy: .public), body=\(String(describing: body?.count), privacy: .public)")
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                logger.error("Response is not HTTPURLResponse.")
                return nil
            }

            logger.debug("Response fetched, url=\(url, privacy: .public), status=\(response.statusCode, privacy: .public)")

            guard response.statusCode == 200 else {
                return nil
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            return try decoder.decode(T.self, from: data)

        } catch {
            logger.error("Request error for URL: \(url.absoluteString, privacy: .public), error: \(String(describing: error), privacy: .public)")
            return nil
        }
    }

}
