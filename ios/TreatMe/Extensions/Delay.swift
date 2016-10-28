//
//  Delay.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/31/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation

func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: closure
    )
}
