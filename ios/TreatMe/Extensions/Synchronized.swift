//
//  Synchronized.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/13/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation

func synchronized<T>(_ lock: AnyObject, closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer {
        objc_sync_exit(lock)
    }
    return try closure()
}
