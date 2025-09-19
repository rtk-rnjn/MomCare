//
//  String+Serialization.swift
//  MomCare
//
//  Created by Aryan Singh on 19/09/25.
//

import Foundation

extension String {
    func toData(using encoding: String.Encoding = .utf8) -> Data {
        return data(using: encoding) ?? Data()
    }

    func fromBase64() -> Data {
        return Data(base64Encoded: self) ?? Data()
    }
}
