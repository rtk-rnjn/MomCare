import Foundation

extension String {
    func toData(using encoding: String.Encoding = .utf8) -> Data {
        data(using: encoding) ?? Data()
    }

    func fromBase64() -> Data {
        Data(base64Encoded: self) ?? Data()
    }
}
