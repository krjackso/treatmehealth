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
    case error
    case warn
    case success
    case info
    case busy

    var backgroundColor: UIColor? {
        switch self {
        case .error: return .TMRed()
        case .warn: return .TMOrange()
        case .success: return .TMGreen()
        case .info: return .TMBlue()
        case .busy: return nil
        }
    }
    var font: UIFont? {
        switch self {
        default: return UIFont.systemFont(ofSize: 17.0)
        }
    }
    var textColor: UIColor? {
        switch self {
        default: return UIColor.white
        }
    }
    var blurEffect: UIBlurEffect? {
        switch self {
        case .busy: return UIBlurEffect(style: .dark)
        default: return nil
        }
    }
}
