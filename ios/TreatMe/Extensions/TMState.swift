//
//  TMDropState.swift
//  TreatMe
//
//  Created by Keilan Jackson on 4/9/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation
import SwiftyDrop

enum TMState: DropStatable {
    case Error
    case Warn
    case Success
    case Info
    case Busy

    var backgroundColor: UIColor? {
        switch self {
        case .Error: return .TMRed()
        case .Warn: return .TMOrange()
        case .Success: return .TMGreen()
        case .Info: return .TMBlue()
        case .Busy: return nil
        }
    }
    var font: UIFont? {
        switch self {
        default: return UIFont.systemFontOfSize(17.0)
        }
    }
    var textColor: UIColor? {
        switch self {
        default: return .whiteColor()
        }
    }
    var blurEffect: UIBlurEffect? {
        switch self {
        case .Busy: return UIBlurEffect(style: .Dark)
        default: return nil
        }
    }
}