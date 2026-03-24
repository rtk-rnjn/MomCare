import Foundation

protocol APIError: Error, LocalizedError {}

struct BadRequestError: @preconcurrency APIError {
    var errorDescription: String? {
        "Invalid request."
    }

    var failureReason: String? {
        "The request was missing required parameters or was malformed."
    }

    var recoverySuggestion: String? {
        "Please check the entered information and try again."
    }
}

struct UnauthorizedError: @preconcurrency APIError {
    var errorDescription: String? {
        "Authentication failed."
    }

    var failureReason: String? {
        "Your credentials are invalid or your session has expired."
    }

    var recoverySuggestion: String? {
        "Please log in again to continue."
    }
}

struct ForbiddenError: @preconcurrency APIError {
    var errorDescription: String? {
        "Access denied."
    }

    var failureReason: String? {
        "Your account does not have permission to perform this action."
    }

    var recoverySuggestion: String? {
        "Please verify your account or contact support."
    }
}

struct NotFoundError: @preconcurrency APIError {
    var errorDescription: String? {
        "Resource not found."
    }

    var failureReason: String? {
        "The requested resource could not be located."
    }

    var recoverySuggestion: String? {
        "Please try to login again or refresh the app."
    }
}

struct ConflictError: @preconcurrency APIError {
    var errorDescription: String? {
        "Conflict occurred."
    }

    var failureReason: String? {
        "The request conflicts with an existing resource."
    }

    var recoverySuggestion: String? {
        "Try using a different value or update the existing resource."
    }
}

struct AccountDeletedError: @preconcurrency APIError {
    var errorDescription: String? {
        "Account deleted."
    }

    var failureReason: String? {
        "This account has been permanently deleted."
    }

    var recoverySuggestion: String? {
        "Please create a new account or contact support if this is unexpected."
    }
}

struct ValidationError: @preconcurrency APIError {
    var errorDescription: String? {
        "Invalid input."
    }

    var failureReason: String? {
        "Some of the provided information is invalid."
    }

    var recoverySuggestion: String? {
        "Please review your input and try again."
    }
}

struct AccountLockedError: @preconcurrency APIError {
    var errorDescription: String? {
        "Account locked."
    }

    var failureReason: String? {
        "Your account has been temporarily locked."
    }

    var recoverySuggestion: String? {
        "Please try again later or contact support."
    }
}

struct NetworkError: @preconcurrency APIError {
    var errorDescription: String? {
        "Network connection failed."
    }

    var failureReason: String? {
        "The request could not be completed due to a network issue."
    }

    var recoverySuggestion: String? {
        "Please check your internet connection and try again."
    }
}

struct UnknownAPIError: @preconcurrency APIError {
    var errorDescription: String? {
        "Something went wrong."
    }

    var failureReason: String? {
        "The server returned an unexpected response."
    }

    var recoverySuggestion: String? {
        "Please try again later."
    }
}

enum APIErrorResolver {
    static func error(from statusCode: Int, with error: HTTPErrorResponse? = nil) -> any LocalizedError {
        switch statusCode {
        case 400:
            BadRequestError()

        case 401:
            UnauthorizedError()

        case 403:
            ForbiddenError()

        case 404:
            NotFoundError()

        case 409:
            ConflictError()

        case 410:
            AccountDeletedError()

        case 422:
            error ?? ValidationError()

        case 423:
            AccountLockedError()

        default:
            UnknownAPIError()
        }
    }
}
