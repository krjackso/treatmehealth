//
//  Dictionary.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/12/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation

extension Dictionary {

    // Merges a dictionary into this one, taking the values from the other dictionary when keys are the same
    func merge(_ dict: Dictionary) -> Dictionary {
        var result = self
        dict.forEach { (key, value) in
            result[key] = value
        }
        return result
    }

}
