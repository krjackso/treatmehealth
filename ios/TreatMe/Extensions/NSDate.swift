//
//  NSDate.swift
//  TreatMe
//
//  Created by Keilan Jackson on 2/27/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation
import Decodable

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }

extension NSDate: Decodable {
    public class func decode(json: AnyObject) throws -> Self {
        let seconds = try NSTimeInterval.decode(json)
        return self.init(timeIntervalSince1970: seconds)
    }
}

extension NSDate {
    private func dateComponents() -> NSDateComponents {
        let calendar = NSCalendar.currentCalendar()
        return calendar.components([.Second, .Minute, .Hour, .Day, .Month, .Year], fromDate: self, toDate: NSDate(), options: [])
    }

    func relativeDay() -> String {
        let calendar = NSCalendar.currentCalendar()

        let timezoneOffset = NSTimeZone.localTimeZone().secondsFromGMT

        let today = calendar.dateByAddingUnit(.Second, value: timezoneOffset, toDate: NSDate(), options: .MatchNextTime)
        let yesterday = calendar.dateByAddingUnit(.Day, value: -1, toDate: today!, options: .MatchNextTime)
        let offsetTime = calendar.dateByAddingUnit(.Second, value: timezoneOffset, toDate: self, options: .MatchNextTime)

        if yesterday!.dateComponents().day == offsetTime!.dateComponents().day {
            return "yesterday"
        } else if today!.dateComponents().day == offsetTime!.dateComponents().day {
            return ""
        } else {
            return NSDateFormatter.localizedStringFromDate(self, dateStyle: .ShortStyle, timeStyle: .NoStyle)
        }
    }

    func asFriendlyTime() -> String {
        let timePart = NSDateFormatter.localizedStringFromDate(self, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: .ShortStyle)
        let dayPart = self.relativeDay()

        return "\(timePart) \(dayPart)"
    }
}