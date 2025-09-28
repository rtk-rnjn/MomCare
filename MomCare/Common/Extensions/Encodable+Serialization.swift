//
//  Encodable+Serialization.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

import Foundation
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.Encodable+Serialization", category: "Extension")

extension Encodable {
    /// Converts the encodable object into a dictionary.
    ///
    /// - Parameter snakeCase: Whether to convert property names to snake_case (default is `false`).
    /// - Returns: A dictionary representation of the object (`[String: Any]` or similar), or `nil` if encoding fails.
    ///
    /// ### Usage
    /// ```swift
    /// struct User: Codable {
    ///     let firstName: String
    ///     let lastName: String
    /// }
    ///
    /// let user = User(firstName: "John", lastName: "Doe")
    /// let dict: [String: Any]? = user.toDictionary(snakeCase: true)
    /// ```
    func toDictionary<T>(snakeCase: Bool = false) -> T? {
        let encoder = JSONEncoder()
        if snakeCase {
            encoder.keyEncodingStrategy = .convertToSnakeCase
        }

        do {
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data) as? T
        } catch {
            logger.error("Failed to convert object to dictionary: \(error.localizedDescription)")
            return nil
        }
    }

    /// Encodes the object into JSON `Data`.
    ///
    /// - Parameter keyEncodingStrategy: Key encoding strategy for the JSON keys (default is `.convertToSnakeCase`).
    /// - Returns: JSON `Data` representing the object, or `nil` if encoding fails.
    ///
    /// ### Usage
    /// ```swift
    /// let user = User(firstName: "John", lastName: "Doe")
    /// if let data = user.toData() {
    ///     print(String(data: data, encoding: .utf8)!)
    /// }
    /// ```
    func toData(
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase
    ) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = keyEncodingStrategy
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        do {
            return try encoder.encode(self)
        } catch {
            logger.error("Failed to encode object: \(error.localizedDescription)")
            return nil
        }
    }
}
