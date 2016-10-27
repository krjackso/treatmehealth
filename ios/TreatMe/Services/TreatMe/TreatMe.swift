//
//  TreatMe.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/8/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation

class TreatMe {
    static let client = TreatMeClient()
    private(set) static var data = TreatMeData()

    static func resetData() {
        TreatMe.data = TreatMeData()
    }
}