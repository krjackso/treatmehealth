//
//  ChatMessage.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/4/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import ActiveLabel

class MessageCell: UICollectionViewCell {

    static let identifier = "MessageCell"
    static let minHeight: CGFloat = 40.0
    static let nonTextHeight: CGFloat = 30.0
    static let horizontalPad: CGFloat = 65.0

    static let messageTextFont: UIFont = UIFont.systemFont(ofSize: 13.0)
    let usernameTextFont = UIFont.boldSystemFont(ofSize: 13.0)
    let timestampFont = UIFont.italicSystemFont(ofSize: 12.0)

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: ActiveLabel!

    fileprivate var user: User?

    override func awakeFromNib() {
        super.awakeFromNib()

        usernameLabel.font = usernameTextFont

        timestampLabel.font = timestampFont

        messageLabel.customize { label in
            label.numberOfLines = 0
            label.font = MessageCell.messageTextFont
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .left
            label.hashtagColor = UIColor.TMBlue()
            label.mentionColor = UIColor.TMBlue()
            label.URLColor = UIColor.TMBlue()
        }

        imageView.layer.cornerRadius = 5.0
        imageView.tintColor = UIColor.white

        self.backgroundColor = UIColor.white

        NotificationCenter.default.addObserver(self, selector: #selector(updateUserImage), name: NSNotification.Name(rawValue: TreatMeNotifications.RefreshUserImage.rawValue), object: nil)
    }

    fileprivate func setDefaultPictureForUser(_ user: User) {
        self.imageView.backgroundColor = UserProfileImage.colorForUser(user)
        self.imageView.image = UserProfileImage.defaultImage()
    }

    func updateUserImage() {
        if let user = self.user {
            self.imageView.setImageForUser(user).catch { _ -> Void in
                self.setDefaultPictureForUser(user)
            }
        }
    }

    func setUser(_ user: User) {
        if user != self.user {
            self.user = user
            self.usernameLabel.text = user.username
            self.updateUserImage()
            self.setNeedsLayout()
        }
    }

}
