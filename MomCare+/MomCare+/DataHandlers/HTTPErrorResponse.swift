import Foundation

enum CodableValue: Codable, Sendable {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case array([CodableValue])
    case dict([String: CodableValue])
    case null

    // MARK: Lifecycle

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
            return
        }
        if let int = try? container.decode(Int.self) {
            self = .int(int)
            return
        }
        if let double = try? container.decode(Double.self) {
            self = .double(double)
            return
        }
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        if let array = try? container.decode([CodableValue].self) {
            self = .array(array)
            return
        }
        if let dict = try? container.decode([String: CodableValue].self) {
            self = .dict(dict)
            return
        }

        self = .null
    }

    // MARK: Internal

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .int(value): try container.encode(value)
        case let .double(value): try container.encode(value)
        case let .bool(value): try container.encode(value)
        case let .string(value): try container.encode(value)
        case let .array(value): try container.encode(value)
        case let .dict(value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
}

extension CodableValue {
    var stringValue: String? {
        if case let .string(s) = self {
            return s
        }
        return nil
    }

    var intValue: Int? {
        if case let .int(i) = self {
            return i
        }
        return nil
    }

    var doubleValue: Double? {
        if case let .double(double) = self {
            return double
        }
        return nil
    }

    var boolValue: Bool? {
        if case let .bool(bool) = self {
            return bool
        }
        return nil
    }

    nonisolated var displayString: String {
        switch self {
        case let .int(value): "\(value)"
        case let .double(value): "\(value)"
        case let .bool(value): value ? "true" : "false"
        case let .string(value): value
        case .array: "(list)"
        case .dict: "(object)"
        case .null: "null"
        }
    }
}

extension CodableValue {
    init(any value: Any) {
        switch value {
        case let v as Int:
            self = .int(v)

        case let v as Double:
            self = .double(v)

        case let v as Bool:
            self = .bool(v)

        case let v as String:
            self = .string(v)

        case let v as [Any]:
            self = .array(v.map { CodableValue(any: $0) })

        case let v as [String: Any]:
            self = .dict(v.mapValues { CodableValue(any: $0) })

        default:
            self = .string("\(value)")
        }
    }
}

enum HTTPValidationErrorLocation: Codable, Sendable {
    case string(String)
    case int(Int)

    // MARK: Lifecycle

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

    // MARK: Internal

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .string(value):
            try container.encode(value)
        case let .int(value):
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
    enum Detail: Codable {
        case message(String)
        case validation([HTTPValidationError])

        // MARK: Lifecycle

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

        // MARK: Internal

        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case let .message(message):
                try container.encode(message)

            case let .validation(errors):
                try container.encode(errors)
            }
        }

        func toOSLogMessageString() -> String {
            switch self {
            case let .message(message):
                return message

            case let .validation(errors):
                let errorMessages = errors.map { error in
                    let locations = error.loc.map { loc -> String in
                        switch loc {
                        case let .string(value):
                            return value

                        case let .int(index):
                            return "[\(index)]"
                        }
                    }

                    let fieldPath = locations.joined(separator: ".")

                    let message = error.msg
                    let type = error.type

                    return "\(fieldPath): \(message) (type: \(type))"
                }

                return errorMessages.joined(separator: "; ")
            }
        }
    }

    let detail: Detail

    var errorDescription: String? {
        switch detail {
        case let .message(message):
            return message

        case let .validation(errors):
            guard !errors.isEmpty else {
                return "Something went wrong with your request."
            }

            if errors.count == 1, let error = errors.first {
                let field = error.loc.last.map {
                    switch $0 {
                    case let .string(s): s
                    case let .int(i): "item \(i)"
                    }
                } ?? "A field"
                return "\(field.capitalized) \(error.msg.lowercased())."
            }

            return "\(errors.count) fields need your attention before we can continue."
        }
    }

    var failureReason: String? {
        switch detail {
        case let .message(message):
            if message.localizedCaseInsensitiveContains("unauthorized") || message.localizedCaseInsensitiveContains("forbidden") {
                return "You don't have permission to perform this action."
            } else if message.localizedCaseInsensitiveContains("not found") {
                return "The requested resource could not be found."
            } else if message.localizedCaseInsensitiveContains("timeout") {
                return "The server took too long to respond."
            }
            return "The server wasn't able to complete your request."

        case let .validation(errors):
            let fields = errors.compactMap { error -> String? in
                guard let last = error.loc.last else {
                    return nil
                }

                switch last {
                case let .string(s): return s
                case let .int(i): return "item \(i)"
                }
            }

            guard !fields.isEmpty else {
                return "Some required information is missing or incorrect."
            }

            let listed = fields.prefix(3).joined(separator: ", ")
            let suffix = fields.count > 3 ? " and \(fields.count - 3) more" : ""
            return "There's a problem with: \(listed)\(suffix)."
        }
    }

    var recoverySuggestion: String? {
        switch detail {
        case let .message(message):
            if message.localizedCaseInsensitiveContains("unauthorized") || message.localizedCaseInsensitiveContains("forbidden") {
                return "Try signing in again or contact support if the problem persists."
            } else if message.localizedCaseInsensitiveContains("not found") {
                return "Double-check the details and try again. If this keeps happening, the item may have been removed."
            } else if message.localizedCaseInsensitiveContains("timeout") {
                return "Check your connection and try again in a moment."
            }
            return "Please try again. If the issue continues, reach out to support."

        case let .validation(errors):
            let hints = errors.compactMap { error -> String? in
                guard let last = error.loc.last else {
                    return nil
                }

                let field: String = switch last {
                case let .string(string): string
                case let .int(int): "item \(int)"
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
}
