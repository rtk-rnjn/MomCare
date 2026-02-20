//
//  URL+Normalization.swift
//  MomCare+
//
//  Created by Aryan singh on 14/02/26.
//

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
