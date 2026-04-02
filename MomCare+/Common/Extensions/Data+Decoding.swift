import Foundation

extension Data {
    nonisolated func decodeUsingJSONDecoder<T: Codable & Sendable>() throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: self)
    }
}
