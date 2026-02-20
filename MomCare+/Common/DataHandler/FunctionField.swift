//
//  FunctionField.swift
//  MomCare+
//
//  Created by Aryan singh on 13/02/26.
//

import Foundation

enum FieldType<Value: Codable> {
    case unset
    case value(Value)
    case null
}

extension FieldType: Codable where Value: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else {
            let value = try container.decode(Value.self)
            self = .value(value)
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .unset:
            break
        case .null:
            try container.encodeNil()
        case let .value(value):
            try container.encode(value)
        }
    }
}

extension FieldType: Sendable where Value: Sendable {}
