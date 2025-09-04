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

    func toDictionary<T>(snakeCase: Bool = false) -> T? {

        let encoder = JSONEncoder()

        guard let data = try? encoder.encode(self) else { return nil }

        if snakeCase {

            encoder.keyEncodingStrategy = .convertToSnakeCase

        }

        do {

            return try JSONSerialization.jsonObject(with: data) as? T

        } catch {

            logger.error("Failed to convert object to dictionary: \(String(describing: error))")

            return nil

        }

    }

    func toData(keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase) -> Data? {

        let encoder = JSONEncoder()

        encoder.keyEncodingStrategy = keyEncodingStrategy

        encoder.dateEncodingStrategy = .iso8601

        encoder.outputFormatting = .prettyPrinted

        do {

            return try encoder.encode(self)

        } catch {

            logger.error("Failed to encode object: \(String(describing: error))")

            return nil

        }

    }

}
