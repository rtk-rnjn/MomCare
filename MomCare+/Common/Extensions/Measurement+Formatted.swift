//
//  Measurement+Formatted.swift
//  MomCare
//
//  Created by Aryan singh on 19/02/26.
//

import Foundation

extension Measurement where UnitType: Dimension {
    var formattedNoDecimal: String {
        formatted(
            .measurement(
                width: .abbreviated,
                usage: .asProvided,
                numberFormatStyle: .number.precision(.fractionLength(0))
            )
        )
    }

    var formattedOneDecimal: String {
        formatted(
            .measurement(
                width: .abbreviated,
                usage: .asProvided,
                numberFormatStyle: .number.precision(.fractionLength(1))
            )
        )
    }
}
