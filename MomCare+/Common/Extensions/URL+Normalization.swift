import Foundation

extension URL {
    var normalizedForCache: String {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return absoluteString
        }
        components.query = nil
        components.fragment = nil
        return components.string ?? absoluteString
    }
}
