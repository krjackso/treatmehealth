//
//  ChatTitleView.swift
//  TreatMe
//
//  Created by Keilan Jackson on 4/24/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit

class ChatTitleView: UIView {

    lazy var channelLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blackColor()
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

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

        [
            channelLabel,
            onlineIndicator
        ].forEach(self.addSubview)

        self.updateConstraints()
    }

    override func updateConstraints() {
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .Right, relatedBy: .Equal, toItem: channelLabel, attribute: .Left, multiplier: 1.0, constant: -5))

        self.addConstraint(NSLayoutConstraint(item: channelLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: channelLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))

        super.updateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOnline(online: Bool) {
        if online {
            self.onlineIndicator.hidden = false
        } else {
            self.onlineIndicator.hidden = true
        }
    }
}
