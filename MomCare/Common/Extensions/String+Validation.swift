//

//  String+Validation.swift

//  MomCare

//

//  Created by RITIK RANJAN on 17/06/25.

//

import Foundation

extension String {

    func isValidEmail() -> Bool {

        let emailRegex = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"

        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)

    }

    func isValidPhoneNumber() -> Bool {

        let phoneRegex = "^[0-9]{10}$"

        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self)

    }

    func isNumeric() -> Bool {

        return Double(self) != nil

    }

}
