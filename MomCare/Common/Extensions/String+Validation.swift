//
//  String+Validation.swift
//  MomCare
//
//  Created by RITIK RANJAN on 17/06/25.
//

import Foundation

extension String {
    /// Checks if the string is a valid email address.
    ///
    /// Uses a regular expression to validate common email patterns.
    ///
    /// - Returns: `true` if the string matches the email pattern, `false` otherwise.
    ///
    /// ### Usage
    /// ```swift
    /// let email = "test@example.com"
    /// let isValid = email.isValidEmail() // true
    /// ```
    func isValidEmail() -> Bool {
        let emailRegex = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }

    /// Checks if the string is a valid 10-digit phone number.
    ///
    /// - Returns: `true` if the string contains exactly 10 digits, `false` otherwise.
    ///
    /// ### Usage
    /// ```swift
    /// let phone = "9876543210"
    /// let isValid = phone.isValidPhoneNumber() // true
    /// ```
    func isValidPhoneNumber() -> Bool {
        let phoneRegex = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self)
    }

    /// Checks if the string represents a numeric value.
    ///
    /// - Returns: `true` if the string can be converted to a `Double`, `false` otherwise.
    ///
    /// ### Usage
    /// ```swift
    /// let value = "123.45"
    /// let isNumber = value.isNumeric() // true
    /// ```
    func isNumeric() -> Bool {
        return Double(self) != nil
    }
}
