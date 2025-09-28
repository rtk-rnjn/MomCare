//
//  Array+Subscript.swift
//  MomCare
//
//  Created by Khushi Rana on 12/09/25.
//

extension Array {
    /// Safely accesses an element at the given index.
    ///
    /// - Parameter index: The index of the element you want to access.
    /// - Returns: The element at the given index if it exists, otherwise `nil`.
    ///
    /// ### Usage
    /// ```swift
    /// let numbers = [10, 20, 30]
    ///
    /// let first = numbers[safe: 0]   // 10
    /// let outOfBounds = numbers[safe: 5]   // nil
    ///
    /// if let value = numbers[safe: 1] {
    ///     print("Value at index 1 is \(value)") // Prints: Value at index 1 is 20
    /// }
    /// ```
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
