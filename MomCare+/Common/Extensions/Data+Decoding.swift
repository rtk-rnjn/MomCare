import Foundation

extension Data {
    func decodeUsingJSONDecoder<T: Codable>() throws -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: self)
    }

    func decodeUsingPropertyListDecoder<T: Codable>() throws -> T? {
        let decoder = PropertyListDecoder()
        return try decoder.decode(T.self, from: self)
    }

    func decodeToString(using encoding: String.Encoding = .utf8) -> String? {
        String(data: self, encoding: encoding)
    }

    func toBase64() -> String {
        base64EncodedString()
    }
}
