//
//  ChannelTableCell.swift
//  TreatMe
//
//  Created by Keilan Jackson on 4/23/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit

class ChannelTableCell: UITableViewCell {

    static let Identifier = "UserChannelCell"

    lazy var channelLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.TMLightGray()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var onlineIndicator: UIView = {
        let indicator = UIView()
        indicator.layer.cornerRadius = 5
        indicator.backgroundColor = UIColor.TMOrange()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    lazy var unreadLabel: UIPaddedLabel = {
        let padding = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let unread = UIPaddedLabel(insets: padding)
        unread.textColor = UIColor.TMLightGray()
        unread.backgroundColor = UIColor.TMRed()
        unread.translatesAutoresizingMaskIntoConstraints = false
        unread.clipsToBounds = true
        unread.layer.cornerRadius = 7
        unread.textAlignment = .Center
        unread.font = UIFont.systemFontOfSize(14.0)

        return unread
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [
            channelLabel,
            onlineIndicator,
            unreadLabel
        ].forEach(self.addSubview)

        self.selectionStyle = .None

        self.updateConstraints()
    }

    override func updateConstraints() {
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 10))

        self.addConstraint(NSLayoutConstraint(item: channelLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: channelLabel, attribute: .Left, relatedBy: .Equal, toItem: onlineIndicator, attribute: .Right, multiplier: 1.0, constant: 5))

        self.addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 18))
        self.addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 22))
        self.addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 18))
        self.addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -10))

        super.updateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActive(active: Bool) {
        if active {
            self.backgroundColor = UIColor.TMOrange()
            self.channelLabel.textColor = UIColor.TMLightGray()
            self.onlineIndicator.backgroundColor = UIColor.TMLightGray()
        } else {
            self.backgroundColor = UIColor.blackColor()
            self.channelLabel.textColor = UIColor.TMLightGray()
            self.onlineIndicator.backgroundColor = UIColor.TMOrange()
        }
    }

    func setOnline(online: Bool) {
        if online {
            self.onlineIndicator.hidden = false
        } else {
            self.onlineIndicator.hidden = true
        }
    }

    func setUnread(unread: Int) {
        if unread == 0 {
            self.unreadLabel.hidden = true
        } else if unread < 10 {
            self.unreadLabel.hidden = false
            self.unreadLabel.text = "\(unread)"
        } else {
            self.unreadLabel.hidden = false
            self.unreadLabel.text = "9+"
        }
        self.unreadLabel.sizeToFit()
    }
}
