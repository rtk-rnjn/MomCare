import Foundation

extension Calendar {
    var orderedShortWeekdaySymbols: [String] {
        let symbols = shortWeekdaySymbols

        let startIndex = firstWeekday - 1
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }
}
