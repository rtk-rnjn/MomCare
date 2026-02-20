import Foundation
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.Encodable+Serialization", category: "Extension")

extension Encodable {
    func toDictionary<T: Codable>(snakeCase: Bool = false) -> T? {
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

    func encodeUsingJSONEncoder(
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
