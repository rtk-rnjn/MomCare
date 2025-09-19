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

    func decodeUsingPropertyListDecoder<T: Codable>() -> T? {
        let decoder = PropertyListDecoder()
        do {
            return try decoder.decode(T.self, from: self)
        } catch {
            logger.error("Failed to decode data: \(String(describing: error))")
            return nil
        }
    }

    func decodeToString(using encoding: String.Encoding = .utf8) -> String? {
        return String(data: self, encoding: encoding)
    }

    func toBase64() -> String {
        return base64EncodedString()
    }
}
