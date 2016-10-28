//
//  Array.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/30/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation

extension Array {

    func indexBy<T: Hashable>(_ transform: ((Element) -> T)) -> [T: Element] {
        return self.reduce([T: Element]()) { (sofar, el) in
            var result = sofar
            let idx = transform(el)
            result[idx] = el
            return result
        }
    }

}
