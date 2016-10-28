//
//  User+ProfileImage.swift
//  TreatMe
//
//  Created by Keilan Jackson on 4/3/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit

struct UserProfileImage {
    static var defaultColors: [UIColor] = [
        UIColor.TMRed(),
        UIColor.TMBlue(),
        UIColor.TMGreen(),
        UIColor.TMOrange(),
        UIColor.TMPurple()
    ]

    static var userColors: [User: UIColor] = [:]

    static func defaultImage() -> UIImage {
        let image = UIImage(named: "smiley-icon")!
        return image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }

    static func colorForUser(_ user: User) -> UIColor {
        if userColors[user] == nil {
            let idHash: Int = user.id.unicodeScalars.reduce(0) { (sofar, v) in
                return sofar + Int(v.value)
            }
            let idx = idHash % UserProfileImage.defaultColors.count
            userColors[user] = UserProfileImage.defaultColors[idx]
        }
        return userColors[user]!
    }
}

