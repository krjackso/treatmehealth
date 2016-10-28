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
        unread.textAlignment = .center
        unread.font = UIFont.systemFont(ofSize: 14.0)

        return unread
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [
            channelLabel,
            onlineIndicator,
            unreadLabel
        ].forEach(self.addSubview)

        self.selectionStyle = .none

        self.updateConstraints()
    }

    override func updateConstraints() {
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 10))

        self.addConstraint(NSLayoutConstraint(item: channelLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: channelLabel, attribute: .left, relatedBy: .equal, toItem: onlineIndicator, attribute: .right, multiplier: 1.0, constant: 5))

        self.addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1.0, constant: 18))
        self.addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .width, multiplier: 1.0, constant: 22))
        self.addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 18))
        self.addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -10))

        super.updateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActive(_ active: Bool) {
        if active {
            self.backgroundColor = UIColor.TMOrange()
            self.channelLabel.textColor = UIColor.TMLightGray()
            self.onlineIndicator.backgroundColor = UIColor.TMLightGray()
        } else {
            self.backgroundColor = UIColor.black
            self.channelLabel.textColor = UIColor.TMLightGray()
            self.onlineIndicator.backgroundColor = UIColor.TMOrange()
        }
    }

    func setOnline(_ online: Bool) {
        if online {
            self.onlineIndicator.isHidden = false
        } else {
            self.onlineIndicator.isHidden = true
        }
    }

    func setUnread(_ unread: Int) {
        if unread == 0 {
            self.unreadLabel.isHidden = true
        } else if unread < 10 {
            self.unreadLabel.isHidden = false
            self.unreadLabel.text = "\(unread)"
        } else {
            self.unreadLabel.isHidden = false
            self.unreadLabel.text = "9+"
        }
        self.unreadLabel.sizeToFit()
    }
}
