//
//  Data+Decoding.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

import Foundation
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.Data+Decoding", category: "Extension")

extension Data {
    /// Decodes the `Data` into a `Codable` type using `JSONDecoder`.
    ///
    /// - Note: Uses `.iso8601` as the default `dateDecodingStrategy`.
    ///
    /// - Returns: An instance of type `T` if decoding succeeds, otherwise `nil`.
    ///
    /// ### Usage
    /// ```swift
    /// let user: User? = jsonData.decodeUsingJSONDecoder()
    /// ```
    func decodeUsingJSONDecoder<T: Codable>() -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: self)
        } catch {
            logger.error("Failed to decode data: \(String(describing: error))")
            return nil
        }
    }

    /// Decodes the `Data` into a `Codable` type using `PropertyListDecoder`.
    ///
    /// - Returns: An instance of type `T` if decoding succeeds, otherwise `nil`.
    ///
    /// ### Usage
    /// ```swift
    /// let settings: AppSettings? = plistData.decodeUsingPropertyListDecoder()
    /// ```
    func decodeUsingPropertyListDecoder<T: Codable>() -> T? {
        let decoder = PropertyListDecoder()
        do {
            return try decoder.decode(T.self, from: self)
        } catch {
            logger.error("Failed to decode data: \(String(describing: error))")
            return nil
        }
    }

    /// Converts the `Data` into a `String` using the specified encoding.
    ///
    /// - Parameter encoding: The string encoding to use (default is `.utf8`).
    /// - Returns: A decoded `String`, or `nil` if conversion fails.
    ///
    /// ### Usage
    /// ```swift
    /// let jsonString = jsonData.decodeToString()
    /// ```
    func decodeToString(using encoding: String.Encoding = .utf8) -> String? {
        return String(data: self, encoding: encoding)
    }

    /// Encodes the `Data` into a Base64 string.
    ///
    /// - Returns: A Base64-encoded representation of the `Data`.
    ///
    /// ### Usage
    /// ```swift
    /// let base64 = imageData.toBase64()
    /// ```
    func toBase64() -> String {
        return base64EncodedString()
    }
}
