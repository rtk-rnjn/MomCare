//
//  Array+Subscript.swift
//  MomCare
//
//  Created by Khushi Rana on 12/09/25.
//

extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
