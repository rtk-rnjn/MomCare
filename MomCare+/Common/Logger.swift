import OSLog

private let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.MomCare"
enum MomCareLogger {
    static let view: Logger = .init(subsystem: bundleIdentifier, category: "View")
    static let network: Logger = .init(subsystem: bundleIdentifier, category: "Network")
    static let database: Logger = .init(subsystem: bundleIdentifier, category: "Database")
    static let cache: Logger = .init(subsystem: bundleIdentifier, category: "Cache")
    static let appDelegate: Logger = .init(subsystem: bundleIdentifier, category: "AppDelegate")

    enum ViewModel {
        static let authentication: Logger = .init(subsystem: bundleIdentifier, category: "ViewModel.Authentication")
    }

    static let `extension`: Logger = .init(subsystem: bundleIdentifier, category: "Extension")


    enum Miscellaneous {
        static let general: Logger = .init(subsystem: bundleIdentifier, category: "General")
    }
}
