
import Foundation

enum CodableValue: Codable, Sendable {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case array([CodableValue])
    case dict([String: CodableValue])
    case null

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) { self = .bool(bool); return }
        if let int = try? container.decode(Int.self) { self = .int(int); return }
        if let double = try? container.decode(Double.self) { self = .double(double); return }
        if let string = try? container.decode(String.self) { self = .string(string); return }
        if let array = try? container.decode([CodableValue].self) { self = .array(array); return }
        if let dict = try? container.decode([String: CodableValue].self) { self = .dict(dict); return }

        self = .null
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .int(let v):    try container.encode(v)
        case .double(let v): try container.encode(v)
        case .bool(let v):   try container.encode(v)
        case .string(let v): try container.encode(v)
        case .array(let v):  try container.encode(v)
        case .dict(let v):   try container.encode(v)
        case .null:          try container.encodeNil()
        }
    }
}

extension CodableValue {
    var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }

    var intValue: Int? {
        if case .int(let i) = self { return i }
        return nil
    }

    var doubleValue: Double? {
        if case .double(let d) = self { return d }
        return nil
    }

    var boolValue: Bool? {
        if case .bool(let b) = self { return b }
        return nil
    }

    nonisolated var displayString: String {
        switch self {
        case .int(let v):    return "\(v)"
        case .double(let v): return "\(v)"
        case .bool(let v):   return v ? "true" : "false"
        case .string(let v): return v
        case .array:         return "(list)"
        case .dict:          return "(object)"
        case .null:          return "null"
        }
    }
}

enum HTTPValidationErrorLocation: Codable, Sendable {
    case string(String)
    case int(Int)

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }

        if let int = try? container.decode(Int.self) {
            self = .int(int)
            return
        }

        throw DecodingError.typeMismatch(
            HTTPValidationErrorLocation.self,
            .init(codingPath: decoder.codingPath, debugDescription: "Expected String or Int")
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        }
    }
}

struct HTTPValidationError: Codable, Sendable {
    let loc: [HTTPValidationErrorLocation]
    let msg: String
    let type: String
    let input: CodableValue?
    let ctx: [String: CodableValue]?
}

struct HTTPErrorResponse: Codable, LocalizedError {

    let detail: Detail

    var errorDescription: String? {
        switch detail {
        case .message(let message):
            return message

        case .validation(let errors):
            guard !errors.isEmpty else { return "Something went wrong with your request." }

            if errors.count == 1, let error = errors.first {
                let field = error.loc.last.map {
                    switch $0 {
                    case .string(let s): return s
                    case .int(let i): return "item \(i)"
                    }
                } ?? "A field"
                return "\(field.capitalized) \(error.msg.lowercased())."
            }

            return "\(errors.count) fields need your attention before we can continue."
        }
    }

    var failureReason: String? {
        switch detail {
        case .message(let message):
            if message.localizedCaseInsensitiveContains("unauthorized") || message.localizedCaseInsensitiveContains("forbidden") {
                return "You don't have permission to perform this action."
            } else if message.localizedCaseInsensitiveContains("not found") {
                return "The requested resource could not be found."
            } else if message.localizedCaseInsensitiveContains("timeout") {
                return "The server took too long to respond."
            }
            return "The server wasn't able to complete your request."

        case .validation(let errors):
            let fields = errors.compactMap { error -> String? in
                guard let last = error.loc.last else { return nil }
                switch last {
                case .string(let s): return s
                case .int(let i): return "item \(i)"
                }
            }

            guard !fields.isEmpty else { return "Some required information is missing or incorrect." }
            let listed = fields.prefix(3).joined(separator: ", ")
            let suffix = fields.count > 3 ? " and \(fields.count - 3) more" : ""
            return "There's a problem with: \(listed)\(suffix)."
        }
    }

    var recoverySuggestion: String? {
        switch detail {
        case .message(let message):
            if message.localizedCaseInsensitiveContains("unauthorized") || message.localizedCaseInsensitiveContains("forbidden") {
                return "Try signing in again or contact support if the problem persists."
            } else if message.localizedCaseInsensitiveContains("not found") {
                return "Double-check the details and try again. If this keeps happening, the item may have been removed."
            } else if message.localizedCaseInsensitiveContains("timeout") {
                return "Check your connection and try again in a moment."
            }
            return "Please try again. If the issue continues, reach out to support."

        case .validation(let errors):
            let hints = errors.compactMap { error -> String? in
                guard let last = error.loc.last else { return nil }
                let field: String
                switch last {
                case .string(let s): field = s
                case .int(let i): field = "item \(i)"
                }

                if let ctx = error.ctx, let expected = ctx["expected"] {
                    return "'\(field)' should be \(expected.displayString)."
                }

                return "Fix '\(field)': \(error.msg.lowercased())."
            }

            return hints.isEmpty
                ? "Review your input and make sure all fields are filled in correctly."
                : hints.prefix(2).joined(separator: " ")
        }
    }
    enum Detail: Codable {
        case message(String)
        case validation([HTTPValidationError])

        init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let message = try? container.decode(String.self) {
                self = .message(message)
                return
            }

            if let errors = try? container.decode([HTTPValidationError].self) {
                self = .validation(errors)
                return
            }

            throw DecodingError.typeMismatch(
                Detail.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String or [HTTPValidationError]"
                )
            )
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .message(let message):
                try container.encode(message)

            case .validation(let errors):
                try container.encode(errors)
            }
        }
    }
}
