//
//  String.swift
//  TreatMe
//
//  Created by Keilan Jackson on 2/28/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation

let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
let usernameRegex = "^[a-zA-Z0-9]{4,}$"
let passRegex = "^.{6,}$"


extension String {
    func isEmail() -> Bool {
        return !self.isEmpty && self.range(of: emailRegex, options: .regularExpression) != nil
    }

    func isUsername() -> Bool {
        return !self.isEmpty && self.range(of: usernameRegex, options: .regularExpression) != nil
    }

    func isPassword() -> Bool {
        return !self.isEmpty && self.range(of: passRegex, options: .regularExpression) != nil
    }
}
