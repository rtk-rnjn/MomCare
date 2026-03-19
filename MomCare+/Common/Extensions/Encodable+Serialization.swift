import Foundation
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.Encodable+Serialization", category: "Extension")

extension Encodable {
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
