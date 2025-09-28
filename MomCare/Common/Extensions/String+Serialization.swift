//
//  String+Serialization.swift
//  MomCare
//
//  Created by Aryan Singh on 19/09/25.
//

import Foundation

extension String {
    /// Converts the string into `Data` using the specified string encoding.
    ///
    /// - Parameter encoding: The string encoding to use (default is `.utf8`).
    /// - Returns: A `Data` object representing the string. Returns empty `Data` if conversion fails.
    ///
    /// ### Usage
    /// ```swift
    /// let str = "Hello, World!"
    /// let data = str.toData()
    /// ```
    func toData(using encoding: String.Encoding = .utf8) -> Data {
        return data(using: encoding) ?? Data()
    }

    /// Decodes a Base64-encoded string into `Data`.
    ///
    /// - Returns: A `Data` object from the Base64 string. Returns empty `Data` if decoding fails.
    ///
    /// ### Usage
    /// ```swift
    /// let base64 = "SGVsbG8sIFdvcmxkIQ=="
    /// let data = base64.fromBase64()
    /// ```
    func fromBase64() -> Data {
        return Data(base64Encoded: self) ?? Data()
    }
}
