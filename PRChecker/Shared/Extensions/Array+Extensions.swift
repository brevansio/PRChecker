//
//  Array+Extensions.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/07.
//

import Foundation

extension Array where Element: Equatable {
    func arrayByRemovingDuplicates() -> [Element] {
        var resultArray = [Element]()
        self.forEach { element in
            guard !resultArray.contains(element) else { return }
            resultArray.append(element)
        }
        return resultArray
    }
}
