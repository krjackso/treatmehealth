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
        label.textColor = UIColor.black
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
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: onlineIndicator, attribute: .right, relatedBy: .equal, toItem: channelLabel, attribute: .left, multiplier: 1.0, constant: -5))

        self.addConstraint(NSLayoutConstraint(item: channelLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: channelLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))

        super.updateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOnline(_ online: Bool) {
        if online {
            self.onlineIndicator.isHidden = false
        } else {
            self.onlineIndicator.isHidden = true
        }
    }
}
