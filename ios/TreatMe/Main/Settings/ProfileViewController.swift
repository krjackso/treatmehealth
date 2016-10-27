//
//  ProfileViewController.swift
//  TreatMe
//
//  Created by Keilan Jackson on 4/3/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import CameraViewController
import Kingfisher
import SwiftyDrop
import HockeySDK

class ProfileViewController: UIViewController {

    lazy var camera: CameraViewController = { [unowned self] in
        let completion: CameraViewCompletion = { (image, _) in
            self.cameraCompleted(image)
        }
        return CameraViewController(croppingEnabled: true, allowsLibraryAccess: true, completion: completion)
    }()

    let closeImage = UIImage(named: "close-x-icon")!

    lazy var closeButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(self.closeImage, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(self.closeButtonPress), forControlEvents: .TouchUpInside)

        return button
    }()

    lazy var uploadButton: UIButton = { [unowned self] in
        let button = UIButton(type: .System)
        button.setTitle("Upload Photo", forState: .Normal)
        button.setTitleColor(UIColor.TMBlue(), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        button.layer.cornerRadius = 5.0
        button.layer.borderColor = UIColor.TMBlue().CGColor
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(self.uploadButtonPress), forControlEvents: .TouchUpInside)
        return button
    }()

    lazy var profileImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView()

        imageView.tintColor = UIColor.whiteColor()
        imageView.backgroundColor = UserProfileImage.colorForUser(self.user)

        imageView.setImageForUser(self.user).error { _ -> Void in
            imageView.image = UserProfileImage.defaultImage()
        }

        imageView.layer.cornerRadius = 5.0
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 100)
        ])

        return imageView
    }()

    lazy var logoutButton: UIButton = { [unowned self] in
        let button = UIButton(type: .System)
        button.setTitle("Log Out", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor.TMRed()
        button.layer.cornerRadius = 5.0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

        button.addTarget(self, action: #selector(self.logoutButtonPress), forControlEvents: .TouchUpInside)

        return button
    }()

    lazy var usernameLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "@\(self.user.username)"
        label.font = UIFont.systemFontOfSize(17.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 15.0/17
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var realnameLabel: UILabel = { [unowned self] in
        let label = UILabel()
        if let first = self.user.firstName, last = self.user.lastName {
            label.text = "\(first) \(last)"
        } else {
            label.frame.size = CGSizeZero
        }
        label.font = UIFont.boldSystemFontOfSize(23)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 17.0/23
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var settingsButton: UIButton = { [unowned self] in
        let button = UIButton(type: .System)
        button.setTitle("Go to Settings", forState: .Normal)
        button.setTitleColor(UIColor.TMBlue(), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        button.layer.cornerRadius = 5.0
        button.layer.borderColor = UIColor.TMBlue().CGColor
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(self.settingsButtonPress), forControlEvents: .TouchUpInside)
        return button
    }()

    lazy var feedbackButton: UIButton = { [unowned self] in
        let button = UIButton(type: .System)
        button.setTitle("Feedback", forState: .Normal)
        button.setTitleColor(UIColor.TMBlue(), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        button.layer.cornerRadius = 5.0
        button.layer.borderColor = UIColor.TMBlue().CGColor
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(self.feedbackButtonPress), forControlEvents: .TouchUpInside)
        return button
    }()

    private let user: User

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.offWhite()

        [
            realnameLabel,
            usernameLabel,
            profileImageView,
            closeButton,
            uploadButton,
            settingsButton,
            feedbackButton,
            logoutButton
        ].forEach(self.view.addSubview)
    }

    override func updateViewConstraints() {
        self.view.layoutMargins = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0, right: 0.0)

        // Button widths
        [uploadButton, settingsButton, feedbackButton, logoutButton].forEach { button in
            self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 140))
        }

        // closeButton
        self.view.addConstraints([
            NSLayoutConstraint(item: closeButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: closeButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: self.view.layoutMargins.top)
        ])

        // realnameLabel
        self.view.addConstraints([
            NSLayoutConstraint(item: realnameLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: realnameLabel, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: self.view.layoutMargins.top + 40),
            NSLayoutConstraint(item: realnameLabel, attribute: .Left, relatedBy: .GreaterThanOrEqual, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: realnameLabel, attribute: .Right, relatedBy: .LessThanOrEqual, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: -10),
        ])

        // usernameLabel
        self.view.addConstraints([
            NSLayoutConstraint(item: usernameLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: usernameLabel, attribute: .Top, relatedBy: .Equal, toItem: self.realnameLabel, attribute: .Bottom, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: usernameLabel, attribute: .Left, relatedBy: .GreaterThanOrEqual, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: usernameLabel, attribute: .Right, relatedBy: .LessThanOrEqual, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: -10),
        ])

        // profileImageView
        self.view.addConstraints([
            NSLayoutConstraint(item: profileImageView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: profileImageView, attribute: .Top, relatedBy: .Equal, toItem: self.usernameLabel, attribute: .Bottom, multiplier: 1.0, constant: 10),
        ])

        // uploadButton
        self.view.addConstraints([
            NSLayoutConstraint(item: uploadButton, attribute: .Top, relatedBy: .Equal, toItem: profileImageView, attribute: .Bottom, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: uploadButton, attribute: .CenterX, relatedBy: .Equal, toItem: profileImageView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        ])

        // settingsButton
        self.view.addConstraints([
            NSLayoutConstraint(item: settingsButton, attribute: .Top, relatedBy: .Equal, toItem: uploadButton, attribute: .Bottom, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: settingsButton, attribute: .CenterX, relatedBy: .Equal, toItem: profileImageView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            ])

        // feedbackButton
        self.view.addConstraints([
            NSLayoutConstraint(item: feedbackButton, attribute: .Top, relatedBy: .Equal, toItem: settingsButton, attribute: .Bottom, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: feedbackButton, attribute: .CenterX, relatedBy: .Equal, toItem: profileImageView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            ])

        // logoutButton
        self.view.addConstraints([
            NSLayoutConstraint(item: logoutButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -20.0),
            NSLayoutConstraint(item: logoutButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0)
        ])

        super.updateViewConstraints()
    }

    func closeButtonPress() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func uploadButtonPress() {
        self.presentViewController(camera, animated: true, completion: nil)
    }

    func logoutButtonPress() {
        TreatMe.client.logout().always { _ in
            TreatMe.resetData()
            PusherClient.instance.stop()
            Auth.instance.clear()
            Flow.goToLogin(self)
        }
    }

    func settingsButtonPress() {
        UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
    }

    func feedbackButtonPress() {
        BITHockeyManager.sharedHockeyManager().feedbackManager.showFeedbackListView()
    }

    func cameraCompleted(image: UIImage?) {
        if let image = image {
            Drop.down("Uploading image...", state:.Blur(.Dark), duration: 30.0, action: nil)

            TreatMe.client.uploadProfilePicture(image).then { imageUrl -> Void in
                self.profileImageView.setImageWithUrlString(imageUrl)
                Drop.down("Successfully updated profile image!", state: TMState.Success)
                NSNotificationCenter.defaultCenter().postNotificationName(TreatMeNotifications.RefreshUserImage.rawValue, object: self)
            }.error { error in
                Drop.down("Failed to change profile image. Please try again!", state: TMState.Error)
            }

        }
        self.camera.dismissViewControllerAnimated(true, completion: nil)
        self.updateViewConstraints()
    }

}