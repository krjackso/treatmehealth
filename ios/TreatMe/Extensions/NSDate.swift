//
//  NSDate.swift
//  TreatMe
//
//  Created by Keilan Jackson on 2/27/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation

extension Date {
    fileprivate func dateComponents() -> DateComponents {
        let calendar = Calendar.current
        return (calendar as NSCalendar).components([.second, .minute, .hour, .day, .month, .year], from: self, to: Date(), options: [])
    }

    func relativeDay() -> String {
        let calendar = Calendar.current

        let timezoneOffset = NSTimeZone.local.secondsFromGMT()

        let today = (calendar as NSCalendar).date(byAdding: .second, value: timezoneOffset, to: Date(), options: .matchNextTime)
        let yesterday = (calendar as NSCalendar).date(byAdding: .day, value: -1, to: today!, options: .matchNextTime)
        let offsetTime = (calendar as NSCalendar).date(byAdding: .second, value: timezoneOffset, to: self, options: .matchNextTime)

        if yesterday!.dateComponents().day == offsetTime!.dateComponents().day {
            return "yesterday"
        } else if today!.dateComponents().day == offsetTime!.dateComponents().day {
            return ""
        } else {
            return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .none)
        }
    }

    func asFriendlyTime() -> String {
        let timePart = DateFormatter.localizedString(from: self, dateStyle: DateFormatter.Style.none, timeStyle: .short)
        let dayPart = self.relativeDay()

        return "\(timePart) \(dayPart)"
    }
}
