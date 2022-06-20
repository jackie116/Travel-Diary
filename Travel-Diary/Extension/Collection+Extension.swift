//
//  Collection+Extension.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/19.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
